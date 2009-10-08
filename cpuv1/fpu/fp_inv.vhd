-- 0.0 Ç≈äÑÇÈÇ»Ç®ÅIÅIÅI
-- Ç∆ÇËÇ†Ç¶Ç∏ïMéZÇ»ÇÃÇ≈ÇƒÇÁíxÇ¢

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FP_INV is
  
  port (
    A : in  std_logic_vector(31 downto 0);
    O : out std_logic_vector(31 downto 0));

end FP_INV;


architecture STRUCTURE of FP_INV is

  signal AS : std_logic;
  signal AE : std_logic_vector(7 downto 0);
  signal AM : std_logic_vector(24 downto 0);
  
  signal OM1 : std_logic_vector(24 downto 0);
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE1, OE2 : std_logic_vector(7 downto 0);

  subtype NUM is std_logic_vector(24 downto 0);
  type P_T is array(0 to 25) of NUM;
  type TMP_T is array (0 to 24) of NUM;
  signal P : P_T;
  signal tmp : TMP_T;

begin  -- STRUCTURE

  -- ï™â
  AS <= A(31);
  AE <= A(30 downto 23); 
  AM <= "01" & A(22 downto 0);

  -- âºêîïîÇÃäÑÇËéZÇïMéZÇ≈
  P(25) <= "0010000000000000000000000";
  FOR1: for i in 24 downto 0 generate
    tmp(i) <= P(i + 1)(23 downto 0) & '0';
    OM1(i) <= '1' when tmp(i) >= AM else '0';
    P(i) <= tmp(i) - AM when tmp(i) >= AM else tmp(i);
  end generate; 

  -- ê≥ãKâª
  OM2 <= OM1(23 downto 1) when OM1(24) = '1' else
         OM1(22 downto 0);

  -- éwêîïî
  OE1 <= 254 - AE;
  OE2 <= OE1 when OM1(24) = '1' else
         OE1 - 1;

  -- èIÇÌÇË
  O <= AS & OE2 & OM2;
  
end STRUCTURE;
