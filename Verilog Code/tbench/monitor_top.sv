`include "uart_tx.sv"
`include "baudgen.sv"
`include "uart_rx.sv"
`include "parity_checker.sv"

class input_generator;

randc logic [7:0] tx_in;
rand bit rx_parity;
endclass

module monitor_top(
   input wire HRESETn, 
   input wire Tx_parity,
   input wire [15:0] ERRCOUNTER,
   input wire Tx_RS_232,
   output wire Rx_RS_232,
   input wire [3:0] Baud_Reg,
   input wire clk,
   output wire Rx_parity
);

   bit tb_tx0_output;
   bit tb_rx0_input;
   bit rx_done;
   bit tx_done;
   bit baudtick;
   bit reset_baud_flag = 1'b0;

   logic [8:0] rx_out;
   logic [7:0] data_in = 1'b0;
   logic [15:0] tb_ERRCOUNTER = 'd0;

   baudgen bg0;
   uart_tx tx0;
   uart_rx rx0;
   parity_checker pc0;
   parity_gen pg_new;
   input_generator ig0;

   
   


   initial begin
      bg0 = new();
      tx0 = new();
      rx0 = new();
      pc0 = new();
      ig0 = new();
      bg0.Setbaudrate(Baud_Reg);
      ig0.randomize();
      data_in = ig0.tx_in;
      Rx_parity = ig0.rx_parity;
      fork
         begin
            forever begin
               @(Baud_Reg);
               bg0.Setbaudrate(Baud_Reg);
            end
         end
         begin 
            forever begin
               @(posedge clk, negedge HRESETn);
               begin
                  bg0.run(HRESETn & !reset_baud_flag, baudtick);
               end
            end
         end 
         begin 
            forever begin
                @(posedge tx_done);
                #100;
                ig0.randomize();
                data_in = ig0.tx_in;
                Rx_parity = ig0.rx_parity;
                $display("Inputting %0b ");
            end
         end


         begin 
            forever #1 begin
               tx0.run(data_in, Rx_RS_232, clk, ig0.rx_parity, HRESETn,
               !tx_fifo_empty, baudtick, tx_done  );
            end
         end
         begin
            forever begin
               @(posedge clk, negedge HRESETn);
               begin
                  tx0.clk_edges(HRESETn);
               end
            end
         end
         begin 
            forever begin
               #1 begin
               rx0.compute(clk, HRESETn, baudtick, Tx_RS_232, rx_done, rx_out , reset_baud_flag);
               end
            end
         end
         begin
            forever begin
               @(posedge clk, negedge HRESETn);
               rx0.clk_edges();
            end 
         end 
         begin
            forever  begin
               @(posedge rx_done);
               pc0.check_parity(rx_out, Tx_parity, tb_ERRCOUNTER);
               #5;
               $display("The tx sent: %0b and the tb_ERRCOUNTER: %0b",rx_out[7:0], tb_ERRCOUNTER);
            end
         end
      join_none
      
      forever #1 begin
        if(tb_ERRCOUNTER != ERRCOUNTER)
            $error("ERRCOUNTER is wrong");
      end
      /*HRESETn = 1'b0;
      #40;
      HRESETn = 1'b1;
      #40;
      
      for(int i = 0; i<5 ; i++)begin
         @(posedge clk)
         ig0.randomize();
         uart_wdata [7:0] = ig0.tx_in;
         @(posedge clk);
         #10;
         uart_wr = 1'b1;
         @(posedge clk);
         #10;
         uart_wr = 1'b0;
      end
      $display("The writes are finished");
      #40;
      #40;
      @(rx_fifo_full);
      uart_rd = 1'b1;
      @(rx_fifo_empty);
      $display("The rx fifo is empty");
      @(tx_fifo_empty);
      $finish;*/
   end

endmodule // tb_top
