`include "baudgen_model.sv"
interface Baud_if(input bit clk);
	logic [3:0] set_in;
	logic reset_in;
	logic baudtick_out;
	
	modport TB( output set_in,
	output reset_in,
	input baudtick_out,
	input clk);

endinterface

class input_generator;
	randc logic [3:0] set_baud;
	constraint c {
		set_baud >= 'd0;
		set_baud < 'd14;
	}
endclass

module Baud_tb( Baud_if.TB baudif);

baudgen_model bg0;
bit sim_baudtick;
input_generator ig0;
	covergroup cover_inputs;
	coverpoint baudif.set_in iff (baudif.reset_in);
	coverpoint baudif.set_in {
		bins vslow = {['d0:'d3]};
		bins slow = {['d4:'d7]};
		bins fast = {['d8:'d10]};
		bins vfast = {['d11:'d13]};
	}
	endgroup
cover_inputs cova;
logic [19:0] sim_counter;
	initial begin
		bg0 = new();
		ig0 = new();
		cova = new();
		fork
			begin forever 
				begin
					@(baudif.set_in);
					bg0.Setbaudrate(baudif.set_in);
				end
			end
			begin
				forever begin
					@(posedge baudif.clk, negedge baudif.reset_in)begin
						bg0.run(baudif.reset_in, sim_baudtick, sim_counter);
					end
				end
			end
			begin forever #1
				begin
					if(sim_baudtick != baudif.baudtick_out)
						$error("There is an error with the model/rtl");
				end
			end
		join_none
		baudif.reset_in <= 1'b0;
		#30 baudif.reset_in <= 1'b1;
		for(int i = 0 ; i < 14 ; i++)begin
			assert(ig0.randomize()) else $fatal;
			baudif.set_in <= ig0.set_baud;
			cova.sample();
			@(posedge baudif.baudtick_out)
			begin
				#20 $display("The output is going high!");
			end
		end
		baudif.reset_in <= 1'b0;
		#30 baudif.reset_in <= 1'b1;
		for(int i = 0 ; i < 14 ; i++)begin
			assert(ig0.randomize()) else $fatal;
			baudif.set_in <= ig0.set_baud;
			cova.sample();
			@(posedge baudif.baudtick_out)
			begin
				#20 $display("The output is going high!");
			end
		end
	$finish;
	end
	


endmodule

module Baud_top;

bit clk;
initial begin
	clk = 0;
	forever #10 clk = !clk;
end

Baud_if if0(clk);
BAUDGEN bg0(.clk(clk),
	.resetn(if0.reset_in),
	.set_baud(if0.set_in),
	.baudtick(if0.baudtick_out));
Baud_tb tb0(if0);
endmodule
