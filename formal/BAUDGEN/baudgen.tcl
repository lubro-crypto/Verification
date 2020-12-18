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
