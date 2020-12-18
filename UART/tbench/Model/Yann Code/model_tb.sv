`include "uart_tx.sv"
`include "baudgen.sv"
`include "uart_rx.sv"
`include "parity_checker.sv"

class input_generator;

randc logic [7:0] tx_in;
endclass

module model_tb_top(
   input wire HRESETn, 
   input wire parity_type,
   input wire uart_wr,
   input wire uart_rd,
   input wire [7:0] uart_wdata,
   output wire [15:0] ERRCOUNTER,
   output wire [7:0] uart_rdata,
   output wire tx_fifo_full,
   output wire tx_fifo_empty,
   output wire rx_fifo_full,
   output wire rx_fifo_empty
);

   bit parity_type = 1'b0;
   bit tx;
   bit HRESETn; 
   bit clk;
   bit rx_done;
   bit tx_done;
   bit baudtick;
   bit uart_rd = 1'b0;
   bit uart_wr = 1'b0;
   bit tx_fifo_empty = 1'b1;
   bit rx_fifo_empty = 1'b1;
   bit tx_fifo_full = 1'b0;
   bit rx_fifo_full = 1'b0;

   logic [8:0] rx_out;
   logic [3:0] Baud_Reg = 4'd12;
   logic [7:0] data_in = 1'b0;
   logic [15:0] ERRCOUNTER = 'd0;
   logic [7:0] uart_rdata = 'b0;
   logic [7:0] uart_wdata = 'b0;
   logic [7:0] tx_fifo [$];
   logic [7:0] rx_fifo [$];
   logic [2:0] tx_size = 'd0;
   logic [2:0] rx_size = 'd0;

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
   
      fork
         begin
            clk = 1'b0;
            forever #1 begin
               clk = ~clk;
               #20;
            end 
         end  
         begin 
            forever begin
               @(posedge clk, negedge HRESETn);
               begin
                  bg0.run(HRESETn, baudtick);
               end
            end
         end 
         begin 
            forever #1 begin
               tx0.run(data_in, tx, clk, parity_type, HRESETn,
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
               rx0.compute(clk, HRESETn, baudtick, tx, rx_done, rx_out );
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
               pc0.check_parity(rx_out, parity_type, ERRCOUNTER);
            end
         end
         begin 
            forever begin
               @(posedge clk);
               begin
               tx_fifo_empty = (tx_fifo.size <= 0);
               rx_fifo_empty = (rx_fifo.size <= 0);
               tx_fifo_full = (tx_fifo.size >= 4);
               rx_fifo_full = (rx_fifo.size >= 4);
               tx_size = tx_fifo.size;
               rx_size = rx_fifo.size;
               //Read enable ==>pop
               if(tx_done && !tx_fifo_empty) 
               begin
                  data_in = tx_fifo.pop_front();
               end
               if(uart_rd && !rx_fifo_empty)
               begin
                  uart_rdata [7:0] = rx_fifo.pop_front();
               end
               //Write enable ==> push
               if(uart_wr && !tx_fifo_full)begin
                  tx_fifo.push_back(uart_wdata[7:0]);
               end

               if(rx_done && !rx_fifo_full) begin
                  rx_fifo.push_back(rx_out[7:0]);
               end
               
               end
            end
         end
      join_none
      
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
