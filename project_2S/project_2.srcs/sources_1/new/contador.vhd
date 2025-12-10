----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2025 20:06:55
-- Design Name: 
-- Module Name: contador - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity contador is
    Port ( clk_100Meg : in STD_LOGIC;
           rst : in STD_LOGIC;
           clear : in STD_LOGIC;
           wave_sel : in STD_LOGIC_VECTOR (2 downto 0);
           enable_bar : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR (4 downto 0));
end contador;

architecture structural of contador is


CONSTANT MAX_WIDTH: natural:= 12;  -- com 12 Fica perto dos 25kHz com ~24.414kHz
  -- Set MAX_WIDTH := 26 for hardware implementation only
signal ctick : std_logic := '0';

--constant all_ones: std_logic_vector (4 downto 0) := (others =>'1');
--constant all_zero: std_logic_vector (4 downto 0) := (others =>'0');
signal counter1 : std_logic_vector (4 downto 0) := (others =>'0');
signal up_down : std_logic := '0';  
COMPONENT triangular_wave
 PORT (  clk_100Meg : in STD_LOGIC;
         rst : in STD_LOGIC;
         ctick : in STD_LOGIC);  
END COMPONENT; 

begin

     process(clk_100Meg)
         variable counter : std_logic_vector (MAX_WIDTH-1 downto 0) := (others =>'0'); 
         constant all_ones: std_logic_vector (MAX_WIDTH-1 downto 0) := (others =>'1');
     begin

         if rising_edge(clk_100Meg) then  
                  counter := counter + 1;  
             end if;  
             
             if counter = all_ones then 
                  --counter := (others => '0');
                  ctick <= '1'; 
             else
                  ctick <= '0'; 
          end if;    
     end process;

    process(clk_100Meg)
    
    variable counter1 : std_logic_vector (4 downto 0) := (others =>'0');
    
    begin

        if rising_edge(clk_100Meg) then
            if clear = '1' then
                    counter1 := (others => '0');
            end if; 
            if  ctick = '1' and enable_bar = '1'  then
                if wave_sel = "000" then 
                    counter1 := counter1 + 1;
                elsif wave_sel = "001" then
                    counter1 := counter1 - 1;
                else 
                    if up_down = '1' then
                        counter1 := counter1 + 1;
                    elsif up_down = '0' then                    
                        counter1 := counter1 - 1;
                    end if;
                    if counter1 = "1111" then
                        up_down <= '0';
                    elsif counter1 = "0000" then
                        up_down <= '1';
                    end if;
                end if;  
            end if;
        end if;
        Q <= counter1;  
    end process;

--        process(clk_100Meg)
    
--    begin

--        if rising_edge(clk_100Meg) then

--            if  ctick = '1' then
--                if clear = '1' then
--                    counter1 <= (others => '0');
--                elsif enable_bar = '1' then
--                    counter1 <= counter1 + 1;
--                end if; 
--            end if;    
--        end if;
        
--    end process;
--Q <= counter1; 

end structural; 
