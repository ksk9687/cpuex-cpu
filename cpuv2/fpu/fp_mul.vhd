-- ラッチ：前と中と後ろの 2 つ

-- 正規化数および 0.0 に対応した乗算器
-- 丸めはばっさり切り捨て
-- TODO アンダーフロー

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity FP_MUL is
  
  port (
    clk : in std_logic;
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));

end FP_MUL;


architecture STRUCTURE of FP_MUL is

  -- 1st stage
  signal AH, BH, AL, BL : std_logic_vector(11 downto 0);
  
  signal OMH1, OMM1, OMM2 : std_logic_vector(23 downto 0);
  signal OE1 : std_logic_vector(7 downto 0);
  signal OS1, OZ1 : std_logic;

  -- 2nd stage
  signal OMM3 : std_logic_vector(13 downto 0);
  signal OMH2 : std_logic_vector(23 downto 0);
  signal OM1 : std_logic_vector(24 downto 0);
  signal OE2, OE2P1 : std_logic_vector(7 downto 0);
  signal OS2, OZ2 : std_logic;
  
  -- 3rd stage
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE3 : std_logic_vector(7 downto 0);


begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------

  -- 仮数部を分解
  AH <= '1' & A(22 downto 12); AL <= A(11 downto 0);
  BH <= '1' & B(22 downto 12); BL <= B(11 downto 0);
  
  process(clk)
  begin
    if rising_edge(clk) then
      -- 乗算 (実際には次のクロックを 5ns ぐらい消費しやがる)
      OMH1 <= AH * BH;
      OMM1 <= AH * BL;
      OMM2 <= BH * AL;
      
      -- ゼロ？
      if (A(30 downto 23) = 0 or B(30 downto 23) = 0) then
        OZ1 <= '1';
      else
        OZ1 <= '0';
      end if;

      -- うえのほう
      OE1 <= A(30 downto 23) + B(30 downto 23) - 127;
      OS1 <= A(31) xor B(31);
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 2nd stage
  -----------------------------------------------------------------------------

  
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      -- 前のクロックではじめた乗算が 6 ns 弱消費しやがる！
      OMM3 <= ('0' & OMM1(23 downto 11)) + ('0' & OMM2(23 downto 11));
      OMH2 <= OMH1;
      OE2 <= OE1;
      OE2P1 <= OE1 + 1;
      OS2 <= OS1;
      OZ2 <= OZ1;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- 3rd stage
  -----------------------------------------------------------------------------

  -- 加算を終え繰り上がりを処理
  
  -- TODO 一番下のビットを別に処理すると +1 になって都合がよい可能性がある
  --OM1 <= (OMH2 & '0') + ("00000000000" & OMM3) + 2;
  OM1(24 downto 1) <= OMH2 + ("0000000000" & OMM3(13 downto 1)) + 1;
  OM1(0) <= OMM3(0);
  
  OM2 <= OM1(23 downto 1) when OM1(24) = '1' else OM1(22 downto 0);
  OE3 <= OE2P1 when OM1(24) = '1' else OE2;

  -- 結果
  O <= OS2 & OE3 & OM2 when OZ2 = '0' else
       "00000000000000000000000000000000";
  
end STRUCTURE;
