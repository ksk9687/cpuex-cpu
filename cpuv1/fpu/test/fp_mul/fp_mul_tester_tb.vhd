-- FP_MULのテストのModelsim用テストベンチ

library IEEE;
use IEEE.std_logic_1164.all;

entity FP_MUL_TESTER_TB is
  
end FP_MUL_TESTER_TB;


architecture BEHAVIOR of FP_MUL_TESTER_TB is
  component FP_MUL_TESTER
    port (
      clkin  : in  std_logic;
      ledout : out std_logic);
  end component;

  signal clk, ledout : std_logic;
  
begin  -- BEHAVIOR

  fpu_tester_inst : FP_MUL_TESTER
    port map (clkin => clk, ledout => ledout);
  
  process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;

end BEHAVIOR;
