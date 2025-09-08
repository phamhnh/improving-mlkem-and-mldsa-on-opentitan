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

if { [info exists ::env(PROCESS)] && $::env(PROCESS) eq "7" } {
    # do something for asap7
    puts "PROCESS is asap7 $::env(PROCESS)"
    set start_f 200.0
    set scale_factor 1000000.0
    flush $f
} else {
    # do something else
    puts "PROCESS is not asap7 $::env(PROCESS)"
    set start_f 20.0
    set scale_factor 1000.0
    flush $f
}


# Set clock port name
set clk "clk_i"

set_timing_paths $clk [expr {$scale_factor/$start_f}]


# Define search range
#set fast_f 10000
#set fast_f [expr {($start_f - $slow_f) * 2 + $slow_f}]

set slow_f -1
set fast_f -1

set best_f $slow_f
set max_freq $best_f

set mid_f $start_f

# Binary search for max frequency
while {1} {

    set mid_f [expr {((int($mid_f) + 4) / 5) * 5}]

    puts "\n\n***********************************************"
    puts "***********************************************"
    puts "Slow frequency: $slow_f MHz (period: [expr {$scale_factor/$slow_f}] ns)"
    puts "Fast frequency: $fast_f MHz (period: [expr {$scale_factor/$fast_f}] ns)"
    puts "Testing clock period: $mid_f MHz (Frequency: [expr {$scale_factor/$mid_f}] ns)"
    puts "***********************************************"
    puts "***********************************************\n\n"

    # Apply new clock constraint
    set_timing_paths $clk [expr {$scale_factor/$mid_f}]

    repair_timing -setup
    repair_timing -hold

    #puts "writing schmeatic"
    #write_verilog -force  $outdir/test.v
    #puts "schematic done"

    #report_timing_summary -file $file_timing_summary

    #set slack [get_property SLACK [get_timing_paths -nworst 1]]

    set paths [find_timing_paths -path_delay max ]
    set path [lindex $paths 0]

    set slack [get_property $path slack]
    puts "slack: $slack"


    puts "\n\n***********************************************"
    puts "***********************************************"
    puts "Slow frequency: $slow_f MHz (period: [expr {$scale_factor/$slow_f}] ns)"
    puts "Fast frequency: $fast_f MHz (period: [expr {$scale_factor/$fast_f}] ns)"
    puts "Tested clock period: $mid_f MHz (Frequency: [expr {$scale_factor/$mid_f}] ns)"
    puts "***********************************************"
    puts "Slack: $slack ns"

    if {$slack >= 0} {
      if {$mid_f > $best_f} {
        set best_f $mid_f
        set max_freq $best_f
      }

      set slow_f $mid_f
    } else {
      set fast_f $mid_f
    }

    puts "New best frequency: $best_f MHz (period: [expr {$scale_factor/$best_f}] ns)"
    puts "New slow frequency: $slow_f MHz (period: [expr {$scale_factor/$slow_f}] ns)"
    puts "New fast frequency: $fast_f MHz (period: [expr {$scale_factor/$fast_f}] ns)"
    puts "***********************************************"
    puts "***********************************************\n\n"

    if {$fast_f > 0} {
      if {$fast_f - $slow_f <= 5} {
        break
      }
    }

    if {$fast_f == -1} {
       set mid_f [expr {2*$mid_f}]
    } elseif {$slow_f == -1} {
       set mid_f [expr {0.5*$mid_f}]
    } else {
      set mid_f [expr {$scale_factor/(($scale_factor/$slow_f + $scale_factor/$fast_f) / 2.0)}]
    }
}

set best_period [expr {$scale_factor/$max_freq}]

puts "\n\n================================================"
puts "Maximum Achievable Frequency: $max_freq MHz"
puts "Clock Period: $best_period ns"
puts "================================================\n\n"

set_timing_paths $clk $best_period

repair_timing -setup
repair_timing -hold


report_units

report_tns -max
report_wns -max

#set clock [lindex [all_clocks] 0]
#set clock_period [get_property $clock period]

write_both $f "name: $::env(DESIGN_NAME)"

write_both $f "Fmax: $max_freq ($best_period)"

set shortest_slack 100000.0

#foreach group {in2reg reg2out reg2reg in2out} {
foreach group {in2out} {
    #set paths [find_timing_paths -path_group $group -sort_by_slack -group_path_count 1]
    set paths [find_timing_paths -path_group $group -path_delay max ]
    set path [lindex $paths 0]

    set slack [get_property $path slack]
    write_both $f "${group}_slack: $slack"

    # List of path points (start pin -> ... -> end pin)
    set points [get_property $path points]

    # End-point arrival is the arrival at the last point
    set end_point        [lindex $points end]
    set end_arrival_time [get_property $end_point arrival]

    # (Optional) start-point arrival, if you want pure path delay = end - start
    set start_point       [lindex $points 0]
    set start_arrival_time [get_property $start_point arrival]

    set required [get_property $end_point required]
#    set arrival [expr {$end_arrival_time - $start_arrival_time}]
    set arrival [expr {$required - $start_arrival_time}]

    write_both $f "${group}_required: $required"

#    puts "start_arrival_time=$start_arrival_time  end_arrival=$end_arrival_time  slack=$slack  required=$required"

#    write_both $f "${group}_arrival: $arrival"
#    set slowest_path [expr { $arrival > $slowest_path ? $arrival : $slowest_path }]
    set shortest_slack [expr { $slack < $shortest_slack ? $slack : $shortest_slack }]
}

write_both $f "shortest_slack: $shortest_slack"

#set clock_period_ps [sta::find_clk_min_period $clock 1]
#set fmax [expr round(1.0e-6 / $clock_period_ps)]

#set fmax [expr round(1000000.0 / $slowest_path)]
#write_both $f "fmax: $fmax MHz"

#set freq [expr round(1000000.0 / $clock_period)]
#write_both $f "clock setting: $clock_period ($freq)"
#write_both $f "clock setting: $clock_period"

set instance_count [llength [get_cells *]]
write_both $f "instances: $instance_count"

set design_area [sta::format_area [rsz::design_area] 0]
write_both $f "design_area: $design_area"

set util [format %.0f [expr [rsz::utilization] * 100]]
write_both $f "utilization: $util"

#set core_area [sta::format_area [rsz::core_area] 0]
#write_both $f "core_area: $core_area"

# set_power_activity -input -activity 0.5
# 
# report_power > tmp.txt
# exec cat tmp.txt
# set f2 [open tmp.txt r]
# set power_line [lindex [split [read $f2] "\n"] 9]
# regexp {(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $power_line -> _ _ _ _ power
# close $f2
# 
# write_both $f "power: $power mW"

# # Inspect that single endpoint
# report_checks -path_delay max -to [get_ports {operation_flags_o[3]}] \
#   -fields {path_type clock startpoint endpoint delay slack} -digits 4 -group_count 3
# 
# # Also see if anything is unconstrained more broadly
# #report_unconstrained_points
# 
# report_checks -path_delay max \
#               -fields {path_type startpoint endpoint slack} \
#               -digits 4

# report_checks -path_delay max -fields {startpoint endpoint slack} -digits 4

# set p [lindex [find_timing_paths -path_delay max -max_paths 1 -sort_by_slack] 0]
# puts "Worst endpoint: [get_property $p endpoint], slack = [get_property $p slack]"

close $f
puts "Results written to: $::env(OUTPUT)"

