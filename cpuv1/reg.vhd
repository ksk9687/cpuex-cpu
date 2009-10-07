-- @module : reg
-- @author : ksk
-- @date   : 2009/10/06

--ÉåÉWÉXÉ^

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg is 
port (
    clk			: in	  std_logic;
    d,s1,s2 : in std_logic_vector(4 downto 0);
    dflg : in std_logic;
    
    data_d : in std_logic_vector(31 downto 0);
    data_s1,data_s2 : out std_logic_vector(31 downto 0)
    
    ); 
    
end reg;     
        

architecture synth of reg is    
    type reg is array (0 to 31) of std_logic_vector (31 downto 0);
	signal registers : reg;
	
begin
    --read
    data_s1 <= registers(conv_integer(s1));
    data_s2 <= registers(conv_integer(s2));
    
    WRITE : process (clk)
     -- Declarations
     begin
	     if rising_edge(Clk) then
	     	if dflg = '1' then
	     		registers(conv_integer(d)) <= data_d;
	     	else
	     	    registers(conv_integer(d)) <= registers(conv_integer(d));
	     	end if;
     end if;
     end process WRITE;
    	
    
    

end synth;








