class uart_rx;


    localparam logic [2:0] idle_st = 'd0;
    localparam logic [2:0] start_st = 'd1;
    localparam logic [2:0] data_st = 'd3;
    localparam logic [2:0] stop_st = 'd2;
    logic [1:0] current_state = 'd0;
    logic [1:0] next_state = 'd0;
    logic [3:0] b_reg; //baud-rate/over sampling counter
    logic [3:0] b_next;
    logic [3:0] count_reg; //data-bit counter
    logic [3:0] count_next;
    logic [8:0] data_reg; //data register
    logic [8:0] data_next;
    bit baud_rate_reset = 1'b0;
    bit reset;

    task compute(input bit clk, 
        input resetn, 
        input bit b_tick, 
        input  rx,
        output bit rx_done,
        output logic [8:0] dout, 
        output bit baud_rate_reset);
        next_state = current_state;
        count_next = count_reg;
        data_next = data_reg;
        rx_done = 1'b0;
        reset = resetn;
        dout = data_reg;
        baud_rate_reset = 1'b0;

        case(current_state)
        idle_st:
            if(~rx)
            begin
                baud_rate_reset = 1;
                next_state = start_st;
                b_next = 0;
            end
            
        start_st:
            if(b_tick)begin
                
                next_state = data_st;
                b_next = 0;
                count_next = 0;
                
            end
        data_st:
            if(b_tick)
            
            begin

            b_next = 0;
            data_next = {rx, data_reg [8:1]};
            if(count_next ==8) // 8 Data bits ==> now 9
                next_state = stop_st;
            else
                count_next = count_reg + 1'b1;
            end
            
        stop_st:
            if(b_tick)
            begin
                
                next_state = idle_st;
                rx_done = 1'b1;
                
            end
        endcase
    endtask
    task clk_edges();
        if(!reset)
        begin
            current_state <= idle_st;
            count_reg <= 0;
            data_reg <=0;
        end
        else
        begin
            current_state <= next_state;
            count_reg <= count_next;
            data_reg <= data_next;
        end
    endtask 
endclass 