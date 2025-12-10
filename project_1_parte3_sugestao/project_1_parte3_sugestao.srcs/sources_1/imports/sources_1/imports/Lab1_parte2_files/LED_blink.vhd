----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.09.2025 20:36:10
-- Design Name: 
-- Module Name: LED_blink - Behavioral
-- Project Name: 
-- Target Devices: 
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
use IEEE.std_logic_unsigned.all; -- this is for counter := counter + 1;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LED_blink is
    Port ( clk_100Meg : in STD_LOGIC;
           rst : in STD_LOGIC;
           blink2LED : out STD_LOGIC;
           ctick:in STD_LOGIC);
end LED_blink;

architecture Behavioral of LED_blink is
   signal aux_blink: std_logic :='0';
   
   
begin

-- Creation the internal blink signal with low frequency and 50% duty-cycle
process(clk_100Meg)  
 begin
    if (ctick ='1') then
        blink2LED <= '1';
    elsif  (ctick ='0') then
        blink2LED <= '0';  
    end if;
    
 end process;
 
 
end Behavioral;
