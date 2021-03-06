
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 

library UNISIM;
use UNISIM.VComponents.all;

entity instructionBuffer is
	port  (
		clk,flush : in std_logic;        -- input clock, xx MHz.
		read ,write: in std_logic;
		readok,writeok: out std_logic;
		readdata : out std_logic_vector(62 downto 0);
		writedata: in std_logic_vector(62 downto 0)
	);
end instructionBuffer;

architecture arch of instructionBuffer is
	 constant nop_out : std_logic_vector(62 downto 0) := "000"&x"000"&x"0"&op_nop&x"000000000"&"00";
	type ram_t is array (0 to 7) of std_logic_vector (62 downto 0);
	 signal RAM : ram_t := (others => nop_out);
	 
	 signal read_pointer,read_pointer_p1 :std_logic_vector(2 downto 0) := (others => '0');
	 signal write_pointer,write_pointer_p1 :std_logic_vector(2 downto 0) := (others => '0');
	 signal writeok_in,readok_in,rst :std_logic := '0';
	 signal readdata_in : std_logic_vector(62 downto 0) := nop_out;
	 signal tmp : std_logic_vector(2 downto 0) := "000";
	 
begin
	readdata_in <= RAM(conv_integer(read_pointer));
	
	readdata(62 downto 48) <= readdata_in(62 downto 48);
	readdata(47 downto 44) <= readdata_in(47 downto 44);

	--op
	readdata(43 downto 38) <= readdata_in(43 downto 38) when readok_in = '1' else
	nop_out(43 downto 38);
	--Rd
	readdata(37) <= readdata_in(37) and readok_in;
	readdata(36 downto 31) <= readdata_in(36 downto 31);
	--Rs1
	readdata(30) <= readdata_in(30) and readok_in;
	readdata(29 downto 24) <= readdata_in(29 downto 24);
	--Rs2
	readdata(23) <= readdata_in(23) and readok_in;
	readdata(22 downto 17) <= readdata_in(22 downto 17);
	--Cr
	readdata(16) <= readdata_in(16) and readok_in;
	readdata(15) <= readdata_in(15) and readok_in;
	--Im
	readdata(14 downto 0) <= readdata_in(14 downto 0);
	
	
	writeok <= writeok_in;
	writeok_in <= tmp(0) or tmp(1) or tmp(2); 
	
	--write_pointer_p1 <= (write_pointer + '1');
	--writeok_in <= '0' when read_pointer = write_pointer_p1 else '1';
	
	tmp(0) <= read_pointer(0) xor (not write_pointer(0));
	tmp(1) <= read_pointer(1) xor (write_pointer(1) xor write_pointer(0));
	tmp(2) <= read_pointer(2) xor (write_pointer(2) xor (write_pointer(1) and write_pointer(0)));
	
	readok <= readok_in;
	readok_in <= '0' when (read_pointer = write_pointer) else '1';

	
	
	process(clk)
	begin
		if rising_edge(clk) then
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

