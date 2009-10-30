library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.instruction.all;

entity ALU is
  port (
 	clk : in std_logic;
    op : in std_logic_vector(2 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    C    : out std_logic_vector(31 downto 0);
    cmp    : out std_logic_vector(2 downto 0)
    );
end ALU;


architecture STRUCTURE of ALU is

  signal lt, eq, gt : std_logic;
  signal cmp : std_logic_vector(31 downto 0);

  signal lt_unsigned, lt_sign : std_logic;
  
  signal C0 : std_logic_vector(31 downto 0) := (others => '0');
  signal A : std_logic_vector(31 downto 0) := (others => '0');
  signal B : std_logic_vector(31 downto 0) := (others => '0');
  
  signal op_hold : std_logic_vector(5 downto 0);
begin  -- STRUCTURE

  eq <= '1' when A = B else '0';
  lt <= A(31) when (A(31) xor B(31)) = '1' else
        '1' when A(30 downto 0) < B(30 downto 0) else
        '0';
  gt <= B(31) when (A(31) xor B(31)) = '1' else
        '1' when A(30 downto 0) > B(30 downto 0) else
        '0';
  cmp <= gt & eq & lt;

  with op select
  C0 <=	A + B when alu_op_add,
  		A - B when alu_op_sub,
		"11111111111111111111111111111111" when others;

end STRUCTURE;
