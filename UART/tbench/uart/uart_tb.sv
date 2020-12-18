class input_generator;
    randc logic [7:0] data_in;
    rand bit Tx_parity;
    rand bit Rx_parity;
    constraint parity{
        Tx_parity == Rx_parity :/80,
        Tx_parity != Rx_parity:/ 20
    };
    randc logic [3:0] set_baud;
	constraint c {
		set_baud >= 'd0;
		set_baud < 'd14;
	}
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
bit sim_tx_start;
bit sim_tx_done;
bit simTx_RS232;
bit simRx_RS232;
bit sim_rx_done;
logic [8:0] sim_rx_out;
covergroup cover_inputs;
	coverpoint uartif.Baud_Reg iff (uartif.resetn);
	coverpoint uartif.Baud_Reg {
		bins vslow = {['d0:'d3]};
		bins slow = {['d4:'d7]};
		bins fast = {['d8:'d10]};
		bins vfast = {['d11:'d13]};
	}
    coverpoint uartif.Tx_d_in iff (uartif.resetn);
    coverpoint uartif.Tx_d_in {
        bins zero = {0}; 
        bins vsmall = {1};
        bins little = {2};
        bins med = {[3:4]};
        bins big = {5};
        bins huge = {6};
        bins max = {7};
    }
    coverpoint uartif.PARITYSEL_Tx iff (uartif.resetn);
    coverpoint uartif.PARITYSEL_Tx ;
    coverpoint uartif.PARITYSEL_Rx iff (uartif.resetn);
    coverpoint uartif.PARITYSEL_Rx ;
endgroup
    initial begin
        fork
        begin
            forever begin
                @(uartif.Baud_Reg);
                bg0.Setbaudrate(uartif.Baud_Reg);
            end
        end
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
               tx0.run(data_in, simTx_RS232, uartif.clk, uartif.PARITYSEL_Tx, uartif.resetn,
               sim_tx_start, sim_baudtick, sim_tx_done  );
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
               rx0.compute(uartif.clk, uartif.resetn, sim_baudtick, simRx_RS232, sim_rx_done, sim_rx_out );
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
               pc0.check_parity(sim_rx_out, uartif.PARITYSEL_Rx, sim_ERRCOUNTER);
            end
         end
         begin forever begin
            @(posedge clk);
            if(uartif.Tx_d_out != sim_tx_out)
                $error("The tx out's are not equal");
            if(uartif.ERRCOUNTER != sim_ERRCOUNTER)
                $error("The ERRCOUNTERS are not equal");
         end
        join_none   

        uartif.resetn <= 1'b0;
        #30 uartif.resetn <= 1'b1;
        //even parity
        uartif.PARITYSEL_Tx <= 1'b0;
        uartif.PARITYSEL_Rx <= 1'b0;
        for(int i = 0; i < 100; i++)begin
            ig0.randomize();
            uartif.Baud_Reg = ig0.set_baud;
            uartif.PARITYSEL_Tx  = ig0.Tx_parity;
            uartif.ParitySEL_Rx = ig0.Rx_parity;
            uartif.Tx_d_in = ig0.data_in;
            $display("The input is %0d", uartif.Tx_d_in);
            #20 uartif.Tx_start <= 1'b1;
            #20 uartif.Tx_start <= 1'b0;
            @(posedge uartif.Rx_done);
            if(uartif.Rx_d_out != sim_rx_out)
                $error("The Rx'outs are not equal");

            #100 $display("The transmission has finished");
            if({^uart_if.Tx_d_in, uart_if.Tx_d_in } == uartif.Rx_d_out) 
                $display("The transmission was successful");
            else 
                $error("The transmission failed");
            end
                @(posedge uartif.Rx_done);

            end
        end
        $finish;
    end 
    assign uartif.Rx_d_in = uartif.Tx_d_out;
    assign simRx_RS232 = uartif.Tx_d_out;

endmodule