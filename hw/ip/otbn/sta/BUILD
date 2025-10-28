package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "sv2v_wrapper",
    srcs = ["sv2v_wrapper.sh"],
)

filegroup(
    name = "constraints_asap7",
    srcs = ["constraints_asap7.sdc"],
)

filegroup(
    name = "constraints_noclk_asap7",
    srcs = ["constraints_noclk_asap7.sdc"],
)

filegroup(
    name = "constraints_sky130hd",
    srcs = ["constraints_sky130hd.sdc"],
)

filegroup(
    name = "constraints_noclk_sky130hd",
    srcs = ["constraints_noclk_sky130hd.sdc"],
)

genrule(
    name = "openroad_combined_tcl",
    srcs = [
        ":openroad.tcl",
        ":rounding.tcl",
        ":timing.tcl"
    ],
    outs = ["openroad_combined.tcl"],
    cmd  = "cat $(location rounding.tcl) $(location timing.tcl) $(location openroad.tcl) > $@",
    visibility = ["//visibility:public"],
)
