-- 0.0 で割るなお！！！
-- 表引きして掛け算するだけ！！

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.fp_inv_table.all;

entity FP_INV is
  
  port (
    A : in  std_logic_vector(31 downto 0);
    O : out std_logic_vector(31 downto 0));

end FP_INV;


architecture STRUCTURE of FP_INV is

  signal AS : std_logic;
  signal AE : std_logic_vector(7 downto 0);
  signal X1, X2 : std_logic_vector(11 downto 0);
  signal C, XX : std_logic_vector(23 downto 0);
  signal OM1 : std_logic_vector(47 downto 0);
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE : std_logic_vector(7 downto 0);
  
begin  -- STRUCTURE

  -- 分解
  AS <= A(31);
  AE <= A(30 downto 23); 
  X1 <= "1" & A(22 downto 12);
  X2 <= A(11 downto 0);

  -- 表引きしたり xor したりして掛け算
  C <= table(CONV_INTEGER(X1(10 downto 0)));
  XX <= X1 & (X2 xor "111111111111");
  OM1 <= C * XX;

  -- そろえる
  OM2 <= OM1(45 downto 23) when OM1(46) = '1' else
         OM1(44 downto 22);
  OE <= 253 - AE when OM1(46) = '1' else
        252 - AE;
  O <= AS & OE & OM2;
           
end STRUCTURE;
