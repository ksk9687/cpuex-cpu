-- 正規化数および 0.0 に対応した乗算器
-- 丸めはばっさり切り捨て

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FP_MUL is
  
  port (
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));

end FP_MUL;


architecture STRUCTURE of FP_MUL is

  signal AS, BS : std_logic;
  signal AE, BE : std_logic_vector(7 downto 0);
  signal AM, BM : std_logic_vector(23 downto 0);
  
  signal OM1 : std_logic_vector(47 downto 0);
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE1, OE2 : std_logic_vector(7 downto 0);
  signal OS : std_logic;
  signal O1 : std_logic_vector(31 downto 0);

begin  -- STRUCTURE

  -- 1 つ以上 0.0 の場合は 0.0
  O <= O1 when (A(30 downto 0) /= 0 and B(30 downto 0) /= 0)
       else "00000000000000000000000000000000";
  
  -- 分解
  AS <= A(31);
  BS <= B(31);
  AE <= A(30 downto 23); 
  BE <= B(30 downto 23); 
  AM <= '1' & A(22 downto 0);
  BM <= '1' & B(22 downto 0);

  -- 仮数部の積を計算
  OM1 <= AM * BM;

  -- 仮数部は各々 [1.0, 2.0) より積は [1.0, 4.0)
  OM2 <= OM1(46 downto 24) when OM1(47) = '1' else
         OM1(45 downto 23);

  -- 指数部（オーバーフロー・アンダーフローは無視）
  OE1 <= AE + BE - 127;
  OE2 <= OE1 + 1 when OM1(47) = '1' else
         OE1;

  -- 符号
  OS <= AS xor BS;

  -- 結果
  O1 <= OS & OE2 & OM2;
  
end STRUCTURE;
