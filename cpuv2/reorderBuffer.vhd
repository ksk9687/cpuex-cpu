--リオーダバッファ　FF

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reorderBuffer is
	port  (
		clk,rst : in std_logic;
		write : in std_logic;
		writeok: out std_logic;
		
		reg_d,reg_s1,reg_s2 : in std_logic_vector(5 downto 0);
		reg_s1_ok,reg_s2_ok : out std_logic;
		reg_s1_data,reg_s2_data : out std_logic_vector(31 downto 0);
		newtag : out std_logic_vector(2 downto 0);
		
		readok: out std_logic;
		reg_num : out std_logic_vector(5 downto 0);
		reg_data : out std_logic_vector(31 downto 0);
		
		write1,write2,write3 : in std_logic;
		dtag1,dtag2,dtag3 : in std_logic_vector(2 downto 0);
		value1,value2,value3 : in std_logic_vector(31 downto 0)
	);
end reorderBuffer;

architecture arch of reorderBuffer is
	constant init_entry : std_logic_vector(38 downto 0) := (others => '0');
	type entry_t is array (0 to 7) of std_logic_vector (38 downto 0);
	signal buf : entry_t := (others => init_entry);
	
	constant init_map_entry : std_logic_vector(2 downto 0) := (others => '0');
	type map_t is array (0 to 63) of std_logic_vector (2 downto 0);
	signal bufmap : map_t := (others => init_map_entry);
	
	signal read_pointer :std_logic_vector(2 downto 0) := (others => '0');
	signal write_pointer :std_logic_vector(2 downto 0) := (others => '0');
	signal writeok_in,readok_in :std_logic := '0';
	 signal readdata_in : std_logic_vector(38 downto 0) := init_entry;
	 
	signal s1_tag,s2_tag :std_logic_vector(2 downto 0) := (others => '0');
begin

	writeok <= writeok_in;
	writeok_in <= '0' when read_pointer = (write_pointer + '1') else '1';
	readok <= readok_in;
	reg_data <= buf(conv_integer(read_pointer))(31 downto 0);
	reg_num <= buf(conv_integer(read_pointer))(37 downto 32);
	readok_in <= '0' when read_pointer = write_pointer else buf(conv_integer(read_pointer))(38);
	
	s1_tag <=bufmap(conv_integer(reg_s1))(2 downto 0);
	s2_tag <= bufmap(conv_integer(reg_s2))(2 downto 0);
	reg_s1_ok <= buf(conv_integer( s1_tag ))(38);
	reg_s2_ok <= buf(conv_integer( s2_tag ))(38);
	reg_s1_data <= buf(conv_integer( s1_tag ))(31 downto 0);
	reg_s2_data <= buf(conv_integer( s2_tag ))(31 downto 0);
	
	--新しいTAG（エントリ番号）
	newtag <= write_pointer;
	
	process(clk,rst)
	begin
		if rst = '1' then
			read_pointer <= (others => '0');
			write_pointer <= (others => '0');
		elsif rising_edge(clk) then
			
			--追加
			if (write = '1') and (writeok_in = '1') then
				buf(conv_integer(write_pointer))(38 downto 32) <= '0'&reg_d;
				bufmap(conv_integer(reg_d)) <= write_pointer;
				write_pointer <= write_pointer + '1';
			end if;
			
			--消去
			if (readok_in = '1') then
				read_pointer <= read_pointer + '1';
				buf(conv_integer(read_pointer))(38) <= '0';
			end if;
			
			if write1 = '1' then
				buf(conv_integer(dtag1))(38) <= '1';
				buf(conv_integer(dtag1))(31 downto 0) <= value1;
			end if;
			if write2 = '1' then
				buf(conv_integer(dtag2))(38) <= '1';
				buf(conv_integer(dtag2))(31 downto 0) <= value2;
			end if;
			if write3 = '1' then
				buf(conv_integer(dtag3))(38) <= '1';
				buf(conv_integer(dtag3))(31 downto 0) <= value3;
			end if;
		end if;
	end process;


end arch;

