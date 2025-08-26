# For use as fusescoc pre_buld hook to "deactivete" the standard Vivado flow.
# This should better be done as a bash script.
## diff --git a/hw/ip/otbn/otbn.core b/hw/ip/otbn/otbn.core
## index 8683006db3..75cc02234a 100644
## --- a/hw/ip/otbn/otbn.core
## +++ b/hw/ip/otbn/otbn.core
## @@ -94,6 +94,8 @@ filesets:
##  
##    files_sta:
##      files:
## +      - ../../../vivado_timing_scripts/set_impl_hooks.tcl:
## +          copyto: set_impl_hooks.tcl
##        - ../../../vivado_timing_scripts/timing.tcl:
##            copyto: timing.tcl
##        - ../../../vivado_timing_scripts/gen_sv.tcl:
## @@ -133,6 +135,12 @@ parameters:
##      datatype: bool
##      paramtype: vlogdefine
##  
## +scripts:
## +  do_sta:
## +    cmd: 
## +      - "vivado -mode batch -source"
## +      - set_impl_hooks.tcl
## +
##  targets:
##    default: &default_target
##      filesets:
## @@ -183,10 +191,19 @@ targets:
##        - files_rtl_top
##        - files_sta
##        - files_sv_sta
##      toplevel: otbn
##      tools:
##        vivado:
##          part: "xc7a200tfbg676-3"
## +    hooks:
## +      pre_build:
## +        - do_sta



file copy -force timing.tcl lowrisc_ip_otbn_0.1_synth.tcl

# set outFile [open "lowrisc_ip_otbn_0.1_synth.tcl" "w"]
# puts $outFile "# deleted"
# close $outFile

set outFile [open "lowrisc_ip_otbn_0.1_netlist.tcl" "w"]
puts $outFile "# deleted"
close $outFile

set outFile [open "lowrisc_ip_otbn_0.1_run.tcl" "w"]
puts $outFile "# deleted"
close $outFile

set outFile [open "lowrisc_ip_otbn_0.1_pgm.tcl" "w"]
puts $outFile "# deleted"
close $outFile

