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

    pd,pd2 : in std_logic_vector(6 downto 0);
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
	
begin
  	ROC0 : ROC port map (O => rst);
    --read
    data_s1 <= registers(conv_integer(s1(5 downto 0)));
    data_s2 <= registers(conv_integer(s2(5 downto 0)));
    data_s12 <= registers(conv_integer(s12(5 downto 0)));
    data_s22 <= registers(conv_integer(s22(5 downto 0)));
    
    --どこから値を読めばよいか
    --0:リオーダバッファ 1:レジスタファイル
    s1_ok <= '1' when using(conv_integer(s1(5 downto 0))) = "000" else '0';
    s2_ok <= '1' when using(conv_integer(s2(5 downto 0))) = "000" else '0';
    
    s12_ok <= '1' when using(conv_integer(s12(5 downto 0))) = "000" else '0';
    s22_ok <= '1' when using(conv_integer(s22(5 downto 0))) = "000" else '0';
    
    WRITE : process (rst)
     begin
     	if rising_edge(clk) then
	    	if flush = '1' then
	    		using <= others => (others => '0'));
	    	else
		     	if dflg = '1' then
		     		registers(conv_integer(d(5 downto 0))) <= data_d;
		     	end if;
		     	
		     	
		     	if (pd(5 downto 0) = pd2(5 downto 0)) and rob_alloc1 = '1' and rob_alloc2 = '1' then
	     			if (pd(5 downto 0) = d(5 downto 0)) and dflg = '1' then
						using(conv_integer(pd(5 downto 0))) <= using(conv_integer(pd(5 downto 0))) + '1';
		     		else
		     			if dflg = '1' then
		     				using(conv_integer(d(5 downto 0))) <= using(conv_integer(d(5 downto 0))) - '1';
		     			end if;	     			
	 	     			using(conv_integer(pd(5 downto 0))) <= using(conv_integer(pd(5 downto 0))) + "10";
					end if;
	     		else
	     			if (pd(5 downto 0) = d(5 downto 0)) and dflg = '1' and rob_alloc1 = '1' then
						if rob_alloc2 = '1' then
		 	     			using(conv_integer(pd2(5 downto 0))) <= using(conv_integer(pd2(5 downto 0))) + '1';
		     			end if;
		     		elsif (pd2(5 downto 0) = d(5 downto 0)) and dflg = '1' and rob_alloc2 = '1' then
		     			if rob_alloc1 = '1' then
		 	     			using(conv_integer(pd(5 downto 0))) <= using(conv_integer(pd(5 downto 0))) + '1';
		     			end if;
		  	     	else
		     			if dflg = '1' then
		     				using(conv_integer(d(5 downto 0))) <= using(conv_integer(d(5 downto 0))) - '1';
		     			end if;
		     			if rob_alloc1 = '1' then
		 	     			using(conv_integer(pd(5 downto 0))) <= using(conv_integer(pd(5 downto 0))) + '1';
		     			end if;
		     			if rob_alloc2 = '1' then
		 	     			using(conv_integer(pd2(5 downto 0))) <= using(conv_integer(pd2(5 downto 0))) + '1';
		     			end if;
					end if;
	     		end if;
     		end if;
     	end if;
     end process WRITE;
    	
    
end synth;








