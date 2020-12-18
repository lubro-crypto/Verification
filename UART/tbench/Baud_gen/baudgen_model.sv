class baudgen_model;

    int count = 10417; 
    int counting = 0;
    function void Setbaudrate(logic [3:0] setBaudrate );
        case (setBaudrate)
        
            'd0:
                count = 10417;
            'd1:
                count = 5209;
            'd2:
                count = 2605;
            'd3:
                count = 1303;
            'd4:
                count = 652;
            'd5:
                count = 326;
            'd6:
                count = 218;
            'd7:
                count = 162;
            'd8:
                count = 82;
            'd9:
                count = 55;
            'd10:
                count = 28;
            'd11:
                count = 25;
            'd12:
                count = 13;
        
        endcase
    endfunction
    
    task run(input bit resetn, output bit baudtick);
        if(!resetn)begin
            counting = 0;
        end 
        else if(counting == count)begin
            counting = 0; 

            baudtick = 1'b1;
            end
        else begin
            counting = counting + 1;
            baudtick = 1'b0;
        end
        
        
    endtask 

endclass