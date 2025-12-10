library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity wave is
 PORT (  clk_100Meg : in STD_LOGIC; 
         clear : in STD_LOGIC;
         wave_sel_man : in STD_LOGIC_VECTOR (1 downto 0);
         enable_bar : in STD_LOGIC;
         pred_wav : in STD_LOGIC;
         hybrid_wave : in STD_LOGIC;
         ctick : in STD_LOGIC;
         predef_ctick:in STD_LOGIC;
         tick_sel: in STD_LOGIC;
         U_control: in STD_LOGIC;
         D_control: in STD_LOGIC;
         Q : out STD_LOGIC_VECTOR (4 downto 0); 
         ctick_2 : in STD_LOGIC);   
end wave;

architecture Behavioural of wave is 

    signal wave_reg : std_logic_vector (4 downto 0) := (others =>'0');
    signal step_reg : std_logic_vector (4 downto 0) := ("10000");
    signal enable_step  : std_logic := '0'; 
    signal square  : std_logic;
    signal hold_direction : std_logic_vector(1 downto 0);
    signal wave_sel: std_logic_vector (1 downto 0); 
    signal wave_sel_auto: std_logic_vector (1 downto 0);
    signal up_down_q, up_down_d : std_logic;
    signal up_down_step : std_logic := '0';
    signal tick: std_logic;
    signal Qi:  natural:= 0;
    signal count : std_logic := '0';
    type estados is (inicial, hd, stay, hu, down);
    type estados_U is (inicial_U,uh,ut);
    type estados_D is (inicial_D,dh,dt);
    signal estado_actual, estado_seguinte: estados; 
    signal estado_actual_U, estado_seguinte_U: estados_U;
    signal estado_actual_D, estado_seguinte_D: estados_D;
--begin
   
