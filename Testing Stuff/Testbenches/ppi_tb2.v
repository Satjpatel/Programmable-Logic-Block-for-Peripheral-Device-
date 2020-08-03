`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:Sat Patel 
//
// Create Date:   18:29:59 06/09/2020
// Design Name:   ppi
// Module Name:   S:/Github Uploads/Programmable Logic Block for Peripheral Device Interfacing/ProgrammablePeripheralInterface/ppi_tb2.v
// Project Name:  ProgrammablePeripheralInterface
// Target Device:  
// Tool versions:  
// Description: Simulation for Reading and Writing data from CWR and STATUS Register 
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

module ppi_tb2;

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
		
	reg [7:0] drive_PortA, drive_PortB, drive_PortC, drive_data ; 
	
	parameter cycle = 100 ; 
	
	assign PortA = drive_PortA ; 
	assign PortB = drive_PortB ; 
	assign PortC = drive_PortC ; 
	assign data = drive_data ; 
	
	initial 
	begin 
		//For reset 
		drive_PortA = 8'hzz ; 
		drive_PortB = 8'hzz ; 
		drive_PortC = 8'hzz ; 
		rdb = 1 ; 
		wrb = 1 ; 
		address = 3'o0 ; 
		drive_data = 8'hzz ; 
		reset = 1 ; 
		
		#cycle

		task_reset ; 
		
		//To write to STATUS 
		address = 3'o7 ; 
		drive_data = 8'hff ; 
		CWR_STATUS_write(address) ; 
		drive_data = 8'hzz ; 
		
		//Read from STATUS reg 
		address = 3'o7 ; 
		read_port ; 
		#cycle ; 
		
		//Read from CWR reg 
		address = 3'd3 ; 
		read_port ; 
		#cycle ; 
		
		#cycle ; 
	end 
	
	
	
	
			
	//Task definations 
	task write_port ; 
	begin 
		wrb = 1 ; 
		rdb = 1 ; 
		#cycle ; 
		wrb = 0 ; 
		#cycle ; 
		wrb = 1 ; 
		#cycle ; 
	end 
	endtask 
	
	task read_port ; 
	begin 
		wrb = 1 ; 
		rdb = 1 ; 
		#cycle ; 
		rdb = 0 ; 
		#cycle ; 
		rdb = 1 ; 
		#cycle ; 
	end 
	endtask 
	
	task CWR_STATUS_write;
	input [2:0] address; 
	begin 
		reset = 0;
		rdb = 1 ;
		wrb = 1 ;
		#cycle ; 
		wrb = 0 ;
		#cycle ;
		wrb = 1 ;
		#cycle;
	end
	endtask 
	
	task task_reset; 
	begin 
		reset = 0 ; 
		#cycle ; 
		reset = 1 ; 
		#cycle ; 
		reset = 0 ; 
		#cycle ; 
	end 
	endtask	
		
		
		
			
		
		
endmodule

