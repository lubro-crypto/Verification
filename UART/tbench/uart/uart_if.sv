interface uart_if(input bit clk);

    //reset signals
    logic resetn;

    //Baud Rate signals
    logic [3:0] Baud_Reg;
    logic b_tick;

    //Data In signal for the tx
    logic [7:0] Tx_d_in;
    //Done Signal for the tx
    logic Tx_done;
    //Start Signal for the tx
    logic Tx_start;
    //Data Out Signal for the tx
    logic Tx_d_out;


    //Data In Signal for the Rx
    logic Rx_d_in;
    //Done for the Rx
    logic Rx_done;
    //Data Out Signal for the Rx
    logic [8:0] Rx_d_out;

    //Parity select, 0 = even, 1 = odd
    logic PARITYSEL_Tx;
    logic PARITYSEL_Rx;

    //Error Counter
    logic [15:0] ERRCOUNTER;

    

    modport TB (
        input clk, output resetn, output Baud_Reg, input b_tick,
        output Tx_d_in, input Tx_done, output Tx_start, input Tx_d_out,
        output Rx_d_in, input Rx_done, 
        output PARITYSEL_Rx, output PARITYSEL_Tx  
    );

endinterface