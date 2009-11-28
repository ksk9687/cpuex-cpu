library IEEE;
use IEEE.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

entity CLOCK is
  port (
    clkin       : in  std_logic;
    clkout0     : out std_logic;
    clkout90    : out std_logic;
    clkout180   : out std_logic;
    clkout270   : out std_logic;
    clkout2x    : out std_logic;
    clkout2x90 	: out std_logic;
    clkout2x180 : out std_logic;
    clkout2x270 : out std_logic;
    clkout4x	: out std_logic;
    clkout1x	: out std_logic;
    locked      : out std_logic);
end CLOCK;

architecture CLOCK of CLOCK is
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
  
 
begin  -- CLOCK

  locked <= locked0 and locked1;

  ROC0 : ROC
    port map (
      O => rst0);

  DCM0 : DCM
    generic map (
      CLK_FEEDBACK       => "1X",
      CLKIN_PERIOD       => 20.0,
      CLKFX_MULTIPLY     => 2,
      CLKFX_DIVIDE       => 1,
      CLKDV_DIVIDE       => 2.0,
      CLKOUT_PHASE_SHIFT => "NONE")
    port map (
      CLKIN  => ibufg_clkin,
      CLKFB  => bufg_clkfb,
      CLK0   => clk0,
      CLK90  => clk90,
      CLK180 => clk180,
      CLK270 => clk270,
      CLK2X  => clk2x,
      CLKDV => clkdv,
      LOCKED => locked0,
      RST    => rst0);

  rst1 <= '1' when rst0 = '1' or locked0 = '0' else
          '0';
  
  DCM1 : DCM
    generic map (
      CLK_FEEDBACK       => "1X",
      CLKIN_PERIOD       => 10.0,
      CLKFX_MULTIPLY     => 2,
      CLKFX_DIVIDE       => 1,
      CLKDV_DIVIDE       => 2.0,
      CLKOUT_PHASE_SHIFT => "NONE")
    port map (
      CLKIN  => bufg_clk2x,
      CLKFB  => bufg_clk2xfb,
      CLK0   => clk2x0,
      CLK90  => clk2x90,
      CLK180 => clk2x180,
      CLK270 => clk2x270,
      CLK2X  => clk4x0,
      CLKDV  => clk1x0,
      LOCKED => locked1,
      RST    => rst1);

  IBUFG0 : IBUFG
    port map (
      I => clkin,
      O => ibufg_clkin);

  BUFG0 : BUFG
    port map (
      I => clk0,
      O => bufg_clkfb);

  clkout0 <= bufg_clkfb;

  BUFG2 : BUFG
    port map (
      I => clk90,
      O => clkout90);

  BUFG3 : BUFG
    port map (
      I => clk180,
      O => clkout180);

  BUFG4 : BUFG
    port map (
      I => clk270,
      O => clkout270);

  BUFG5 : BUFG
    port map (
      I => clk2x,
      O => bufg_clk2x);

  BUFG6 : BUFG
    port map (
      I => clk2x0,
      O => bufg_clk2xfb);

  clkout2x <= bufg_clk2xfb;

  BUFG7 : BUFG
    port map (
      I => clk2x180,
      O => clkout2x180);

  BUFG8 : BUFG
    port map (
      I => clk2x270,
      O => clkout2x270);
      
  BUFG9 : BUFG
    port map (
      I => clk2x90,
      O => clkout2x90);
      
  BUFG10 : BUFG
    port map (
      I => clk4x0,
      O => clkout4x);
   
  BUFG11 : BUFG
    port map (
      I => clk1x0,
      O => clkout1x);   
end CLOCK;