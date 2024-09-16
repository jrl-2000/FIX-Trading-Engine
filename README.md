This Project is a work in progress

FPGA Implementation of the Financial Information eXchange (FIX) protocol trading engine
Monitoring Ethernet traffic, the FPGA takes in frames of FIX messages of ASCII characters in
hexadecimal representation and parses them for Tag-Value pairs as well as verifies the message via
FIX version, message length, and checksum

Ver 1.0:
Parser scans for Tag 8

Ver 1.1
Parser scans for Tag 10

Ver 1.2:
Parser calculates checksum mod 256; testbench

Ver 1.3:
Added Always Block for Tag 9 and calculated msg length

Ver 1.4:
Added Always Block for Tag 35, 35, 49, and 50

Ver 1.5:
Skeleton Coee for Tag 35 Look-Up Table (LUT)

Ver 1.6:
Added Bare metal Ethernet logic (SV)

Ver 1.7:
 In progress; TCP/IP STack?????
