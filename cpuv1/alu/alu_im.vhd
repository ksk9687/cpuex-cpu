library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.instruction.all;

entity ALU_IM is

  port (
 	clk : in std_logic;
    op : in std_logic_vector(5 downto 0);
    A0, B0 : in  std_logic_vector(31 downto 0);
    C    : out std_logic_vector(31 downto 0));
end ALU_IM;


architecture STRUCTURE of ALU_IM is
  signal C0 : std_logic_vector(31 downto 0) := (others => '0');
  signal A : std_logic_vector(31 downto 0) := (others => '0');
  signal B : std_logic_vector(31 downto 0) := (others => '0');
begin  -- STRUCTURE

  with op select
  C0 <=	A + B when op_addi,
  		SHR(A, B(4 downto 0)) when op_srl,
  		SHL(A, B(4 downto 0)) when op_sll,
  		B when op_li,
		"11111111111111111111111111111111" when others;
  
  C <= C0;
  
  A <= A0;
  B <= B0;
  
  process(clk)
  begin
  	if rising_edge(clk) then
  		--C <= C0;
  	end if;
  end process;
  
end STRUCTURE;
