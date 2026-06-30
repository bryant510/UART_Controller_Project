module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200
)(
    input wire clk,
    input wire rst,
    input wire rx_pin,
    output reg [7:0] rx_data,
    output reg rx_valid // Goes high for one clock cycle when data is ready
);

    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    // State machine
    reg [1:0] state = 0; // 0: IDLE, 1: START, 2: DATA, 3: STOP
    reg [15:0] count = 0;
    reg [2:0] bit_idx = 0;
    reg [7:0] shift_reg = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            rx_valid <= 0;
        end else begin
            rx_valid <= 0;
            case (state)
                0: begin // IDLE
                    if (rx_pin == 0) begin // Wait for Start Bit
                        state <= 1;
                        count <= 0;
                    end
                end
                1: begin // START BIT
                    if (count == CLK_PER_BIT / 2) begin // Sample middle
                        if (rx_pin == 0) state <= 2;
                        else state <= 0;
                        count <= 0;
                    end else count <= count + 1;
                end
                2: begin // DATA BITS
                    if (count == CLK_PER_BIT - 1) begin
                        shift_reg[bit_idx] <= rx_pin;
                        count <= 0;
                        if (bit_idx == 7) begin
                            state <= 3;
                            bit_idx <= 0;
                        end else bit_idx <= bit_idx + 1;
                    end else count <= count + 1;
                end
                3: begin // STOP BIT
                    if (count == CLK_PER_BIT - 1) begin
                        rx_data <= shift_reg;
                        rx_valid <= 1;
                        state <= 0;
                    end else count <= count + 1;
                end
            endcase
        end
    end
endmodule