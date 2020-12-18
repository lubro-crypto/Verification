module parity_generator
#(parameter DWIDTH = 8)
(
input wire [DWIDTH-1:0] data_in ,
input wire PARITYSEL,
output wire data_output
);
/*
If the input evn is high, then it is even parity generated
Otherwise odd parity
*/
wire [DWIDTH:0] Test_wire =  {data_output, data_in[DWIDTH-1:0]};

wire even_parity = ^data_in;
wire inject_bug = 1'b0;
assign data_output = (PARITYSEL ==1'b1 && !inject_bug) ? ~even_parity : even_parity;

//check behaviour
property check_parity;
    @(posedge data_output, negedge data_output)
        if(data_output || !data_output)
            PARITYSEL == ^{data_output, data_in};

endproperty
assert_check_parity: assert property (check_parity)
    else $error ("Error: paritygen failed");

endmodule