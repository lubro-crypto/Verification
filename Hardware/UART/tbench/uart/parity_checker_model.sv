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
