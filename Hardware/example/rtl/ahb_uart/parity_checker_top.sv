module parity_check_top
#(parameter COUNTERWIDTH = 16)
(input [8:0] d_in,
input PARITYSEL,
input start,
input resetn,
output [COUNTERWIDTH-1:0] ERRCOUNTER);

wire PARITYERR;
reg [COUNTERWIDTH-1:0] COUNTER = 'd0;
parity_checker chk0(.data_in(d_in),.PARITYSEL(PARITYSEL),.PARITYERR(PARITYERR));
wire inject_bug = 1'b0;
always @(posedge start, negedge resetn)begin
    if(!resetn) COUNTER <= 'd0;
    else if(PARITYERR) begin
        if(inject_bug)
            COUNTER <= 2'd2 + COUNTER;  
        else
            COUNTER <= 'd1 + COUNTER;  
    end
end

assign ERRCOUNTER = COUNTER;

endmodule