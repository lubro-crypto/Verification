//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT ("LICENCE") IS A LEGAL AGREEMENT BETWEEN      //
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

module BAUDGEN
(
  input wire clk,
  input wire resetn,
  input wire [3:0] set_baud,
  output wire baudtick
);
/*
110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 128000 and 256000
bits per second 
18bits per sample
*/

parameter [265:0] Counts_Array = { 19'd28410, 19'd10417, 19'd5209, 19'd2605, 19'd1303, 19'd652, 19'd326, 19'd218, 19'd162, 19'd82, 19'd55, 19'd28, 19'd25, 19'd13};
reg [18:0] count_reg;
wire [18:0] count_next;
wire [18:0] count;
wire [3:0] index;

initial 
  begin
    count_reg <= 0;
  end
//Counter
always @ (posedge clk, negedge resetn)
  begin
    if(!resetn)begin
      count_reg <= 0;
    end
    else
      count_reg <= count_next;
end

assign index = 'd13 - set_baud;

assign count = Counts_Array[index*19+:256];

assign count_next = ((count_reg == count) ? 0 : count_reg + 1'b1);

assign baudtick = ((count_reg == count && resetn == 1) ? 1'b1 : 1'b0);

property check_count_reg;
@(posedge clk) disable iff (!resetn)
if(count_reg == count && resetn == 1'b1)
    baudtick == 1;
endproperty

assert_check_count_reg: assert property (check_count_reg)
    else $error("tick gone high when count reg != count");
////////////////////////////////////



///////////////////////////////////////////////////////////////////////////

reg [18:0] counter = 1'b0;

always @(posedge clk, negedge resetn)
  if(!resetn)
    counter = 'd0;
  else if (baudtick != 1'b1 ) begin
    counter = counter + 1;
  end
  else counter = 0;

property count_clock_cycles_between_tick;
@(negedge baudtick)
  count == counter;
endproperty 

assert_count_clock_cycles_between_tick: assert property (count_clock_cycles_between_tick)
    else  $error("counter false");

endmodule







