-- 簡単なテスト

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity ALU_TESTER is
  
  port (
    clkin  : in  std_logic;
    ledout : out std_logic);
    
end ALU_TESTER;


architecture STRUCTURE of ALU_TESTER is

  component ALU
    port (
      clk : in std_logic;
      op : in std_logic_vector(5 downto 0);
      A, B : in  std_logic_vector(31 downto 0);
      C    : out std_logic_vector(31 downto 0));
  end component;

  constant n : integer := 10;
  
  subtype vec6  is std_logic_vector(5 downto 0);
  subtype vec32 is std_logic_vector(31 downto 0);
  type table6  is array(0 to n - 1) of vec6;
  type table32 is array(0 to n - 1) of vec32;
  
  constant table_op : table6 := (
    "000000", -- add
    "000001", -- addi
    "000010", -- sub
    "000011", -- srl
    "000100", -- sll
    "001100", -- cmp
    "001100", -- cmp
    "001100", -- cmp
    "001100", -- cmp
    "001100"  -- cmp
    );
  
  constant table_a : table32 := (
    "00000000000000000000000000000010",
    "00000000000000000000000000000010",
    "00000000000000000000000000110001",
    "00000000000101011010100100101010",
    "00000000000101011010100100101010",
    "00000000000000000000000000000100",
    "00000000000000000000000000001000",
    "00000000000000000000000000010000",
    "00000000000000000000000000000000",
    "11111111111111111111111111111111");
  
  constant table_b : table32 := (
    "00000000000000000000000000010110",
    "00000000000000000000000000010110",
    "00000000000000000000000000000100",
    "00000000000000000000000000000110",
    "00000000000000000000000000000110",
    "00000000000000000000000000001000",
    "00000000000000000000000000001000",
    "00000000000000000000000000001000",
    "11111111111111111111111111111111",
    "00000000000000000000000000000000");
  
  signal clk, reset : std_logic;
  signal i : integer range 0 to n - 1;
  
  signal op : std_logic_vector(5 downto 0) := "000000";
  signal a, b, c : std_logic_vector(31 downto 0)
    := "00000000000000000000000000000000";
  
begin  -- STRUCTURE

  ibufg_inst : ibufg port map (I => clkin, O => clk);
  roc_inst : roc port map (O => reset);

  alu_inst : ALU port map (clk => clk, op => op, A  => a, B  => b, C => c);

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

    op <= table_op(i);
    a <= table_a(i);
    b <= table_b(i);    
  end process;
  
end STRUCTURE;
