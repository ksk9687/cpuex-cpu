--リオーダバッファ　FF

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;
entity reorderBuffer is
	port  (
		clk,flush : in std_logic;
		write1,write2,regwrite1,regwrite2 : in std_logic;
		write1ok,write2ok: out std_logic;
		
		op,op2 : in std_logic_vector(1 downto 0);
		reg_d,reg_d2,reg_s1,reg_s2,reg_s12,reg_s22 : in std_logic_vector(5 downto 0);
		
		reg_s1_ok,reg_s2_ok,reg_s12_ok,reg_s22_ok : out std_logic;
		reg_s1_data,reg_s2_data,reg_s12_data,reg_s22_data : out std_logic_vector(31 downto 0);
		s1tag,s2tag,s12tag,s22tag : out std_logic_vector(2 downto 0);
		newtag1,newtag2 : out std_logic_vector(2 downto 0);
		
		read: in std_logic;
		readok: out std_logic;
		reg_num : out std_logic_vector(5 downto 0);
		reg_data : out std_logic_vector(31 downto 0);
		outop : out std_logic_vector(1 downto 0);
		
		dwrite1,dwrite2 : in std_logic;
		dtag1,dtag2 : in std_logic_vector(3 downto 0);
		value1,value2 : in std_logic_vector(31 downto 0)
	);
end reorderBuffer;

architecture arch of reorderBuffer is
	signal rst :std_logic := '0';
	
	constant init_entry : std_logic_vector(40 downto 0) := (others => '0');
	type entry_t is array (0 to 7) of std_logic_vector (40 downto 0);
	signal buf : entry_t := (others => init_entry);
	
	constant init_map_entry : std_logic_vector(2 downto 0) := (others => '0');
	type map_t is array (0 to 63) of std_logic_vector (2 downto 0);
	signal bufmap : map_t := (others => init_map_entry);
	
	signal read_pointer :std_logic_vector(2 downto 0) := (others => '0');
	signal write_pointer :std_logic_vector(2 downto 0) := (others => '0');
	signal write1ok_in,write2ok_in,readok_in :std_logic := '0';
	signal readdata_in : std_logic_vector(40 downto 0) := init_entry;
	 
	signal s1_tag,s2_tag,s12_tag,s22_tag :std_logic_vector(2 downto 0) := (others => '0');
