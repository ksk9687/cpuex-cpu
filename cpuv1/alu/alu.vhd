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
    A, B : in  std_logic_vector(31 downto 0);
    C    : out std_logic_vector(31 downto 0));
end ALU;


architecture STRUCTURE of ALU is

  signal lt, eq, gt : std_logic;
  signal cmp : std_logic_vector(31 downto 0);
  
  signal C0 : std_logic_vector(31 downto 0) := (others => '0');
begin  -- STRUCTURE

  lt <= '1' when A < B else '0';
  eq <= '1' when A = B else '0';
  gt <= '1' when A > B else '0';
  cmp <= "00000000000000000000000000000" & gt & eq & lt;

  with op select
  C0 <=	A + B when op_add | op_addi,
  		A - B when op_sub,
  		SHR(A, B) when op_srl,
  		SHL(A, B) when op_sll,
  		cmp when op_cmp,
  		B when op_li,
		"11111111111111111111111111111111" when others;
  
  process(clk)
  begin
  	if rising_edge(clk) then
  		C <= C0;
  	end if;
  end process;
  
  
end STRUCTURE;
