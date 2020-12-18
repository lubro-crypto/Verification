module parity_checker
#(parameter DWIDTH = 8)
(
	input wire [DWIDTH:0] data_in,
	input wire PARITYSEL,
	output wire PARITYERR
);
/*
even if PARITYSEL = 0 
//////
PARITY_SEL  = 1 so odd parity
even_parity = 0 
*/
wire true_output;
wire even_parity = ^data_in;
assign true_output = (PARITYSEL == 1'b1) ? ~even_parity : even_parity ;
//Inject bug
wire inject_bug = 1'b0;
assign PARITYERR = ((data_in > 9'd450) && inject_bug) ? ~true_output : true_output;
//assign PARITYERR = (PARITYSEL == 1'b0) ? ~even_parity : even_parity;


//check behaviour
wire parity_MSB;
wire bitwise_parity_check;

assign bitwise_parity_check = ^(data_in [DWIDTH-1:0]);
assign parity_MSB = (PARITYSEL ==1'b1) ? ~bitwise_parity_check : bitwise_parity_check;

property check_parity;
    @(posedge data_in, negedge data_in)
		if (parity_MSB == data_in [DWIDTH]) 
			PARITYERR == 0;
		
endproperty
assert_check_parity: assert property (check_parity)
    else $error ("Error: transmission error");
endmodule