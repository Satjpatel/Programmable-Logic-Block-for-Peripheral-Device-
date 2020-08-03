`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sat Patel 
//
// Create Date:   20:49:19 06/09/2020
// Design Name:   ppi
// Module Name:   S:/Github Uploads/Programmable Logic Block for Peripheral Device Interfacing/ProgrammablePeripheralInterface/ppi_tb4.v
// Project Name:  ProgrammablePeripheralInterface
// Target Device:  
// Tool versions:  
// Description: Simulation with PortA as Strobed I/O and PortB as Input in Mode2 Operation
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

module ppi_tb4;

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
		reset = 0 ; 
		
		#cycle

		task_reset ; 
		
		//For Mode2 with PortB input 
		
		//To write to STATUS 
		address = 3'd7 ; 
		drive_data = 8'hff ; 
		CWR_STATUS_write(address) ; 
		
		address = 3'd3 ; 
		drive_data = 8'b11000110 ; 
		//Drive PortC[4] to default 1 
		drive_PortC[4] = 1 ; 
		//Drive PirtC[6] to default 1 
		drive_PortC[6] = 1 ; 
		CWR_STATUS_write(address) ; 
		drive_data = 8'hzz ; 
		
		//Read from PortA 
		address = 3'd0 ; 
		drive_PortA = 8'ha5 ; 
		drive_PortC[4] = 0 ; //This is to have stbab at low 
		#cycle ; 
		drive_PortC[4] = 1 ; //This is to have stbab back at high 
		read_port ; 
		#cycle; 
		drive_PortA = 8'hzz ; 
		
		//Write to PortA 
		drive_data = 8'haa ; 
		write_port ; 
		#cycle ; 
		drive_PortC[6] = 0 ; //This is to have ackab at low 
		#cycle ; 
		drive_PortC[6] = 1 ; //This is to have ackab at high 
		drive_PortA = 8'hzz ; 
		#cycle ; 
		drive_data = 8'hzz ; 
		#cycle ; 
		
		//Read from PortB 
		address = 3'o1 ; 
		drive_PortB = 8'h35 ; 
		read_port ; 
		drive_PortC = 8'hzz ; 
		
		#cycle; 
		
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

