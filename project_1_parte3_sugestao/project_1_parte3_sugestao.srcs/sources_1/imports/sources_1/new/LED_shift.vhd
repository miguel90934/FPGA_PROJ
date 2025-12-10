----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2025 10:57:35
-- Design Name: 
-- Module Name: LED_shift - Behavioral
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
use IEEE.std_logic_unsigned.all;
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LED_shift is
    Port ( clk_100Meg : in STD_LOGIC;
           rst : in STD_LOGIC;
           btn1:in STD_LOGIC_VECTOR(1 downto 0);
           ctick: in STD_LOGIC;
           ctick_2tick: in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (6 downto 0));
end LED_shift;

architecture Behavioral of LED_shift is
   
     signal shift_reg: std_logic_vector (6 downto 0) := "0000000";
     signal invert:std_logic_vector (6 downto 0) := "0000000";
     constant all_ones: std_logic_vector (6 downto 0) := (others =>'1');
     constant all_zero: std_logic_vector (6 downto 0) := (others =>'0');
     signal plus_one: std_logic := '0';
     signal invert_timer: std_logic := '1';
    begin
 
    -- process for shift_reg
    process (clk_100Meg) 
         begin
            if clk_100Meg'event and clk_100Meg='1' then --if rising_edge (clk_100Meg)
                if rst = '1' then
                    shift_reg <= "0000000";
                elsif (ctick ='1') then
                    if ((plus_one = '0') and (shift_reg = all_ones)) or ((plus_one = '0') and (shift_reg = all_zero))then
                        plus_one <= '1'; 
                    else 
                        shift_reg <= (not shift_reg(0)) & shift_reg(6 downto 1);
                        plus_one <= '0';
                    end if;
                end if;
            end if;
    end process;
   invert <= not shift_reg; 
     
    process(shift_reg, btn1,invert,ctick_2tick)
        begin
            --if rising_edge (clk_100Meg) then
                if btn1 = "00" then 
                    LED <= shift_reg;
                elsif btn1 ="10" then
                    LED <=  invert; 
                elsif btn1 = "11" then
                    if ctick_2tick = '1' then
                        if invert_timer = '0' then
                            LED <= invert;
                            invert_timer <='1';
                        elsif invert_timer = '1' then
                         LED <= shift_reg;
                         invert_timer <='0';
                        end if;
                    end if; 
        end if;
    end process; 
         
            



end Behavioral;
