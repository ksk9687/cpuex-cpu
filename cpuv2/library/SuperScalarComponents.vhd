library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package SuperScalarComponents is

component ALU_IM
  port (
 	clk : in std_logic;
    op : in std_logic_vector(2 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    C    : out std_logic_vector(31 downto 0)
    );
end component;

end package;


