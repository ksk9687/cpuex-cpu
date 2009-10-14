

-- @module : loadstore
-- @author : ksk
-- @date   : 2009/10/06


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.util.all; 

entity lsu is 
port (
    --clk			: in	  std_logic
    lsop : in std_logic_vector(1 downto 0);
	
	reg : in std_logic_vector(31 downto 0);
	im : in std_logic_vector(15 downto 0);
	
    loadstore : out std_logic_vector(1 downto 0);
	address : out std_logic_vector(31 downto 0)
    );
     
end lsu;     
        

architecture synth of lsu is
        
begin

	loadstore <= lsop;
	address <= reg + sign_extention(im);	 
end synth;








