module uart_tb_top;

bit clk;
initial begin
    clk = 0 ;
    forever #10 clk = !clk;
end


uart_if if0(clk);
BAUDGEN bg0(
    .clk(if0.clk),
    .resetn(if0.resetn),
    .set_baud(if0.Baud_Reg),
    .baudtick(if0.b_tick)
);
UART_RX rx0(
    .clk(if0.clk),
    .resetn(if0.resetn),
    .b_tick(if0.b_tick),
    .rx(if0.Rx_d_in),
    .rx_done(if0.Rx_done),
    .dout(if0.Rx_d_out)
);
UART_TX tx0(
    .clk(if0.clk),
    .resetn(if0.resetn),
    .b_tick(if0.b_tick),
    .tx_start(if0.Tx_start),
    .d_in(if0.Tx_d_in),
    .tx_done(if0.Tx_done),
    .tx(if0.Tx_d_out),
    .PARITYSEL(if0.PARITYSEL_Tx)
);
parity_check_top pc0(
    .d_in(if0.Rx_d_out),
    .PARITYSEL(if0.PARITYSEL_Rx),
    .resetn(if0.resetn),
    .ERRCOUNTER(if0.ERRCOUNTER)
);

uart_tb tb0(if0);

endmodule