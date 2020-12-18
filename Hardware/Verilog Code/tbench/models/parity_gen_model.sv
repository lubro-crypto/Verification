class parity_gen_model #(parameter DWIDTH = 8);

    task run(input logic [DWIDTH - 1:0] data_in, input bit PARITYSEL, output bit data_output);
        int Ones = 0; //Number of Ones
        for(int i = 0; i<DWIDTH; i++)begin

            if(data_in[i] == 1'b1)begin
                Ones++;
            end
        end
        if( (Ones%2 == 0 && !PARITYSEL) || (Ones%2 != 0 && PARITYSEL))begin
            //If it is even parity and there are an even numbers of 1's
            //If it is odd parity and there are an odd number of 1's
            data_output = 1'b0;
        end
        else if ( (Ones%2 == 1 && !PARITYSEL) || (Ones%2 != 1 && PARITYSEL))begin
            ////If there are an odd number of ones for even parity
            data_output = 1'b1;
        end
    
                
    endtask

endclass // parity_gen
