library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity hex2ledmod is
	Port (
		data : in STD_LOGIC_VECTOR(7 downto 0);
		doth : in STD_LOGIC;
		dotl : in STD_LOGIC;
		led2h : out STD_LOGIC_VECTOR(7 downto 0);
		led2l : out STD_LOGIC_VECTOR(7 downto 0)
	);
end hex2ledmod;

architecture Behavioral of hex2ledmod is
	component hex2led
    Port (
           h : in STD_LOGIC_VECTOR(3 downto 0);
           led : out STD_LOGIC_VECTOR(6 downto 0)
    );
	end component;
begin
	led2h_inst : hex2led port map (
		data(7 downto 4),
		led2h(6 downto 0)
	);
	led2h(7)<=doth;

	led2l_inst : hex2led port map (
		data(3 downto 0),
		led2l(6 downto 0)
	);
	led2l(7)<=dotl;

end Behavioral;