begin

  	ROC0 : ROC port map (O => rst);
  	
	write1ok <= write1ok_in;
	write2ok <= write2ok_in;
	write1ok_in <= '0' when read_pointer = (write_pointer + '1') else '1';
	write2ok_in <= '0' when read_pointer = (write_pointer + "10") else '1' and write1ok_in;
	
	readok <= readok_in;
	reg_data <= buf(conv_integer(read_pointer))(31 downto 0);
	reg_num <= buf(conv_integer(read_pointer))(37 downto 32);
	outop <= "00" when read_pointer = write_pointer else buf(conv_integer(read_pointer))(40 downto 39);
	readok_in <= '0' when read_pointer = write_pointer else
	buf(conv_integer(read_pointer))(38);
	
	s1tag <= s1_tag;
	s2tag <= s2_tag;
	s12tag <= s12_tag;
	s22tag <= s22_tag;
	
	s1_tag <= bufmap(conv_integer(reg_s1));
	s2_tag <= bufmap(conv_integer(reg_s2));
	s12_tag <= bufmap(conv_integer(reg_s12));
	s22_tag <= bufmap(conv_integer(reg_s22));
	
	reg_s1_ok <= '1' when dtag1 = s1_tag and dwrite1 = '1' else
	'1' when dtag2 = s1_tag and dwrite2 = '1' else
	buf(conv_integer( s1_tag ))(38);
	reg_s2_ok <= '1' when dtag1 = s2_tag and dwrite1 = '1' else
	'1' when dtag2 = s2_tag and dwrite2 = '1' else
	buf(conv_integer( s2_tag ))(38);
	reg_s12_ok <= '1' when dtag1 = s12_tag and dwrite1 = '1' else
	'1' when dtag2 = s12_tag and dwrite2 = '1' else
	buf(conv_integer( s12_tag ))(38);
	reg_s22_ok <= '1' when dtag1 = s22_tag and dwrite1 = '1' else
	'1' when dtag2 = s22_tag and dwrite2 = '1' else
	buf(conv_integer( s22_tag ))(38);
	
	reg_s1_data <= value1 when dtag1 = s1_tag and dwrite1 = '1' else
	value2 when dtag2 = s1_tag and dwrite2 = '1' else
	buf(conv_integer( s1_tag ))(31 downto 0);
	reg_s2_data <= value1 when dtag1 = s2_tag and dwrite1 = '1' else
	value2 when dtag2 = s2_tag and dwrite2 = '1' else
	buf(conv_integer( s2_tag ))(31 downto 0);
	reg_s12_data <= value1 when dtag1 = s12_tag and dwrite1 = '1' else
	value2 when dtag2 = s12_tag and dwrite2 = '1' else
	buf(conv_integer( s12_tag ))(31 downto 0);
	reg_s22_data <= value1 when dtag1 = s22_tag and dwrite1 = '1' else
	value2 when dtag2 = s22_tag and dwrite2 = '1' else
	buf(conv_integer( s22_tag ))(31 downto 0);
	
	--新しいTAG（エントリ番号）
	newtag1 <= write_pointer;
	newtag2 <= write_pointer + '1';
	
	process(clk)
	begin
		if rst = '1' then
				read_pointer <= (others => '0');
				write_pointer <= (others => '0');
			
		elsif rising_edge(clk) then
			if flush = '1' then
				read_pointer <= (others => '0');
				write_pointer <= (others => '0');
			else
				--追加
				if (write1 = '1') and (write2 = '1') then
					write_pointer <= write_pointer + "10";
				elsif (write1 = '1') then
					write_pointer <= write_pointer + '1';
				end if;
				if reg_d = reg_d2 and (regwrite1 = '1') and (regwrite2 = '1') then
					bufmap(conv_integer(reg_d2)) <= write_pointer + '1';
				else
					if (regwrite1 = '1') then
						bufmap(conv_integer(reg_d)) <= write_pointer;
					end if;
					if (regwrite2 = '1') then
						bufmap(conv_integer(reg_d2)) <= write_pointer + '1';
					end if;
				end if;
				
				--消去
				if (read = '1') then
					read_pointer <= read_pointer + '1';
				end if;
				
				if (readok_in = '1') and read_pointer = "000" then
					buf(0)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "000") then
					buf(0)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "000") then
					buf(0)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "111" then
					buf(0)(40 downto 39) <= op2;
					buf(0)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "000" then
					buf(0)(40 downto 39) <= op;
					buf(0)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "000") then
					buf(0)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "000") then
					buf(0)(31 downto 0) <= value2;
				end if;
				
				if (readok_in = '1') and read_pointer = "001" then
					buf(1)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "001") then
					buf(1)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "001") then
					buf(1)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "000" then
					buf(1)(40 downto 39) <= op2;
					buf(1)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "001" then
					buf(1)(40 downto 39) <= op;
					buf(1)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "001") then
					buf(1)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "001") then
					buf(1)(31 downto 0) <= value2;
				end if;
				
				if (readok_in = '1') and read_pointer = "010" then
					buf(2)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "010") then
					buf(2)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "010") then
					buf(2)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "001" then
					buf(2)(40 downto 39) <= op2;
					buf(2)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "010" then
					buf(2)(40 downto 39) <= op;
					buf(2)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "010") then
					buf(2)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "010") then
					buf(2)(31 downto 0) <= value2;
				end if;
				
				if (readok_in = '1') and read_pointer = "011" then
					buf(3)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "011") then
					buf(3)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "011") then
					buf(3)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "010" then
					buf(3)(40 downto 39) <= op2;
					buf(3)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "011" then
					buf(3)(40 downto 39) <= op;
					buf(3)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "011") then
					buf(3)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "011") then
					buf(3)(31 downto 0) <= value2;
				end if;
				
				if (readok_in = '1') and read_pointer = "100" then
					buf(4)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "100") then
					buf(4)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "100") then
					buf(4)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "011" then
					buf(4)(40 downto 39) <= op2;
					buf(4)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "100" then
					buf(4)(40 downto 39) <= op;
					buf(4)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "100") then
					buf(4)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "100") then
					buf(4)(31 downto 0) <= value2;
				end if;
				
				if (readok_in = '1') and read_pointer = "101" then
					buf(5)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "101") then
					buf(5)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "101") then
					buf(5)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "100" then
					buf(5)(40 downto 39) <= op2;
					buf(5)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "101" then
					buf(5)(40 downto 39) <= op;
					buf(5)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "101") then
					buf(5)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "101") then
					buf(5)(31 downto 0) <= value2;
				end if;
				
				if (readok_in = '1') and read_pointer = "110" then
					buf(6)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "110") then
					buf(6)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "110") then
					buf(6)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "101" then
					buf(6)(40 downto 39) <= op2;
					buf(6)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "110" then
					buf(6)(40 downto 39) <= op;
					buf(6)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "110") then
					buf(6)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "110") then
					buf(6)(31 downto 0) <= value2;
				end if;
				
				if (readok_in = '1') and read_pointer = "111" then
					buf(7)(38) <= '0';
				elsif (dwrite1 = '1') and (dtag1 = "111") then
					buf(7)(38) <= '1';
				elsif (dwrite2 = '1') and (dtag2 = "111") then
					buf(7)(38) <= '1';
				end if;
				if (write2 = '1') and write_pointer = "110" then
					buf(7)(40 downto 39) <= op2;
					buf(7)(37 downto 32) <= reg_d2;
				elsif (write1 = '1') and write_pointer = "111" then
					buf(7)(40 downto 39) <= op;
					buf(7)(37 downto 32) <= reg_d;
				end if;
				if (dwrite1 = '1') and (dtag1 = "111") then
					buf(7)(31 downto 0) <= value1;
				elsif (dwrite2 = '1') and (dtag2 = "111") then
					buf(7)(31 downto 0) <= value2;
				end if;
				
			end if;
		end if;
	end process;


end arch;
