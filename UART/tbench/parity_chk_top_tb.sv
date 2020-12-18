
`include "parity_checker.sv"

interface parity_chk_top_if
#(parameter DWIDTH = 8, parameter COUNTERWIDTH = 16)
();
logic [DWIDTH:0] data_in;
logic SEL;
logic start;
logic reset;

logic [COUNTERWIDTH - 1:0 ] ERRCOUNTER;

modport TB(
 output SEL, output data_in, output start, output reset, input ERRCOUNTER);

endinterface

class input_generator #(parameter DWIDTH = 8); 
	randc logic [DWIDTH:0] parity_input;
    rand bit parity_bit;
endclass

module parity_chk_top_tb
#(parameter DWIDTH = 8)
( parity_chk_top_if.TB parityif);
reg parity_bit ;
input_generator ig0;
reg [15:0] simulate_ERRCOUNTER = 'd0;
parity_checker pc0;
initial 
begin
    pc0 = new();
	ig0 = new();
    fork
        begin
            forever 
            begin
                @(posedge parityif.start);
                pc0.check_parity(parityif.data_in, parityif.SEL, simulate_ERRCOUNTER );
            end
        end
        begin 
            forever #1 begin
                if(simulate_ERRCOUNTER != uartif.ERRCOUNTER) 
                    $error("There is something wrong");
            end
        end
    join_none
    parityif.reset = 1'b0;
	#10 ;
    parityif.reset = 1'b1;
	for(int i = 0; i< 100; i++)begin
		ig0.randomize();
		parityif.data_in <= ig0.parity_input;
        parityif.SEL <= ig0.parity_bit;
        #10;
	end
    parityif.reset = 1'b0;
    #10;
    parityif.reset = 1'b1;
    for(int i = 0; i< 100; i++)begin
		ig0.randomize();
		parityif.data_in <= ig0.parity_input;
        parityif.SEL <= ig0.parity_bit;
        #10;
	end

	
end


endmodule

module parity_chk_top_tb_top;

parity_chk_top_if if0();
parity_chk_top_tb tb0(if0);
parity_check_top chk0(.d_in(if0.data_in),.PARITYSEL(if0.SEL),.ERRCOUNTER(if0.ERRCOUNTER), .start(if0.start), .resetn(if0.reset));

endmodule
