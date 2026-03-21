----------------------------------------------------------------------------------
-- Company: Computer Engineering @Khon Kaen University
-- Engineer: Puwadon Puchamni
-- 
-- Create Date: 03/20/2026 12:06:44 AM
-- Design Name: 
-- Module Name: TempTop - Behavioral
-- Project Name: Copter_Scramble_Rubik
-- Target Devices: nexys A7 100t
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity machine_all_in is
    Port ( d_in  : in  STD_LOGIC_VECTOR(15 downto 0);
           d_out : out STD_LOGIC_VECTOR(15 downto 0));
end machine_all_in;

architecture Structural of machine_all_in is
    signal ctrl : STD_LOGIC; 
begin

    ctrl <= d_in(2) xor d_in(5) xor d_in(4) xor d_in(8);
    
    d_out(0)  <= d_in(0)  nand ctrl;    
    d_out(1)  <= d_in(1)  nor  d_in(0);  
    d_out(2)  <= d_in(2)  and  ctrl;     
    d_out(3)  <= d_in(3)  or   d_in(2); 
    
    d_out(4)  <= d_in(4)  xnor ctrl; 
    d_out(5)  <= d_in(5)  xor  d_in(4); 
    d_out(6)  <= not d_in(6);       
    d_out(7)  <= (d_in(7) and ctrl) or d_in(6);
    
    d_out(8)  <= d_in(15) xor  ctrl;   
    d_out(9)  <= d_in(14) nand d_in(8);  
    d_out(10) <= d_in(13) nor  ctrl;    
    d_out(11) <= d_in(11) xnor d_in(10); 
    
    d_out(12) <= ctrl;                   
    d_out(13) <= not (d_in(13) and ctrl);
    d_out(14) <= d_in(14) xor d_in(1);   
    d_out(15) <= d_in(15) xnor d_in(0); 

end Structural;
