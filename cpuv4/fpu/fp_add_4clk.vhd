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
  
  -- 1st stage
  signal agtb : std_logic;
  signal AE, BE ,WE ,LE: std_logic_vector(7 downto 0);
  signal AM1, BM1 , WM , LM: std_logic_vector(24 downto 0);
  signal BEminusAE, AEminusBE,WEminusLE : std_logic_vector(7 downto 0);
  signal AS, BS , OS : std_logic;

  -- 2nd stage
  signal AM2, BM2 ,LM2: std_logic_vector(24 downto 0);
  signal PM, QM : std_logic_vector(24 downto 0);
  signal OE1 : std_logic_vector(7 downto 0);
  signal OS1 : std_logic;
  signal op : std_logic;

  -- 3rd stage
  signal OM1 : std_logic_vector(24 downto 0);
  signal OE2 : std_logic_vector(7 downto 0);
  signal OS2 : std_logic;


begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------

  BEminusAE <= B(30 downto 23) - A(30 downto 23);
  AEminusBE <= A(30 downto 23) - B(30 downto 23);
  
  agtb <= '1' when (A(30 downto 0) > B(30 downto 0)) else
  '0';
  
  AM1 <="01" & A(22 downto 0) when A(30 downto 23) /= "00000000" else
  "0000000000000000000000000";
  BM1 <="01" & B(22 downto 0) when B(30 downto 23) /= "00000000" else
  "0000000000000000000000000";
  
  process (clk)
  begin  -- process
    if rising_edge(clk) then     
      if (agtb = '1') then
      	WEminusLE <= AEminusBE;
      	WE <= A(30 downto 23);
      	WM <= AM1;
      	LM <= BM1;
      	OS <= A(31);
      else
      	WEminusLE <= BEminusAE;
      	WE <= B(30 downto 23);
      	WM <=BM1;
      	LM <=AM1;
      	OS <= B(31);
      end if;
      	AS <= A(31);
      	BS <= B(31);
    end if;
  end process;
  

  -----------------------------------------------------------------------------
  -- 2nd stage
  -----------------------------------------------------------------------------
  
  LM2 <= SHR(LM, WEminusLE);
  
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      OE1 <= WE;
      PM <= WM;
      OS1 <= OS;
      QM <= LM2;

      op <= AS xor BS;
    end if;
  end process;
  

  -----------------------------------------------------------------------------
  -- 3st stage
  -----------------------------------------------------------------------------
  
  -- ‰ÁŽZ
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      if op = '1' then
        OM1 <= PM - QM;
      else
        OM1 <= PM + QM;
      end if;
      OE2 <= OE1;
      OS2 <= OS1;
    end if;
  end process;


  
  -----------------------------------------------------------------------------
  -- 4th stage
  -----------------------------------------------------------------------------

  -- Œ‹‰Ê
  O(31) <= OS2;
  
  O(30 downto 0) <=
    (OE2 +  1) & OM1(23 downto 1)                             when OM1(24) = '1' else
    (OE2     ) & OM1(22 downto 0)                             when OM1(23) = '1' else
    (OE2 -  1) & OM1(21 downto 0) & "0"                       when OM1(22) = '1' else
    (OE2 -  2) & OM1(20 downto 0) & "00"                      when OM1(21) = '1' else
    (OE2 -  3) & OM1(19 downto 0) & "000"                     when OM1(20) = '1' else
    (OE2 -  4) & OM1(18 downto 0) & "0000"                    when OM1(19) = '1' else
    (OE2 -  5) & OM1(17 downto 0) & "00000"                   when OM1(18) = '1' else
    (OE2 -  6) & OM1(16 downto 0) & "000000"                  when OM1(17) = '1' else
    (OE2 -  7) & OM1(15 downto 0) & "0000000"                 when OM1(16) = '1' else
    (OE2 -  8) & OM1(14 downto 0) & "00000000"                when OM1(15) = '1' else
    (OE2 -  9) & OM1(13 downto 0) & "000000000"               when OM1(14) = '1' else
    (OE2 - 10) & OM1(12 downto 0) & "0000000000"              when OM1(13) = '1' else
    (OE2 - 11) & OM1(11 downto 0) & "00000000000"             when OM1(12) = '1' else
    (OE2 - 12) & OM1(10 downto 0) & "000000000000"            when OM1(11) = '1' else
    (OE2 - 13) & OM1( 9 downto 0) & "0000000000000"           when OM1(10) = '1' else
    (OE2 - 14) & OM1( 8 downto 0) & "00000000000000"          when OM1( 9) = '1' else
    (OE2 - 15) & OM1( 7 downto 0) & "000000000000000"         when OM1( 8) = '1' else
    (OE2 - 16) & OM1( 6 downto 0) & "0000000000000000"        when OM1( 7) = '1' else
    (OE2 - 17) & OM1( 5 downto 0) & "00000000000000000"       when OM1( 6) = '1' else
    (OE2 - 18) & OM1( 4 downto 0) & "000000000000000000"      when OM1( 5) = '1' else
    (OE2 - 19) & OM1( 3 downto 0) & "0000000000000000000"     when OM1( 4) = '1' else
    (OE2 - 20) & OM1( 2 downto 0) & "00000000000000000000"    when OM1( 3) = '1' else
    (OE2 - 21) & OM1( 1 downto 0) & "000000000000000000000"   when OM1( 2) = '1' else
    (OE2 - 22) & OM1( 0 downto 0) & "0000000000000000000000"  when OM1( 1) = '1' else
    (OE2 - 23)                    & "00000000000000000000000" when OM1( 0) = '1' else
    "0000000000000000000000000000000";  -- zero
  
end STRUCTURE;