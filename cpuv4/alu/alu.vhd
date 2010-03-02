library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ALU is
  port (
    clk  : in std_logic;
    op   : in std_logic_vector(1 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));
end ALU;

architecture STRUCTURE of ALU is
	signal Ob : std_logic_vector(31 downto 0) := (others=>'0');
begin

  with op select
  Ob <=	A + B when "01",--add
  		A - B when "10",--sub
		A when others;--mv li
		
	process(clk)
	begin
		if rising_edge(clk) then
			O <= Ob;
		end if;
	end process;
			
end STRUCTURE;
