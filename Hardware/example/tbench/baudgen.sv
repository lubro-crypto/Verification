class baudgen;

    int count = 10417; 
    int counting = 0;
    int multiplier =0 ;
    bit setflag = 0;
    function void Setbaudrate(logic [3:0] setBaudrate );
        case (setBaudrate)
        
            'd0:
                count = 28410;
            'd1:
                count = 10417;
            'd2:
                count = 5209;
            'd3:
                count = 2605;
            'd4:
                count = 1303;
            'd5:
                count = 652;
            'd6:
                count = 326;
            'd7:
                count = 218;
            'd8:
                count = 162;
            'd9:
                count = 82;
            'd10:
                count = 55;
            'd11:
                count = 28;
            'd12:
                count = 25;
            'd13:
                count = 13;
        
        endcase
    endfunction
    task reset(input resetn);
        if(!resetn)begin
            counting = 0;
            multiplier = 0; 
            setflag =1;
            $error("There is  a reset and the values are reset");
        end 
    endtask
    
    task run( output bit baudtick);
        if(setflag)begin
            baudtick = 1'b1;
            setflag = 1'b0;
        end
        else if(counting == count)begin
            counting = 0; 
            if(multiplier == 15)
                begin
                    multiplier = 0; 
                    baudtick = 1'b1;
                end
            else
            begin
                baudtick = 1'b0; //Set so you don't have to have the if(b_tick ==15)
                multiplier++;
            end        


        end
        else begin
            counting = counting + 1;
            baudtick = 1'b0;
        end
        
        
    endtask 

endclass