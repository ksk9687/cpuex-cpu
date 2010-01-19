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
  signal OS1 : std_logic;

  -- 2nd stage
  signal OMM1_2, OMM2_2 : std_logic_vector(12 downto 0);
  signal OMH2 : std_logic_vector(23 downto 0);
  signal OE2  : std_logic_vector(7 downto 0);
  signal OS2 : std_logic;

  -- 3rd stage
  signal OMM3 : std_logic_vector(13 downto 0);
  signal OM1 : std_logic_vector(24 downto 0);
  signal OE3, OE3plus1 : std_logic_vector(7 downto 0);
  signal OS3 : std_logic;
  
  -- 4th stage
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE4 : std_logic_vector(7 downto 0);

	signal ZERO,ZERO_1 : std_logic := '0';
begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------

  -- 仮数部を分解
  AH <= '1' & A(22 downto 12);
  AL <= A(11 downto 0);
  BH <= '1' & B(22 downto 12);
  BL <= B(11 downto 0);
  
--  AH <= '1' & A(22 downto 12) when A(30 downto 23) /= 0 else "000000000000";
--  AL <= A(11 downto 0)        when A(30 downto 23) /= 0 else "000000000000";
--  BH <= '1' & B(22 downto 12) when B(30 downto 23) /= 0 else "000000000000";
--  BL <= B(11 downto 0)        when B(30 downto 23) /= 0 else "000000000000";
  
  ZERO <= '1' when (A(30 downto 23) = 0) or (B(30 downto 23) = 0) else '0';
  
  process(clk)
  begin
    if rising_edge(clk) then
      -- 乗算 (実際には次のクロックを 5ns ぐらい消費しやがる)
      OMH1 <= AH * BH;
      OMM1 <= AH * BL;
      OMM2 <= BH * AL;
      
      if ZERO = '1' then
        OE1 <= "00000000";
      else
        OE1 <= ((A(30 downto 23)) + (B(30 downto 23))) - "01111111";
      end if;

      OS1 <= A(31) xor B(31);
      
      ZERO_1 <= ZERO;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 2nd stage
  -----------------------------------------------------------------------------

  
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      -- 前のクロックではじめた乗算が 6 ns 弱消費しやがる！
      -- OMM3 <= ('0' & OMM1(23 downto 11)) + ('0' & OMM2(23 downto 11));
      if ZERO_1 = '0' then
      	OMM1_2 <= OMM1(23 downto 11);
      	OMM2_2 <= OMM2(23 downto 11);
      	OMH2 <= OMH1;
      else--どちらかの入力が０だった
      	OMM1_2 <= (others => '0');
      	OMM2_2 <= (others => '0');
      	OMH2 <= (others => '0');
      end if;
      
      OE2 <= OE1(7 downto 0);
      OS2 <= OS1;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- 3rd stage
  -----------------------------------------------------------------------------

  -- 加算を終え繰り上がりを処理
  
  -- TODO 一番下のビットを別に処理すると +1 になって都合がよい可能性がある
  --OM1 <= (OMH2 & '0') + ("00000000000" & OMM3) + 2;
  OMM3 <= ('0' & OMM1_2) + ('0' & OMM2_2);
  
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      OM1(24 downto 1) <= OMH2 + ("0000000000" & OMM3(13 downto 1)) + '1';
      OM1(0) <= OMM3(0);
      
      OE3      <= OE2;
      OE3plus1 <= OE2 + '1';
      
      OS3 <= OS2;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 4th stage
  -----------------------------------------------------------------------------

  OM2 <= OM1(23 downto 1) when OM1(24) = '1' else OM1(22 downto 0);
  OE4 <= OE3plus1 when OM1(24) = '1' else OE3;
  O <= OS3 & OE4 & OM2;
  
end STRUCTURE;
