//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT (�LICENCE�) IS A LEGAL AGREEMENT BETWEEN      //
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  //
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   //
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  //
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   //
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   //
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    //
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                //
//                                                                              //
//ARM hereby grants to you, subject to the terms and conditions of this Licence,//
//a non-exclusive, worldwide, non-transferable, copyright licence only to       //
//redistribute and use in source and binary forms, with or without modification,//
//for academic purposes provided the following conditions are met:              //
//a) Redistributions of source code must retain the above copyright notice, this//
//list of conditions and the following disclaimer.                              //
//b) Redistributions in binary form must reproduce the above copyright notice,  //
//this list of conditions and the following disclaimer in the documentation     //
//and/or other materials provided with the distribution.                        //
//                                                                              //
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     //
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     //
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR //
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE //
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, //
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    //
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.//
//////////////////////////////////////////////////////////////////////////////////


module UART_RX(
  input wire clk,
  input wire resetn,
  input wire b_tick,        //Baud generator tick
  input wire rx,            //RS-232 data port
  
  output reg rx_done,       //transfer completed
  output wire [8:0] dout    //output data
  );

//STATE DEFINES  
  localparam [1:0] idle_st = 2'b00;
  localparam [1:0] start_st = 2'b01;
  localparam [1:0] data_st = 2'b11;
  localparam [1:0] stop_st = 2'b10;

//Internal Signals  
  reg [1:0] current_state;
  reg [1:0] next_state;
  reg [3:0] b_reg; //baud-rate/over sampling counter
  reg [3:0] b_next;
  reg [3:0] count_reg; //data-bit counter
  reg [3:0] count_next;
  reg [8:0] data_reg; //data register
  reg [8:0] data_next;
  reg verif_idle;
  reg verif_data; 
  reg verif_start;
  reg verif_stop;
  reg verif_reset;
  reg rx_prev  = 'd0;
  reg req;
  
  wire inject_bug = 1'b0;

//State Machine  
  always @ (posedge clk, negedge resetn)
  begin
    if(!resetn)
      begin
        current_state <= idle_st;
        b_reg <= 0;
        count_reg <= 0;
        data_reg <=0;
      end
    else
      begin
        current_state <= next_state;
        b_reg <= b_next;
        count_reg <= count_next;
        data_reg <= data_next;
      end
  end

//Next State Logic 
  always @*
  begin
    next_state = current_state;
    b_next = b_reg;
    count_next = count_reg;
    data_next = data_reg;
    rx_done = 1'b0;
        
    case(current_state)
      idle_st:
        if(~rx)
          begin
            next_state = start_st;
            b_next = 0;
          end
          
      start_st:
        if(b_tick)begin
          if(b_reg == 15) //Why 7
            begin
              next_state = data_st;
              b_next = 0;
              count_next = 0;
            end
          else
            b_next = b_reg + 1'b1;
        end
      data_st:
        if(b_tick)begin
          if(b_reg == 15)
            begin
              b_next = 0;
              if(inject_bug) data_next = {!rx, data_reg [8:1]};
              else data_next = {rx, data_reg [8:1]};
              if(count_next ==8) // 8 Data bits ==> now 9
                next_state = stop_st;
              else
                count_next = count_reg + 1'b1;
            end
          else
            b_next = b_reg + 1;
        end
      stop_st:
        if(b_tick)begin
          if(b_reg == 15) //One stop bit
            begin
              next_state = idle_st;
              rx_done = 1'b1;
            end
          else
           b_next = b_reg + 1;
        end
    endcase
  end
  
  //////////////////////////////////////////////////////////////////////////////////////

  assign dout = data_reg;
always@(posedge clk)begin
  verif_idle <= (current_state == idle_st && rx == 1);
  verif_data <= (current_state == data_st && rx == data_next [8]);
  verif_start <= (current_state == start_st && rx == 0) ;
  verif_stop <= (current_state == stop_st && rx == 1) ;
  verif_reset <= (resetn == 0 && data_reg == 'd0);
end

always@(posedge b_tick)begin
  if (b_reg == 15 && current_state == data_st) begin
    rx_prev = rx;
  end
end
  
  property check_rx_1; 
    @(posedge b_tick) disable iff (current_state != idle_st) 
      rx == 1;
endproperty
assert_check_rx_1: assert property (check_rx_1)
else $error("Error: incorrect rx1 sequenced");
/////////

  property check_rx_2; 
    @(posedge b_tick) disable iff (current_state != start_st) 
    rx == 0;
endproperty 
assert_check_rx_2: assert property (check_rx_2)
else $error("Error: incorrect rx2 sequenced");
////////

  property check_rx_3; 
    @(posedge b_tick) disable iff (current_state != stop_st) 
    rx == 1;
endproperty 
assert_check_rx_3: assert property (check_rx_3)
else $error("Error: incorrect rx3 sequenced");
///////

  property check_rx_4; 
    @(posedge b_tick) disable iff (current_state != data_st) 
    ##1 rx_prev == data_reg [8];
endproperty 
assert_check_rx_4: assert property (check_rx_4)
else $error("Error: incorrect rx4 sequenced");



endmodule


//check behaviour
//If count_next ==0,then don't check the data_reg as this is leftover from the previous communication 
//Also need to check the last bit in the stop state

// property check_rx;
//   @(posedge b_tick)
//     ( (current_state == idle_st && rx == 1) || (current_state == start_st && rx == 0) || (current_state == stop_st && rx == 1) ) == 1
//     // (current_state == data_st && count_next != 0 && rx_prev == data_reg [8]) 
// endproperty
// assert_check_tx: assert property (check_rx)
//   else $error ("Error: incorrect rx sequence");

  // check_result: assert property(
  //                             @(posedge b_tick) disable iff(count_next == 0 && current_state == data_st)
  //                              rx_prev == data_reg [8]
  //                             );