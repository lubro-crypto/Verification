class input_generator

module uart_tb
(uart_if.TB uartif);

    initial begin
        uartif.resetn <= 1'b0;
        #30 uartif.resetn <= 1'b1;
        //even parity
        uartif.PARITYSEL_Tx <= 1'b0;
        uartif.PARITYSEL_Rx <= 1'b0;
        for(int i = 0; i < 7; i++)begin
            uartif.Baud_Reg = 'd2*i;
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
                uartif.Tx_d_in <= j*'d25;
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