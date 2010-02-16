library IEEE;
use IEEE.std_logic_1164.all;

entity FP_CMP_TESTER_TB is
  
end FP_CMP_TESTER_TB;


architecture BEHAVIOR of FP_CMP_TESTER_TB is
  component FP_CMP_TESTER
  port (
    clkin  : in  std_logic;
    ledout : out std_logic_vector(1 downto 0));
  end component;

  signal clk : std_logic;
  signal ledout : std_logic_vector(1 downto 0);
  
begin  -- BEHAVIOR

  fat : FP_CMP_TESTER
    port map (
      clkin  => clk,
      ledout => ledout);
  
  process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;

end BEHAVIOR;
