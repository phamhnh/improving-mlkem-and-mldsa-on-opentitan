#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from textwrap import indent

PP_START = ("`ifdef", "`ifndef", "`elsif", "`else", "`endif")

PORT_RE = re.compile(
    r"""^\s*
        (?P<dir>input|output|inout)\s+
        (?P<type>.*?)
        (?=\s+[A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*\s*$)   # look-ahead to the names
        (?P<names>[\w\s,]+?)                  # one or more names, comma-separated
        \s*$""",
    re.IGNORECASE | re.VERBOSE,
)

MODULE_HDR_RE = re.compile(
    r"""module\s+
        (?P<name>\w+)\s*
        (?:\#\s*\((?P<params>.*?)\)\s*)?      # non-greedy params
        (?P<imports>(?:import\b.*?;\s*)*)?    # zero or more 'import ...;' clauses
        \(\s*(?P<ports>.*?)\s*\)\s*;          # non-greedy ports
    """,
    re.DOTALL | re.VERBOSE,
)

def strip_line_comment(s: str) -> str:
    # remove // comments, but leave backticks etc.
    return re.sub(r"//.*", "", s)

def is_pp(line: str) -> bool:
    ls = line.lstrip()
    return any(ls.startswith(k) for k in PP_START)

def split_port_block(port_block: str):
    """
    Tokenize the ANSI port list into a sequence of:
      - {"kind": "pp", "text": "<original preproc line>\n"}
      - {"kind": "port", "dir":..., "kind_kw":..., "sign":..., "packed":..., "name":..., "raw":...}
    We preserve the order and interleaving with preproc directives.
    """
    tokens = []
    buf = ""
    bracket_depth = 0

    lines = port_block.splitlines()
    # We'll join non-PP lines into logical declarations separated by top-level commas.
    def flush_buf():
        nonlocal buf
        s = strip_line_comment(buf).strip()
        if not s:
            buf = ""
            return
        # A single declaration can still hold multiple names separated by commas.
        m = PORT_RE.match(s.rstrip(","))
        if not m:
            raise ValueError(f"Couldn't parse port declaration:\n>>> {s}")
        dir_ = m.group("dir")
        names = [n.strip() for n in m.group("names").split(",") if n.strip()]
        for name in names:
            tokens.append({
                "kind": "port",
                "dir": dir_.lower(),
                "type": m.group("type"),
                "name": name,
                "raw": s,
            })
        buf = ""

    for line in lines:
        line = strip_line_comment(line)
        if is_pp(line):
            # flush any buffered declaration before emitting the directive
            flush_buf()
            tokens.append({"kind": "pp", "text": line.rstrip()})
            continue
        # accumulate declaration text
        # track bracket depth to avoid splitting inside [ ... , ... ]
        for ch in line:
            if ch == "[":
                bracket_depth += 1
            elif ch == "]" and bracket_depth > 0:
                bracket_depth -= 1
            if ch == "," and bracket_depth == 0:
                buf += ch
                flush_buf()
                # continue building next decl (could be more on the same line)
                continue
            buf += ch
        # if the line didn't end with a comma, keep accumulating
    flush_buf()
    return tokens

def group_by_pp(tokens):
    """
    Convert the flat token stream into a list where preproc context is explicit:
      Each element is either:
        - {"pp": "<directive line>"}  (for `ifdef/else/endif`)
        - {"port": <port_dict>}
    This makes it easy to replay the same directives in every section.
    """
    items = []
    for t in tokens:
        if t["kind"] == "pp":
            items.append({"pp": t["text"]})
        else:
            items.append({"port": t})
    return items

def emit_port_header(items, clk):
    """Reconstruct the port list (direction/type/name), preserving PP lines."""
    out = []
    for it in items:
        if "pp" in it:
            out.append(it["pp"])
        else:
            p = it["port"]
            if p['name'] != clk:
                line = f"{p['dir']} {p['type']}"
                line += f" {p['name']},"
                out.append(line)
    # Remove trailing comma on the last real port (leave PP lines intact)
    for i in range(len(out) - 1, -1, -1):
        if any(out[i].lstrip().startswith(k) for k in PP_START):
            continue
        out[i] = out[i].rstrip().rstrip(",")
        break
    return "\n".join(out)

def emit_section_with_pp(items, gen_line_for_port):
    """
    Re-emit PP lines and, for ports, call gen_line_for_port(p) -> str|None.
    """
    out = []
    for it in items:
        if "pp" in it:
            out.append(it["pp"])
        else:
            s = gen_line_for_port(it["port"])
            if s:
                out.append(s)
    return "\n".join(out)

def wrapper(input_file, target, wrapper, output_path, clk="clk_i"):
#    if len(sys.argv) < 3:
#        print("Usage: sv_wrap.py <input.sv> <module_name> [<wrapper_name>]")
#        sys.exit(1)
#
#    sv_path = Path(sys.argv[1])
#    target = sys.argv[2]
#    wrapper = sys.argv[3] if len(sys.argv) >= 4 else f"{target}_regwrap"

    sv_path = Path(input_file)

    text = sv_path.read_text()

    m = MODULE_HDR_RE.search(text)
    if not m:
        sys.exit("Error: couldn't find an ANSI-style module header.")

    modname = m.group("name")
    if modname != target:
        # keep searching in case multiple modules exist
        for mm in MODULE_HDR_RE.finditer(text):
            if mm.group("name") == target:
                m = mm
                break
        else:
            sys.exit(f"Error: module '{target}' not found.")

    params_txt = m.group("params") or ""
    imports_txt = "\n " + m.group("imports") or ""
    ports_txt  = m.group("ports") or ""

    tokens = split_port_block(ports_txt)
    items  = group_by_pp(tokens)

    # ---- Build wrapper header (clk, rst_n + original ports) ----
    header_ports = []
    header_ports.append(f"input  logic {clk},")
