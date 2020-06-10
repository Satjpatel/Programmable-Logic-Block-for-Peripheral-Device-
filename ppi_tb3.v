`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sat Patel 
//
// Create Date:   19:06:52 06/09/2020
// Design Name:   ppi
// Module Name:   S:/Github Uploads/Programmable Logic Block for Peripheral Device Interfacing/ProgrammablePeripheralInterface/ppi_tb3.v
// Project Name:  ProgrammablePeripheralInterface
// Target Device:  
// Tool versions:  
// Description: Simulation with PortA and PortB as Strobed Input in Mode 1 Operation 
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

module ppi_tb3;

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
		
		//For Mode 1 with PortA and PortB input 
		
		//To write to STATUS 
		address = 3'o7 ; 
		drive_data = 8'hff ; 
		CWR_STATUS_write(address) ; 
		
		address = 3'o0 ; 
		drive_PortA = 8'ha5 ; 
		drive_PortB = 8'hba ; 
		drive_PortC[4] = 0 ; //This is to have stbab at low 
		drive_PortC[2] = 1 ; //To have stbbb at high 
		#cycle ; 
		drive_PortC[4] = 1 ; //To have stbbb back at high 
		read_port ; 
		address = 3'o1 ; 
		drive_PortC[2] = 0 ; //This is to have stbbb at low 
		#cycle; 
		drive_PortC[2] = 1 ; //To have stbbb back at high 
		#cycle; 
		read_port; 
		drive_PortA = 8'hzz ; 
		drive_PortB = 8'hzz ; 
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