--    process(clk_100Meg)
--    variable up_down : std_logic := '1';
--    variable count   : std_logic_vector (2 downto 0) := (others =>'0');
--    --variable square  : std_logic := '0'; 
begin

    process(ctick,ctick_2,tick_sel) --tick FREQ
    begin
        if tick_sel = '1' then --square  
            tick <= ctick;     --F1
        else 
            tick <= ctick_2;   --F2=F1/2
        end if; 
    end process;

    process(clk_100Meg)--contador up_down
    begin
    
    if rising_edge(clk_100Meg) then
        if(tick  = '1' )then
            if clear = '1' then
                   wave_reg <= (others => '0');
            elsif enable_bar = '1' then 
                if up_down_q = '1' then
                    wave_reg <= wave_reg + 1;
                else
                    wave_reg <= wave_reg - 1; 
                end if;
            end if;
         end if;
     end if;
     end process;

        process(clk_100Meg)--contador up_down
    begin
    
    if rising_edge(clk_100Meg) then
        --if(tick  = '1' )then
            if clear = '1' then
                   step_reg <= ("10000");
            elsif enable_step = '1' then 
                if up_down_step = '1' and step_reg /= "00000"  then
                    step_reg <= step_reg + 1;
                elsif up_down_step = '0' and step_reg /= "11111"  then
                    step_reg <= step_reg - 1; 
                end if;
            end if;
         --end if; 
     end if;
     end process;
     
     
    process(clk_100Meg)--registo up_down
    begin
    
    if rising_edge(clk_100Meg) then
        if(tick = '1')then
            if clear = '1' then
                up_down_q <= '0';
            else 
                up_down_q <= up_down_d; 
            end if;
         end if;
     end if;
     end process;
       
     process(wave_sel,wave_reg,up_down_q)
     begin
        if wave_sel = "10" then --Ascending
            up_down_d <= '1';
        elsif wave_sel = "11" then -- Descending
            up_down_d <= '0';           
        elsif wave_sel = "00" then -- Triangular
            if wave_reg = "11110" then
                up_down_d <= '0';
            elsif wave_reg = "00001" then
                up_down_d <= '1';
            else 
                up_down_d <= up_down_q;
            end if;
        else                        --Squared
            if wave_reg = "11110" then
                up_down_d <= '0';
            elsif wave_reg = "00001" then
                up_down_d <= '1';
            else 
                up_down_d <= up_down_q;
            end if;    
        end if;
    end process;
    
    process(wave_sel, pred_wav, wave_sel_man, wave_sel_auto, hybrid_wave) -- predefined_wave
    begin
        if pred_wav = '0' then
            wave_sel <= wave_sel_man;
        elsif hybrid_wave = '1' then 
            wave_sel <= "00";
        else  
            wave_sel <= wave_sel_auto;
        end if;   
    end process;
    
    process(clk_100Meg)--wave_sel_auto
    begin
    if clear = '1' then
       wave_sel_auto <= (others => '0');
    elsif rising_edge(clk_100Meg) then
        if(predef_ctick = '1')then
            wave_sel_auto <= wave_sel_auto + 1; 
         end if;
     end if;
     end process;
   
   registo_de_estado: process (clk_100Meg, clear)
     begin -- processo 1: síncrono
         if clear ='1' then
            estado_actual <= inicial;
         elsif clk_100Meg'event and clk_100Meg = '1' then
            estado_actual <= estado_seguinte;
         end if;
         end process; --registo_de_estado
   --type estados is (inicial, hd, stay, hu, down);
   
   
   
   registo_de_estado_U: process (clk_100Meg, clear)
     begin -- processo 1: síncrono
         if clear ='1' then
            estado_actual_U <= inicial_U;
         elsif clk_100Meg'event and clk_100Meg = '1' then
            estado_actual_U <= estado_seguinte_U;
         end if;
         end process; --registo_de_estado
   --type estados_1 is (inicial_1,uh,dh,ut,dt);
   
      proc_estado_seguinte_U: process (estado_actual_U, U_control)
     begin -- processo 2: lógica do estado_seguinte
     
        estado_seguinte_U <= estado_actual_U;
         -- por omissão mantém o estado --
            case estado_actual_U is
            when inicial_U =>
                 if (U_control = '1') then
                    estado_seguinte_U <= uh;
                 end if;                 
            when uh =>
                if ( U_control = '0' ) then
                    estado_seguinte_U <= ut; 
                end if;
            when ut =>
                    estado_seguinte_U <= inicial_U;
            end case;
    end process; --proc_estado_seguinte

   registo_de_estado_D: process (clk_100Meg, clear)
     begin -- processo 1: síncrono
         if clear ='1' then
            estado_actual_D <= inicial_D;
         elsif clk_100Meg'event and clk_100Meg = '1' then
            estado_actual_D <= estado_seguinte_D;
         end if;
         end process; --registo_de_estado
   --type estados_1 is (inicial_1,uh,dh,ut,dt);

  proc_estado_seguinte_D: process (estado_actual_D, D_control)
     begin -- processo 2: lógica do estado_seguinte
     
        estado_seguinte_D <= estado_actual_D;
         -- por omissão mantém o estado --
            case estado_actual_D is
            when inicial_D =>
                 if (D_control = '1') then
                    estado_seguinte_D <= dh;
                 end if;                 
            when dh =>
                if ( D_control = '0' ) then
                    estado_seguinte_D <= dt; 
                end if;
            when dt =>
                    estado_seguinte_D <= inicial_D;
            end case;
    end process; --proc_estado_seguinte
   
   process(step_reg,estado_actual_D,estado_actual_U, D_control, U_control)
    begin
        enable_step <= '0';
        up_down_step <= '0';
        if U_control = '1' then
            up_down_step <= '1';
            case estado_actual_D is
                when inicial_D => enable_step <= '0';
                when dh => enable_step <= '0';
                when dt => enable_step <= '1';
            end case;
        end if; 
        if D_control = '1' then
            up_down_step <= '0'; 
            case estado_actual_U is
                when inicial_U => enable_step <= '0';
                when uh => enable_step <= '0';
                when ut => enable_step <= '1';
            end case;
        end if;        
   end process;
   
   proc_estado_seguinte: process (estado_actual, wave_reg, up_down_d)
     begin -- processo 2: lógica do estado_seguinte
     
        estado_seguinte <= estado_actual;
         -- por omissão mantém o estado --
            case estado_actual is
            when inicial =>
                 if (up_down_q = '0') then
                    estado_seguinte <= hd;
                 end if;
            when hd =>
                if ( (wave_reg = step_reg and up_down_q = '0')or(wave_reg = "00000" and up_down_q = '1') ) then
                    estado_seguinte <= stay;
                end if;
            when stay =>
                if ((wave_reg = step_reg and up_down_q = '1')or(wave_reg = "11111" and up_down_q = '0')) then
                    estado_seguinte <= hu;
                end if;
            when hu =>
                if (up_down_q = '0') then
                    estado_seguinte <= down;
                end if;
            when  down =>
                if (up_down_q = '1') then
                    estado_seguinte <= inicial;
                end if;
            end case;
    end process; --proc_estado_seguinte   
   
    process(wave_reg, wave_sel, estado_actual, enable_bar, hybrid_wave, step_reg) --Output
      
    begin
        
        if (wave_sel = "01" and enable_bar = '1' and hybrid_wave = '0') then --square
            if wave_reg > "01111" then
                Q <= "11111";
            else    
                Q <= "00000";
            end if;
        elsif (hybrid_wave = '1') then
            case estado_actual is
            when inicial => Q <= wave_reg;
            when hd => Q <= wave_reg;
            when stay => Q <= step_reg;
            when hu => Q <= wave_reg;
            when down => Q <= wave_reg;
            --type estados is (inicial, hd, stay, hu, down);
            end case;   
        else
            Q <= wave_reg;
            --Qi <= wave_reg;
        end if;
    end process;
      
   
    
    
    
    
    ----------------------------------------------------------------------------------------            
