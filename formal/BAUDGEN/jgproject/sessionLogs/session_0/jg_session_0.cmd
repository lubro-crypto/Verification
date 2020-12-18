#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2018.06
# platform  : Linux 3.10.0-957.21.3.el7.x86_64
# version   : 2018.06p002 64 bits
# build date: 2018.08.27 18:04:53 PDT
#----------------------------------------
# started Fri Dec 18 13:34:01 GMT 2020
# hostname  : ee-mill3.ee.ic.ac.uk
# pid       : 100461
# arguments : '-label' 'session_0' '-console' 'ee-mill3.ee.ic.ac.uk:42960' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/tms4517/nfshome/JasperGold/BAUDGEN/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/tms4517/nfshome/JasperGold/BAUDGEN/jgproject/.tmp/.initCmds.tcl' 'baudgen.tcl'
# Script for multiplier example in JasperGold
clear -all
analyze -clear
#analyze -sv parity_gen.sv
analyze -sv baudgen.sv
#elaborate -bbox_mul 64 -top parity_generator
elaborate -bbox_mul 64 -top BAUDGEN

# Setup global clocks and resets
clock clk
#reset -expression !(rst_n)
reset -expression !(resetn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

#cover -name test_cover_from_tcl {@(posedge clk) disable iff (!rst_n) done && ab == 10'd35}
prove -bg -all
prove -bg -task {<embedded>}
visualize -new_window; visualize -violation -property <embedded>::BAUDGEN.assert_count_clock_cycles_between_tick -bg
visualize -new_window; visualize -violation -property <embedded>::BAUDGEN.assert_count_clock_cycles_between_tick -bg
prove -bg -all
