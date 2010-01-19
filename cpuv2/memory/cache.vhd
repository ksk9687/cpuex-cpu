--命令キャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end cache;


architecture arch of cache is
    type cache_tag_type is array (0 to 4095) of std_logic_vector (2 downto 0);--2 + 1
    type cache_data_type is array (0 to 4095) of std_logic_vector (34 downto 0); --32
   
   signal tag,tag_p : std_logic_vector(2 downto 0) := '0'&"00";
   --ignal cache : cache_tag_type := (others => '0'&"00");
   signal cache_data : cache_data_type;
   
    signal read_addr : std_logic_vector(11 downto 0) := (others => '0');
    signal cmp_addr : std_logic_vector(1 downto 0) := (others => '0');
    signal data : std_logic_vector(34 downto 0) := (others => '0');
    signal hit_p,set_buf : std_logic := '0';
    signal set_data_buf : std_logic_vector(31 downto 0) := (others => '0');
begin
	read_data <=data(31 downto 0);
	hit <= data(34)and (not set_buf) when data(33 downto 32) = cmp_addr else '0';
	
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache_data(conv_integer(set_addr(11 downto 0))) <= '1'&set_addr(13 downto 12)&set_data;
	        end if;
			data <= cache_data(conv_integer(address(11 downto 0)));
	        cmp_addr <= address(13 downto 12);
	        set_buf <= set;
	    end if;
	end process;
end arch;

--命令キャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity small_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end small_cache;


architecture arch of small_cache is
    type cache_tag_type is array (0 to 2047) of std_logic_vector (3 downto 0);--3 + 1
    type cache_data_type is array (0 to 2047) of std_logic_vector (31 downto 0); --32
    
   signal tag,tag_p,tag_p2,tag_write : std_logic_vector(3 downto 0) := '0'&"000";
   signal cache : cache_tag_type := (others => '0'&"000");
   signal cache_data : cache_data_type:= (others => (others => '0'));
   
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal read_addr : std_logic_vector(10 downto 0) := (others => '0');
    signal cmp_addr : std_logic_vector(2 downto 0) := (others => '0');
    signal addr_buf,set_addr_buf : std_logic_vector(13 downto 0) := (others => '0');
    signal hit1,hit2,hit_p,hit_p2,conflict : std_logic := '0';
    signal set_data_buf : std_logic_vector(31 downto 0) := (others => '0');
    component icache_tag IS
	port (
	a: IN std_logic_VECTOR(10 downto 0);
	d: IN std_logic_VECTOR(3 downto 0);
	dpra: IN std_logic_VECTOR(10 downto 0);
	clk: IN std_logic;
	we: IN std_logic;
	spo: OUT std_logic_VECTOR(3 downto 0);
	dpo: OUT std_logic_VECTOR(3 downto 0));
end component;
begin
	IT0:icache_tag
	port map(
	set_addr(10 downto 0),
	tag_write,
	address(10 downto 0),
	clk,set,tag_p2,tag_p);
	
	tag_write <= '1'&set_addr(13 downto 11);
	read_data <= cache_data(conv_integer(read_addr));
	hit <= tag(3) when tag(2 downto 0) = cmp_addr(2 downto 0) else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            --cache(conv_integer(set_addr(10 downto 0))) <= '1'&set_addr(13 downto 11);
	            cache_data(conv_integer(set_addr(10 downto 0))) <= set_data;
	        end if;
	        read_addr <= address(10 downto 0);
	        cmp_addr <= address(13 downto 11);
			
			tag <= tag_p;
	    end if;
	end process;
end arch;


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity block_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end block_cache;


architecture arch of block_cache is
    type cache_tag_type is array (0 to 2047) of std_logic_vector (3 downto 0);--3 + 1
    type cache_data_type is array (0 to 2047) of std_logic_vector (31 downto 0); --32
    
   signal tag,tag_p,tag_p2,tag_write : std_logic_vector(3 downto 0) := '0'&"000";
   signal cache : cache_tag_type := (others => '0'&"000");
   signal cache_data : cache_data_type:= (others => (others => '0'));
   
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal read_addr : std_logic_vector(10 downto 0) := (others => '0');
    signal cmp_addr : std_logic_vector(2 downto 0) := (others => '0');
    signal addr_buf,set_addr_buf : std_logic_vector(13 downto 0) := (others => '0');
    signal hit1,hit2,hit_p,hit_p2,conflict,conflict1,conflict2 : std_logic := '0';
    signal set_data_buf : std_logic_vector(31 downto 0) := (others => '0');

