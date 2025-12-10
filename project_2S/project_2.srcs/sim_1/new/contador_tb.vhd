----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.10.2025
-- Design Name: Testbench for contador
-- Module Name: tb_contador
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench to simulate the "contador" module
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_contador is
-- Testbench has no ports
end tb_contador;

architecture Behavioral of tb_contador is

    -- Component Declaration for the Unit Under Test (UUT)
    component contador
        Port ( clk_100Meg  : in  STD_LOGIC;
               rst         : in  STD_LOGIC;
               clear       : in  STD_LOGIC;
               enable_bar  : in  STD_LOGIC;
               Q           : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    -- Signals to connect to UUT
    signal clk_100Meg  : std_logic := '0';
    signal rst         : std_logic := '0';
    signal clear       : std_logic := '0';
    signal enable_bar  : std_logic := '0';
    signal Q           : std_logic_vector(4 downto 0);

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz clock

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: contador
        Port map (
            clk_100Meg  => clk_100Meg,
            rst         => rst,
            clear       => clear,
            enable_bar  => enable_bar,
            Q           => Q
        );

    ------------------------------------------------------------------------
    -- Clock Generation
    ------------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk_100Meg <= '0';
            wait for CLK_PERIOD / 2;
            clk_100Meg <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    ------------------------------------------------------------------------
    -- Stimulus Process
    ------------------------------------------------------------------------
    stim_proc: process
    begin
        wait for 100ns;
        -- Initial Reset
        rst <= '1';
        clear <= '1';
        enable_bar <= '0';
        wait for 0.15 ms;

        rst <= '0';  -- Release reset
        clear <= '0';
        wait for 100 ns;

        -- Enable counting
        enable_bar <= '1';
        wait for 1000 ns;
        
        
         --Trigger clear
        clear <= '1';
        wait for 20 ns;
        clear <= '0';
        wait for 200 ns;

        -- Disable counting
        enable_bar <= '0';
        wait for 200 ns;

        -- Re-enable counting
        enable_bar <= '1';
        wait for 1.5 ms;
        clear <= '1';
        wait for 20 ns;
        clear <= '0';
        wait for 200 ns;
        enable_bar <= '0';
        wait for 0.3ms;
        enable_bar <= '1'; 
        -- End of simulation
        wait;
    end process;

end Behavioral;