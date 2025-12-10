    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.std_logic_unsigned.all; 
    --use IEEE.NUMERIC_STD.ALL;
    
    entity tb_Top_cell is
    end tb_Top_cell;
    
    architecture sim of tb_Top_cell is
    
      ---------------------------------------------------------------------------
      -- Component under test
      ---------------------------------------------------------------------------
      component Top_cell
        Port (
          clk_100Meg   : in  STD_LOGIC;
          clear        : in  STD_LOGIC;
          pred_wav     : in  STD_LOGIC;
          wave_sel_man : in  STD_LOGIC_VECTOR (1 downto 0);
          enable_bar   : in  STD_LOGIC;
          hybrid_wave  : in  STD_LOGIC;
          tick_sel     : in  STD_LOGIC;
          U_control    : in  STD_LOGIC;  -- NEW: U button
          D_control    : in  STD_LOGIC;  -- NEW: D button
          Q            : out STD_LOGIC_VECTOR (4 downto 0)
        );
      end component;
    
      ---------------------------------------------------------------------------
      -- Signals to drive the DUT
      ---------------------------------------------------------------------------
      signal clk_100Meg   : std_logic := '0';
      signal clear        : std_logic := '0';
      signal pred_wav     : std_logic := '0';
      signal wave_sel_man : std_logic_vector(1 downto 0) := (others => '0');
      signal enable_bar   : std_logic := '0';
      signal hybrid_wave  : std_logic := '0';
      signal tick_sel     : std_logic := '0';
      signal U_control    : std_logic := '0';  -- NEW
      signal D_control    : std_logic := '0';  -- NEW
      signal Q            : std_logic_vector(4 downto 0);
    
      --constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock
    
    -- ADICIONADO: sinal para monitorizar a tensão calculada 
      signal Vx_expected : real := 0.0; 
    
      constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock
    
      ----------------------------------------------------------------------------
      -- Função R-2R (sem recorrer a numeric_std): converte bit-a-bit para inteiro
      -- Esta versão NÃO usa unsigned/to_integer - assim podes continuar com
      -- IEEE.std_logic_unsigned.ALL sem misturar packages.
      ----------------------------------------------------------------------------
      FUNCTION R2R_DAC_VOLTAGE_BY_WEIGHTS (
         Q_in  : IN STD_LOGIC_VECTOR(4 DOWNTO 0)
      ) RETURN REAL IS
         CONSTANT VREF   : REAL := 3.3;
         CONSTANT N_BITS : INTEGER := 5;
         VARIABLE V_X    : REAL := 0.0;
         VARIABLE dec    : INTEGER := 0;
         VARIABLE i      : INTEGER;
      BEGIN
         -- converte bit-a-bit para inteiro (LSB é Q_in(0))
         dec := 0;
         FOR i IN 0 TO N_BITS-1 LOOP
            IF Q_in(i) = '1' THEN
               dec := dec + (2 ** i);
            END IF;
         END LOOP;
    
         -- calcula Vx como VREF * dec / (2^N - 1)
         V_X := VREF * REAL(dec) / REAL((2 ** N_BITS) - 1);
         RETURN V_X;
      END FUNCTION R2R_DAC_VOLTAGE_BY_WEIGHTS;
      
    
    begin
      ---------------------------------------------------------------------------
      -- Instantiate the DUT
      ---------------------------------------------------------------------------
      uut : Top_cell
        port map (
          clk_100Meg   => clk_100Meg, 
          clear        => clear,
          pred_wav     => pred_wav,
          wave_sel_man => wave_sel_man,
          hybrid_wave  => hybrid_wave,
          enable_bar   => enable_bar,
          tick_sel     => tick_sel,
          U_control    => U_control,   -- connect U button
          D_control    => D_control,   -- connect D button
          Q            => Q
        );
    
      ---------------------------------------------------------------------------
      -- Clock generator: 100 MHz
      ---------------------------------------------------------------------------
      clk_process : process
      begin
        clk_100Meg <= '0';
        wait for CLK_PERIOD / 2;
        clk_100Meg <= '1';/tb_Top_cell/uut/clear
        wait for CLK_PERIOD / 2;
      end process;
        
        monitor_vx_proc: process(Q)
        begin
            Vx_expected <= R2R_DAC_VOLTAGE_BY_WEIGHTS(Q);
        end process monitor_vx_proc;
      ---------------------------------------------------------------------------
      -- Stimulus process
      ---------------------------------------------------------------------------
      stim_proc : process
      begin
        -- Initial reset
        clear <= '1';
        wait for 100 ns;
        clear <= '0';
    
        -- Enable waveform generation
        enable_bar <= '1';
    
        -------------------------------------------------------------------
        -- Test case 1: Triangular waveform (manual mode)
        -------------------------------------------------------------------
        pred_wav     <= '0';
        wave_sel_man <= "00"; 
        tick_sel     <= '0';   -- select ctick_2 (lower frequency)
        wait for 1 ms;
    
        -------------------------------------------------------------------
        -- Test case 2: Square waveform (manual mode)
        -------------------------------------------------------------------
        wave_sel_man <= "01";
        tick_sel     <= '1';   -- switch to ctick (higher frequency)
        wait for 1 ms;
    
        -------------------------------------------------------------------
        -- Test case 3: Ascending ramp
        -------------------------------------------------------------------
        wave_sel_man <= "10";
        tick_sel     <= '0';   -- back to ctick_2
        wait for 1 ms;
    
        -------------------------------------------------------------------
        -- Test case 4: Descending ramp
        -------------------------------------------------------------------
        wave_sel_man <= "11";
        wait for 1 ms; 
    
        -------------------------------------------------------------------
        -- Test case 5: Automatic waveform sequence (pred_wav = '1')
        -------------------------------------------------------------------
        pred_wav <= '1';
        wave_sel_man <= "00";  -- selection ignored in auto mode
        tick_sel <= '1';
        hybrid_wave <= '0';    -- ensure hybrid is off first
        wait for 4 ms;
        
        -------------------------------------------------------------------
        -- Test case 6: Hybrid wave with button control tests
        -------------------------------------------------------------------
        pred_wav <= '0';
        hybrid_wave <= '1';    -- enable hybrid mode
        wait for 1 ms;
        
        U_control <= '1';      -- Hold U button
        D_control <= '1', '0' after 100us,'1' after 200us, '0' after 300us,'1' after 400us,'0' after 500us;
        wait for 1 ms;
        
        U_control <= '0';
        D_control <= '1';      -- Hold U button
        U_control <= '1', '0' after 100us,'1' after 200us, '0' after 300us,'1' after 400us,'0' after 500us,'1' after 600us,'0' after 700us,'1' after 800us,'0' after 900us;  
        wait for 1 ms; 
        D_control <= '0';      -- Release U button
        
        wait for 1 ms;         -- Observe waveform with mid level
    
        D_control <= '1';      -- Hold D button
        wait for 50 ns;
        for i in 1 to 31 loop  -- 15 steps down from 31 to 16
          U_control <= '1';    -- Press U button
          wait for 50 ns;           
          U_control <= '0';    -- Release U button
          wait for 50 ns;
        end loop;
        D_control <= '0';      -- Release D button
        wait for 2 ms;         -- Observe waveform with mid level
        
        U_control <= '1';      -- Hold U button
        wait for 50 ns;
        for i in 1 to 40 loop
          D_control <= '1';    -- Press D button
          wait for 50 ns;
          D_control <= '0';    -- Release D button
          wait for 50 ns;
        end loop;
        U_control <= '0';      -- Release U button
        wait for 1 ms;         -- Observe waveform with mid level       
        
        D_control <= '1';      -- Hold D button
        wait for 50 ns;
        for i in 1 to 2 loop   -- 15 steps down from 31 to 16
          U_control <= '1';    -- Press U button
          wait for 50 ns;           
          U_control <= '0';    -- Release U button
          wait for 50 ns;
        end loop;
        D_control <= '0';      -- Release D button
        wait for 2 ms;         -- Observe waveform with mid level
        
--        D_control <= '1';      -- Hold D button
--        wait for 50 ns;
--        for i in 1 to 16 loop  -- 15 steps down from 31 to 16
--          U_control <= '1';    -- Press U button
--          wait for 50 ns;           
--          U_control <= '0';    -- Release U button
--          wait for 50 ns;
--        end loop;
--        D_control <= '0';      -- Release D button
--        wait for 2 ms;         -- Observe waveform with mid level
    --    D_control <= '1';      -- Hold D button
    --    wait for 50 ns;
    --    for i in 1 to 32 loop  -- 15 steps down from 31 to 16
    --      U_control <= '1';    -- Press U button
    --      wait for 50 ns;
    --      U_control <= '0';    -- Release U button
    --      wait for 50 ns;
    --    end loop;
    --    D_control <= '0';      -- Release D button
    --    wait for 2 ms;         -- Observe waveform with mid level 
        -------------------------------------------------------------------
        -- Disable waveform
        -------------------------------------------------------------------
        enable_bar <= '1';
        wait for 500 ns;
    
        -------------------------------------------------------------------
        -- End simulation
        -------------------------------------------------------------------
        report "Simulation complete!";
        wait;
      end process;
    
    end sim;
