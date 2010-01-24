--RSA

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity returnAddressStack is
	port  (
		clk,rst,flush : in std_logic;
		jal,jr : in std_logic;
		pc : in std_logic_vector(14 downto 0);
		new_pc : out std_logic_vector(14 downto 0)
	);
end returnAddressStack;

architecture arch of returnAddressStack is

	type ras_t is array (0 to 15) of std_logic_vector (14 downto 0);
	signal ras	:	ras_t := (others => (others => '0'));

	signal p :std_logic_vector(1 downto 0) := (others => '0');
	signal read_pointer,read_pointer_buf :std_logic_vector(3 downto 0) := (others => '0');
	signal read_pointer2,read_pointer2_buf :std_logic_vector(3 downto 0) := (others => '1');
begin
	new_pc <= ras(conv_integer(read_pointer2));

	process(clk,rst)
	begin
		if rst = '1' then
			read_pointer <= (others => '0');
			read_pointer2 <= (others => '1');
		elsif rising_edge(clk) then
			if jr = '1' then 
				read_pointer <= read_pointer - '1';
				read_pointer2 <= read_pointer2 - '1';
			elsif jal = '1' then
				ras(conv_integer(read_pointer)) <= pc;
				read_pointer <= read_pointer + '1';
				read_pointer2 <= read_pointer2 + '1';
			end if;
		end if;
	end process;
	
	

end arch;

