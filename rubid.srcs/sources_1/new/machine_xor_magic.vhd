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

entity machine_xor_magic is
    Port ( d_in  : in  STD_LOGIC_VECTOR(15 downto 0);
           d_out : out STD_LOGIC_VECTOR(15 downto 0));
end machine_xor_magic;

architecture GateLevel of machine_xor_magic is
begin
    -- Magic number from M150 barcode LOL.
    -- 8851123240291
    -- to hex: x"80D1A9C1D63" 
    -- x"1D63" (Binary: 0001_1101_0110_0011)
    
    -- d_out = d_in ^ mask
    -- mask = 0 -> unchange
    -- mask = 1 -> invert
    
    -- 0001
    d_out(15) <= d_in(15);        
    d_out(14) <= d_in(14);        
    d_out(13) <= d_in(13);        
    d_out(12) <= not d_in(12);   
    
    -- 1101
    d_out(11) <= not d_in(11);     
    d_out(10) <= not d_in(10);     
    d_out(9)  <= d_in(9);      
    d_out(8)  <= not d_in(8);  
    
    -- 0110
    d_out(7)  <= d_in(7);      
    d_out(6)  <= not d_in(6);      
    d_out(5)  <= not d_in(5);   
    d_out(4)  <= d_in(4);        
    
    -- 0011
    d_out(3)  <= d_in(3);          
    d_out(2)  <= d_in(2);        
    d_out(1)  <= not d_in(1);     
    d_out(0)  <= not d_in(0);  

end GateLevel;
