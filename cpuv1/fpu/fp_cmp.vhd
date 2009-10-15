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
  
  signal abscmp : std_logic_vector(2 downto 0);
  signal cmp : std_logic_vector(2 downto 0);

begin  -- STRUCTURE

  -- gt & eq & lt
  abscmp(2) <= '1' when A(30 downto 0) > B(30 downto 0) else '0';
  abscmp(1) <= '1' when A(30 downto 0) = B(30 downto 0) else '0';
  abscmp(0) <= '1' when A(30 downto 0) < B(30 downto 0) else '0';

  cmp <= "010"  when A(30 downto 0) = 0 and B(30 downto 0) = 0 else
         "100"  when A(31) = '0' and B(31) = '1' else
         "001"  when A(31) = '1' and B(31) = '0' else
         abscmp when A(31) = '0' and B(31) = '0' else
         abscmp xor "111";

  O <= "00000000000000000000000000000" & cmp;

end STRUCTURE;
