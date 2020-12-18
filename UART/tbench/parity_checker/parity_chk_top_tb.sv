class parity_checker_model;
    logic [15:0] Internal_ERRCOUNTER = 0;
    logic reset_flag = 1'b0;
    bit error = 1'b0;

    task check_parity(input logic [8:0] rx_dout, input bit PARITYSEL, output logic [15:0] ERRCOUNTER, input bit resetn);
        int Ones = 0;

        
        for(int i =0; i<9 ; i++) begin
            if(rx_dout[i] == 1'b1) 
                Ones = Ones + 1'b1; 
        end
        if( (Ones%2 == 0 && !PARITYSEL) || (Ones%2 != 0 && PARITYSEL))begin
            //If it is even parity and there are an even numbers of 1's
            //If it is odd parity and there are an odd number of 1's
            error = 1'b0;
        end
        else if ( (Ones%2 == 1 && !PARITYSEL) || (Ones%2 != 1 && PARITYSEL))begin
            ////If there are an odd number of ones for even parity
            error = 1'b1;
        end

        if(error)
            Internal_ERRCOUNTER = Internal_ERRCOUNTER + 1'b1;
        
        if( !resetn ) 
        begin
            Internal_ERRCOUNTER = 'd0;
        end
        ERRCOUNTER = Internal_ERRCOUNTER;

    endtask
    
endclass

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
(
parity_chk_top_if.TB parityif);


covergroup cover_a_value;
    coverpoint parityif.data_in iff (parityif.reset); 
    coverpoint parityif.data_in {
        bins zero = {0}; 
        bins lo = {[1:2]};
        bins med = {[3:5]};
        bins hi = {[6:7]};
        bins max = {8};
    }
    coverpoint parityif.SEL iff (parityif.reset);
    coverpoint parityif.SEL {
        bins even = {0};
        bins odd = {1};
    }
endgroup
input_generator ig0;
reg [15:0] simulate_ERRCOUNTER = 'd0;
parity_checker_model pc0;
cover_a_value cav0;
initial 
begin
    pc0 = new();
	ig0 = new();
    cav0 = new();
    fork
        begin
            forever 
            begin
                @(posedge parityif.start, negedge parityif.reset);
                pc0.check_parity(parityif.data_in, parityif.SEL, simulate_ERRCOUNTER , parityif.reset);
            end
        end
        begin 
            forever #1 begin
                if(simulate_ERRCOUNTER != parityif.ERRCOUNTER) 
                    $error("There is something wrong, the errors are not correct");
            end
        end
    join_none
    parityif.reset = 1'b0;
	#10 ;
    parityif.reset = 1'b1;
	for(int i = 0; i< 100; i++)begin
		assert(ig0.randomize) else $fatal;
		parityif.data_in <= ig0.parity_input;
        parityif.SEL <= ig0.parity_bit;
        cav0.sample();
        #10;
        parityif.start <= 1'b1;
        #10;
        parityif.start <= 1'b0;
        #10;
	end
    parityif.reset = 1'b0;
    #10;
    parityif.reset = 1'b1;
    for(int i = 0; i< 100; i++)begin
		assert(ig0.randomize) else $fatal;
		parityif.data_in <= ig0.parity_input;
        parityif.SEL <= ig0.parity_bit;
        cav0.sample();
        #10;
        parityif.start <= 1'b1;
        #10;
        parityif.start <= 1'b0;
        #10;
	end

	
end


endmodule

module parity_chk_top_tb_top;

parity_chk_top_if if0();
parity_chk_top_tb tb0(if0);
parity_check_top chk0(.d_in(if0.data_in),.PARITYSEL(if0.SEL),.ERRCOUNTER(if0.ERRCOUNTER), .start(if0.start), .resetn(if0.reset));

endmodule