#    header_ports.append("input  logic rst_n,")
    header_ports.append(emit_port_header(items, clk))
    
    header_ports_str = "\n".join(header_ports)

#    if clk not in header_ports_str:
#      header_ports_str = f"  input  logic {clk},\n" + header_ports_str

    # ---- Input registers ----
    def decl_input_q(p):
        if p["name"] == clk:
            return None
        if p["dir"] != "input":
            return None
        return f"{p['type']} {p['name']}_q;"

    input_decls = emit_section_with_pp(items, decl_input_q)

    # input flop body (assignments) – only for inputs
    #input_reset = emit_section_with_pp(items, lambda p: f"{p['name']}_q <= '0;" if p["dir"] == "input" else None)
    input_load  = emit_section_with_pp(items, lambda p: f"{p['name']}_q <= {p['name']};" if p["dir"] == "input" and p["name"] != clk else None)

    # ---- DUT output pre-reg wires ----
    def decl_output_dut(p):
        if p["dir"] != "output":
            return None
        return f"{p['type']} {p['name']}_dut;"

    dut_out_decls = emit_section_with_pp(items, decl_output_dut)

    # ---- DUT instance connections ----
    def inst_conn(p):
        sig = clk if p["name"] == clk else f"{p['name']}_q" if p["dir"] == "input" else (f"{p['name']}_dut" if p["dir"] == "output" else p["name"])
        return f".{p['name']}({sig}),"

    inst_ports = []
    inst_ports.append(emit_section_with_pp(items, inst_conn))
    # remove trailing comma
    inst_ports_str = "\n".join(inst_ports)
    inst_lines = inst_ports_str.splitlines()
    for i in range(len(inst_lines) - 1, -1, -1):
        if any(inst_lines[i].lstrip().startswith(k) for k in PP_START):
            continue
        inst_lines[i] = inst_lines[i].rstrip().rstrip(",")
        break
    inst_ports_str = "\n".join(inst_lines)

    # ---- Output flop section ----
    #out_reset = emit_section_with_pp(items, lambda p: f"{p['name']} <= '0;" if p["dir"] == "output" else None)
    out_load  = emit_section_with_pp(items, lambda p: f"{p['name']} <= {p['name']}_dut;" if p["dir"] == "output" else None)

    # ---- Reconstruct parameter list (verbatim) ----
    params_section = ""
    if params_txt.strip():
        # keep original text, but normalize indentation
        params_lines = [ln.rstrip() for ln in params_txt.splitlines()]
        # add parameter int ... commas as-is
        params_section = "#(\n" + "\n".join(params_lines) + "\n)"

    sv = []
    sv.append(f"// Auto-generated wrapper around: {target}")
    sv.append(f"module {wrapper} {params_section} {imports_txt} (")
    sv.append(indent(header_ports_str, "  "))
    sv.append(");\n")

    # Input registers
    sv.append("  // ===============================")
    sv.append("  // Input registers")
    sv.append("  // ===============================")
    if input_decls.strip():
        sv.append(indent(input_decls, "  "))
    sv.append("")
    sv.append(f"  always_ff @(posedge {clk}) begin")
    #sv.append("  always_ff @(posedge clk or negedge rst_n) begin")
    #sv.append("    if (!rst_n) begin")
    #if input_reset.strip():
    #    sv.append(indent(input_reset, "      "))
    #sv.append("    end else begin")
    if input_load.strip():
        sv.append(indent(input_load, "    "))
    #sv.append("    end")
    sv.append("  end\n")

    # DUT output pre-reg wires
    sv.append("  // ===============================")
    sv.append("  // DUT instance and pre-registered outputs")
    sv.append("  // ===============================")
    if dut_out_decls.strip():
        sv.append(indent(dut_out_decls, "  "))
        sv.append("")

    # DUT instance
    sv.append(f"  {target} u_dut (")
    sv.append(indent(inst_ports_str, "    "))
    sv.append("  );\n")

    # Output registers
    sv.append("  // ===============================")
    sv.append("  // Output registers")
    sv.append("  // ===============================")
    sv.append(f"  always_ff @(posedge {clk}) begin")
    #sv.append("  always_ff @(posedge clk or negedge rst_n) begin")
    #sv.append("    if (!rst_n) begin")
    #if out_reset.strip():
    #    sv.append(indent(out_reset, "      "))
    #sv.append("    end else begin")
    if out_load.strip():
        sv.append(indent(out_load, "    "))
    #sv.append("    end")
    sv.append("  end\n")

    sv.append("endmodule\n")

#    sys.stdout.write("\n".join(sv))

    wrapper_code = "\n".join(sv)

    if output_path is None:
        print(wrapper_code)
    else:
        with open(output_path, 'w') as f:
            f.write(wrapper_code)
        print(f"Wrapper written to {output_path}")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Generate SV wrapper with registered I/Os")
    parser.add_argument("input_file", help="Path to SystemVerilog module file")
    parser.add_argument("module", help="Name of the SystemVerilog module")
    parser.add_argument("--output_file", help="Optional output file path")
    parser.add_argument("--clk", default="clk_i", help="Clock signal name (default: clk_i)")
    args = parser.parse_args()

    wrapper(args.input_file, args.module, "wrapper", args.output_file, args.clk)

