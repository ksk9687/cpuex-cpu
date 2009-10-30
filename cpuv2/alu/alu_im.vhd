library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.instruction.all;

entity ALU_IM is

  port (
 	clk : in std_logic;
    op : in std_logic_vector(2 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    C    : out std_logic_vector(31 downto 0)
    );
end ALU_IM;


architecture STRUCTURE of ALU_IM is

begin  -- STRUCTURE

  with op select
  C <=	A + B when alu_op_addi,
  		SHL(A, B) when alu_op_sll,
  		B when alu_op_li,
		"11111111111111111111111111111111" when others;
 
  
end STRUCTURE;
