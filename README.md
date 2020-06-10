# Programmable-Logic-Block-for-Peripheral-Device-
A Verilog Code to mimic the functionality of the 8255 Interfacing Integrated Circuit 
Contains 38 pins 
- Input -> 
1. wrb (write bar) 
2. rdb (read bar) 
3. address [2:0 ] 
4. reset (to initialize it ) 

InOut Ports -> 
1. data [7:0] 
2. PortA [7:0]
3. PortB [7:0]
4. PortC [7:0] 

It operates in three modes - 
Mode 0 - where the three ports operate as input or output buses 
Mode 1 - where PortA and PortB operate as strobed input or output , and PortC supports in controlling 
Mode 2 - where PortA operates as strobed inout, Port b as simple input or output( same as in Mode 0 ) and PortC supports the functionality. 

Testing 

Mode 0 -> Done

Reading and Writing CWR and STATUS Register -> Done 


Mode 1 -> Done  





Ref:
1. Verilog Coding for Logic Synthesis by Weng Fook Lee (Wiley Publication) 
2. http://www.asic-world.com/verilog/veritut.html
3. https://www.fpga4student.com/
4. Verilog HDL - A Guide to Digital System and Synthesis by Samir Palnitkar 
