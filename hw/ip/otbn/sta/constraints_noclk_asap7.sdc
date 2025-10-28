report_units

# clk unit: ps
set clk_period 4000
set in2reg_max  $clk_period
set reg2out_max $clk_period
set in2out_max  $clk_period
set sdc_version 2.0
set non_clk_inputs [all_inputs -no_clocks]

set_max_delay [expr { $in2out_max  }] -from $non_clk_inputs -to [all_outputs]

# This allows us to view the different groups
# in the histogram in the GUI and also includes these
# groups in the report
group_path -name in2out -from $non_clk_inputs -to [all_outputs]

