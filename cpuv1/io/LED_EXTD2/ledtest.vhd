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
		outdata0 : out std_logic_vector(7 downto 0);
		outdata1 : out std_logic_vector(7 downto 0);
		outdata2 : out std_logic_vector(7 downto 0);
		outdata3 : out std_logic_vector(7 downto 0);
		outdata4 : out std_logic_vector(7 downto 0);
		outdata5 : out std_logic_vector(7 downto 0);
		outdata6 : out std_logic_vector(7 downto 0);
		outdata7 : out std_logic_vector(7 downto 0)
    );
end ledtest;

architecture Behavioral of ledtest is
	constant counterth : integer := 23;

	signal clk : STD_LOGIC;
	signal reset : std_logic;
	signal counter : STD_LOGIC_VECTOR((counterth-1) downto 0);
	signal hexcounter : STD_LOGIC_VECTOR(31 downto 0);
	signal dotcounter : STD_LOGIC_VECTOR(7 downto 0);
	component ledextd2
		Port (
		leddata   : in std_logic_vector(31 downto 0);
		leddotdata: in std_logic_vector(7 downto 0);
		outdata0 : out std_logic_vector(7 downto 0);
		outdata1 : out std_logic_vector(7 downto 0);
		outdata2 : out std_logic_vector(7 downto 0);
		outdata3 : out std_logic_vector(7 downto 0);
		outdata4 : out std_logic_vector(7 downto 0);
		outdata5 : out std_logic_vector(7 downto 0);
		outdata6 : out std_logic_vector(7 downto 0);
		outdata7 : out std_logic_vector(7 downto 0)
		);
	end component;
begin
	ibufg_inst : ibufg port map (I => clkin,O => clk);
	roc_inst : roc port map (O => reset);
	
	led_inst : ledextd2 port map (
		hexcounter,
		dotcounter,
		outdata0,
		outdata1,
		outdata2,
		outdata3,
		outdata4,
		outdata5,
		outdata6,
		outdata7
	);
	process (clk, reset)
	begin  -- process
		if reset = '1' then                 -- asynchronous reset (active low)
			counter <= (others => '0');
			hexcounter <= X"44444444";
			dotcounter <= "00001010";
		elsif clk'event and clk = '1' then  -- rising clock edge
			counter <= counter + 1;
			if (counter = conv_std_logic_vector(0,counterth)) then
				hexcounter <= hexcounter + 1;
			end if;
		end if;
	end process;
end Behavioral;
