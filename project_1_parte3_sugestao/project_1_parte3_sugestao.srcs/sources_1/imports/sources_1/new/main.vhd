----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2025 10:30:19
-- Design Name: 
-- Module Name: main - structural
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

entity main is
    Port ( clk_100Meg : in STD_LOGIC;
           rst : in STD_LOGIC;
           btn1: in STD_LOGIC_VECTOR (1 downto 0);
           blink2LED : out STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (6 downto 0));
end main;

architecture structural of main is

CONSTANT MAX_WIDTH: natural:= 2;  -- Set MAX_WIDTH := 5 for simulation only
  -- Set MAX_WIDTH := 26 for hardware implementation only

signal ctick : std_logic := '0';
signal ctick_2tick : std_logic := '0';


COMPONENT LED_blink
 PORT (  clk_100Meg : in STD_LOGIC;
         rst : in STD_LOGIC;
         ctick : in STD_LOGIC;
         blink2LED : out STD_LOGIC);
END COMPONENT;

COMPONENT LED_shift
    PORT ( clk_100Meg : in STD_LOGIC;
           rst : in STD_LOGIC;
           btn1: in STD_LOGIC_VECTOR(1 downto 0);
           ctick : in STD_LOGIC;
           ctick_2tick : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (6 downto 0));
END COMPONENT;
    
begin

     process(clk_100Meg,rst)
         variable counter : std_logic_vector (MAX_WIDTH-1 downto 0) := (others =>'0'); 
         variable counter_2tick : std_logic_vector ((MAX_WIDTH)-1 downto 0) := (others =>'0'); 
         constant all_ones: std_logic_vector (MAX_WIDTH-1 downto 0) := (others =>'1');
         variable ctick_control: std_logic := '0';
     begin
    if rst = '1' then
        counter := (others => '0'); 
        ctick <= '0';

    elsif rising_edge(clk_100Meg) then
        --counter := counter + 1;
        counter_2tick := counter_2tick + 1;
        -- Check if counter reached the limit
        if (counter_2tick = all_ones) then 
            counter_2tick := (others => '0');
            ctick_2tick <= '1';
            if(ctick_control = '0') then
                ctick_control := '1';
            else 
                ctick_control := '0';
                ctick <= '1';
            end if;
         else 
            ctick_2tick <= '0';
            ctick <= '0';
        end if;       
     end if;      
     end process;

    u1: LED_shift PORT MAP( 
        clk_100Meg => clk_100Meg, rst => rst, btn1 => btn1,
         ctick => ctick,ctick_2tick => ctick_2tick, LED => LED);
 -- Instantiate the LED_blink component
    u2: LED_blink PORT MAP (
    clk_100Meg => clk_100Meg, rst => rst,ctick => ctick,
    blink2LED => blink2LED);


end structural;
