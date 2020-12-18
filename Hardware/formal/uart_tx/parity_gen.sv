module parity_generator
#(parameter DWIDTH = 8)
(
input wire [DWIDTH-1:0] data_in,
input wire PARITYSEL,
output wire data_output
);
/*
If the input evn is high, then it is even parity generated
Otherwise odd parity
*/
wire [DWIDTH:0] Test_wire =  {data_output, data_in[DWIDTH-1:0]};

wire even_parity = ^data_in;
//assign even_parity = ^data_in;

assign data_output = (PARITYSEL ==1'b1) ? ~even_parity : even_parity;

always @*
    assert (PARITYSEL == ^({data_output, data_in}))
        else $error ("Error: paritygen failed");

check_result: assert property(PARITYSEL == ^({data_output, data_in}));

endmodule

