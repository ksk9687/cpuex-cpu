-- TODO こいつだけ std_logic_signed

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity FP_ADD is
  
  port (
    A,B  : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));
  
end FP_ADD;


architecture STRUCTURE of FP_ADD is
  
  signal AS, BS, OS : std_logic;
  signal AE, BE, OE1, OE2 : std_logic_vector(8 downto 0);

  signal AM1, BM1 : std_logic_vector(25 downto 0);
  signal AM2, BM2 : std_logic_vector(25 downto 0);
  signal AM3, BM3 : std_logic_vector(25 downto 0);

  signal OM1 : std_logic_vector(25 downto 0);
  signal OM2 : std_logic_vector(25 downto 0);
  signal OM3 : std_logic_vector(25 downto 0);

  signal O1 : std_logic_vector(31 downto 0);

begin  -- STRUCTURE

  -- 負数とされないために指数部の頭に0
  AS <= A(31); AE <= '0' & A(30 downto 23); AM1 <= "001" & A(22 downto 0);
  BS <= B(31); BE <= '0' & B(30 downto 23); BM1 <= "001" & B(22 downto 0);

  -- 片方or両方が0の場合を例外処理
  O <= A when B(30 downto 0) = 0 else
       B when A(30 downto 0) = 0 else
       O1;
  
  -- 指数を大きいほうへ揃える
  OE1 <= AE when AE >= BE else BE;
  AM2 <= SHR(AM1, OE1 - AE);
  BM2 <= SHR(BM1, OE1 - BE);

  -- 符号を仮数部に適用
  AM3 <= AM2 when AS = '0' else -AM2;
  BM3 <= BM2 when BS = '0' else -BM2;

  -- 加算
  OM1 <= AM3 + BM3;

  -- 符号を仮数部から取り出す
  OS <= '0' when OM1 >= 0 else '1';
  OM2 <= OM1 when OS = '0' else -OM1;

  -- 指数を決定
  OE2 <= OE1 +  1 when OM2(24) = '1' else
         OE1 -  0 when OM2(23) = '1' else
         OE1 -  1 when OM2(22) = '1' else
         OE1 -  2 when OM2(21) = '1' else
         OE1 -  3 when OM2(20) = '1' else
         OE1 -  4 when OM2(19) = '1' else
         OE1 -  5 when OM2(18) = '1' else
         OE1 -  6 when OM2(17) = '1' else
         OE1 -  7 when OM2(16) = '1' else
         OE1 -  8 when OM2(15) = '1' else
         OE1 -  9 when OM2(14) = '1' else
         OE1 - 10 when OM2(13) = '1' else
         OE1 - 11 when OM2(12) = '1' else
         OE1 - 12 when OM2(11) = '1' else
         OE1 - 13 when OM2(10) = '1' else
         OE1 - 14 when OM2( 9) = '1' else
         OE1 - 15 when OM2( 8) = '1' else
         OE1 - 16 when OM2( 7) = '1' else
         OE1 - 17 when OM2( 6) = '1' else
         OE1 - 18 when OM2( 5) = '1' else
         OE1 - 19 when OM2( 4) = '1' else
         OE1 - 20 when OM2( 3) = '1' else
         OE1 - 21 when OM2( 2) = '1' else
         OE1 - 22 when OM2( 1) = '1' else
         OE1 - 23 when OM2( 0) = '1' else
         "000000000";

  -- 指数部にあわせてシフト (マイナスを指定できるのかが非常に気になる)
  OM3 <= SHR(OM2, OE2 - OE1) when OM2(24) = '1' or OM2(23) = '1' else
         SHL(OM2, OE1 - OE2);

  -- 出力
  O1(31) <= OS;
  O1(30 downto 23) <= OE2(7 downto 0);
  O1(22 downto 0) <= OM3(22 downto 0);
  
end STRUCTURE;
