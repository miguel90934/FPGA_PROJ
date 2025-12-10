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

entity Top_cell is 
    Port ( clk_100Meg : in STD_LOGIC;--
           clear : in STD_LOGIC;--
           pred_wav : in STD_LOGIC;--
           wave_sel_man : in STD_LOGIC_VECTOR (1 downto 0); --
           tick_sel: in STD_LOGIC;--
           enable_bar : in STD_LOGIC;--
           U_control: in STD_LOGIC;--
           D_control: in STD_LOGIC;--
           hybrid_wave : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR (4 downto 0));
end Top_cell ;

architecture structural of Top_cell  is
  
CONSTANT MAX_WIDTH: natural:= 9;  -- com 16 Fica perto dos 1.69kHz
CONSTANT MAX_WIDTH_PRE: natural:= 15; --27 para testes 
  -- Set MAX_WIDTH := 26 for hardware implementation only  
  
signal ctick : std_logic := '0'; 
signal ctick_2 : std_logic := '0';
signal predef_ctick : std_logic := '0';

signal counter1 : std_logic_vector (4 downto 0) := (others =>'0'); 
signal up_down : std_logic := '0'; 
 
COMPONENT wave
 PORT (  clk_100Meg : in STD_LOGIC;
         clear : in STD_LOGIC;
         wave_sel_man : in STD_LOGIC_VECTOR (1 downto 0);  
         enable_bar : in STD_LOGIC;
         pred_wav : in STD_LOGIC;
         tick_sel: in STD_LOGIC;
         hybrid_wave : in STD_LOGIC;
         U_control: in STD_LOGIC;
         D_control: in STD_LOGIC;
         ctick : in STD_LOGIC;
         predef_ctick:in STD_LOGIC; 
         Q : out STD_LOGIC_VECTOR (4 downto 0); 
         ctick_2 : in STD_LOGIC);   
END COMPONENT; 

begin

     process(clk_100Meg,clear) 
         variable counter : std_logic_vector (MAX_WIDTH-1 downto 0) := (others =>'0'); 
         variable counter_2tick : std_logic_vector (MAX_WIDTH-1 downto 0) := (others =>'0');
         variable predef_counter : std_logic_vector (MAX_WIDTH_PRE-1 downto 0) := (others =>'0');
         Variable i: std_logic_vector (1 downto 0) := (others => '0');
         constant all_ones: std_logic_vector (MAX_WIDTH-1 downto 0) := (others =>'1');
         constant all_ones_pre: std_logic_vector (MAX_WIDTH_PRE-1 downto 0) := (others =>'1');
         variable ctick_control: std_logic := '0';
     begin
    if clear = '1' then
        counter := (others => '0'); 
        --i := (others => '0');
        counter_2tick := (others => '0');
        ctick_control := '0';
        predef_counter:= (others => '0');
        ctick  <= '0';
        ctick_2 <= '0';
        i := "00";

    elsif rising_edge(clk_100Meg) then
        --counter := counter + 1;
        counter_2tick := counter_2tick + 1;
        predef_counter:= predef_counter + 1;
        if (counter_2tick = all_ones) then 
            counter_2tick := (others => '0');
            ctick_2 <= '1';
            if(ctick_control = '0') then
                ctick_control := '1'; 
            else 
                ctick_control := '0';
                ctick <= '1'; 
            end if;
         else 
            ctick_2 <= '0';
            ctick <= '0';
         end if;   
         if predef_counter = all_ones_pre  then
                if i = "10" then
                    predef_counter := (others => '0');
                    predef_ctick <= '1';
                  i := "00";
                else
                    i := i+1;
                end if;  
         else
                predef_ctick <= '0';            
         end if;       
     end if;      
     end process;

    u1: wave PORT MAP( 
        clk_100Meg => clk_100Meg, clear => clear, wave_sel_man => wave_sel_man, tick_sel => tick_sel, 
         ctick => ctick,ctick_2 => ctick_2, predef_ctick=> predef_ctick, enable_bar => enable_bar,
         hybrid_wave => hybrid_wave, pred_wav => pred_wav, Q => Q, U_control => U_control, D_control => D_control); 
            
         
    --process(clk_100Meg)
    
    --variable counter1 : std_logic_vector (4 downto 0) := (others =>'0');
    
    --begin

--        if rising_edge(clk_100Meg) then
--            if clear = '1' then
--                    counter1 := (others => '0');
--            end if; 
--            if  ctick = '1' and enable_bar = '1'  then
--                if wave_sel = "00" then 
--                    counter1 := counter1 + 1;
--                elsif wave_sel = "01" then
--                    counter1 := counter1 - 1;
--                else 
--                    if up_down = '1' then
--                        counter1 := counter1 + 1;
--                    elsif up_down = '0' then                    
--                        counter1 := counter1 - 1;
--                    end if;
--                    if counter1 = "1111" then
--                        up_down <= '0';
--                    elsif counter1 = "0000" then
--                        up_down <= '1';
--                    end if;
--                end if;  
--            end if; 
--        end if;
--        Q <= counter1;  
--    end process;

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


