library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FPU is

  port (
    op   : in  std_logic_vector(5 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));

end FPU;


architecture STRUCTURE of FPU is

  component FP_ADD
    port (
      A, B : in  std_logic_vector(31 downto 0);
      O    : out std_logic_vector(31 downto 0));
  end component;

  component FP_MUL
    port (
      A, B : in  std_logic_vector(31 downto 0);
      O    : out std_logic_vector(31 downto 0));
  end component;
  
  component FP_INV
    port (
      A : in  std_logic_vector(31 downto 0);
      O : out std_logic_vector(31 downto 0));
  end component;

  signal O_ADD, O_MUL, O_INV : std_logic_vector(31 downto 0);
  signal B_ADD : std_logic_vector(31 downto 0);

begin  -- STRUCTURE

  fp_add_inst : FP_ADD port map (O => O_ADD, A => A, B => B_ADD);
  fp_mul_inst : FP_MUL port map (O => O_MUL, A => A, B => B);
  fp_inv_inst : FP_INV port map (O => O_INV, A => A);

  B_ADD <= B when op = "000101" else       -- add
           (B(31) xor '1') & B(30 downto 0);  -- sub -> negate

  O <= O_ADD when op = "000101" else
       O_ADD when op = "000110" else
       O_MUL when op = "000111" else
       O_INV when op = "001000" else
       "11111111111111111111111111111111";  -- BAD OP
  
end STRUCTURE;