set start_f 10

set help_text {
Usage: vivado -mode batch -source my_script.tcl -tclargs [options]

Options:
  --top_module <name>   Name of the top module to synthesize.
  --wrap                Enable wrapping.
  --start_freq <freq>   Start frequrncy for search (default: $start_f MHz).
  -h, --help            Show this help and exit.
}

if {$argc == 0 || [lindex $argv 0] in {"-h" "--help"}} {
    puts $help_text
    exit 0
}


set top_module ""
set wrap 0

for {set i 0} {$i < $argc} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        --top_module {
            incr i
            set top_module [lindex $argv $i]
        }
        --start_freq {
            incr i
            set start_f [lindex $argv $i]
        }
        --wrap {
            set wrap 1
        }
        default {
            puts "Unknown option: $arg"
        }
    }
}

puts "top_module=$top_module, start_freq=$start_f, wrap=$wrap"

source lowrisc_ip_otbn_0.1.tcl

if {$wrap} {
  puts "Generating wrapper."
  source gen_sv.tcl
  set top_module wrapper
}


synth_design -mode out_of_context -top $top_module


set outdir reports/

set file_utilization $outdir/utilization.txt
set file_utilization_hierarchical $outdir/utilization_hierarchical.txt
set file_timing $outdir/timing.txt
set file_timing_summary $outdir/timing_summary.txt
set file_clocks $outdir/clocks.txt


write_checkpoint -force $outdir/synth.dcp


# Set clock port name
set clk "clk_i"


# Create clock to attach it to a clock buffer.
create_clock -name $clk -period [expr 1000.0/$start_f] [get_ports $clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y2 [get_ports $clk]


# Define search range
set slow_f    1
set fast_f 1000

set best_f $slow_f
set max_freq $best_f

set mid_f [expr $start_f/2]


# Binary search for max frequency
while {1} {

    if {[expr ($fast_f - $slow_f)] <= 5} {
      break
    }

    if {$fast_f == 1000} {
       set mid_f [expr 2*$mid_f]
    } else {
      set mid_f [expr 1000.0/((1000.0/$slow_f + 1000.0/$fast_f) / 2.0)]
    }

    if {[expr $mid_f >= $fast_f]} {
       puts "$mid_f >= $fast_f"
       exit -1
    }

    set mid_f [expr ((int($mid_f) + 4) / 5) * 5]

    puts "\n\n***********************************************"
    puts "***********************************************"
    puts "Slow frequency: $slow_f MHz (period: [expr 1000.0/$slow_f] ns)\n"
    puts "Fast frequency: $fast_f MHz (period: [expr 1000.0/$fast_f] ns)\n"
    puts "Testing clock period: $mid_f MHz (Frequency: [expr 1000.0/$mid_f] ns)\n"
    puts "***********************************************"
    puts "***********************************************\n\n"

    set mid_period [expr 1000.0/$mid_f]

    # Apply new clock constraint
    create_clock -name $clk -period $mid_period [get_ports $clk]

    puts "new clock"

    opt_design
    set ACTIVE_STEP opt_design
    
    place_design
    set ACTIVE_STEP place_design
    
    place_design
    
    phys_opt_design
    set ACTIVE_STEP phys_opt_design
    
    route_design
    set ACTIVE_STEP route_design


    report_timing_summary -file $file_timing_summary

    set slack [get_property SLACK [get_timing_paths -nworst 1]]

    puts "\n\n***********************************************"
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

    puts "Best frequency: $best_f MHz (period: [expr 1000.0/$best_f] ns)\n"
    puts "Slow frequency: $slow_f MHz (period: [expr 1000.0/$slow_f] ns)\n"
    puts "Fast frequency: $fast_f MHz (period: [expr 1000.0/$fast_f] ns)\n"
    puts "***********************************************"
    puts "***********************************************\n\n"

    open_checkpoint $outdir/synth.dcp
}

set best_period [expr 1000.0/$max_freq]

puts "\n\n================================================"
puts "Maximum Achievable Frequency: $max_freq MHz"
puts "Clock Period: $best_period ns"
puts "================================================\n\n"

create_clock -name $clk -period $best_period [get_ports $clk]

opt_design
set ACTIVE_STEP opt_design

place_design
set ACTIVE_STEP place_design

place_design

phys_opt_design
set ACTIVE_STEP phys_opt_design

route_design
set ACTIVE_STEP route_design


report_utilization -file $file_utilization
report_utilization -hierarchical -hierarchical_depth 6 -file $file_utilization_hierarchical

report_timing -file $file_timing

report_timing_summary -file $file_timing_summary

report_clocks -file $file_clocks


set rpt [report_utilization -return_string]
puts "==== Resource Overview ===="
puts $rpt


set p [lindex [get_timing_paths -from [get_clocks $clk] -to [get_clocks $clk] -setup -nworst 1] 0]
report_timing -of_objects $p


puts "================================================\n"
puts "Maximum Achievable Frequency: $max_freq MHz"
puts "Clock Period: $best_period ns"
puts "\n================================================\n"

