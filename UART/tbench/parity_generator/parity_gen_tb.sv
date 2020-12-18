`include "Parity_Generator.sv"
interface parity_if
#(parameter DWIDTH = 8)() ;
logic [DWIDTH-1:0] data_in;
logic data_out;
logic odd;

modport TB(
	output data_in, output odd, input data_out);
modport DUT(
	input data_in, input odd, output data_out); 


endinterface
class input_generator #(parameter DWIDTH = 8); 
	randc logic [DWIDTH-1:0] parity_input;
	rand bit paritysel;
endclass
module parity_tb
#(parameter DWIDTH = 5)
(
parity_if.TB parityif);
input_generator ig0;
parity_gen_model pg0;
bit out;
initial 
begin
	pg0 = new();
	ig0 = new() ;
	fork
		begin 
			forever #1 begin
				pg0.run(parityif.data_in, parityif.odd, out );
			end
		end
		begin 
			forever #1 begin
				if(out != parityif.data_out)begin
					$error("There is a problem with the generation") ;
				end
			end
		end
	join_none
	//So odd
	for(int i = 0; i< 100; i++)begin
		ig0.randomize();
		parityif.data_in <= ig0.parity_input;
		parityif.odd <= ig0.paritysel;
		#10;
	end
	$finish;
end


endmodule

module parity_top;

parity_if if1();
parity_tb tb1(if1);
parity_generator gen1(.data_in(if1.data_in),.PARITYSEL(if1.odd),.data_output(if1.data_out));

endmodule
