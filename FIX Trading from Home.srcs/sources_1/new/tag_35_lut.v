`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jonathan Lopez
// 
// Create Date: 08/03/2024 01:43:00 PM
// Design Name: FIX 4.4 Protcol 
// Module Name: tag_35_lut
// Project Name: FIX 4.4 Trading from Home
// Target Devices: Digilent Nexys A7 Development Board Artix-7 FPGA
// XC7A100TCSG324-1
// Tool Versions: Vivado 2023.2
// Description: Look-Up-Table for Tag 35
// 
// Dependencies: 
// 
// Revision: 0.0.1
// Revision 0.0.1 - File Created
// Additional Comments:
// Tag 35 has 182 options Ranging from 0 to EP. This module brings in a 16-bit ASCII value of Tag 35 and decodes it.
// If Tag 35 is just 1 ASCII character, the lower 8-bits are ignored as the Parser module found the SOH (0x01 to mark the end of Tag 35 in the bit stream)
//////////////////////////////////////////////////////////////////////////////////


module tag_35_lut(
    input TAG_35_MSG[15:0],
    input PROCESS_ENABLE,
    output done_LUT_35
);


// There are 182 COmbinations of Tag 35
always @(posedge PROCESS_ENABLE, TAG_35_MSG) begin
    if (PROCESS_ENABLE) begin
        case (TAG_35_MSG)
            // Error
            16'h0000: begin
            end
            // heartbeat
            // 0-9
            16'h3000: begin
            end
            16'h3100: begin
            end
            16'h3200: begin
            end
            16'h3300: begin
            end
            16'h3400: begin
            end
            16'h3500: begin
            end
            16'h3600: begin
            end
            16'h3700: begin
            end
            16'h3800: begin
            end
            16'h3900: begin
            end

            // Capital A-Z
            16'h4100: begin
            end
            16'h4200: begin
            end
            16'h4300: begin
            end
            16'h4400: begin
            end
            16'h4500: begin
            end
            16'h4600: begin
            end
            16'h4700: begin
            end
            16'h4800: begin
            end
            16'h4900: begin
            end
            16'h4A00: begin
            end
            16'h4B00: begin
            end
            16'h4C00: begin
            end
            16'h4D00: begin
            end
            16'h4E00: begin
            end
            16'h4F00: begin
            end
            16'h5000: begin
            end
            16'h5100: begin
            end
            16'h5200: begin
            end
            16'h5300: begin
            end
            16'h5400: begin
            end
            16'h5500: begin
            end
            16'h5600: begin
            end
            16'h5700: begin
            end
            16'h5800: begin
            end
            16'h5900: begin
            end
            16'h5A00: begin
            end

            // Lower Case a-z
            6'h6100: begin
            end
            16'h6200: begin
            end
            16'h6300: begin
            end
            16'h6400: begin
            end
            16'h6500: begin
            end
            16'h6600: begin
            end
            16'h6700: begin
            end
            16'h6800: begin
            end
            16'h6900: begin
            end
            16'h6A00: begin
            end
            16'h6B00: begin
            end
            16'h6C00: begin
            end
            16'h6D00: begin
            end
            16'h6E00: begin
            end
            16'h6F00: begin
            end
            16'h7000: begin
            end
            16'h7100: begin
            end
            16'h7200: begin
            end
            16'h7300: begin
            end
            16'h7400: begin
            end
            16'h7500: begin
            end
            16'h7600: begin
            end
            16'h7700: begin
            end
            16'h7800: begin
            end
            16'h7900: begin
            end
            16'h7A00: begin
            end

            // Capital AA-AZ
            16'h4141: begin
            end
            16'h4142: begin
            end
            16'h4143: begin
            end
            16'h4144: begin
            end
            16'h4145: begin
            end
            16'h4146: begin
            end
            16'h4147: begin
            end
            16'h4148: begin
            end
            16'h4149: begin
            end
            16'h414A: begin
            end
            16'h414B: begin
            end
            16'h414C: begin
            end
            16'h414D: begin
            end
            16'h414E: begin
            end
            16'h414F: begin
            end
            16'h4150: begin
            end
            16'h4151: begin
            end
            16'h4152: begin
            end
            16'h4153: begin
            end
            16'h4154: begin
            end
            16'h4155: begin
            end
            16'h4156: begin
            end
            16'h4157: begin
            end
            16'h4158: begin
            end
            16'h4159: begin
            end
            16'h415A: begin
            end

            // Capital BA-BZ
            16'h4241: begin
            end
            16'h4242: begin
            end
            16'h4243: begin
            end
            16'h4244: begin
            end
            16'h4245: begin
            end
            16'h4246: begin
            end
            16'h4247: begin
            end
            16'h4248: begin
            end
            16'h4249: begin
            end
            16'h424A: begin
            end
            16'h424B: begin
            end
            16'h424C: begin
            end
            16'h424D: begin
            end
            16'h424E: begin
            end
            16'h424F: begin
            end
            16'h4250: begin
            end
            16'h4251: begin
            end
            16'h4252: begin
            end
            16'h4253: begin
            end
            16'h4254: begin
            end
            16'h4255: begin
            end
            16'h4256: begin
            end
            16'h4257: begin
            end
            16'h4258: begin
            end
            16'h4259: begin
            end
            16'h425A: begin
            end

            // Capital CA-CZ
            16'h4341: begin
            end
            16'h4342: begin
            end
            16'h4343: begin
            end
            16'h4344: begin
            end
            16'h4345: begin
            end
            16'h4346: begin
            end
            16'h4347: begin
            end
            16'h4348: begin
            end
            16'h4349: begin
            end
            16'h434A: begin
            end
            16'h434B: begin
            end
            16'h434C: begin
            end
            16'h434D: begin
            end
            16'h434E: begin
            end
            16'h434F: begin
            end
            16'h4350: begin
            end
            16'h4351: begin
            end
            16'h4352: begin
            end
            16'h4353: begin
            end
            16'h4354: begin
            end
            16'h4355: begin
            end
            16'h4356: begin
            end
            16'h4357: begin
            end
            16'h4358: begin
            end
            16'h4359: begin
            end
            16'h435A: begin
            end


            // Capital DA-DZ
            16'h4441: begin
            end
            16'h4442: begin
            end
            16'h4443: begin
            end
            16'h4444: begin
            end
            16'h4445: begin
            end
            16'h4446: begin
            end
            16'h4447: begin
            end
            16'h4448: begin
            end
            16'h4449: begin
            end
            16'h444A: begin
            end
            16'h444B: begin
            end
            16'h444C: begin
            end
            16'h444D: begin
            end
            16'h444E: begin
            end
            16'h444F: begin
            end
            16'h4450: begin
            end
            16'h4451: begin
            end
            16'h4452: begin
            end
            16'h4453: begin
            end
            16'h4454: begin
            end
            16'h4455: begin
            end
            16'h4456: begin
            end
            16'h4457: begin
            end
            16'h4458: begin
            end
            16'h4459: begin
            end
            16'h445A: begin
            end

            // Capital DA-EP
            16'h4541: begin
            end
            16'h4542: begin
            end
            16'h4543: begin
            end
            16'h4544: begin
            end
            16'h4545: begin
            end
            16'h4546: begin
            end
            16'h4547: begin
            end
            16'h4548: begin
            end
            16'h4549: begin
            end
            16'h454A: begin
            end
            16'h454B: begin
            end
            16'h454C: begin
            end
            16'h454D: begin
            end
            16'h454E: begin
            end
            16'h454F: begin
            end
            16'h4550: begin
            end
            //default: 
        endcase
        
    end
    
end




endmodule
