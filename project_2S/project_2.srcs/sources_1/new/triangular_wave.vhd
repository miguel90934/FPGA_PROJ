----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.10.2025 11:38:43
-- Design Name: 
-- Module Name: triangular_wave - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity triangular_wave is
           Port (clk_100Meg : in STD_LOGIC;
           clear : in STD_LOGIC;
           enable_bar : in STD_LOGIC;       
           Q : out STD_LOGIC_VECTOR (4 downto 0));
end triangular_wave;

architecture Behavioral of triangular_wave is
    signal up_down : std_logic := '0';
begin

    process(clk_100Meg)
    
    variable counter1 : std_logic_vector (4 downto 0) := (others =>'0');
    
    begin

        if rising_edge(clk_100Meg) then
            if clear = '1' then
                    counter1 := (others => '0');
            end if;
            if  ctick = '1' and enable_bar = '1'  then
                    if up_down = '1' then 
                    counter1 := counter1 + 1; 
                    else
                    counter1 := counter1 - 1;
                    end if;
            end if;   
        end if;
        Q <= counter1;  
    end process;

end Behavioral;
