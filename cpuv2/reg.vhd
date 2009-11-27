--レジスタ　コンディションレジスタ
-- RAW WAWの検出


-- @module : reg
-- @author : ksk
-- @date   : 2009/10/06



library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg is 
port (
    clk,rst,flush,stallx			: in	  std_logic;
    d: in std_logic_vector(5 downto 0);
    pd,s1,s2 : in std_logic_vector(6 downto 0);
    dflg: in	  std_logic;
    crflg,pcrflg : in std_logic_vector(1 downto 0);
    
    cr_d : in std_logic_vector(2 downto 0);
    data_d : in std_logic_vector(31 downto 0);
    data_s1,data_s2 : out std_logic_vector(31 downto 0);
    
    cr : out std_logic_vector(2 downto 0);
    reg_ok: out std_logic
    ); 
    
end reg;
        

architecture synth of reg is
    type reg is array (0 to 63) of std_logic_vector (31 downto 0);
	signal registers : reg;
	
    type using_table_t is array (0 to 63) of std_logic;
	signal using	:	std_logic_vector (63 downto 0) := (others => '0');
	
	signal cr_a :std_logic_vector (2 downto 0) := "000";
	signal cr_using :std_logic:= '0';
	signal ok :std_logic:= '0';
begin
    --read
    data_s1 <= registers(conv_integer(s1(5 downto 0)));
    data_s2 <= registers(conv_integer(s2(5 downto 0)));
    cr <= cr_a;
    
    reg_ok <= ok;
    
    ok <= not ((s1(6) and using(conv_integer(s1(5 downto 0))))
    or (s2(6) and using(conv_integer(s2(5 downto 0))))
    or (pd(6) and using(conv_integer(pd(5 downto 0))))
    or (pcrflg(1) and cr_using));
    
--    ok <=
--    '0' when (s1(6) = '1' and using(conv_integer(s1(5 downto 0))) = '1') else--RAW
--    '0' when (s2(6) = '1' and using(conv_integer(s2(5 downto 0))) = '1') else--RAW
--    '0' when (pd(6) = '1' and using(conv_integer(pd(5 downto 0))) = '1') else--WAW
--    '0' when (pcrflg(1) = '1' and cr_using = '1') else--CR RAW,WAW
--    '1';
    
    
    WRITE : process (clk,rst)
     begin
     	if rst = '1'then
     		using <= (others => '0');
	     	cr_using <= '0';
	     	cr_a <= "000";
	    elsif rising_edge(clk) then
--	    	if flush = '1' then
--	     		using<= (others => '0');
--		     	cr_using <= '0';
--		     	cr_a <= "000";
--	    	else
	     	if dflg = '1'then
	     		registers(conv_integer(d(5 downto 0))) <= data_d;
	     		using(conv_integer(d(5 downto 0))) <= '0';
	     	end if;
	     	
	     	if ok = '1' and stallx = '1'and flush = '0' then
	     		using(conv_integer(pd(5 downto 0))) <= pd(6);
     			cr_using <= pcrflg(0);
	     	end if;
	     	
	     	--Crの書き換え
	     	if crflg = "11" then
	     		cr_a <= cr_d;
	     		cr_using <= '0';
	     	end if;
--	     	end if;
     	end if;
     end process WRITE;
    	
    

end synth;








