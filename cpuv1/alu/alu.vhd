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

  C <= A + B     when op(5 downto 1) = op_add(5 downto 1) else
       A - B     when op = op_sub else
       SHR(A, B) when op = op_srl else
       SHL(A, B) when op = op_sll else
       cmp       when op = op_cmp else
       B         when op = op_li else
       "11111111111111111111111111111111";  -- BAD OP
  
end STRUCTURE;