begin

	tag_write <= '1'&set_addr(13 downto 11);
	read_data <= cache_data(conv_integer(read_addr));
	tag <= cache(conv_integer(read_addr));
	hit <= tag(3) and (not conflict) and (not conflict1) when tag(2 downto 0) = cmp_addr(2 downto 0) else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache(conv_integer(set_addr(10 downto 0))) <= tag_write;
	            cache_data(conv_integer(set_addr(10 downto 0))) <= set_data;
	        end if;
	        read_addr <= address(10 downto 0);
	        cmp_addr <= address(13 downto 11);
			
			if set_addr(10 downto 0) = address(10 downto 0) then
			  conflict <= set;
			 else
			  conflict <= '0';
			 end if;
			conflict1 <= conflict;
	    end if;
	end process;
end arch;

--命令キャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lazy_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end lazy_cache;


architecture arch of lazy_cache is
    type cache_tag_type is array (0 to 2047) of std_logic_vector (3 downto 0);--3 + 1
    type cache_data_type is array (0 to 2047) of std_logic_vector (31 downto 0); --32
    
   signal tag,tag_p : std_logic_vector(3 downto 0) := '0'&"000";
   signal cache : cache_tag_type := (others => '0'&"000");
   signal cache_data : cache_data_type;
   
    signal address_buf,address_buf1,address_buf2,address_buf3,address_buf4 : std_logic_vector(13 downto 0) := (others => '0');
    signal hit_p : std_logic := '0';
begin
	read_data <= cache_data(conv_integer(address_buf(10 downto 0)));
	
	tag <= cache(conv_integer(address_buf(10 downto 0)));
	hit_p <= tag(3) when tag(2 downto 0) = address_buf(13 downto 11) else '0';
	
	hit <= hit_p when (address_buf = address_buf1) and (address_buf1 = address_buf2) and (address_buf2 = address_buf3)and (address_buf3 = address_buf4) else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        address_buf1 <= address_buf;
	        address_buf2 <= address_buf1;
	        address_buf3 <= address_buf2;
	        address_buf4 <= address_buf3;
	    end if;
	end process;
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	           cache(conv_integer(set_addr(10 downto 0))) <= '1'&set_addr(13 downto 11);
	           cache_data(conv_integer(set_addr(10 downto 0))) <= set_data;
	        end if;
	        address_buf <= address; 
	    end if;
	end process;
end arch;

--データキャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dcache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end dcache;

architecture arch of dcache is

component data_cache IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(31 downto 0);
	addra: IN std_logic_VECTOR(10 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(31 downto 0));
END component;
component data_cache_tag IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(9 downto 0);
	addra: IN std_logic_VECTOR(10 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	douta: OUT std_logic_VECTOR(9 downto 0));
END component;
   
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal entry,set_entry : std_logic_vector(9 downto 0) := (others => '0');
    signal cmp,cmp_buf :std_logic_vector(4 downto 0) := "00000";
    signal address_buf,ac_addr : std_logic_vector(19 downto 0) := (others => '0');
    signal we : std_logic_vector(0 downto 0) := (others => '0');
    signal conflict : std_logic := '0';
begin
	--read_data <= cache_data(conv_integer(address_buf(10 downto 0)));
	hit <= entry(9) and (not conflict) when entry(8 downto 0) = address_buf(19 downto 11) else '0';
	ac_addr <= set_addr when set = '1' else address;
	we(0) <= set;	
	
	set_entry <= '1'&set_addr(19 downto 11);
	
	DC0 : data_cache
	port map(
	clk,set_data,ac_addr(10 downto 0),
	we,read_data);
	
	DCTAG0 : data_cache_tag
	port map(
	clk,set_entry,ac_addr(10 downto 0),
	we,entry);
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        address_buf <= address;
	       	conflict <= set;
	    end if;
	end process;
end arch;

--データキャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity block_dcache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end block_dcache;

