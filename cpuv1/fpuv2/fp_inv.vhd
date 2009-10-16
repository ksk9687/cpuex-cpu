-- ラッチ：前・中・後の 3 つ

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
    clk : in std_logic;
    A   : in  std_logic_vector(31 downto 0);
    O   : out std_logic_vector(31 downto 0));

end FP_INV;


architecture STRUCTURE of FP_INV is

  signal AS : std_logic;
  signal AE : std_logic_vector(7 downto 0);
  signal X1, X2 : std_logic_vector(11 downto 0);
  signal C, XX : std_logic_vector(23 downto 0);
  signal OM1 : std_logic_vector(47 downto 0);
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE : std_logic_vector(7 downto 0);
  signal O1 : std_logic_vector(31 downto 0);

  signal Adff1 : std_logic_vector(31 downto 0);
  signal Cdff2, XXdff2 : std_logic_vector(23 downto 0);
  signal AEdff2 : std_logic_vector(7 downto 0);
  signal ASdff2 : std_logic;
  signal Odff3 : std_logic_vector(31 downto 0);
  
begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------
  -- Adff1 <= A
  
  -- 分解
  AS <= Adff1(31);
  AE <= Adff1(30 downto 23); 
  X1 <= "1" & Adff1(22 downto 12);
  X2 <= Adff1(11 downto 0);

  -- 表引きしたり xor したりして掛け算
  C <= table(CONV_INTEGER(X1(10 downto 0)));
  XX <= X1 & (X2 xor "111111111111");


  -----------------------------------------------------------------------------
  -- 2st stage
  -----------------------------------------------------------------------------
  -- Cdff2 <= C, XXdff2 <= XX, ASdff2 <= AS, AEdff2 <= AE
  
  OM1 <= Cdff2 * XXdff2;

  -- そろえる
  OM2 <= OM1(45 downto 23) when OM1(46) = '1' else
         OM1(44 downto 22);
  OE <= 253 - AEdff2 when OM1(46) = '1' else
        252 - AEdff2;
  O1 <= ASdff2 & OE & OM2;
  

  -----------------------------------------------------------------------------
  -- 3rd stage
  -----------------------------------------------------------------------------
  -- Odff3 <= O1

  O <= Odff3;

  -----------------------------------------------------------------------------
  -- process
  -----------------------------------------------------------------------------
  
  process(clk)
  begin
    if rising_edge(clk) then
      Adff1 <= A;
      
      Cdff2 <= C;
      XXdff2 <= XX;
      ASdff2 <= AS;
      AEdff2 <= AE;
      
      Odff3 <= O1;
    end if;
  end process;
           
end STRUCTURE;
