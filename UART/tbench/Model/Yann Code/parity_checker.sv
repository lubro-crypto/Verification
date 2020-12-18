class parity_checker;
    logic [15:0] Internal_ERRCOUNTER = 0;
    bit error = 1'b0;
    task check_parity(input logic [8:0] rx_dout, input bit PARITYSEL, output logic [15:0] ERRCOUNTER);

        error = (PARITYSEL) ? (!(^rx_dout)) : (^rx_dout);

        if(error)
            Internal_ERRCOUNTER = Internal_ERRCOUNTER + 1'b1;
        
        ERRCOUNTER = Internal_ERRCOUNTER;
    endtask
endclass