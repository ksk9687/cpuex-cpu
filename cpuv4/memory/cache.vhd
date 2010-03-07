library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.instruction.all; 

entity full_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(12 downto 0);
		set_addr: in std_logic_vector(12 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data1 : out std_logic_vector(35 downto 0);
		read_data2 : out std_logic_vector(35 downto 0)
	);
end full_cache;


architecture arch of full_cache is
    signal write_data,out_data : std_logic_vector(71 downto 0) := (others => '0');
    signal buf1,buf2 : std_logic_vector(31 downto 0) := (others => '0');
    signal set_d : std_logic_vector(0 downto 0) := (others => '0');
    signal count : std_logic_vector(1 downto 0) := (others => '0');

	component cache_16384 IS
		port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(71 downto 0);
		addra: IN std_logic_VECTOR(12 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		clkb: IN std_logic;
		addrb: IN std_logic_VECTOR(12 downto 0);
		doutb: OUT std_logic_VECTOR(71 downto 0));
	END component;
begin

  CACHE0 : cache_16384 port map(
  	clk,write_data,set_addr,set_d,
  	clk,address,out_data
  );

	set_d(0) <= set when count = "10" else '0';
  	write_data <= buf1(7 downto 0)&buf2&set_data;
	read_data1 <= out_data(71 downto 36);
	read_data2 <= out_data(35 downto 0);
	
	process(clk)
	begin
		if rising_edge(clk) then
			if set = '1' then
				if count = "10" then
					count <= "00";
				else
					count <= count + '1';
				end if;
				if count = "00" then
					buf1 <= set_data;
				end if;
				if count = "01" then
					buf2 <= set_data;
				end if;
			end if;
		end if;
	end process;
	

end arch;


--ROM
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.instruction.all; 

library UNISIM;
use UNISIM.VComponents.all;

entity irom is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(12 downto 0);
		set_addr: in std_logic_vector(12 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data1 : out std_logic_vector(35 downto 0);
		read_data2 : out std_logic_vector(35 downto 0)
	);
end irom;


architecture arch of irom is
    type rom_t is array (0 to 31) of std_logic_vector (35 downto 0); 
    
	signal ROM : rom_t := (
"000000000000000000000000000000000000",
"010011000000000000000000000000000000",
"000000000000001111110010000000000000",
"000101001111111111111111110000000000",

"000101001111111111101111110000000000",
"000101001111101111101111100000000000",
"000101001111101111101111100000000000",
"000011000000001111000000000000001001",

"110000000000000000000000000000001000",
"000000000000000000010000000000000000",
"000000000000000000100000000000000000",
"000000000000000000110000000000000001",

"110010010000010000000010100000010010",
"000101000000101111010000110000000000",
"000100000000110000100000000000000000",
"000100001111010000110000000000000000",


"000001000000010000010000000000000001",
"110000000000000000000000000000001100",
"011100000000100000000000000000000000",
"110000000000000000000000000000010011",

"101111000000000000000000000000000000",
"101111000000000000000000000000000000",
"101111000000000000000000000000000000",
"101111000000000000000000000000000000",

"101111000000000000000000000000000000",
"101111000000000000000000000000000000",
"101111000000000000000000000000000000",
"101111000000000000000000000000000000",

"101111000000000000000000000000000000",
"101111000000000000000000000000000000",
"101111000000000000000000000000000000",
"101111000000000000000000000000000000"
    );
	
    signal i1,i2 : std_logic_vector(35 downto 0) := nop_inst;
begin
    
	i1 <= ROM(conv_integer(address(3 downto 0)&'0'));
	i2 <= ROM(conv_integer(address(3 downto 0)&'1'));
	process(clk)
	begin
		if rising_edge(clk) then
		 	read_data1 <= i1;
		 	read_data2 <= i2;
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
		hit,hit_tag : out std_logic
	);
end block_dcache;

architecture arch of block_dcache is
    type cache_tag_type is array (0 to 4095) of std_logic_vector (8 downto 0);--8 + 1
    type cache_data_type is array (0 to 4095) of std_logic_vector (31 downto 0); --32
    
  
   signal tag,tag_p : std_logic_vector(8 downto 0) := '0'&"00000000";
   signal cache : cache_tag_type := (others => '0'&"00000000");
   signal cache_data : cache_data_type := (others => (others => '0'));
   
    signal data,data_p : std_logic_vector(31 downto 0) := (others => '0');
    signal entry,entry_p,entry_buf : std_logic_vector(8 downto 0) := (others => '0');
    signal cmp,cmp_buf :std_logic_vector(4 downto 0) := "00000";
    signal address_buf,address_buf_f,ac_addr,rd_addr,address_buf2 : std_logic_vector(19 downto 0) := (others => '0');
    signal conflict,conflict1,conflict2,hit_p,hit1,hit2,hit3,hit_p1,hit_p2,hit_p3 : std_logic := '0';

	component dcache_4096x32 IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(31 downto 0);
	addra: IN std_logic_VECTOR(11 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	clkb: IN std_logic;
	addrb: IN std_logic_VECTOR(11 downto 0);
	doutb: OUT std_logic_VECTOR(31 downto 0));
	END component;
	
	component dcache_tag_4096x9 IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(8 downto 0);
	addra: IN std_logic_VECTOR(11 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	clkb: IN std_logic;
	addrb: IN std_logic_VECTOR(11 downto 0);
	doutb: OUT std_logic_VECTOR(8 downto 0));
	END component;
	
   signal set_tag : std_logic_vector(8 downto 0) := '0'&"00000000";
   signal set_d : std_logic_vector(0 downto 0) := "0";
