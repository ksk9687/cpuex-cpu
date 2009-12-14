--命令キャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end cache;


architecture arch of cache is
    type cache_tag_type is array (0 to 4095) of std_logic_vector (2 downto 0);--2 + 1
    type cache_data_type is array (0 to 4095) of std_logic_vector (31 downto 0); --32
    
   signal tag,tag_p : std_logic_vector(2 downto 0) := '0'&"00";
   signal cache : cache_tag_type := (others => '0'&"00");
   signal cache_data : cache_data_type;
   
    signal address_buf : std_logic_vector(13 downto 0) := (others => '0');
    signal read_addr : std_logic_vector(11 downto 0) := (others => '0');
    signal read : std_logic_vector(31 downto 0) := (others => '0');
    signal hit_p,hit_zero_add : std_logic := '0';
begin
	read_data <= cache_data(conv_integer(address_buf(11 downto 0)));
	
	tag <= cache(conv_integer(address_buf(11 downto 0)));
	hit <= tag(2) when tag(1 downto 0) = address_buf(13 downto 12) else '0';
	
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	           cache(conv_integer(set_addr(11 downto 0))) <= '1'&set_addr(13 downto 12);
	        end if;
	        address_buf <= address(13 downto 0);
	    end if;
	end process;
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache_data(conv_integer(set_addr(11 downto 0))) <= set_data;
	        end if;
	    end if;
	end process;
	
	
end arch;



--データキャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dcache is
	generic (
		width : integer := 9;
		depth : integer := 2048;
		check_width : integer := 2
	);
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_f : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end dcache;

architecture arch of dcache is
    type cache_tag_type is array (0 to depth - 1) of std_logic_vector (width downto 0); --width + 1
    type cache_data_type is array (0 to depth - 1) of std_logic_vector (31 downto 0); --32
    
    signal cache : cache_tag_type :=(
    	others => (others => '0')
    	);
    	
   signal cache_data : cache_data_type;
   
    signal entry,entry_buf : std_logic_vector(width downto 0) := (others => '0');
    signal read_addr : std_logic_vector((width - 1) downto 0) := (others => '0');
    signal read : std_logic_vector(31 downto 0) := (others => '0');
    signal hit_buf,hit_p,read_f_buf: std_logic := '0';
    signal cmp,cmp_buf :std_logic_vector(4 downto 0) := "00000";
    signal address_buf : std_logic_vector(19 downto 0) := (others => '0');
begin
	read_data <= cache_data(conv_integer(address_buf((19 - width)downto 0)));
	hit <= (not read_f_buf) or (cmp(0) and cmp(1) and cmp(2) and cmp(3) and cmp(4));
	 
	
	cmp(0) <= not( (entry(0) xor address_buf(11)) or (entry(1) xor address_buf(12)) );
	cmp(1) <= not( (entry(2) xor address_buf(13)) or (entry(3) xor address_buf(14)) );
	cmp(2) <= not( (entry(4) xor address_buf(15)) or (entry(5) xor address_buf(16)) );
	cmp(3) <= not( (entry(6) xor address_buf(17)) or (entry(7) xor address_buf(18)) );
	cmp(4) <= (not (entry(8) xor address_buf(19))) and entry(9);

	entry <= cache(conv_integer(address_buf((19 - width) downto 0)));


	process (clk)
	begin
	    if rising_edge(clk) then
	        address_buf <= address;
	        read_f_buf <= read_f;
	    end if;
	end process;
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache(conv_integer(set_addr((19 - width) downto 0))) <= '1'&set_addr(19 downto (20 - width));
	        end if;
	    end if;
	end process;
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache_data(conv_integer(set_addr((19 - width) downto 0))) <= set_data;
	        end if;
	    end if;
	end process;
end arch;


--馬鹿キャッシュ
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baka_dcache is
	generic (
		width : integer := 9;
		depth : integer := 2048;
		check_width : integer := 5
	);
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_f : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end baka_dcache;

architecture arch of baka_dcache is
    type cache_tag_type is array (0 to depth - 1) of std_logic_vector (width downto 0); --width + 1
    type cache_data_type is array (0 to depth - 1) of std_logic_vector (31 downto 0); --32
    
    signal cache : cache_tag_type :=(
    	others => (others => '0')
    	);
    	
   signal cache_data : cache_data_type;
   
    signal entry,entry_buf : std_logic_vector(width downto 0) := (others => '0');
    signal read_addr : std_logic_vector((width - 1) downto 0) := (others => '1');
    signal read,data_buf : std_logic_vector(31 downto 0) := (others => '0');
    signal hit_buf,hit_p,read_f_buf : std_logic := '0';
    signal address_buf : std_logic_vector(19 downto 0) := (others => '1');
begin
	read_data <= data_buf;
	hit_p <= '1' when address = address_buf else '0';

	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	read_f_buf <= not read_f;
	    	hit <= hit_p;
	    	if (set = '1') then
	    		address_buf <= set_addr;
	    		data_buf <= set_data;
	    	end if;
	    end if;
	end process;
end arch;


