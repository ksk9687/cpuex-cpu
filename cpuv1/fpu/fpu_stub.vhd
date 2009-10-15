library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.instruction.all;

entity FPU is

  port (
    op   : in  std_logic_vector(5 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));

end FPU;


architecture STRUCTURE of FPU is


  signal O_ADD, O_MUL, O_INV : std_logic_vector(31 downto 0);
  signal B_ADD : std_logic_vector(31 downto 0);

begin  -- STRUCTURE

	o<= A;

  
end STRUCTURE;
