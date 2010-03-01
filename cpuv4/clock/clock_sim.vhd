library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity clockgen is
   port ( 
          
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		CLKFX_OUT : OUT std_logic;
		CLKFX180_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
          );
end clockgen;


architecture CLOCK of clockgen is
  signal clk0   : std_logic;
  signal clk90  : std_logic;
  signal clk180 : std_logic;
  signal clk270 : std_logic;
  signal clk2x  : std_logic;
  signal clkdv  : std_logic;
  
  signal clk2x0   : std_logic;
  signal clk2x90 : std_logic;
  signal clk2x180 : std_logic;
  signal clk2x270 : std_logic;
  
  signal clk4x0   : std_logic;
  signal clk1x0   : std_logic;

  signal bufg_clkfb   : std_logic;
  signal ibufg_clkin  : std_logic;
  signal bufg_clk2x   : std_logic;
  signal bufg_clk2xfb : std_logic;

  signal locked0 : std_logic;
  signal locked1 : std_logic;
  
  
  signal rst0 : std_logic;
  signal rst1 : std_logic;
  signal clkout90,clkout180,clkout270,CLK270_OUT,CLK90_OUT,CLK2X_OUT,clkout1x : std_logic;
  
begin  -- CLOCK
CLKIN_IBUFG_OUT <= CLKIN_IN;
CLK0_OUT <= CLKIN_IN;
CLKFX_OUT <= CLKIN_IN;
CLKFX180_OUT <= not CLKIN_IN;
LOCKED_OUT <= RST_IN;
end CLOCK;


