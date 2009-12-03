
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity instructionBuffer is
	port  (
		clk,rst,flush : in std_logic;        -- input clock, xx MHz.
		read ,write: in std_logic;
		readok,writeok: out std_logic;
		readdata,writedata: out std_logic_vector(49 downto 0)
	);
end instructionBuffer;

architecture arch of instructionBuffer is
	type ram_t is array (0 to 31) of std_logic_vector (49 downto 0);
	 signal RAM : ram_t := ('1'&x"00000"&op_nop&"00"&x"000000");
	 
	 signal read_pointer :std_logic_vector(4 downto 0) := (others => '0');
	 signal write_pointer :std_logic_vector(4 downto 0) := (others => '0');
	 signal writeok_in :std_logic := '0';
	 
	 constant nop_out : std_logic_vector(49 downto 0) := op_nop&x"00000000000";
begin
	readdata <= RAM(read_pointer) when readok_in = '1' else nop_out;
	
	writeok <= writeok_in;
	writeok_in <= '0' when read_pointer = write_pointer + '1' else '1';
	readok <= readok_in;
	readok_in <= '0' when read_pointer = write_pointer else '1';
	
	process(clk,rst)
	begin
		if rst = '1' then
			read_pointer := (others => '0');
			write_pointer := (others => '0');
		elsif rising_edge(clk) then
			if flush = '1' then
				read_pointer := (others => '0');
				write_pointer := (others => '0');			
			else
				if (write = '1') and (writeok_in = '1') then
					RAM(write_pointer) <= readdata;
					write_pointer <= write_pointer + '1';
				end if;
				if (read = '1') and (readok_in = '1') then
					read_pointer <= read_pointer + '1';
				end if;
			end if;
		end if;
	end process;
	


end arch;

