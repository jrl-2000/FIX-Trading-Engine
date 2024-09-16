`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jonathan Lopez
// 
// Create Date: 08/28/2024 08:49:24 PM
// Design Name: FIX 4.4 Parser testbench
// Module Name: parser_tb
// Project Name: FIX Trading from Home 4.4
// Target Devices: Digilent Nexys A7 Development Board Artix-7 FPGA
// XC7A100TCSG324-1
// Tool Versions: AMD / Xilinx Vivado 2023.2
// Description: Testbench module for the Parsing module to decode ASCII FIX message recieved via Ethernet
// 
// Dependencies: 
// parser.v
// Revision: 0.0.1
// Revision 0.0.1 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module parser_tb(
    );

reg clk = 1'b1;
reg rst = 1'b0;
reg [11999:0] data_in;
reg start = 1'b0;

wire done;

// 500MHz Test CLK
// Simulate CLK
always #1
clk = ~clk;

// Instantiate the DUT
parser DUT(
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .done(done)
);


initial begin
    // Powert On Reset
    rst = 1'b0;
    #2;
    rst = 1'b1;
    #2;
    rst = 1'b0;
    #2;
    data_in[11999:10487] = 1512'h383D4649582E342E3401393D3136360133353D360133343D3134360134393D50455246444C5230370135303D70657266646C7230370135323D32303234303732342D31323A33363A30372E3836350135363D4445564F445452554D49440132323D310132333D310132373D3530303030300132383D4E0134383D34393137374A4152330135343D320135353D5B4E2F415D013231353D31013231363D32013231373D414C4C013231383D39382E3131013432333D360131303D30303801;
    start = 1'b1;
    #2;
    start = 1'b0;
    #2;



end


endmodule