architecture arch of block_dcache is
    type cache_tag_type is array (0 to 2047) of std_logic_vector (9 downto 0);--9 + 1
    type cache_data_type is array (0 to 2047) of std_logic_vector (31 downto 0); --32
    
   signal tag,tag_p : std_logic_vector(9 downto 0) := '0'&"000000000";
   signal cache : cache_tag_type := (others => '0'&"000000000");
   signal cache_data : cache_data_type := (others => (others => '0'));
   
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal entry,set_entry : std_logic_vector(9 downto 0) := (others => '0');
    signal cmp,cmp_buf :std_logic_vector(4 downto 0) := "00000";
    signal address_buf,ac_addr,rd_addr : std_logic_vector(19 downto 0) := (others => '0');
    signal we : std_logic_vector(0 downto 0) := (others => '0');
    signal conflict,conflict1 : std_logic := '0';
begin
	read_data <= cache_data(conv_integer(address_buf(10 downto 0)));
	hit <= entry(9) and (not conflict) and (not conflict1) when entry(8 downto 0) = address_buf(19 downto 11) else '0';
	entry <= cache(conv_integer(address_buf(10 downto 0)));
	
	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	if set = '1' then
	    	   cache(conv_integer(set_addr(10 downto 0))) <= '1'&set_addr(19 downto 11);
	           cache_data(conv_integer(set_addr(10 downto 0))) <= set_data;
	    	end if;
	    	
	        address_buf <= address;
	    	
	    	if set_addr(10 downto 0) = address(10 downto 0) then
	    		conflict <= set;
	    	else
	    		conflict <= '0';
	    	end if;
	    	conflict1 <= conflict;
	    end if;
	end process;
end arch;

--馬鹿キャッシュ
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baka_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end baka_cache;


architecture arch of baka_cache is
    type cache_tag_type is array (0 to 4095) of std_logic_vector (2 downto 0);--2 + 1
    type cache_data_type is array (0 to 4095) of std_logic_vector (31 downto 0); --32
    
    signal read,data_buf : std_logic_vector(31 downto 0) := (others => '0');
    signal hit_buf,hit_p,read_f_buf : std_logic := '0';
    signal address_buf,address_buf1 : std_logic_vector(13 downto 0) := (others => '1');
begin
	read_data <= data_buf;
	hit_p <= '1' when address = address_buf else '0';

	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	hit <= hit_p;
	    	if (set = '1') then
	    		address_buf1 <= address_buf;
	    		address_buf <= set_addr;
	    		data_buf <= set_data;
	    	end if;
	    end if;
	end process;
end arch;


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity simple_dcache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end simple_dcache;

architecture arch of simple_dcache is
    type cache_tag_type is array (0 to 2047) of std_logic_vector (9 downto 0);--9 + 1
    type cache_data_type is array (0 to 2047) of std_logic_vector (31 downto 0); --32
    
   signal tag,tag_p : std_logic_vector(9 downto 0) := '0'&"000000000";
   signal cache : cache_tag_type := (others => '0'&"000000000");
   signal cache_data : cache_data_type := (others => (others => '0'));
   
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal entry,set_entry : std_logic_vector(9 downto 0) := (others => '0');
    signal cmp,cmp_buf :std_logic_vector(4 downto 0) := "00000";
    signal address_buf,ac_addr,rd_addr : std_logic_vector(19 downto 0) := (others => '0');
    signal we : std_logic_vector(0 downto 0) := (others => '0');
    signal conflict : std_logic := '0';
begin
	read_data <= cache_data(conv_integer(address_buf(10 downto 0)));
	hit <= (entry(9) and (not conflict)) when entry(8 downto 0) = address_buf(19 downto 11) else '0';
	
	entry <= cache(conv_integer(address_buf(10 downto 0)));
	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	if set = '1' then
	    	   cache(conv_integer(set_addr(10 downto 0))) <= '1'&set_addr(19 downto 11);
	           cache_data(conv_integer(set_addr(10 downto 0))) <= set_data;
	    	end if;
	    	
	    	if address(10 downto 0) = set_addr(10 downto 0) then
	    		conflict <= '1';
	    	else
	    		conflict <= '0';
	    	end if;
	       
	       address_buf <= address;
	    end if;
	end process;
end arch;

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
		--read_f : in std_logic;
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
	    	hit <= hit_p;
	    	if (set = '1') then
	    		address_buf <= set_addr;
	    		data_buf <= set_data;
	    	end if;
	    end if;
	end process;
end arch;