begin
	
  CACHE0 : dcache_4096x32 port map(
  	clkfast,set_data,set_addr(11 downto 0),set_d,
  	clkfast,address(11 downto 0),data_p
  );
  CACHE_TAG0 : dcache_tag_4096x9 port map(
  	clkfast,set_tag,set_addr(11 downto 0),set_d,
  	clkfast,address(11 downto 0),entry_p
  );

  	set_d(0) <= set;
	set_tag <= '1'&set_addr(19 downto 12);
	
	read_data <= data;
	
	hit <= (not conflict1) and hit1 and hit2 and hit3;
	hit_tag <= hit1 and hit2 and hit3;
	
	process(clkfast)
	begin
		if rising_edge(clkfast) then
	        address_buf_f <= address;
		end if;
	end process;
	
	hit_p1 <= '1' when entry_p(3 downto 0) = address_buf_f(15 downto 12) else '0';
	hit_p2 <= '1' when entry_p(7 downto 4) = address_buf_f(19 downto 16) else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	hit1 <= hit_p1;
	    	hit2 <= hit_p2;
	    	hit3 <= entry_p(8);
	    	data <= data_p;
	       -- address_buf <= address;
	    	
	    	if set_addr(11 downto 0) = address(11 downto 0) then
	    		conflict <= set;
		    	conflict1 <= conflict or set;
		    	conflict2 <= conflict or conflict1 or set;
	    	else
	    		conflict <= '0';
		    	conflict1 <= conflict;
		    	conflict2 <= conflict or conflict1;
	    	end if;
	    end if;
	end process;
end arch;



library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity block_s_dcache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit,hit_tag : out std_logic
	);
end block_s_dcache;

architecture arch of block_s_dcache is
    type cache_tag_type is array (0 to 2047) of std_logic_vector (9 downto 0);--9 + 1
    type cache_data_type is array (0 to 2047) of std_logic_vector (31 downto 0); --32
    
  
   signal tag,tag_p : std_logic_vector(9 downto 0) := '0'&"000000000";
   signal cache : cache_tag_type := (others => '0'&"000000000");
   signal cache_data : cache_data_type := (others => (others => '0'));
   
    signal data,data_p : std_logic_vector(31 downto 0) := (others => '0');
    signal entry,entry_p,entry_buf : std_logic_vector(9 downto 0) := (others => '0');
    signal cmp,cmp_buf :std_logic_vector(4 downto 0) := "00000";
    signal address_buf,address_buf_f,ac_addr,rd_addr,address_buf2 : std_logic_vector(19 downto 0) := (others => '0');
    signal conflict,conflict1,conflict2,hit_p,hit1,hit2,hit3,hit_p1,hit_p2,hit_p3 : std_logic := '0';

   signal set_tag : std_logic_vector(9 downto 0) := '0'&"000000000";
   signal set_d : std_logic_vector(0 downto 0) := "0";
   	
   	component dcache_2048x32 IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(31 downto 0);
	addra: IN std_logic_VECTOR(10 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	clkb: IN std_logic;
	addrb: IN std_logic_VECTOR(10 downto 0);
	doutb: OUT std_logic_VECTOR(31 downto 0));
	END component;
	
	component dcache_tag_2048x10 IS
	port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(9 downto 0);
	addra: IN std_logic_VECTOR(10 downto 0);
	wea: IN std_logic_VECTOR(0 downto 0);
	clkb: IN std_logic;
	addrb: IN std_logic_VECTOR(10 downto 0);
	doutb: OUT std_logic_VECTOR(9 downto 0));
	END component;
	
	
begin
  CACHE0 : dcache_2048x32 port map(
  	clkfast,set_data,set_addr(10 downto 0),set_d,
  	clkfast,address(10 downto 0),data_p
  );
  CACHE_TAG0 : dcache_tag_2048x10 port map(
  	clkfast,set_tag,set_addr(10 downto 0),set_d,
  	clkfast,address(10 downto 0),entry_p
  );

  	set_d(0) <= set;
	set_tag <= '1'&set_addr(19 downto 11);
	
	read_data <= data;
	
	hit <= (not conflict1) and hit1 and hit2 and hit3;
	hit_tag <= hit1 and hit2 and hit3;
	
	
	hit_p1 <= '1' when entry_p(3 downto 0) = address(14 downto 11) else '0';
	hit_p2 <= '1' when entry_p(8 downto 4) = address(19 downto 15) else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	hit1 <= hit_p1;
	    	hit2 <= hit_p2;
	    	hit3 <= entry_p(9);
	    	data <= data_p;
	    	
	    	if set_addr(10 downto 0) = address(10 downto 0) then
	    		conflict <= set;
		    	conflict1 <= conflict or set;
		    	conflict2 <= conflict or conflict1 or set;
	    	else
	    		conflict <= '0';
		    	conflict1 <= conflict;
		    	conflict2 <= conflict or conflict1;
	    	end if;
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
		hit,hit_tag : out std_logic
	);
end baka_dcache;

architecture arch of baka_dcache is
    signal read,data_buf : std_logic_vector(31 downto 0) := (others => '0');
    signal hit_buf,hit_p,hit_tag_p,read_f_buf : std_logic := '0';
    signal address_buf ,address_b: std_logic_vector(19 downto 0) := (others => '1');
begin
	read_data <= data_buf;
	hit <= '1' when address_b = address_buf else '0';
	hit_tag <= '1' when address_b = address_buf else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	address_b <= address;
	    	if (set = '1') then
	    		address_buf <= set_addr;
	    		data_buf <= set_data;
	    	end if;
	    end if;
	end process;
end arch;