--        elsif wave_sel = "11" then --Descending
--                if up_down = '1' then
--                    wave_reg <= "11111";
--                else
--                    wave_reg <= wave_reg - 1;
--                end if;
--                if wave_sel = "00" then --Triangular
--                    if up_down = '1' then
--                        wave_reg <= wave_reg + 1;
--                    else
--                        wave_reg <= wave_reg - 1; 
--                    end if;
                 
--                elsif wave_sel = "01" then --square
--                    if up_down = '1' then
--                        wave_reg <= "00000";
--                    else
--                        wave_reg <= "00000";
--                    end if;  
                    
--                elsif wave_sel = "10" then --Ascending
--                    if up_down = '0' then
--                        wave_reg <= "00000";
--                    else
--                        wave_reg <= wave_reg + 1;
--                    end if;
                    
--                elsif wave_sel = "11" then --Descending
--                    if up_down = '1' then
--                        wave_reg <= "11111";
--                    else
--                        wave_reg <= wave_reg - 1;
--                    end if;
--                end if;
           
            
--            end if;

--if   (ctick = '1' and enable_bar = '1' and pred_wav = '0')  then



--        if rising_edge(clk_100Meg) then
--            if clear = '1' then
--                    wave_reg <= (others => '0');
--            end if; 
--            if (predef_ctick = '1' and  pred_wav = '1' ) then
--                if count = "00" then
--                    if up_down = '1' then --Triangular
--                        wave_reg <= wave_reg + 1;
--                    else
--                        wave_reg <= wave_reg - 1;
--                    end if; 
--                elsif   count = "01" then --square
--                    if up_down = '1' then
--                        wave_reg <= "00000";
--                    else
--                        wave_reg <= "00000";
--                    end if; 
--                elsif   count = "10" then   --Ascending
--                    if up_down = '0' then
--                        wave_reg <= "00000";
--                    else
--                        wave_reg <= wave_reg + 1;
--                    end if;
--                elsif   count = "11" then   --Descending
--                    if up_down = '1' then
--                        wave_reg <= "11111";
--                    else
--                        wave_reg <= wave_reg - 1;
--                    end if;
--                end if; 
--                count := count + 1;                           
--            end if;
             
--            if   (ctick = '1' and enable_bar = '1' and pred_wav = '0')  then
                 
--                if wave_sel = "00" then --Triangular
--                    if up_down = '1' then
--                        wave_reg <= wave_reg + 1;
--                    else
--                        wave_reg <= wave_reg - 1; 
--                    end if;
                 
--                elsif wave_sel = "01" then --square
--                    if up_down = '1' then
--                        wave_reg <= "00000";
--                    else
--                        wave_reg <= "00000";
--                    end if;  
                    
--                elsif wave_sel = "10" then --Ascending
--                    if up_down = '0' then
--                        wave_reg <= "00000";
--                    else
--                        wave_reg <= wave_reg + 1;
--                    end if;
                    
--                elsif wave_sel = "11" then --Descending
--                    if up_down = '1' then
--                        wave_reg <= "11111";
--                    else
--                        wave_reg <= wave_reg - 1;
--                    end if;
--                end if;
--           end if;      
--                if wave_reg = "11111" then
--                    up_down := '0';
--                elsif wave_reg = "00000" then
--                    up_down := '1';   
--                end if;
               
--            --end if; --ctick_enable 
--        end if; --rising
--        Q <= wave_reg;  
    
--    end process;

end Behavioural; 
 
