`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   08:42:39 06/06/2020
// Design Name:   ppi
// Module Name:   S:/Github Uploads/Programmable Logic Block for Peripheral Device Interfacing/ProgrammablePeripheralInterface/ppi_tb1.v
// Project Name:  ProgrammablePeripheralInterface
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ppi
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ppi_tb1;

	// Inputs
	reg rdb;
	reg wrb;
	reg [2:0] address;
	reg reset;

	// Bidirs
	wire [7:0] data;
	wire [7:0] PortA;
	wire [7:0] PortB;
	wire [7:0] PortC;

	// Instantiate the Unit Under Test (UUT)
	ppi uut (
		.rdb(rdb), 
		.wrb(wrb), 
		.address(address), 
		.reset(reset), 
		.data(data), 
		.PortA(PortA), 
		.PortB(PortB), 
		.PortC(PortC)
	);

	initial begin
		// Initialize Inputs
		rdb = 0;
		wrb = 0;
		address = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

