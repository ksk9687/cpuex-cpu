

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 


entity lsu is
	port  (
		clk,rst,read,write,load_ok : in std_logic;
		op : in std_logic_vector(2 downto 0);
    	lsu_ok,lsu_full,lsu_may_full : out std_logic;--
    	
    	ls_addr_in : in std_logic_vector(19 downto 0);--
    	ls_addr_out : out std_logic_vector(19 downto 0);--
    	
    	ls_flg : out std_logic_vector(1 downto 0);--
    	reg_d : out std_logic_vector(5 downto 0);
    	
    	lsu_in : in std_logic_vector(31 downto 0);--
    	lsu_out : out std_logic_vector(31 downto 0);--
    	load_data : in std_logic_vector(31 downto 0);--
    	store_data : out std_logic_vector(31 downto 0)--
	);
end lsu;

architecture arch of lsu is
	type ram_t is array (0 to 7) of std_logic_vector (53 downto 0);
	 signal RAM : ram_t := (others => (others => '0'));
	 
	 signal read_pointer :std_logic_vector(2 downto 0) := (others => '0');
	 signal write_pointer :std_logic_vector(2 downto 0) := (others => '0');
	 signal writeok_in,empty,readok_in,load_end,load_end_p,lsu_ok_in :std_logic := '0';
	 signal buf : std_logic_vector(31 downto 0) := (others => '0');
	 signal writedata : std_logic_vector(53 downto 0) := (others => '0');

begin
	lsu_full <= not writeok_in;
	writeok_in <= '0' when read_pointer = write_pointer + '1' else '1';
	lsu_may_full <= '1' when read_pointer = write_pointer + "10" else '0';
	
	lsu_ok <= (not empty) and lsu_ok_in and (not RAM(conv_integer(read_pointer))(52));
	
	--空か
	empty <= '1' when read_pointer = write_pointer else '0';
	--読み込み位置にあるレコードを消してもよいか。
	lsu_ok_in <= load_end when RAM(conv_integer(read_pointer))(53 downto 52) = "10" else '1';
	
	reg_d <= RAM(conv_integer(read_pointer))(25 downto 20);
	lsu_out <= buf;
	ls_flg(1) <= (RAM(conv_integer(read_pointer))(53) and (not empty));
	ls_flg(0) <= RAM(conv_integer(read_pointer))(52) and (not empty);
	store_data <= RAM(conv_integer(read_pointer))(51 downto 20);
	ls_addr_out <= RAM(conv_integer(read_pointer))(19 downto 0);
	
	writedata(19 downto 0) <= ls_addr_in;
	writedata(51 downto 20) <= lsu_in;
	writedata(52) <= '1' when op = op_store(2 downto 0) else '0'; 
	writedata(53) <= write;



	process(clk,rst)
	begin
		if rst = '1' then
			read_pointer <= (others => '0');
			write_pointer <= (others => '0');
			load_end <= '0';
			load_end_p <= '0';
		elsif rising_edge(clk) then
			
			if (write = '1') and (writeok_in = '1') then
				RAM(conv_integer(write_pointer)) <= writedata;
				write_pointer <= write_pointer + '1';
			end if;
			
			if (((read = '1') or (RAM(conv_integer(read_pointer))(53 downto 52) /= "10")) and (empty = '0')) then
				read_pointer <= read_pointer + '1';
			end if;

			if ((read = '1') or (RAM(conv_integer(read_pointer))(53 downto 52) /= "10")) then
				load_end <= '0';
				load_end_p <= '0';
			elsif (write = '1') and (writeok_in = '1') and (empty = '1') then
				load_end <= '0';
				load_end_p <= '0';		
			elsif (load_ok = '1') and (load_end_p = '1') then
				load_end <= '1';
			else
				load_end_p <= '1';
			end if;
			
			if load_ok = '1' then
				buf <= load_data;
			end if;
		end if;
	end process;
	



end arch;
