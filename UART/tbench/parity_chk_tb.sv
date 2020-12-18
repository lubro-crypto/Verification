interface parity_chk_if
#(parameter DWIDTH = 8)
();
logic [DWIDTH:0] data_in;
logic even;
logic error;

modport TB(
	input error, output even, output data_in);

endinterface

class input_generator #(parameter DWIDTH = 8); 
	randc logic [DWIDTH:0] parity_input;
endclass

module parity_chk_tb
#(parameter DWIDTH = 8)
( parity_chk_if.TB parityif);
reg parity_bit ;
input_generator ig0;
initial 
begin
	ig0 = new();
	#10 parityif.even <= 1'b0;
	for(int i = 0; i< 100; i++)begin
		ig0.randomize();
		parityif.data_in <= ig0.parity_input;
		parity_bit = ^ig0.parity_input;
		#10;
		if( (^ig0.parity_input) == parityif.error ) 
		begin
			$display("The parity works!");
		end
		else 
			$error("The parity didn't work");
		#10;
	end
	parityif.even <= 1'b1;
	for(int i = 0; i< 100; i++)begin
		ig0.randomize();
		parityif.data_in <= ig0.parity_input;
		#10;
		if( (^ig0.parity_input) == !parityif.error ) 
		begin
			$display("The parity works!");
		end
		else 
			$error("The parity didn't work");
		#10;
	end
end


endmodule

module parity_chk_tb_top;

parity_chk_if if0();
parity_chk_tb tb0(if0);
parity_checker chk0(.data_in(if0.data_in),.PARITYSEL(if0.even),.PARITYERR(if0.error));

endmodule
