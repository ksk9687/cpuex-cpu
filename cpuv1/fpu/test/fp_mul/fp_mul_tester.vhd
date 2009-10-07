-- 簡単なテスト
-- TODO ちゃんとしたテスト

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity FP_MUL_TESTER is
  
  port (
    clkin  : in  std_logic;
    ledout : out std_logic);
    
end FP_MUL_TESTER;


architecture STRUCTURE of FP_MUL_TESTER is

  component FP_MUL
    port (
      A, B : in  std_logic_vector(31 downto 0);
      O    : out std_logic_vector(31 downto 0));
  end component;

  constant n : integer := 8;
  
  subtype vec32 is std_logic_vector(31 downto 0);
  type table32 is array(0 to n - 1) of vec32;
  
  constant table_a : table32 := (
    "00000000000000000000000000000000",  -- 0.0
    "00000000000000000000000000000000",  -- 0.0
    "00111111100000000000000000000000",  -- 1.0
    "00111111100000000000000000000000",  -- 1.0
    "00111111100000000000000000000000",  -- 1.0
    "01000000000000000000000000000000",  -- 2.0
    "01000000000000000000000000000000",  -- 2.0
    "00111111110000000000000000000000"   -- 1.5
    );
  
  constant table_b : table32 := (
    "00000000000000000000000000000000",  -- 0.0
    "00111111100000000000000000000000",  -- 1.0
    "00000000000000000000000000000000",  -- 0.0
    "00111111100000000000000000000000",  -- 1.0
    "01000000000000000000000000000000",  -- 2.0
    "01000000000000000000000000000000",  -- 2.0
    "00111111110000000000000000000000",  -- 1.5
    "00111111110000000000000000000000"   -- 1.5
    );
  
  signal clk, reset : std_logic;
  signal i : integer range 0 to n - 1;
  
  signal a, b, c : std_logic_vector(31 downto 0)
    := "00000000000000000000000000000000";
  
begin  -- STRUCTURE

  ibufg_inst : ibufg port map (I => clkin, O => clk);
  roc_inst : roc port map (O => reset);

  fp_mul_inst : FP_MUL port map (A  => a, B  => b, O => c);

  ledout <= '0';

  process (clk, reset)
  begin  -- process
    if reset = '1' then
      i <= 0;

    elsif clk'event and clk = '1' then
      if i+1 = n then
        i <= 0;
      else
        i <= i+1;
      end if;
    end if;

    a <= table_a(i);
    b <= table_b(i);
  end process;
  
end STRUCTURE;
