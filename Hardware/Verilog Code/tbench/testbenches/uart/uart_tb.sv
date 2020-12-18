class input_generator;
    randc logic [7:0] data_in;

endclass;
// `include "uart_tx_model.sv"
// `include "uart_rx_model.sv"
// `include "parity_checker_model.sv"
// `include "baudgen_model.sv"


module uart_tb
(uart_if.TB uartif);
input_generator ig0;

    initial begin
    //     fork 
    //         begin
    //         clk = 1'b0;
    //         forever #1 begin
    //            clk = ~clk;
    //            #20;
    //         end 
    //      end  
    //      begin 
    //         forever begin
    //            @(posedge uartif.clk, negedge resetn);
    //            begin
    //               bg0.run(resetn, baudtick);
    //            end
    //         end
    //      end 
    //      begin 
    //         forever #1 begin
    //            tx0.run(data_in, tx, clk, parity_type, resetn,
    //            !tx_fifo_empty, baudtick, tx_done  );
    //         end
    //      end
    //      begin
    //         forever begin
    //            @(posedge clk, negedge resetn);
    //            begin
    //               tx0.clk_edges(resetn);
    //            end
    //         end
    //      end
    //      begin 
    //         forever begin
    //            #1 begin
    //            rx0.compute(clk, resetn, baudtick, tx, rx_done, rx_out );
    //            end
    //         end
    //      end
    //      begin
    //         forever begin
    //            @(posedge clk, negedge HRESETn);
    //            rx0.clk_edges();
    //         end 
    //      end 
    //      begin
    //         forever  begin
    //            @(posedge rx_done);
    //            pc0.check_parity(rx_out, parity_type, ERRCOUNTER);
    //         end
    //      end
    //     join_none   

        uartif.resetn <= 1'b0;
        #30 uartif.resetn <= 1'b1;
        //even parity
        uartif.PARITYSEL_Tx <= 1'b0;
        uartif.PARITYSEL_Rx <= 1'b0;
        for(int i = 0; i < 7; i++)begin
            ig0.randomize();
            uartif.Baud_Reg = ig0.data_in;
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
        //odd parity
        uartif.PARITYSEL_Tx <= 1'b1;
        uartif.PARITYSEL_Rx <= 1'b1;

        for(int i = 0; i < 7; i++)begin
            uartif.Baud_Reg = 'd2*(i)+'d1;
            for(int j = 0 ; j < 10 ; j++) begin
                ig0.randomize();
                uartif.Baud_Reg = ig0.data_in;
                #20 uartif.Tx_start <= 1'b1;
                #20 uartif.Tx_start <= 1'b0;
                @(posedge uartif.Tx_done) begin
                    #100 $display("The transmission has finished");
                    if({!^uart_if.Tx_d_in, uart_if.Tx_d_in } == uartif.Rx_d_out) 
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