library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FP_CMP is
  
  port (
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));

end FP_CMP;


architecture STRUCTURE of FP_CMP is
  
  signal abslt, abseq, absgt : std_logic;
  signal cmp : std_logic_vector(2 downto 0);

begin  -- STRUCTURE

  abslt <= '1' when A(30 downto 0) < B(30 downto 0) else '0';
  abseq <= '1' when A(30 downto 0) = B(30 downto 0) else '0';
  absgt <= '1' when A(30 downto 0) > B(30 downto 0) else '0';

  cmp <= "010"  when A(30 downto 0) = 0 and B(30 downto 0) = 0 else
         "100"  when A(31) = '0' and B(31) = '1' else
         "001"  when A(31) = '1' and B(31) = '0' else
         absgt & abseq & abslt when A(31) = '0' and B(31) = '0' else
         abslt & abseq & absgt;
  
  O <= "00000000000000000000000000000" & cmp;

end STRUCTURE;
