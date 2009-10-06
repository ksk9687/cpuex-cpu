library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ALU is

  port (
    op : in std_logic_vector(5 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    C    : out std_logic_vector(31 downto 0));

end ALU;


architecture STRUCTURE of ALU is

  signal lt, eq, gt : std_logic;
  signal cmp : std_logic_vector(31 downto 0);

begin  -- STRUCTURE

  lt <= '1' when A < B else '0';
  eq <= '1' when A = B else '0';
  gt <= '1' when A > B else '0';
  cmp <= "00000000000000000000000000000" & gt & eq & lt;

  C <= A + B     when op(5 downto 1) = "00000" else
       A - B     when op = "000010" else
       SHR(A, B) when op = "000011" else
       SHL(A, B) when op = "000100" else
       cmp       when op = "001100" else
       "11111111111111111111111111111111";  -- BAD OP
  
end STRUCTURE;
