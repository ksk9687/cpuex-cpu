library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clockgenerator is
  Port ( globalclk : in  STD_LOGIC;
         globalrst : in  STD_LOGIC;
         clock66 : out  STD_LOGIC;
         clock133 : out  STD_LOGIC;
         clock133_180 : out  STD_LOGIC;
         reset : out  STD_LOGIC);
end clockgenerator;

architecture Behavioral of clockgenerator is
  COMPONENT clockgen
    PORT(
      CLKIN_IN : IN std_logic;
      RST_IN : IN std_logic;          
      CLKIN_IBUFG_OUT : OUT std_logic;
      CLK0_OUT : OUT std_logic;
      CLK2X_OUT : OUT std_logic;
		CLK2X180_OUT : OUT std_logic;
      LOCKED_OUT : OUT std_logic
      );
  END COMPONENT;
  signal rst : std_logic;
  signal rocrst : std_logic;
  signal lock : std_logic;
begin
-- DCM_ADV: Digital Clock Manager Circuit
-- Virtex-4/5
-- Xilinx HDL Libraries Guide, version 10.1.2
  roc_inst : roc port map (O => rocrst);
  rst <= rocrst or (not globalrst);
  reset <= rst or (not lock);
  Inst_clockgen: clockgen PORT MAP(
    CLKIN_IN => globalclk,
    RST_IN => rst,
    CLKIN_IBUFG_OUT => open,
    CLK0_OUT => clock66,
    CLK2X_OUT => clock133,
    CLK2X180_OUT => clock133_180,
    LOCKED_OUT => lock
    );
end Behavioral;

