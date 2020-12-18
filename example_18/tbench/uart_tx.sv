`include "Parity_Generator.sv"

class uart_tx;

   parity_gen px0;
   localparam logic [2:0] idle_st = 'd0;
   localparam logic [2:0] start_st = 'd1;
   localparam logic [2:0] data_st = 'd3;
   localparam logic [2:0] parity_st = 'd2;
   localparam logic [2:0] stop_st = 'd6;
   logic [2:0] current_state = 'd0;
   logic [2:0] next_state = 'd0;

   logic [7:0] data_reg = 'd0;
   logic [7:0] data_next = 'd0;
   logic tx_reg = 1'b1;
   logic tx_next = 1'b1;
   bit parity_bit;
   int i =0;
   bit tx_done1 = 0;
   bit said_something = 0;
   int number_of_bits = 0;
   int number_of_bits_next = 0;
   task run(input logic [7:0] in, output bit tx, input bit clk, input bit PARITY_SEL , input bit  resetn,
            input bit tx_start, input bit b_tick, output bit tx_done );
      begin
         px0 = new();
         fork

            begin
               px0.run(in, PARITY_SEL, parity_bit);
               
            end
            begin
               compute(in, tx_done1, resetn, tx_start,b_tick);
            end
         join_none
         tx = tx_reg;
         tx_done = tx_done1;



      end
   endtask


   task clk_edges( input bit resetn);
        begin
            if(!resetn)begin
               current_state = idle_st;
               data_reg = 0;
               tx_reg = 1'b1;
            end
            else begin
               current_state = next_state;
               tx_reg = tx_next;
               number_of_bits = number_of_bits_next;
            end

            
         end
   endtask


   task compute(input logic [7:0] d_in, output bit  tx_done,  input bit resetn, 
   input bit tx_start, input bit b_tick);
      
      next_state = current_state;
      tx_done = 1'b0;
      tx_next = tx_reg;

      case(current_state)

         idle_st:
         begin
            tx_next = 1'b1;
            if(tx_start)
            begin
               next_state = start_st;
               data_reg = d_in;
            end
         end

         start_st:
         begin
            tx_next = 1'b0;

            if(b_tick)begin
               if(!said_something) 
               begin
                  $display("In the start state");
                  said_something = 1'b1;
               end
               next_state = data_st;
            end
               
         end

         data_st:
         begin
            tx_next = data_reg[number_of_bits];

            if(b_tick)
            begin
               if(said_something) 
               begin
                  $display("In the data state, the number_of_bits is %d, the data_next is %0b, time: %t",number_of_bits, data_reg[number_of_bits], $time);
                  $display("The data_reg is %0b", data_reg);
                  said_something = 1'b0;
               end
               if(number_of_bits == 7 )begin
                  next_state = parity_st;
                  number_of_bits_next = 0;
               end
               else 
                  number_of_bits_next = number_of_bits +1'b1;
            end
            else said_something = 1'b1;
         end

         parity_st:
         begin 
            tx_next = parity_bit;
            if(b_tick)
            begin
               if(!said_something) 
               begin
                  $display("In the parity state");
                  said_something = 1'b1;
               end
               next_state = stop_st;
            end
         end

         stop_st: //send stop bit
         begin
            tx_next = 1'b1;

         if(b_tick)   //one stop bit
            begin
            if(said_something) 
            begin
               $display("In the stop state");
               said_something = 1'b0;
            end
            next_state = idle_st;
            tx_done = 1'b1;
            end
         end
      
      endcase
      
   endtask
endclass // uart_tx
