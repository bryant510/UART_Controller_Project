`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2026 11:44:16 AM
// Design Name: 
// Module Name: tb_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_uart;
    reg clk = 0;
    reg rst = 0;
    reg [7:0] tx_data = 0;
    reg tx_start = 0;
    wire tx_pin;
    wire tx_busy;
    
    // Instantiate transmitter
    uart_tx #(.CLK_FREQ(1000000), .BAUD_RATE(115200)) uut (
        .clk(clk), .rst(rst), .tx_data(tx_Data),
        .tx_start(tx_start), .tx_pin(tx_pin), .tx_busy(tx_busy));
        
    always #5 clk = ~clk; // 100 MHz clock
    
    initial begin 
        rst = 1; #20; rst = 0;
        #100;
        tx_data = 8'h41; // Send 'A'
        tx_start = 1;
        #10 tx_start = 0;
        wait(!tx_busy);
        #500 $finish;
    end
endmodule