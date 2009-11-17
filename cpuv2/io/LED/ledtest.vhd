library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ledtest is
    Port (
           clkin : in STD_LOGIC;
           led2h : out STD_LOGIC_VECTOR(7 downto 0);
           led2l : out STD_LOGIC_VECTOR(7 downto 0)
    );
end ledtest;

architecture Behavioral of ledtest is
	constant counterth : integer := 23;

	signal clk : STD_LOGIC;
	signal reset : std_logic;
	signal counter : STD_LOGIC_VECTOR((counterth-1) downto 0);
	signal hexcounter : STD_LOGIC_VECTOR(7 downto 0);
	component hex2ledmod
		Port (
			data : in STD_LOGIC_VECTOR(7 downto 0);
			doth : in STD_LOGIC;
			dotl : in STD_LOGIC;
			led2h : out STD_LOGIC_VECTOR(7 downto 0);
			led2l : out STD_LOGIC_VECTOR(7 downto 0)
		);
	end component;
	signal dotc : std_logic;
begin
	ibufg_inst : ibufg port map (I => clkin,O => clk);
	roc_inst : roc port map (O => reset);
	
	led_inst : hex2ledmod port map (
		hexcounter,
		'1',
		dotc,
		led2h,
		led2l
	);
	process (clk, reset)
	begin  -- process
		if reset = '1' then                 -- asynchronous reset (active low)
			counter <= (others => '0');
			dotc <= '0';
		elsif clk'event and clk = '1' then  -- rising clock edge
			counter <= counter + 1;
			if (counter((counterth-2) downto 0) = conv_std_logic_vector(0,counterth)) then
				dotc <= not dotc;
			end if;
			if (counter = conv_std_logic_vector(0,counterth)) then
				hexcounter <= hexcounter + 1;
			end if;
		end if;
	end process;
end Behavioral;
