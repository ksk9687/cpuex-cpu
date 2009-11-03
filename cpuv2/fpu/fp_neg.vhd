-- ÉâÉbÉ`ÅFç≈å„Ç… 1 Ç¬

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.fp_inv_table.all;

entity FP_NEG is
  
  port (
    clk : in std_logic;
    A   : in  std_logic_vector(31 downto 0);
    O   : out std_logic_vector(31 downto 0));

end FP_NEG;


architecture STRUCTURE of FP_NEG is
  
begin  -- STRUCTURE
  
  process(clk)
  begin
    if rising_edge(clk) then
      O <= (not A(31) & A(30 downto 0);
    end if;
  end process;
           
end STRUCTURE;
