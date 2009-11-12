library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IROM is
	port  (
		clk : in std_logic;
		pc : in std_logic_vector(19 downto 0);
		
		inst : out std_logic_vector(31 downto 0)
	);
end IROM;

architecture arch of IROM is

begin



end arch;

