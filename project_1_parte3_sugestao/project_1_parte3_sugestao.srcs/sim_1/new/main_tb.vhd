----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.10.2025 22:25:19
-- Design Name: 
-- Module Name: main_tb - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;

entity tb_main is
end tb_main;

architecture tb of tb_main is

    component main
        port (clk_100Meg : in std_logic;
              rst        : in std_logic;
              btn1       : in std_logic_vector (1 downto 0);
              blink2LED  : out std_logic;
              LED        : out std_logic_vector (6 downto 0));
    end component;

    signal clk_100Meg : std_logic;
    signal rst        : std_logic;
    signal btn1       : std_logic_vector (1 downto 0);
    signal blink2LED  : std_logic;
    signal LED        : std_logic_vector (6 downto 0);

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : main
    port map (clk_100Meg => clk_100Meg,
              rst        => rst,
              btn1       => btn1,
              blink2LED  => blink2LED,
              LED        => LED);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk_100Meg is really your main clock signal
    clk_100Meg <= TbClock;

    stimuli : process
    begin
        ---------------------------------------------------------
        -- Initial reset
        ---------------------------------------------------------
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        btn1 <= "00";  -- btn(0)=1, btn(1)=0
        wait for 1000 ns;

        ---------------------------------------------------------
        -- Case 1: All buttons released (LEDs idle)
        ---------------------------------------------------------

        btn1 <= "10";  -- btn(0)=0, btn(1)=1
        wait for 1000 ns;

        ---------------------------------------------------------
        -- Case 4: Both pressed - alternate blue/brown sequence
        ---------------------------------------------------------
        btn1 <= "11";
        wait for 2000 ns;

        ---------------------------------------------------------
        -- Release both (idle again)
        ---------------------------------------------------------
        btn1 <= "00";
        wait for 1000 ns;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
