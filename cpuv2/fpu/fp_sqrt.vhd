-- ラッチ：中の 3 つ

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.fp_sqrt_table.all;

entity FP_SQRT is
  
  port (
    clk : in std_logic;
    A   : in  std_logic_vector(31 downto 0);
    O   : out std_logic_vector(31 downto 0));

end FP_SQRT;


architecture STRUCTURE of FP_SQRT is

  -- 1st stage
  signal C, X : std_logic_vector(23 downto 0);
  signal CH, CL, XH, XL : std_logic_vector(11 downto 0);
  signal OE1 : std_logic_vector(7 downto 0);

  -- 2nd stage
  signal OMHtmp, OMM1tmp, OMM2tmp : std_logic_vector(23 downto 0);
  signal OE2 : std_logic_vector(7 downto 0);

  -- 3rd stage
  signal OMM1, OMM2 : std_logic_vector(12 downto 0);
  signal OMH : std_logic_vector(23 downto 0);
  signal OMM3 : std_logic_vector(13 downto 0);
  signal OE3 : std_logic_vector(7 downto 0);
  
  -- 4th stage
  signal OM1 : std_logic_vector(24 downto 0);
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE4 : std_logic_vector(7 downto 0);
  
begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------

  -- 表引きしたり xor したりして乗算に備える
  C <= table(CONV_INTEGER((not A(23)) & A(22 downto 13)));
  X <= "1" & A(22 downto 12) & (not A(12)) & A(11 downto 1);

  -- 仮数部を分解
  process(clk)
  begin
    if rising_edge(clk) then
      if A(30 downto 23) = 0 then
        CH <= "000000000000"; CL <= "000000000000";
        XH <= "000000000000"; XL <= "000000000000";
        OE1 <= "00000000";
      else
        CH <= C(23 downto 12); CL <= C(11 downto 0);
        XH <= X(23 downto 12); XL <= X(11 downto 0);
        OE1 <= 63 + ('0' & A(30 downto 24));
      end if;
            
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 2st stage
  -----------------------------------------------------------------------------

  process (clk)
  begin  -- process
    if rising_edge(clk) then
      OMHtmp(23 downto 0)  <= CH * XH;
      OMM1tmp(23 downto 0) <= CH * XL;
      OMM2tmp(23 downto 0) <= CL * XH;
      
      OE2 <= OE1;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 3rd stage
  -----------------------------------------------------------------------------

  process (clk)
  begin
    if rising_edge(clk) then
      -- 積
      --OMM1 <= OMM1tmp(23 downto 11);
      --OMM2 <= OMM2tmp(23 downto 11);
      OMM3 <= ('0' & OMM1tmp(23 downto 11)) + ('0' & OMM2tmp(23 downto 11));
      OMH  <= OMHtmp(23 downto 0);
      
      OE3 <= OE2;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 4th stage
  -----------------------------------------------------------------------------

  --OMM3 <= ('0' & OMM1(12 downto 0)) + ('0' & OMM2(12 downto 0));

  --OM1 <= (OMH & '0') + ("00000000000" & OMM3) + 2;
  OM1(24 downto 1) <= OMH + ("0000000000" & OMM3(13 downto 1)) + 1;
  OM1(0) <= OMM3(0);
  
  -- 繰り上がりを処理
  OM2 <= OM1(23 downto 1) when OM1(24) = '1' else OM1(22 downto 0);
  OE4 <= OE3 + 1 when OM1(24) = '1' else OE3;

  -- 結果
  O <= '0' & OE4 & OM2;
           
end STRUCTURE;
