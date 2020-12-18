interface uart_tx_if(input bit clk);

    logic resetn;
    logic tx_start;
    logic b_tick ; //Simulate Baud Generator first and then implement 
    logic [7:0] d_in;
    logic tx_done;
    logic tx;
    logic PARITY_SEL;

    modport TB( input clk, output resetn,
        output tx_start, output b_tick,
        output d_in, input tx_done,
        input tx, output PARITY_SEL );
endinterface

class input_generator;
    randc logic [8:0] tx_input;
    rand bit PARITYSEL;
endclass
`include "uart_tx_model.sv"
module uart_tx_tb(uart_tx_if.TB uartif);

    logic [18:0] count_reg;
    logic baud_tick;
    parameter [18:0] count = 19'd13; // Baud rate of 110, but 16* that so 1760
    logic parity_bit;
    uart_tx_model tx0;
    bit model_tx;
    bit model_tx_done;
    input_generator ig0;

    initial 
    begin
        tx0 = new();
        fork
            begin
                forever #1 begin
                    tx0.run(uartif.d_in, model_tx, uartif.clk, uartif.PARITY_SEL, uartif.resetn, uartif.tx_start, uartif.b_tick, model_tx_done );
                    
                end
            end
            begin forever begin
                @(posedge uartif.clk);
                tx0.clk_edges( uartif.resetn);
            end
            end
            begin
                forever #1 begin
                    if(model_tx != uartif.tx) 
                        $error("They two uarts are not matching");
                end
                
            end
        join_none

        ig0 = new();
        uartif.resetn <= 1'b0;
        count_reg <= 19'd0;
        #30 uartif.resetn <= 1'b1; 
        for(int i = 0 ; i < 100 ; i++ )begin
            ig0.randomize();
            count_reg <= 'd0;
            uartif.d_in <= ig0.tx_input;
            uartif.PARITY_SEL <= ig0.PARITYSEL;
            #20 begin
            uartif.tx_start <= 1'b1;
            end
            #20 uartif.tx_start <= 1'b0;

            for(int j =0; j<11;j++) begin
                @(posedge uartif.b_tick)
                case (j) inside
                    0:
                    begin
                        if(uartif.tx == 1'b0)begin
                            $display("The start state is working");
                        end
                        else
                            $error("The start state isn't working");
                    end
                    [1:8]: 
                    begin
                        if(uartif.tx == uartif.d_in[j-1])begin
                            $display("The data state is working");
                        end
                        else
                            $error("The data state isn't working");
                    end
                    9:
                    begin
                        if(uartif.PARITY_SEL)
                            parity_bit = ~(^uartif.d_in);
                        else
                            parity_bit = (^uartif.d_in);
                        if(uartif.tx == parity_bit)begin
                            $display("The parity state is working");
                        end
                        else
                            $error("The partity state isn't working");
                    end
                    10:
                    begin
                        if(uartif.tx == 1)begin
                            $display("The stop state is working");
                        end
                        else
                            $error("The stop state isn't working");
                        break;
                    end
                endcase 
                for(int k =0; k<15; k++)begin
                    if(j!=10)
                        @(posedge uartif.b_tick)
                                #20;
                end
            end
            @(posedge uartif.tx_done) begin
                #1000
                $display("The serial data has been sent");
            end
        end
        // uartif.PARITY_SEL <= 1'b1; //Odd
        // for(int i = 0 ; i < 100 ; i++ )begin
        //     ig0.randomize();

        //     count_reg <= 'd0;
        //     #20 begin
        //     uartif.d_in <= ig0.tx_input;
        //     uartif.tx_start <= 1'b1;
        //     end
        //     #20 uartif.tx_start <= 1'b0;
        //     for(int j =0; j<11;j++) begin
        //         @(posedge uartif.b_tick)
        //         case (j) inside
        //             0:
        //             begin
        //                 if(uartif.tx == 1'b0)begin
        //                     $display("The start state is working");
        //                 end
        //                 else
        //                     $error("The start state isn't working");
        //             end
        //             [1:8]: 
        //             begin
        //                 if(uartif.tx == uartif.d_in[j-1])begin
        //                     $display("The data state is working");
        //                 end
        //                 else
        //                     $error("The data state isn't working");
        //             end
        //             9:
        //             begin
        //                 parity_bit = !(^uartif.d_in);

        //                 if(uartif.tx == parity_bit)begin
        //                     $display("The parity state is working");
        //                 end
        //                 else
        //                     $error("The partity state isn't working");
        //             end
        //             10:
        //             begin
        //                 if(uartif.tx == 1)begin
        //                     $display("The stop state is working");
        //                 end
        //                 else
        //                     $error("The stop state isn't working");
        //                 break;
        //             end
        //         endcase 
        //         for(int k =0; k<15; k++)begin
        //             if(j!=10)
        //                 @(posedge uartif.b_tick)
        //                         #20;
        //         end
        //     end
        //     @(posedge uartif.tx_done) begin
        //         #1000
        //         $display("The serial data has been sent");
        //     end
        // end
        $finish;
    end
    always@(posedge uartif.clk)
    begin
        if(count_reg == count) begin
            baud_tick <= 1'b1;
            count_reg <= 'd0;
        end
        else begin 
            count_reg <= count_reg + 1'b1;
            baud_tick <= 1'b0;
        end
    end
    assign uartif.b_tick = baud_tick;


endmodule

module uart_tx_tb_top;
bit clk;
initial begin
    clk = 0 ; 
    forever #10 clk = !clk;
end

uart_tx_if if0(clk);
uart_tx_tb tb0(if0);
UART_TX uart0(.clk(clk),
            .resetn(if0.resetn),
            .tx_start(if0.tx_start),
            .b_tick(if0.b_tick),
            .d_in(if0.d_in),
            .tx_done(if0.tx_done),
            .tx(if0.tx),
            .PARITYSEL(if0.PARITY_SEL));
endmodule

