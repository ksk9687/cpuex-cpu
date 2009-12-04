
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 

entity instructionBuffer is
	port  (
		clk,rst,flush : in std_logic;        -- input clock, xx MHz.
		read ,write: in std_logic;
		readok,writeok: out std_logic;
		readdata : out std_logic_vector(49 downto 0);
		writedata: in std_logic_vector(49 downto 0)
	);
end instructionBuffer;

architecture arch of instructionBuffer is
	 constant nop_out : std_logic_vector(49 downto 0) := op_nop&x"00000000000";
	type ram_t is array (0 to 15) of std_logic_vector (49 downto 0);
	 signal RAM : ram_t := (others => nop_out);
	 
	 signal read_pointer :std_logic_vector(4 downto 0) := (others => '0');
	 signal write_pointer :std_logic_vector(4 downto 0) := (others => '0');
	 signal writeok_in,readok_in :std_logic := '0';
	 signal readdata_in : std_logic_vector(49 downto 0) := nop_out;
	 
begin

	readdata_in <= RAM(conv_integer(read_pointer));

	readdata(49 downto 44) <= readdata_in(49 downto 44) when readok_in = '1' else
	nop_out(49 downto 44);
	readdata(43) <= readdata_in(43) and readok_in;
	readdata(42 downto 37) <= readdata_in(42 downto 37);
	readdata(36) <= readdata_in(36) and readok_in;
	readdata(35 downto 30) <= readdata_in(35 downto 30);
	readdata(29) <= readdata_in(29) and readok_in;
	readdata(28 downto 23) <= readdata_in(28 downto 23);
	readdata(22) <= readdata_in(22) and readok_in;
	readdata(21) <= readdata_in(21) and readok_in;
	readdata(20 downto 0) <= readdata_in(20 downto 0);
	
	
	writeok <= writeok_in;
	writeok_in <= '0' when read_pointer = write_pointer + '1' else '1';
	readok <= readok_in;
	readok_in <= '0' when read_pointer = write_pointer else '1';
	
	process(clk,rst)
	begin
		if rst = '1' then
			read_pointer <= (others => '0');
			write_pointer <= (others => '0');
		elsif rising_edge(clk) then
			if flush = '1' then
				read_pointer <= (others => '0');
				write_pointer <= (others => '0');
			else
				if (write = '1') and (writeok_in = '1') then
					RAM(conv_integer(write_pointer)) <= writedata;
					write_pointer <= write_pointer + '1';
				end if;
				if (read = '1') and (readok_in = '1') then
					read_pointer <= read_pointer + '1';
				end if;
			end if;
		end if;
	end process;
	


end arch;

