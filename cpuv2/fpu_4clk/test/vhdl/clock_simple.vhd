library IEEE;
use IEEE.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

entity CLOCK is
  port (
    clkin       : in  std_logic;
    clkout0     : out std_logic;
    clkout2x    : out std_logic);
end CLOCK;

architecture CLOCK of CLOCK is
  signal clk0   : std_logic;
  signal clk2x  : std_logic;
  signal clkdv,bufg_clkdv  : std_logic;

  signal clk2x0   : std_logic;

  signal bufg_clkfb   : std_logic;
  signal ibufg_clkin  : std_logic;
  signal bufg_clk2x   : std_logic;
  signal bufg_clk2xfb : std_logic;

  signal locked0 : std_logic;
  signal locked1 : std_logic;
  
  signal locked0_b1,locked0_b2,locked0_b3,locked0_b4 : std_logic;
  
  signal rst0 : std_logic;
  signal rst1 : std_logic;
  
 
begin  -- CLOCK

  -- locked <= locked0 and locked1;

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
      CLK90  => open,
      CLK180 => open,
      CLK270 => open,
      CLK2X  => clk2x,
      CLKDV => clkdv,
      LOCKED => locked0,
      RST    => rst0);
      
	process(bufg_clkdv)
	begin
		if rising_edge(bufg_clkdv) then
			locked0_b1 <= locked0;
			locked0_b2 <= locked0_b1;
			locked0_b3 <= locked0_b2;
			locked0_b4 <= locked0_b3;
		end if;
	end process;


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
      CLK180 => open,
      CLK270 => open,
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
  
  BUFG_DV : BUFG
    port map (
      I => clkdv,
      O => bufg_clkdv);

  clkout0 <= bufg_clkfb;

  BUFG5 : BUFG
    port map (
      I => clk2x,
      O => bufg_clk2x);

  BUFG6 : BUFG
    port map (
      I => clk2x0,
      O => bufg_clk2xfb);

  clkout2x <= bufg_clk2xfb;

end CLOCK;
