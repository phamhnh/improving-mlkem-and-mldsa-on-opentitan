proc find_module_file {modname} {
    foreach f [get_files -all] {
        set fh [open $f r]
        set content [read $fh]
        close $fh
        if {[regexp "module\\s+${modname}(\\s|#|\\()" $content]} {
            return $f
        }
    }
    return ""
}

set modfile [find_module_file $top_module]

if {$modfile ne ""} {
    puts "Module $top_module defined in $modfile."
} else {
    puts "Module $top_module not found!"
    exit -1
}


# Pick a Python interpreter
set py [auto_execok python3]
if {$py eq ""} { set py [auto_execok python] }
if {$py eq ""} { set py [auto_execok py] }

# Inputs/outputs (these paths are in the Vivado run dir)
set out_sv    [file normalize "wrapper.sv"]

# Ensure output directory exists
file mkdir [file dirname $out_sv]

# Run the generator
set cmd [list $py sv_wrap.py $modfile $top_module --output_file $out_sv]
puts "Running: $cmd"
if {[catch {exec {*}$cmd} result]} {
  puts "Generator failed:\n$result"
  return -code error $result
}
puts "Generator stdout/stderr:\n$result"

# Add the generated SV to the project and mark as SystemVerilog
# (use read_verilog -sv for non-project mode; add_files for project mode)
if {[string equal [current_project -quiet] ""]} {
  # Non-project flow
  read_verilog -sv $out_sv
} else {
  # Project flow
  add_files -norecurse $out_sv
  set_property FILE_TYPE {SystemVerilog} [get_files $out_sv]
  update_compile_order -fileset sources_1
}

# If it contains packages that others import, do this before elaborate/synth.

