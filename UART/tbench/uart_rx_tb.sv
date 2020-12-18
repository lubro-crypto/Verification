`include "uart_tx_model.sv"
`include "uart_rx_model.sv"
`include "parity_checker_model.sv"
`include "baudgen_model.sv"
interface uart_rx_if(input bit clk);

    logic resetn;
    logic b_tick ; //Simulate Baud Generator first and then implement 
    logic [8:0] dout;
    logic rx_done;
    logic RS232;

    modport TB( input clk, output resetn,
        output b_tick, output RS232 , input rx_done,
        input dout );
endinterface

class input_generator;
    randc logic [8:0] RS232_input;
endclass

module uart_rx_tb(uart_rx_if.TB uartif);
/*
*
Send a 1 - idle_st,
Send a 0 - start_st,
Send 9 random bits - data_st, store, them,
Send a 1 for long
Then check that dout = data_stored
*/
    logic [18:0] count_reg;
    logic send_data = 'd0;
    logic baud_tick;
    logic [3:0] baud_counter = 'd0;
    logic [8:0] desired_data = 'd0;

    parameter [18:0] count = 19'd13; // Baud rate of 110, but 16* that so 1760
    initial 
    begin
        input_generator ig0;
        ig0 = new();
        uartif.RS232 = 1'b1; 
        uartif.resetn <= 1'b0;
        count_reg <= 19'd0;
        #30 uartif.resetn <= 1'b1; 
        for(int i = 0 ; i < 100 ; i++ )begin
            ig0.randomize();
            desired_data = ig0.RS232_input;
            // Idle State
            uartif.RS232 = 1'b1; 
            #100;

            // Start State
            uartif.RS232 = 1'b0;
            @(negedge send_data);


            // Data State
            for(int j = 0 ; j< 9 ; j++ )begin
                uartif.RS232 = desired_data[j];
                @(negedge send_data);
            end

            //Stop State
            uartif.RS232 = 1;
            @(posedge uartif.rx_done);

            if(uartif.dout == desired_data)
                $display("The Rx read the data correctly");
            else 
                $error("There is an error in reading the RS-232");
            #100;
        end
        $finish;
    end
    always@(posedge uartif.clk, negedge uartif.resetn)
    begin
        if(uartif.resetn == 1'b0) begin
            baud_tick <= 1'b0;
            count_reg <= 'd0;
            baud_counter <= 'd0;
            send_data <= 1'b0;
        end
        else if(count_reg == count) begin
            baud_tick <= 1'b1;
            count_reg <= 'd0;
            if(baud_counter == 'd15 )
            begin
                send_data <= 1'b1;
                baud_counter <= 'd0;
            end
            baud_counter <= baud_counter +1'b1;
        end
        else begin 
            count_reg <= count_reg + 1'b1;
            baud_tick <= 1'b0;
            send_data <= 1'b0;
        end
    end
    assign uartif.b_tick = baud_tick;


endmodule

module uart_rx_tb_top;
bit clk;
initial begin
    clk = 0 ; 
    forever #10 clk = !clk;
end

uart_rx_if if0(clk);
uart_rx_tb tb0(if0);
UART_RX uart0(.clk(clk),
            .resetn(if0.resetn),
            .b_tick(if0.b_tick),
            .rx(if0.RS232),
            .rx_done(if0.rx_done),
            .dout(if0.dout));
endmodule

