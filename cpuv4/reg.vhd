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
    clk,flush,rob_alloc1,rob_alloc2: in	  std_logic;

    pd,pd2 : in std_logic_vector(5 downto 0);
    s1,s2,s12,s22 : in std_logic_vector(5 downto 0);
       
    dflg: in std_logic;
    d: in std_logic_vector(5 downto 0);
    data_d : in std_logic_vector(31 downto 0);
    data_s1,data_s2,data_s12,data_s22 : out std_logic_vector(31 downto 0);
    
    s1_ok,s2_ok,s12_ok,s22_ok: out std_logic
    ); 
    
end reg;
        

architecture synth of reg is
    type reg is array (0 to 63) of std_logic_vector (31 downto 0);
	signal registers : reg;
	
    type using_table_t is array (0 to 63) of std_logic_vector (2 downto 0);
	signal using	:	using_table_t := (others => (others => '0'));
	signal rst	:	std_logic := '0';
	
	component distreg is
	port (
	a: IN std_logic_VECTOR(5 downto 0);
	d: IN std_logic_VECTOR(31 downto 0);
	dpra: IN std_logic_VECTOR(5 downto 0);
	clk: IN std_logic;
	we: IN std_logic;
	spo: OUT std_logic_VECTOR(31 downto 0);
	dpo: OUT std_logic_VECTOR(31 downto 0));
	END component;
	
begin
  	ROC0 : ROC port map (O => rst);
    --read
    R0 : distreg port map(
    	d,data_d,s1,clk,dflg,open,data_s1
    );
    R1 : distreg port map(
    	d,data_d,s2,clk,dflg,open,data_s2
    );
    R2 : distreg port map(
    	d,data_d,s12,clk,dflg,open,data_s12
    );
    R3 : distreg port map(
    	d,data_d,s22,clk,dflg,open,data_s22
    );
    
    
    --どこから値を読めばよいか
    --0:リオーダバッファ 1:レジスタファイル
    s1_ok <= '1' when using(conv_integer(s1)) = "000" else '0';
    s2_ok <= '1' when using(conv_integer(s2)) = "000" else '0';
    
    s12_ok <= '1' when using(conv_integer(s12)) = "000" else '0';
    s22_ok <= '1' when using(conv_integer(s22)) = "000" else '0';
    
    WRITE : process (clk,rst)
     begin
     	if rst = '1' then
     		using <= (others => (others => '0'));
     	elsif rising_edge(clk) then
	    	if flush = '1' then
	    		using <= (others => (others => '0'));
	    	else
		     	if (pd = pd2) and (rob_alloc1 = '1') and (rob_alloc2 = '1') then
	     			if (pd = d) and (dflg = '1') then
						using(conv_integer(pd)) <= using(conv_integer(pd)) + '1';
		     		else
		     			if dflg = '1' then
		     				using(conv_integer(d)) <= using(conv_integer(d)) - '1';
		     			end if;
	 	     			using(conv_integer(pd)) <= using(conv_integer(pd)) + "10";
					end if;
	     		else
	     			if (pd = d) and (dflg = '1') and (rob_alloc1 = '1') then
						if rob_alloc2 = '1' then
		 	     			using(conv_integer(pd2)) <= using(conv_integer(pd2)) + '1';
		     			end if;
		     		elsif (pd2 = d) and (dflg = '1') and (rob_alloc2 = '1') then
		     			if rob_alloc1 = '1' then
		 	     			using(conv_integer(pd)) <= using(conv_integer(pd)) + '1';
		     			end if;
		  	     	else
		     			if dflg = '1' then
		     				using(conv_integer(d)) <= using(conv_integer(d)) - '1';
		     			end if;
		     			if rob_alloc1 = '1' then
		 	     			using(conv_integer(pd)) <= using(conv_integer(pd)) + '1';
		     			end if;
		     			if rob_alloc2 = '1' then
		 	     			using(conv_integer(pd2)) <= using(conv_integer(pd2)) + '1';
		     			end if;
					end if;
	     		end if;
     		end if;
     	end if;
     end process WRITE;
    	
    
end synth;








