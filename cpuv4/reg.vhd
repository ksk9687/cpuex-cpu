--レジスタ,コンディションレジスタ
-- RAWの検出


-- @module : reg
-- @author : ksk
-- @date   : 2009/10/06



library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity reg is 
port (
    clk,reg_alloc,cr_alloc			: in	  std_logic;
    d: in std_logic_vector(5 downto 0);
    pd,s1,s2 : in std_logic_vector(6 downto 0);
    dflg: in	  std_logic;
    crflg,pcrflg : in std_logic_vector(1 downto 0);
    
    cr_d : in std_logic_vector(2 downto 0);
    data_d : in std_logic_vector(31 downto 0);
    data_s1,data_s2 : out std_logic_vector(31 downto 0);
    
    cr : out std_logic_vector(2 downto 0);
    d_ok,s1_ok,s2_ok,cr_ok: out std_logic
    ); 
    
end reg;
        

architecture synth of reg is
    type reg is array (0 to 63) of std_logic_vector (31 downto 0);
	signal registers : reg;
	
    type using_table_t is array (0 to 63) of std_logic;
	signal using	:	using_table_t := (others => '0');
	
	signal cr_a :std_logic_vector (2 downto 0) := "000";
	signal cr_using,rst :std_logic:= '0';
begin
  	ROC0 : ROC port map (O => rst);
    --read
    data_s1 <= registers(conv_integer(s1(5 downto 0)));
    data_s2 <= registers(conv_integer(s2(5 downto 0)));
    cr <= cr_d when crflg(0) = '1' else cr_a;
    
    --オペランドが使用可能か
    s1_ok <= not using(conv_integer(s1(5 downto 0)));
    s2_ok <= not using(conv_integer(s2(5 downto 0)));
    d_ok <= not using(conv_integer(pd(5 downto 0)));
    
    --crが正しいかどうか
    cr_ok <= (not (pcrflg(1) and cr_using)) or crflg(0);
    
    WRITE : process (clk,rst)
     begin
     	if rst = '1'then
     		using <= (others => '0');
	     	cr_using <= '0';
	     	cr_a <= "000";
	    elsif rising_edge(clk) then
	     	if dflg = '1' then
	     		registers(conv_integer(d(5 downto 0))) <= data_d;
	     	end if;
	     	
--     		if (pd(5 downto 0) = d(5 downto 0)) and dflg = '1' and reg_alloc = '1' then
--				
--     		else
     			if dflg = '1' then
     				using(conv_integer(d(5 downto 0))) <= '0';
     			end if;
     			if reg_alloc = '1' then
 	     			using(conv_integer(pd(5 downto 0))) <= '1';
     			end if;
--			end if;
	    	
	     	--Crの書き換え
	     	if crflg(0) = '1' then
	     		cr_a <= cr_d;
	     	end if;
	     	
	     	if (cr_alloc = '1') and (pcrflg(0) = '1') then
     			cr_using <= '1';
     		elsif crflg(0) = '1' then
	     		cr_using <= '0';
	     	end if;
	     	
     	end if;
     end process WRITE;
    	
    
end synth;








