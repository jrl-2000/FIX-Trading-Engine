`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jonathan Lopez
// 
// Create Date: 08/03/2024 01:43:00 PM
// Design Name: FIX 4.4 Protcol 
// Module Name: parser
// Project Name: FIX 4.4 Trading from Home
// Target Devices: Digilent Nexys A7 Development Board Artix-7 FPGA
// XC7A100TCSG324-1
// Tool Versions: Vivado 2023.2
// Description: Parsing module to decode ASCII FIX message recieved via Ethernet
// 
// Dependencies: 
// 
// Revision: 0.0.1
// Revision 0.0.1 - File Created
// Additional Comments:
// FIX messages are sent in ASCII characters. In order to parse the messages we need to convert them to hexidecimal.
// All characters that appear in FIX are on the ASCII or Extended ASCII table. Each character corresponds to 2 hexidencimal characters
// This how they are tramsitted through PCI-e, Ethernet (which is what I will use), or another high frequency communication protocol.
//////////////////////////////////////////////////////////////////////////////////

module parser(
    input clk,
    input rst,
    input start,
    input [11999:0] data_in, // One Ethernet Frame can contain 1500 Bytes. Multiply by 8 to get 12000 Bits
    output [15:0] TAG_35_MSG_OUT,
    output reg PROCESS_ENABLE_35,
    output done
);

// SOH (Star of Header) character for parsing FIX messages 
// ASCII for SOH is 0x01
localparam SOH = 8'h01;

localparam C_BUILD_VERSION = 16'h0001;

localparam C_BIT_COUNT = 11918;

// Tag 8 tells us the version of FIX we are using.
// Message Header in ASCII Hexidecimal
// "8=FIX.4.4"
localparam FIX_VER_4P4 = 80'h38_3D_46_49_58_2E_34_2E_34_01;
localparam SUM_TAG_8_4P4 = 545;

// "8=FIX4.2"
localparam FIX_VER_4P2 = 80'h38_3D_46_49_58_2E_34_2E_32_01;
localparam SUM_TAG_8_4P2 = 543;

// "8=FIX5.0"
localparam FIX_VER_5P0 = 80'h38_3D_46_49_58_2E_35_2E_30_01;
localparam SUM_TAG_8_5P0 = 542;

// "10="
localparam FIX_TAG_10 = 24'h31_30_3D;
localparam SIZE_24_BYTES = 24;

// "9="
localparam FIX_TAG_9 = 16'h39_3D;
localparam SIZE_16_BYTES = 16;

// "34="
localparam FIX_TAG_34 = 24'h31_34_3D;

// "35="
localparam FIX_TAG_35 = 24'h31_35_3D;

// "49="
localparam FIX_TAG_49 = 24'h34_39_3D;

// "50="
localparam FIX_TAG_50 = 24'h35_30_3D;

// State Machine for parsing Message
integer state = 0;
integer next_state = 0;

localparam ST_IDLE = 0;
localparam ST_PARSE = 1;
localparam ST_CHEKSUM = 2;
localparam ST_DONE = 3;

// Integers
integer BIT_COUNT = 11918;
integer BIT_COUNT_9;
integer BIT_COUNT_34;
integer BIT_COUNT_35;
integer BIT_COUNT_49;
integer BIT_COUNT_50;

integer MSG_LENGTH = 0;

integer CHECKSUM = 0;
integer  TAG_34_SEQ_NUM;

// Registers
reg [11999:0] data;

reg [23:0] TAG_10_MSG = 24'd0;
reg [23:0] TAG_9_MSG = 24'd0;
reg [15:0] TAG_35_MSG = 16'h0000;

reg [63:0] TAG_34_MSG = 64'd0;
reg [23:0] TAG_49_MSG = 24'd0;
reg [23:0] TAG_50_MSG = 24'd0;

reg [11:0] CHECKSUM_MOD_256 = 12'h000;
reg [11:0] CHECKSUM_MSG = 12'h000;
reg [3:0] CHECKSUM_MSG_0 = 4'h0;
reg [3:0] CHECKSUM_MSG_1 = 4'h0;
reg [3:0] CHECKSUM_MSG_2 = 4'h0;

reg [11:0] MSG_LENGTH_REG = 12'h000;
reg [3:0] MSG_LENGTH_0 = 4'h0;
reg [3:0] MSG_LENGTH_1 = 4'h0;
reg [3:0] MSG_LENGTH_2 = 4'h0;


// Flags
reg verified_flag = 1'b0;
reg FOUND_TAG_10 = 1'b0;
reg FOUND_TAG_9 = 1'b0;
reg FOUND_TAG_35 = 1'b0;
reg FOUND_TAG_34 = 1'b0;
reg FOUND_TAG_49 = 1'b0;
reg FOUND_TAG_50 = 1'b0;

reg EN_TAG_35 = 1'b0;
reg EN_TAG_34 = 1'b0;
reg EN_TAG_49 = 1'b0;
reg EN_TAG_50 = 1'b0;


reg [7:0] TAG_34_PLACES;
reg ONES_34 = 1'b0;
reg TENS_34 = 1'b0;
reg HUNDREDS_34 = 1'b0;
reg THOUSNADS_34 = 1'b0;
reg TEN_THOUSNDS_34 = 1'b0;
reg HUNDRED_THOUSNDS_34 = 1'b0;
reg MILLION_34 = 1'b0;
reg TEN_MILLIONS_34 = 1'b0;

reg CHECKSUM_VERIFIED = 1'b0;
reg MSG_LENGTH_VERIFIED = 1'b0;

reg PROCESS_ENABLE_34 = 1'b0;

// Check for first 10 characters for Tag 8: The FIX version:
// and finally the SOH character
always @(data_in) begin
    if (data_in[11999:11919] == FIX_VER_4P4) begin
        data <= data_in;
        verified_flag = 1'b1;
        CHECKSUM = SUM_TAG_8_4P4;
        BIT_COUNT_9 <= C_BIT_COUNT;
        BIT_COUNT_35 <= C_BIT_COUNT;
        BIT_COUNT_34 <= C_BIT_COUNT;
        BIT_COUNT_49 <= C_BIT_COUNT;
        BIT_COUNT_50 <= C_BIT_COUNT;

    end
    else if (data_in[11999:11919] == FIX_VER_4P2) begin
        data <= data_in;
        verified_flag = 1'b1;
        CHECKSUM = SUM_TAG_8_4P2;
    end
    else begin
        verified_flag = 1'b0;
    end
end

// Always Block for Tag 9: Message length
always @(posedge clk, verified_flag) begin
    if (verified_flag) begin
        if (data[BIT_COUNT_9 -: SIZE_16_BYTES] != FIX_TAG_9) begin
            BIT_COUNT_9 <= BIT_COUNT_9 - 8;
        end
        else begin
            FOUND_TAG_9 <= 1'b1;
            @(posedge clk);
            EN_TAG_35 <= 1'b1;
             // Take the Tag 9 Value
            TAG_9_MSG <= data[BIT_COUNT_9 - SIZE_16_BYTES -: SIZE_24_BYTES];
            @(posedge clk);
            // Convert from ASCII subrtacting 0x30 to get into decimal
            MSG_LENGTH_2 <= TAG_9_MSG[23:16] - 8'h30;
            MSG_LENGTH_1 <= TAG_9_MSG[15:8] - 8'h30;
            MSG_LENGTH_0 <= TAG_9_MSG[7:0] - 8'h30;
            // Concatenate back in to 12-bit register to compare
            @(posedge clk);
            MSG_LENGTH_REG <= MSG_LENGTH_2 * 100 + MSG_LENGTH_1 * 10 + MSG_LENGTH_0;
            FOUND_TAG_9 <= 1'b0;
        end      
    end
end

// Always Block for Tag 35
// Large LUT Module
always @(posedge clk, verified_flag) begin
    if  (verified_flag) begin
        if (data[BIT_COUNT_35 -: SIZE_24_BYTES] != FIX_TAG_35) begin
            BIT_COUNT_35 <= BIT_COUNT_35 - 8;
        end
        else begin
            FOUND_TAG_35 <= 1'b1;
            //EN_TAG_34 <= 1'b1;
            if (data[BIT_COUNT_35 - SIZE_24_BYTES -: 8] != SOH) begin
                TAG_35_MSG[15:8] <= data_in[BIT_COUNT_35 - SIZE_24_BYTES -: 8];
            end
            @(posedge clk);            
            if (data[BIT_COUNT_35 - 32 -: 8] != SOH) begin
                TAG_35_MSG[15:8] <= data_in[BIT_COUNT_35 - 32 -: 8];
            end
            PROCESS_ENABLE_35 <= 1'b1;
        end
    end
end

// Always Block for Tag 34
always @(posedge clk, verified_flag) begin
    if  (verified_flag) begin
        if (data[BIT_COUNT_34 -: SIZE_24_BYTES] != FIX_TAG_34) begin
            BIT_COUNT_34 <= BIT_COUNT_34 - 8;
        end
        else begin
            FOUND_TAG_34 <= 1'b1;
            TAG_34_MSG[63:56] <= data_in[BIT_COUNT_34 - SIZE_24_BYTES -: 8];
            ONES_34 <= 1'b1;
            if (data[BIT_COUNT_34 - 32 -: 8] != SOH) begin
                TAG_34_MSG[55:48] <= data_in[BIT_COUNT_34 - 32 -: 8];
                TENS_34 <= 1'b1;
            end
            else begin
                PROCESS_ENABLE_34 <= 1'b1;
            end
            @(posedge clk);            
            if ((data[BIT_COUNT_34 - 40 -: 8] != SOH) && (!PROCESS_ENABLE_34)) begin
                TAG_34_MSG[47:40] <= data_in[BIT_COUNT_34 - 40 -: 8];
                HUNDREDS_34 <= 1'b1;
            end
            else begin
                PROCESS_ENABLE_34 <= 1'b1;
            end
            @(posedge clk);            
            if ((data[BIT_COUNT_34 - 48 -: 8] != SOH) && (!PROCESS_ENABLE_34)) begin
                TAG_34_MSG[39:32] <= data_in[BIT_COUNT_34 - 48 -: 8];
                THOUSNADS_34 <= 1'b1;
            end
            else begin
                PROCESS_ENABLE_34 <= 1'b1;
            end
            @(posedge clk);            
            if ((data[BIT_COUNT_34 - 56 -: 8] != SOH) && (!PROCESS_ENABLE_34)) begin
                TAG_34_MSG[31:24] <= data_in[BIT_COUNT_34 - 56 -: 8];
                TEN_THOUSNDS_34 <= 1'b1;
            end
            else begin
                PROCESS_ENABLE_34 <= 1'b1;
            end
            @(posedge clk);
            if ((data[BIT_COUNT_34 - 64 -: 8] != SOH) && (!PROCESS_ENABLE_34)) begin
                TAG_34_MSG[23:16] <= data_in[BIT_COUNT_34 - 64 -: 8];
                HUNDRED_THOUSNDS_34 <= 1'b1;
            end
            else begin
                PROCESS_ENABLE_34 <= 1'b1;
            end
            @(posedge clk);
            if ((data[BIT_COUNT_34 - 72 -: 8] != SOH) && (!PROCESS_ENABLE_34)) begin
                TAG_34_MSG[15:8] <= data_in[BIT_COUNT_34 - 72 -: 8];
                MILLION_34 <= 1'b1;
            end
            else begin
                PROCESS_ENABLE_34 <= 1'b1;
            end
            @(posedge clk);
            if ((data[BIT_COUNT_34 - 80 -: 8] != SOH) && (!PROCESS_ENABLE_34)) begin
                TAG_34_MSG[7:0] <= data_in[BIT_COUNT_34 - 80 -: 8];
                TEN_MILLIONS_34 <= 1'b1;
                PROCESS_ENABLE_34 <= 1'b1;
            end
            else begin
                PROCESS_ENABLE_34 <= 1'b1;
            end
        end
    end
end

// Always Blcok for caluclating Tag 34 value based on on the flags for Ones through ten of millions. This will cause an overflow if Ten of millions is thrown. only up to millions used. IF 32-bit
always @(posedge PROCESS_ENABLE_34) begin
    TAG_34_PLACES <= {TEN_MILLIONS_34, MILLION_34, HUNDRED_THOUSNDS_34, TEN_THOUSNDS_34, THOUSNADS_34, HUNDREDS_34, TENS_34, ONES_34};
    case (TAG_34_PLACES)
        8'b0000_0001: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56];                      
        end
        8'b0000_0011: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56] * 10 + TAG_34_MSG[55:48];
        end
        8'b0000_0111: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56] * 100 + TAG_34_MSG[55:48] * 10 + TAG_34_MSG[47:40];
        end
        8'b0000_1111: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56] * 1000 + TAG_34_MSG[55:48] * 100 + TAG_34_MSG[47:40] * 10 + TAG_34_MSG[39:32];
        end
        8'b0001_1111: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56] * 10000 + TAG_34_MSG[55:48] * 1000 + TAG_34_MSG[47:40] * 100 + TAG_34_MSG[39:32] * 10 + TAG_34_MSG[31:23];
        end
        8'b0011_1111: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56] * 100000 + TAG_34_MSG[55:48] * 10000 + TAG_34_MSG[47:40] * 1000 + TAG_34_MSG[39:32] * 100 + TAG_34_MSG[31:24] * 10 + TAG_34_MSG[23:16];    
        end
        8'b0111_1111: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56] * 1000000 + TAG_34_MSG[55:48] * 100000 + TAG_34_MSG[47:40] * 10000 + TAG_34_MSG[39:32] * 1000 + TAG_34_MSG[31:24] * 100 + TAG_34_MSG[23:16] * 10 + TAG_34_MSG[15:8]; 
        end
        8'b1111_1111: begin
            TAG_34_SEQ_NUM <= TAG_34_MSG[63:56] * 10000000 + TAG_34_MSG[55:48] * 1000000 + TAG_34_MSG[47:40] * 100000 + TAG_34_MSG[39:32] * 10000 + TAG_34_MSG[31:24] * 1000 + TAG_34_MSG[23:16] * 100 + TAG_34_MSG[15:8] * 10 + TAG_34_MSG[7:0]; 
        end
        //default: 
    endcase
end

// Always Block for Updating State Machine
always @(posedge clk) begin
    if (rst) begin
        state <= ST_IDLE;
    end
    else begin
        state <= next_state;
    end
end

// Always Block for transversing the state machine
always @(posedge clk, state, start, verified_flag) begin
    next_state <= state;
    case (state)
        ST_IDLE: begin
            if (verified_flag && start) begin
                // Clear FLags
                FOUND_TAG_10 <= 1'b0;
                CHECKSUM_VERIFIED <= 1'b0;
                MSG_LENGTH_VERIFIED <= 1'b0;
                MSG_LENGTH <= 0;
                next_state <= ST_PARSE;
            end
        end
        ST_PARSE: begin
            verified_flag <= 1'b0;

            // Parse through the big register and add for Checksum. 
            // Ethernet is MSB First. If it finds Tag 10, then transitions to Calculate Checksum

            if (data[BIT_COUNT -: SIZE_24_BYTES] != FIX_TAG_10) begin
                CHECKSUM <= CHECKSUM + data[BIT_COUNT -: 8];
                BIT_COUNT <= BIT_COUNT - 8;
                MSG_LENGTH <= MSG_LENGTH + 1'b1;
            end
            else begin
                FOUND_TAG_10 <= 1'b1;
                // Get rid of Tag 9 two times
                MSG_LENGTH <= MSG_LENGTH - 3;
                next_state <= ST_CHEKSUM;
            end
        end
        ST_CHEKSUM: begin
           
            // Calculate the Checksum
            // Mod 256
            CHECKSUM_MOD_256 <= CHECKSUM % 256;

            // Take the Tag 10 Value
            TAG_10_MSG <= data[BIT_COUNT - SIZE_24_BYTES -: SIZE_24_BYTES];

            // Convert from ASCII subrtacting 0x30 to get into decimal
            CHECKSUM_MSG_2 <= TAG_10_MSG[23:16] - 8'h30;
            CHECKSUM_MSG_1 <= TAG_10_MSG[15:8] - 8'h30;
            CHECKSUM_MSG_0 <= TAG_10_MSG[7:0] - 8'h30;

            // Concatenate back in to 12-bit register to compare
            CHECKSUM_MSG <= CHECKSUM_MSG_2 * 100 + CHECKSUM_MSG_1 * 10 + CHECKSUM_MSG_0;

            // Compare, Throw Flag, and Transition to Done State
            if ((CHECKSUM_MSG == CHECKSUM_MOD_256) && (MSG_LENGTH_REG == MSG_LENGTH)) begin
                CHECKSUM_VERIFIED <= 1'b1;
                MSG_LENGTH_VERIFIED <= 1'b1;
                next_state <= ST_DONE;
            end
        end
        ST_DONE: begin
            if (CHECKSUM_VERIFIED && MSG_LENGTH_VERIFIED) begin
                next_state <= ST_IDLE;
            end
        end
    endcase
end

assign done = (state == ST_DONE || ST_IDLE) ? 1'b1 : 1'b0;

endmodule