-- ÉâÉbÉ`ÅFç≈å„Ç… 1 Ç¬

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.fp_inv_table.all;

entity FP_ABS is
  
  port (
    A   : in  std_logic_vector(31 downto 0);
    O   : out std_logic_vector(31 downto 0));

end FP_ABS;


architecture STRUCTURE of FP_ABS is
  
begin  -- STRUCTURE
  
  O <= '0' & A(30 downto 0);
           
end STRUCTURE;
