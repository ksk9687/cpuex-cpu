library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IROM is
	port  (
		clk : in std_logic;
		pc : in std_logic_vector(19 downto 0);
		
		inst : out std_logic_vector(31 downto 0)
	);
end IROM;

architecture arch of IROM is
    type rom_t is array (0 to 7) of std_logic_vector (31 downto 0); 
    signal ROM : rom_t :=(
    op_li & o"00" & 0"00" & "00"&x"000",
    op_li & o"00" & 0"00" & "00"&x"037",
    op_led & o"00" & 0"00" & "00"&x"000",
    op_halt & "00" & x"000000",
    op_halt & "00" & x"000000",
    op_halt & "00" & x"000000",
    op_halt & "00" & x"000000",
    op_halt & "00" & x"000000"
    );
    
    
begin
--	inst <= ROM(conv_integer(pc(3 downto 0)));
	process(clk)
	begin
		if rising_edge(clk) then
			inst <= ROM(conv_integer(pc(2 downto 0)));
		end if;
	end process;
	
	 
end arch;

