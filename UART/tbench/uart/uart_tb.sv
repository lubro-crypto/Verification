class input_generator;
    randc logic [7:0] data_in;
    rand bit Tx_parity;
    rand bit Rx_parity;
    constraint parity{
        Tx_parity == Rx_parity :/80,
        Tx_parity != Rx_parity:/ 20
    };
endclass;
// `include "uart_tx_model.sv"
// `include "uart_rx_model.sv"
// `include "parity_checker_model.sv"
// `include "baudgen_model.sv"


module uart_tb
(uart_if.TB uartif);
input_generator ig0;
bit sim_baudtick;
logic [15:0] sim_ERRCOUNTER;
    initial begin
        fork
         begin 
            forever begin
               @(posedge uartif.clk, negedge uartif.resetn);
               begin
                  bg0.run(uartif.resetn, sim_baudtick);
               end
            end
         end 
         begin 
            forever #1 begin
               tx0.run(data_in, tx, uartif.clk, uartif.PARITYSEL_Tx, uartif.resetn,
               !tx_fifo_empty, sim_baudtick, tx_done  );
            end
         end
         begin
            forever begin
               @(posedge uartif.clk, negedge uartif.resetn);
               begin
                  tx0.clk_edges(uartif.resetn);
               end
            end
         end
         begin 
            forever begin
               #1 begin
               rx0.compute(uartif.clk, uartif.resetn, sim_baudtick, tx, rx_done, rx_out );
               end
            end
         end
         begin
            forever begin
               @(posedge uartif.clk, negedge uartif.resetn);
               rx0.clk_edges();
            end 
         end 
         begin
            forever  begin
               @(posedge rx_done);
               pc0.check_parity(rx_out, uartif.PARITYSEL_Rx, sim_ERRCOUNTER);
            end
         end
        join_none   

        uartif.resetn <= 1'b0;
        #30 uartif.resetn <= 1'b1;
        //even parity
        uartif.PARITYSEL_Tx <= 1'b0;
        uartif.PARITYSEL_Rx <= 1'b0;
        for(int i = 0; i < 7; i++)begin
            ig0.randomize();
            uartif.Baud_Reg = ig0.data_in;
            uartif.PARITYSEL_Tx  = ig0.Tx_parity;
            uartif.ParitySEL_Rx = ig0.Rx_parity;
            for(int j = 0 ; j < 10 ; j++) begin
                uartif.Tx_d_in <= j*'d25;
                #20 uartif.Tx_start <= 1'b1;
                #20 uartif.Tx_start <= 1'b0;
                @(posedge uartif.Tx_done) begin
                    #100 $display("The transmission has finished");
                    if({^uart_if.Tx_d_in, uart_if.Tx_d_in } == uartif.Rx_d_out) 
                        $display("The transmission was successful");
                    else 
                        $error("The transmission failed");
                end
            end
        end
        $finish;
    end 
    assign uartif.Rx_d_in = uartif.Tx_d_out;


endmodule