-- ALUのテストのModelsim用テストベンチ

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_TESTER_TB is
  
end ALU_TESTER_TB;


architecture BEHAVIOR of ALU_TESTER_TB is
  component ALU_TESTER
    port (
      clkin  : in  std_logic;
      ledout : out std_logic);
  end component;

  signal clk, ledout : std_logic;
  
begin  -- BEHAVIOR

  alu_tester_inst : ALU_TESTER
    port map (clkin => clk, ledout => ledout);
  
  process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;

end BEHAVIOR;
