`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2026 11:00:30 AM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(
    
    parameter CLK_FREQ = 100_000_000, // 100 MHz
    parameter BAUD_RATE = 115_200
)(
    input wire clk,
    input wire rst, 
    input wire [7:0] tx_data,
    input wire tx_start,
    output reg tx_pin,
    output reg tx_busy
    );
    
    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    // Srare machine states
    localparam IDLE = 0, START = 1, DATA = 2, STOP=3;
    reg [1:0] state = IDLE;
    reg [15:0] count = 0;
    reg [2:0] bit_idx = 0;
    reg [7:0] shift_reg = 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_pin <= 1;
            tx_busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_pin <= 1;
                    tx_busy <= 0;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        state <= START;
                        tx_busy <= 1;
                    end
                 end
                 START: begin
                     tx_pin <= 0;
                     if (count < CLK_PER_BIT - 1) count <= count + 1;
                     else begin count <= 0; state <= DATA; end
                 end
                 DATA: begin
                     tx_pin <= shift_reg[bit_idx];
                     if (count < CLK_PER_BIT - 1) count <= count + 1;
                     else begin
                         count <= 0;
                         if (bit_idx < 7) bit_idx <= bit_idx + 1;
                         else begin bit_idx <= 0; state <= STOP; end
                     end
                 end
                 STOP: begin
                     tx_pin <= 1; // Stop bit
                     if (count < CLK_PER_BIT - 1) count <= count + 1;
                     else begin count <= 0; state <= IDLE; end
                 end
             endcase
         end 
     end
endmodule 