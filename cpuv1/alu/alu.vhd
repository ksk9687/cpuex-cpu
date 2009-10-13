library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.instruction.all;

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

  with op select
  C <=	A + B when op_add | op_addi,
  		A - B when op_sub,
  		SHR(A, B) when op_srl,
  		SHL(A, B) when op_sll,
  		cmp when op_cmp,
  		B when op_li,
		"11111111111111111111111111111111" when others;
  
end STRUCTURE;
