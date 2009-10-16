-- ラッチ：前・中・後の 3 つ

-- TODO こいつだけ std_logic_signed

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FP_ADD is
  
  port (
    clk : in std_logic;
    A, B  : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));
  
end FP_ADD;


architecture STRUCTURE of FP_ADD is
  
  signal AE, BE : std_logic_vector(7 downto 0);

  signal agtb : boolean;
  signal A1, B1 : std_logic_vector(31 downto 0);

  signal AM, BM1, BM2, OM : std_logic_vector(24 downto 0);
  signal OS : std_logic;

  signal O1 : std_logic_vector(31 downto 0);

  signal Adff1, Bdff1 : std_logic_vector(31 downto 0);
  signal OSdff2 : std_logic;
  signal OMdff2 : std_logic_vector(24 downto 0);
  signal AEdff2 : std_logic_vector(7 downto 0);
  signal Odff3 : std_logic_vector(31 downto 0);

begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------
  -- Adff1 <= A, Bdff1 <= B
  
  -- 絶対値を比較し、|A1| > |B1| としている
  agtb <= (Adff1(30 downto 0) > Bdff1(30 downto 0));
  A1 <= Adff1 when agtb else Bdff1;
  B1 <= Bdff1 when agtb else Adff1;

  -- 分解
  AE <= A1(30 downto 23);
  BE <= B1(30 downto 23);

  AM  <= "01" & A1(22 downto 0) when A1(30 downto 0) /= 0 else
         "0000000000000000000000000";
  BM1 <= "01" & B1(22 downto 0) when B1(30 downto 0) /= 0 else
         "0000000000000000000000000";
  BM2 <= SHR(BM1, AE - BE); -- TODO shr をやめる

  -- 加算
  OM <= AM - BM2 when (Adff1(31) xor Bdff1(31)) = '1' else AM + BM2;
  

  -----------------------------------------------------------------------------
  -- 2st stage
  -----------------------------------------------------------------------------
  -- OSdff2 <= A1(31), OMdff2 <= OM, AEdff2 <= AE

  -- 結果
  O1(31) <= OSdff2;
  
  O1(30 downto 0) <=
    (AEdff2 +  1) & OMdff2(23 downto 1)                             when OMdff2(24) = '1' else
    (AEdff2     ) & OMdff2(22 downto 0)                             when OMdff2(23) = '1' else
    (AEdff2 -  1) & OMdff2(21 downto 0) & "0"                       when OMdff2(22) = '1' else
    (AEdff2 -  2) & OMdff2(20 downto 0) & "00"                      when OMdff2(21) = '1' else
    (AEdff2 -  3) & OMdff2(19 downto 0) & "000"                     when OMdff2(20) = '1' else
    (AEdff2 -  4) & OMdff2(18 downto 0) & "0000"                    when OMdff2(19) = '1' else
    (AEdff2 -  5) & OMdff2(17 downto 0) & "00000"                   when OMdff2(18) = '1' else
    (AEdff2 -  6) & OMdff2(16 downto 0) & "000000"                  when OMdff2(17) = '1' else
    (AEdff2 -  7) & OMdff2(15 downto 0) & "0000000"                 when OMdff2(16) = '1' else
    (AEdff2 -  8) & OMdff2(14 downto 0) & "00000000"                when OMdff2(15) = '1' else
    (AEdff2 -  9) & OMdff2(13 downto 0) & "000000000"               when OMdff2(14) = '1' else
    (AEdff2 - 10) & OMdff2(12 downto 0) & "0000000000"              when OMdff2(13) = '1' else
    (AEdff2 - 11) & OMdff2(11 downto 0) & "00000000000"             when OMdff2(12) = '1' else
    (AEdff2 - 12) & OMdff2(10 downto 0) & "000000000000"            when OMdff2(11) = '1' else
    (AEdff2 - 13) & OMdff2( 9 downto 0) & "0000000000000"           when OMdff2(10) = '1' else
    (AEdff2 - 14) & OMdff2( 8 downto 0) & "00000000000000"          when OMdff2( 9) = '1' else
    (AEdff2 - 15) & OMdff2( 7 downto 0) & "000000000000000"         when OMdff2( 8) = '1' else
    (AEdff2 - 16) & OMdff2( 6 downto 0) & "0000000000000000"        when OMdff2( 7) = '1' else
    (AEdff2 - 17) & OMdff2( 5 downto 0) & "00000000000000000"       when OMdff2( 6) = '1' else
    (AEdff2 - 18) & OMdff2( 4 downto 0) & "000000000000000000"      when OMdff2( 5) = '1' else
    (AEdff2 - 19) & OMdff2( 3 downto 0) & "0000000000000000000"     when OMdff2( 4) = '1' else
    (AEdff2 - 20) & OMdff2( 2 downto 0) & "00000000000000000000"    when OMdff2( 3) = '1' else
    (AEdff2 - 21) & OMdff2( 1 downto 0) & "000000000000000000000"   when OMdff2( 2) = '1' else
    (AEdff2 - 22) & OMdff2( 0 downto 0) & "0000000000000000000000"  when OMdff2( 1) = '1' else
    (AEdff2 - 23)                       & "00000000000000000000000" when OMdff2( 0) = '1' else
    "0000000000000000000000000000000";  -- zero

  
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
      Bdff1 <= B;
      
      OSdff2 <= A1(31);
      OMdff2 <= OM;
      AEdff2 <= AE;
      
      Odff3 <= O1;
    end if;
  end process;
  
end STRUCTURE;
