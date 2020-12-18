`include "baudgen_model.sv"
interface Baud_if(input bit clk);
	logic [3:0] set_in;
	logic reset_in;
	logic baudtick_out;
	
	modport TB( output set_in,
	output reset_in,
	input baudtick_out);

endinterface

class input_generator;
	randc logic [3:0] set_baud;
	constraint c {
		set_baud >= 'd0;
		set_baud < 'd14;
	}
endclass

module Baud_tb( Baud_if.TB baudif);
	covergroup cover_inputs {
		slow = ['d0:'d5];
		fast = ['d6:'d14];
	}
	endgroup

	initial begin
		fork
			begin
				forever begin
					@(posedge clk)begin
						
					end
				end
			end
		join_none
		baudif.reset_in <= 1'b0;
		#30 baudif.reset_in <= 1'b1;
		for(int i = 0 ; i < 14 ; i++)begin
			
			baudif.set_in <= i;
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
