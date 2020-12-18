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


module AHBUART(
  //AHB Signals
  input wire         HCLK,
  input wire         HRESETn,
  input wire  [31:0] HADDR,
  input wire  [1:0]  HTRANS,
  input wire  [31:0] HWDATA,
  input wire         HWRITE,
  input wire         HREADY,
  
  output wire        HREADYOUT,
  output wire [31:0] HRDATA,
  
  input wire         HSEL,
  
  //Serial Port Signals
  input wire         RsRx,  //Input from RS-232
  output wire        RsTx,  //Output to RS-232
  //UART Interrupt
  
  output wire uart_irq  //Interrupt
);

//Internal Signals

  
  //Data I/O between AHB and FIFO
  wire [7:0] uart_wdata;  
  wire [7:0] uart_rdata;
  
  //Signals from TX/RX to FIFOs
  wire uart_wr;
  wire uart_rd;
  
  //wires between FIFO and TX/RX
  wire [7:0] tx_data;
  wire [7:0] rx_data;
  wire [31:0] status;

  //
  
  //FIFO Status
  wire tx_full;
  wire tx_empty;
  wire rx_full;
  wire rx_empty;
  
  //UART status ticks
  wire tx_done;
  wire rx_done;
  
  //baud rate signal
  wire b_tick;
  
  //parity type
  //0 - even
  //

  //parity checker wires
  wire [15:0] ERRCOUNTER;
  wire RxParity; 
  wire TxParity ; //Change if you want 
  //AHB Regs
  reg [1:0] last_HTRANS;
  reg [31:0] last_HADDR;
  reg last_HWRITE;
  reg last_HSEL;
  
  //Baud Rate register 
  reg [3:0] Baud_Reg = 'd0;
  wire baudrate_wr;
  
  //pretend Rx ;
  wire Tx_RS_232;
  wire Rx_RS_232;
//Set Registers for AHB Address State
  always@ (posedge HCLK)
  begin
    if(HREADY)
    begin
      last_HTRANS <= HTRANS;
      last_HWRITE <= HWRITE;
      last_HSEL <= HSEL;
      last_HADDR <= HADDR;
    end
    if(baudrate_wr) Baud_Reg <= HWDATA[3:0]; //If the address is to 01 then, write to the baud rate register
  end
  

assign TxParity = 1'b0;

  //If Read and FIFO_RX is empty - wait.
  assign HREADYOUT = ~tx_full;
   
  //UART  write select
  assign uart_wr = last_HTRANS[1] & last_HWRITE & last_HSEL& (last_HADDR[7:0]==8'h00);

  assign baudrate_wr = last_HTRANS[1] & last_HWRITE & last_HSEL& (last_HADDR[7:0]==8'h10);
  //Only write last 8 bits of Data
  assign uart_wdata = HWDATA[7:0];

  //UART read select
  assign uart_rd = last_HTRANS[1] & ~last_HWRITE & last_HSEL & (last_HADDR[7:0]==8'h00);
  
  assign HRDATA = (last_HADDR[7:0]==8'h00) ? {24'h0000_00,uart_rdata}: status;
  assign status = {ERRCOUNTER,6'b000000,tx_full,rx_empty};
  
  assign uart_irq = ~rx_empty; 
  
  BAUDGEN uBAUDGEN(
    .clk(HCLK),
    .resetn(HRESETn),
    .set_baud(Baud_Reg),
    .baudtick(b_tick)
  );
  monitor_top mt0(
    .clk(HCLK),
    .Tx_parity(1'b0),
    .HRESETn(HRESETn),
    .ERRCOUNTER(ERRCOUNTER),
    .Tx_RS_232(Tx_RS_232),
    .Rx_RS_232(Rx_RS_232),
    .Baud_Reg(Baud_Reg),
    .Rx_parity(Rxparity)
  );
  //Transmitter FIFO
  FIFO  
   #(.DWIDTH(8), .AWIDTH(4))
	uFIFO_TX 
  (
    .clk(HCLK),
    .resetn(HRESETn),
    .rd(tx_done),
    .wr(uart_wr),
    .w_data(uart_wdata[7:0]),
    .empty(tx_empty),
    .full(tx_full),
    .r_data(tx_data[7:0])
  );
  
  //Receiver FIFO
  FIFO 
   #(.DWIDTH(8), .AWIDTH(4))
	uFIFO_RX(
    .clk(HCLK),
    .resetn(HRESETn),
    .rd(uart_rd),
    .wr(rx_done),
    .w_data(rx_data[7:0]),
    .empty(rx_empty),
    .full(rx_full),
    .r_data(uart_rdata[7:0])
  );
  
  //UART receiver
  UART_RX uUART_RX(
    .clk(HCLK),
    .resetn(HRESETn),
    .b_tick(b_tick),
    .rx(Rx_RS_232),
    .rx_done(rx_done),
    .dout({RxParityBit,rx_data[7:0]})
  );
  
  parity_check_top pc0(
    .d_in({RxParityBit,rx_data[7:0]}),
    .PARITYSEL(Rxparity),
    .resetn(HRESETn),
    .ERRCOUNTER(ERRCOUNTER),
    .start(rx_done)
  );

  //UART transmitter
  UART_TX uUART_TX(
    .clk(HCLK),
    .resetn(HRESETn),
    .tx_start(!tx_empty),
    .b_tick(b_tick),
    .d_in(tx_data[7:0]),
    .tx_done(tx_done),
    .tx(Tx_RS_232),
    .PARITYSEL(1'b0)
  );
 
  
  
endmodule
