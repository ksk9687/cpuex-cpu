library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.instruction.all;

entity ALU is

  port (
 	clk : in std_logic;
    op : in std_logic_vector(5 downto 0);
    A0, B0 : in  std_logic_vector(31 downto 0);
    C    : out std_logic_vector(31 downto 0));
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
        '1' when A < B else '0';
  gt <= B(31) when (A(31) xor B(31)) = '1' else
        '1' when A > B else '0';
  cmp <= "00000000000000000000000000000" & gt & eq & lt;

  with op_hold select
  C0 <=	A + B when op_add | op_addi,
  		A - B when op_sub,
  		SHR(A, B) when op_srl,
  		SHL(A, B) when op_sll,
  		cmp when op_cmp,
  		B when op_li,
		"11111111111111111111111111111111" when others;
  
  
  A <= A0;
  B <= B0;
  
  process(clk)
  begin
  	if rising_edge(clk) then
      if op /= op_halt then
        op_hold <= op;
      end if;
  		C <= C0;
  	end if;
  end process;
  
end STRUCTURE;
