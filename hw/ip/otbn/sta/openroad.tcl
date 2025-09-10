source $::env(SCRIPTS_DIR)/open.tcl

fconfigure stdout -buffering line
fconfigure stderr -buffering none

# Open output file
set f [open $::env(OUTPUT) w]

# Helper procedure to write to both file and console
proc write_both {file_handle message} {
    puts $file_handle $message
    puts $message
}


proc set_timing_paths {clk clk_period} {
  if {[llength [get_ports -quiet $clk]] > 0} {
    # Create clock to attach it to a clock buffer.
    create_clock -name $clk -period $clk_period [get_ports $clk]
    
    # ---- in2reg: inputs -> regs captured by clk
    set_max_delay $clk_period -from [get_ports [all_inputs]] -to [get_clocks $clk]
    
    # ---- reg2out: regs launched by clk -> output ports
    set_max_delay $clk_period -from [get_clocks $clk] -to [get_ports [all_outputs]]
  }
  
  # ---- in2out: pure combinational ports -> ports
  set_max_delay $clk_period -from [get_ports [all_inputs]] -to [get_ports [all_outputs]]
  # -datapath_only
}

proc place_and_route {} {
  repair_timing -setup
  repair_timing -hold
}

proc get_slack {} {
  set paths [find_timing_paths -path_delay max ]
  set path [lindex $paths 0]

  set slack [get_property $path slack]

  return $slack
}

#source rounding.tcl
#source timing.tcl

if { [info exists ::env(PROCESS)] && $::env(PROCESS) eq "7" } {
    # do something for asap7
    puts "PROCESS is asap7 $::env(PROCESS)"
    set start_f 200.0
    set scale_factor 1000000.0
    set unit "ps"
} else {
    # do something else
    puts "PROCESS is not asap7 $::env(PROCESS)"
    set start_f 20.0
    set scale_factor 1000.0
    set unit "ns"
}


# Set clock port name
set clk "clk_i"

# Get maxium frequency using binary search
set max_f [timing::get_max_freq $clk $start_f $scale_factor]

set_timing_paths $clk [ expr {$scale_factor/$max_f} ]

repair_timing -setup
repair_timing -hold


report_units

report_tns -max
report_wns -max

set max_period [ expr {$scale_factor/$max_f} ]

write_both $f "name: $::env(DESIGN_NAME)"
write_both $f "Fmax: $max_f MHz ($max_period $unit)"



set paths [find_timing_paths -path_delay max ]
set path [lindex $paths 0]

set slack [get_property $path slack]
write_both $f "slack: $slack"

set points [get_property $path points]
set end_point        [lindex $points end]
set required [get_property $end_point required]

write_both $f "required: $required"


set instance_count [llength [get_cells *]]
write_both $f "instances: $instance_count"

set design_area [sta::format_area [rsz::design_area] 0]
write_both $f "design_area: $design_area"

set util [format %.0f [expr [rsz::utilization] * 100]]
write_both $f "utilization: $util"

close $f
puts "Results written to: $::env(OUTPUT)"

