   `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sat J. Patel 
// Create Date:    13:20:33 06/03/2020 
// Design Name: Programmable Logic Block for Peripheral Interface 
// Module Name:    ppi 
// Project Name: Programmable Peripheral Interface 
// Description: A Logic Block to Mimic the functionality of 8255 I/C
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
/*module ppi(
    input rdb,
    input wrb,
    input [2:0] address,
    input reset,
    inout [7:0] data,
    inout [7:0] PortA,
    inout [7:0] PortB,
    inout [7:0] PortC
    );


endmodule
*/ 

//Synthesizable Verilog Code for Programmable Logic Block for Peripheral Interface 
// Abbreviated here as PPI ( Programmable Peripheral Interface) 

//3 Modes 
//24 I/O Pins 
//Total 28 Pins 

module ppi ( 
	input rdb, //Active Low Read Signal 
	input wrb, //Active Low Write Signal 
	input [2:0] address, //Address bus for operation 
	input reset, //Active High signal for clearing the device and initailizing it. 
	
	inout [7:0] data, //For reading CWR and STATUS 
	inout [7:0] PortA, //Data Transfer Bus in All Modes 
	inout [7:0] PortB, //Data Transfer Bus in All Modes 
	inout [7:0] PortC //Data Transfer Bus in Mode 0 and Control Bus for other modes  
	) ; 

//There are 2 internal registers 
//1. Control Word Register (CWR) 
	reg [7:0] CWR;  //Determines the functionality and the direction of the ports 
//2. STATUS Register 
	reg [7:0] STATUS; //Controls O/p PortC when the PLB s operated in Mode1 and Mode2 
	
// Enable signals for Ports (tristate for PortC ) 
	reg PortAenable, PortBenable ; 
	reg [7:0] PortCenable; 

//We also need an tristate output bus for data 
	reg [7:0] out_data ; 
	
assign data = out_data ; 

//We also need tristate output buses for all ports 
	reg [7:0] out_PortA, out_PortB, out_PortC ; 
	
assign PortA = out_PortA ; 
assign PortB = out_PortB ; 
assign PortC = out_PortC ; 

//For internal latching of data, until the microprocessor needs it, we use 
reg [7:0] latch_data; 

//For internal reset options - actually a combination of various things 
	wire int_reset ; 
	
assign int_reset =(reset | ( ~CWR[7] ) | (~wrb & ((address == 3'b011) | (address == 3'b111))) ) ; 

//Reset is self-explainatory 
//CWR[7] is active bit to active the device 
//011 and 111 correspond to writing data into CWR and STATUS registers, bith which don't require the PPI 

//For internal latching of data until microprocessor is empty 

//Mode 0 
reg [7:0] latch_portA_mode0 , latch_portB_mode0, latch_portC ; 
//POrtC works as an input output in Mode 0 only 

//Mode 1 
reg [7:0] latch_portA_mode1_SI , latch_portB_mode1_SI ; 

//Mode 2 - No requirements 

// Following processes are required 

//1. For writing data into the CWR and STATUS 

	always @(posedge reset or posedge wrb) 
		begin
			if(reset)  
				begin 
					CWR <= 8'b10011110 ; //Default mode is Mode 0 
					STATUS <= 00000000 ; 
				end 
			else //At rising edge of wrb 
			begin
				if(address  == 3'b011 ) //CWR Writing address 
					begin 
						//Write value to CWR 
						CWR <= data ; 
					end 
				else if(address == 3'b111) //STATUS Writing address 
					begin 
						//Write data into STATUS 
						STATUS <= data ; 
					end  //Default case me data latch ho jayega, jus the thing we wanted 
			end 
		
		end 
	
//2. For reading the contents of CWR and STATUS 

always @( posedge int_reset or negedge rdb ) 
begin 
	if(int_reset) 
		out_data <= 8'bzzzzzzzz ; 
	else if(~rdb) 
		begin 
			if(address == 3'b011) 
				out_data <= CWR ; 
			else if(address == 3'b111) 
				out_data <= STATUS ; 
		end 
end 


//3. Latching data from data bus 
always @ ( posedge int_reset or negedge wrb ) 
begin
	if(int_reset) 
		latch_data <= 8'h00 ; 
	else  //Falling edge of wrb 
		latch_data <= data ; 
end 


//4. Latching data from portA, portB, portC 
//Internal signals 
wire stbab, stbbb ;  //Loads data into port latch until it is input to the microprocessor 
//Useful for PortA operation in mode1 (strobed input)  and Mode2  
assign stbab = (((CWR[6:5] == 2'b01 ) & ~PortAenable) | (CWR[6:5] == 2'b10 ) ) ? PortC[4] : 1'b1 ; 
//Useful for PortB operation in Mode 1 as strobed input 
assign stbbb = ((CWR[6:5] == 2'b1 ) & ~PortBenable) ? PortC[2] : 1'b1 ; 

always @ (  posedge int_reset or negedge rdb or negedge stbab or negedge stbbb ) 
begin
	if(int_reset) 
	begin
		latch_portA_mode0 <= 8'h00 ; 
		latch_portB_mode0 <= 8'h00 ; 
		latch_portC <= 8'h00 ; 
		latch_portA_mode1_SI <= 8'h00 ; 
		latch_portB_mode1_SI <= 8'h00 ; 
	end 
	else if(~rdb) 
	begin 
		latch_portA_mode0 <= PortA ; 
		latch_portB_mode0 <= PortB ; 
		latch_portC <= PortC ; 
	end 
	else if(~stbab) 
	begin 
		latch_portA_mode1_SI <= PortA ; 
	end 
	else if(~stbbb) 
	begin 
		latch_portB_mode1_SI <= PortB ; 
	end 
end 

//5. Latching data from PortA, PortB and PortC to tri state bus out_data 
always @ ( int_reset or rdb or address or CWR or PortAenable or PortBenable or PortCenable or latch_portA_mode0 or latch_portB_mode0 or latch_portC or latch_portA_mode1_SI or latch_portB_mode1_SI ) 
begin
	if(int_reset) 
	begin
		out_data = 8'hzz ; 
	end
	else if(~rdb & (address == 3'b011 ) )
	begin 
		out_data = CWR ; 
	end 
	else if (~rdb & (address == 3'b111 )) 
	begin
		out_data = STATUS ; 
	end 
	//Mode 0 stuff 
	else if (~rdb & ( address == 3'b000) & (CWR[6:5] == 2'b00 ) & ~PortAenable ) 
	begin
		out_data = latch_portA_mode0 ; 
	end 
	else if (~rdb & ( address == 3'b001) & (CWR[6:5] == 2'b00 ) & ~PortBenable ) 
	begin 
		out_data = latch_portB_mode0 ; 
	end 
	else if (~rdb & ( address == 3'b010) & (CWR[6:5] == 2'b00 ) & (PortCenable == 8'h00 ) ) 
	begin 
		out_data = latch_portC ; 
	end 
	else if(~rdb & ( address == 3'b010 ) & (CWR[6:5] == 2'b00 ) & (PortCenable == 8'h0f) ) 
	begin 
		out_data = {latch_portC[7:4],4'hz} ; 
	end 
	else if (~rdb & ( address == 3'b010 ) & (CWR[6:5] == 2'b00 ) & (PortCenable == 8'hf0) ) 
	begin 
		out_data = {4'hz,latch_portC[3:0]} ; 
	end 
	//Mode 1 stuff 
	else if (~rdb & ( address == 3'b000) & (CWR[6:5] == 2'b01 ) & ~PortAenable ) 
	begin
		out_data = latch_portA_mode1_SI ; 
	end 
	else if (~rdb & ( address == 3'b001) & (CWR[6:5] == 2'b01 ) & ~PortBenable ) 
	begin 
		out_data = latch_portB_mode1_SI ; 
	end 
	//Mode 2 stuff 
	else if (~rdb & ( address == 3'b000) & (CWR[6:5] == 2'b10 ) & ~PortAenable ) 
	begin
		out_data = latch_portA_mode1_SI ; 
	end 
	else if (~rdb & ( address == 3'b001) & (CWR[6:5] == 2'b10 ) & ~PortBenable ) 
	begin 
		out_data = latch_portB_mode0 ; 
	end 
	//default condition 
	else 
	begin
		out_data = 8'hzz ; 
	end 
	
end 

//6. Generating enables signals for all ports in Mode 0 , 1, 2 
always @( int_reset or CWR) 
begin  
	if(int_reset) 
	begin
		PortAenable = 0 ; 
		PortBenable = 0 ; 
		PortCenable = 8'h00 ; 
	end 
	else if( CWR[6:5] == 2'b00 ) //Mode 0 Operation 
	begin
		//PortCupper Output 
		if(~CWR[4]) 
			PortCenable[7:4] = 4'hf ; 
		else 
			PortCenable[7:4] = 4'h0 ; 
		//PortClower Output 
		if(~CWR[3]) 
			PortCenable[3:0] = 4'hf  ; 
		else 
			PortCenable[3:0] = 4'h0  ;  
		
		//PortB Output 
		if(~CWR[2]) 
			PortBenable = 1 ; 
		else 
			PortBenable = 0 ; 
		
		//PortA Output 
		if(~CWR[1]) 
			PortAenable = 1 ; 
		else 
			PortAenable = 0 ; 
	end 
	else if( CWR[6:5] == 2'b01 ) //Mode 1 Operation 
	begin 
		//PortB - strobed o/p 
		if(~CWR[2]) 
			PortBenable = 1 ; //Port B is strobed output 
		else 
			PortBenable = 0 ;  //Vice-versa 
			
		//Port A - Strobed o/p 
		if(~CWR[1]) 
			PortAenable = 1 ; //Port A is strobed output 
		else 
			PortAenable = 0 ; //vice-versa 
		
		//PortA and PortB - Strobed output -- Logic given in the flow diagrams 
		if(CWR[2:1] == 2'b00 ) 
			PortCenable = 8'b10001011 ;
		//Logic given in the flow diagrams 
		else if(CWR[2:1] == 2'b01) 
		//Port A - strobed  o/p and PortB - strobed i/p
			PortCenable = 8'b00101011 ; 
		else if(CWR[2:1] == 2'b10) 
		//Port A - strobed  1/p and PortB - strobed o/p
			PortCenable = 8'b10001011 ; 
		else 
		//Port A - strobed  i/p and PortB - strobed i/p
			PortCenable = 8'b00101011 ; 
		
	end 
	else if( CWR[6:5] == 2'b10) //Mode 2 operation 
	begin 
		//PortB stuff - o/p port 
		if(~CWR[2]) 
			PortBenable = 1 ; 
		else 
			PortBenable = 0 ; 
		
		//Port A stuff - strobed i/o (bidirectional) and PortC is used for handshaking 
		PortCenable = 8'b10101000 ; 
	end 
end 


wire out_obfab, out_obfbb ; 
wire ackab, ackbb ; 


//7. Generating out_obfab, out_obfbb 
reg set_obfab , set_obfbb ; 
//Generating set_obfab 
always @ ( posedge wrb or negedge ackab ) 
begin 
	if(~ackab) //Falling edge of ackab 
		set_obfab <= 0 ; 
	else if (address == 3'b000 ) 
		//in posedge of wrb 
		set_obfab <= 1 ; 
end 

//Generating set_obfbb
always @ ( posedge wrb or negedge ackbb ) 
begin 
	if(~ackbb) 
		set_obfbb <= 0 ; 
	else if (address == 3'b001 ) 
		set_obfbb <= 1 ; 
end 


assign out_obfab = ~(set_obfab & (((CWR[6:5] == 2'b01 ) & PortAenable) | (CWR[6:5] == 2'b10 )) & (address != 3'b011 ) & (address != 3'b111 )) ; 

assign out_obfbb = ~(set_obfbb & (((CWR[6:5] == 2'b01 ) & PortBenable) | (CWR[6:5] == 2'b10 )) & (address != 3'b011 ) & (address != 3'b111 )) ; 

//Generation of input ackab - needed when Mode 1 and PortA is strobed output or in Mode 2 
assign ackab = (((CWR[6:5] == 2'b01 ) & PortAenable & PortC[6] ) | (CWR[6:5] == 2'b10 ) & PortC[6] ) ;  


//Generation of input ackbb - needed in Mode 1 when B is strobed output 
assign ackbb = ((CWR[6:5] == 2'b01) & PortBenable & PortC[2] ) ; 

//For output of PPI in Mode 1 and 2, we need to generate intra and intrb signals 

//PortA in Mode 1,2 -> PortC[3] -> intra 
//PortB n Mode 1 -> PortC[0] -> intrb 
//Full procedure shown in flow diagrams 

reg set_si_intra, set_so_intra ; 
reg set_si_intrb, set_so_intrb ; 
wire out_intra ; 
wire out_intrb ; 
//Generating out_intra 
assign wrb_PortA = (address == 3'b000) & wrb ; 

always @ (negedge wrb_PortA or posedge ackab) 
begin 
	if(~wrb_PortA) 
		set_so_intra <= 0 ; 
	else 
		set_so_intra <= 1 ; 
end 

assign rdb_PortA = (address == 3'b000) & rdb ; 

always @ (posedge stbab or negedge rdb_PortA) 
begin 
	if(~rdb_PortA) 
		set_si_intra <= 0 ; 
	else 
		set_si_intra <= 1 ; 
end 

assign out_intra = int_reset ? 0 : (PortAenable & (CWR[6:5] == 2'b01) & STATUS[2]) ? set_so_intra : (~PortAenable & (CWR[6:5] == 2'b01 ) & STATUS[0] ) ? set_si_intra : ((CWR[6:5] == 2'b10 ) & STATUS[4] & STATUS[5] ) ? (set_so_intra | set_si_intra) : 0 ; 
 
           
//Generating out_intrb 
assign wrb_PortB = (address == 3'b001 ) & wrb ; 

always @ (negedge wrb_PortB or posedge ackbb) 
begin 
	if(~wrb_PortB) 
		set_so_intrb <= 0 ; 
	else 
		set_so_intrb <= 1 ; 
end 

assign rdb_PortB = (address == 3'b001) & rdb ; 

always @ (negedge rdb_PortB or posedge stbbb ) 
begin 
	if(~rdb_PortB) 
		set_si_intrb <= 0 ; 
	else 
		set_si_intrb <= 1 ; 
end 

assign out_intrb = int_reset? 0 : (PortBenable & (CWR[6:5] == 2'b01) & STATUS[3] ) ? set_so_intrb : (~PortBenable & (CWR[6:5] == 2'b01 ) & STATUS[1] ) ? set_si_intrb : 0 ; 

//Generation of output ibfa needed when in Mode 1 and PortA is strobed input or Mode 2 
//ibfa - input buffer full 

reg set_ibfa , reset_ibfa ; 
always @ ( posedge rdb) 
begin 
	if(set_ibfa) 
		reset_ibfa <= 1; 
	else 
		reset_ibfa <= 0 ; 
end 

//Sensitivity list explained in the flow diagrams 
always @ ( CWR or PortAenable or reset_ibfa or stbab or out_ibfa or int_reset) 
begin 
	if(int_reset) 
		set_ibfa = 0 ; 
	else if ((CWR[6:5] == 2'b01 ) & ~PortAenable & ~reset_ibfa & ~stbab) //Port A Input Mode 
		set_ibfa = 1 ; 
	else if ((CWR[6:5] == 2'b10) & ~reset_ibfa & ~stbab) //Port A Mode 2 
		set_ibfa = 1 ; 
	else if(reset_ibfa) 
		set_ibfa = 0 ; 
		
end 

assign out_ibfa = set_ibfa ; 

//Generating output ibfb - Needed when in Mode 1 and Port b is strobed Input 
reg set_ibfb , reset_ibfb ; 
always @ (posedge rdb) 
begin 
	if(set_ibfb) 
		reset_ibfb <= 1 ; 
	else 
		reset_ibfb <= 0 ; 
end 

always @ ( CWR or PortBenable or reset_ibfb or stbbb or out_ibfb or int_reset) 
begin 
	if(int_reset) 
		set_ibfb = 0 ; 
	else if ((CWR[6:5] == 2'b01 ) & PortBenable & ~reset_ibfb & ~stbbb) 
		set_ibfb = 1 ; 
	else if (reset_ibfb) 
		set_ibfb = 0 ; 
end 

assign out_ibfb = set_ibfb ; 

//FINAL Logic 

//We only have to multiplex these 3 ports 

//Multiplexing Signals to PortA 
always @ (int_reset or wrb or address or CWR or PortAenable or latch_data or out_obfab or ackab) 
begin 
	if(int_reset) 
		out_PortA [7:0] = 8'b00000000 ; 
	else if (~wrb & (address == 3'b000 ) & (CWR[6:5] == 2'b00) & PortAenable ) //Mode 0 
		out_PortA = latch_data ; 
	else if ((~out_obfab | ~ackab) & (address == 3'b000 ) & (CWR[6:5] == 2'b01) & PortAenable) //Mode1 
		out_PortA = latch_data ; 
	else if ((~out_obfab | ~ackab) & (address == 3'b000) & (CWR[6:5] == 2'b10)) //Mode 2 
		out_PortA = latch_data ; 
	else 
		out_PortA = 8'bzzzzzzzz ; 
end 

//Multiplexing Signals to PortB 
always @( int_reset or wrb or address or CWR or PortBenable or latch_data or out_obfbb or ackbb) 
begin 
	if(int_reset) 
		out_PortB = 8'bzzzzzzzz ; 
	else if(~wrb & (address == 3'b001) & (CWR[6:5] == 2'b00) & PortBenable) //Mode 0 
		out_PortB = latch_data ; 
	else if((~out_obfbb | ~ackbb) & (address == 3'b001) & (CWR[6:5] == 2'b01) & PortBenable) //Mode 1 
		out_PortB = latch_data ; 
	else if(~wrb & (address == 3'b001) & (CWR[6:5] == 2'b10) & PortBenable) //Mode 2 
		out_PortB = latch_data ; 
	else 
		out_PortB = 8'bzzzzzzzz ; 
end 

//Multiplexing signals to Port C -- Refer Flow diagram for more information 
always @ (int_reset or wrb or address or CWR or PortCenable or latch_data or out_ibfa or out_intra or out_ibfb or out_intrb or out_obfab or out_obfbb or PortAenable or PortBenable) 
begin 
	if(int_reset) 
		out_PortC = 8'bzzzzzzzz ; 
	else if (~wrb & (address == 3'b010) & (CWR[6:5] == 2'b00)) //Mode 0 
		begin 
			if(PortCenable == 8'hff) 
				out_PortC = latch_data ; 
			else if ( PortCenable == 8'h0f) 
				out_PortC = {4'bzzzz. latch_data[3:0] } ; 
			else if ( PortCenable == 8'hf0 ) 
				out_PortC = {latch_data[7:4] , 4'bzzzz} 
			else 
				out_PortC = 8'bzzzzzzzz ; 
		end 
	else if(CWR[6:5] == 2'b01 ) //Mode 1 
		begin 
			if( ~PortAenable & ~PortBenable) //PortA,B as strobed input 
				out_PortC = { 2'bzz , out_ibfa , 1'bz , out_intra, 1'bz , out_ibfb , out_intrb } ; 
			else if (~PortAenable & PortBenable) 
				out_PortC = {2'bzz , out_ibfa , 1'bz , out_intra , 1'bz , out_obfbb , out_intrb } ; 
			else if(PortAenable & ~PortBenable) 
				out_PortC = {out_obfab , 3'bzzz , out_intra, 1'bz , out_ibfb , out_intrb } ; 
			else //PortAenable and PortBenable is high 
				out_PortC = {out_obfab, 3'bzzz , out_intra , 1'bz , out_obfbb , out_intrb } ; 
		end 
	else if(CWR[6:5] == 2'b10 ) //Mode 2 
		out_PortC = { out_obfab , 1'bz , out_ibfa , 1'bz , out_intra, 3'bzzz } ; 
	else 
		out_PortC = 8'bzzzzzzzz ; 
end 


endmodule