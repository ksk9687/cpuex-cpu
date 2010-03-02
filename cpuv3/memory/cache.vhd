library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.instruction.all; 

entity full_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		jmp_flgs : out std_logic_vector(2 downto 0)
	);
end full_cache;


architecture arch of full_cache is
    signal jr,jal,jmp : std_logic := '0';
    signal write_data,out_data : std_logic_vector(35 downto 0) := (others => '0');
    signal set_d : std_logic_vector(0 downto 0) := (others => '0');

	component cache_16384 IS
		port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(35 downto 0);
		addra: IN std_logic_VECTOR(13 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		clkb: IN std_logic;
		addrb: IN std_logic_VECTOR(13 downto 0);
		doutb: OUT std_logic_VECTOR(35 downto 0));
	END component;
begin
  CACHE0 : cache_16384 port map(
  	clk,write_data,set_addr(13 downto 0),set_d,
  	clk,address(13 downto 0),out_data
  );

  set_d(0) <= set;
  	write_data <= '0'&jmp&jal&jr&set_data;
	read_data <= out_data(31 downto 0);
	jmp_flgs <=  out_data(34 downto 32);
	
	jmp <= '1' when set_data(31 downto 26) = op_jmp else '0';
	jal <= '1' when set_data(31 downto 26) = op_jal else '0';
	jr <= '1' when set_data(31 downto 26) = op_jr else '0';

end arch;


--馬鹿キャッシュ
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.instruction.all; 
entity baka_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		jmp_flgs : out std_logic_vector(2 downto 0);
		hit : out std_logic
	);
end baka_cache;


architecture arch of baka_cache is
    signal jmps : std_logic_vector(2 downto 0) := (others => '0');
    signal read,data_buf : std_logic_vector(31 downto 0) := (others => '0');
    signal hit_buf,hit_p,read_f_buf,jmp,jal,jr : std_logic := '0';
    signal address_buf,address_buf1 : std_logic_vector(13 downto 0) := (others => '1');
begin
	read_data <= data_buf;
	hit_p <= '1' when address = address_buf else '0';
	jmp_flgs <= jmps;
	
	jmp <= '1' when set_data(31 downto 26) = op_jmp else '0';
	jal <= '1' when set_data(31 downto 26) = op_jal else '0';
	jr <= '1' when set_data(31 downto 26) = op_jr else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	hit <= hit_p;
	    	if (set = '1') then
	    		address_buf <= set_addr;
	    		data_buf <= set_data;
	    		jmps <= jmp&jal&jr;
	    	end if;
	    end if;
	end process;
end arch;



library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity block_l_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end block_l_cache;


architecture arch of block_l_cache is
    type cache_tag_type is array (0 to 4095) of std_logic_vector (2 downto 0);--3 + 1
    type cache_data_type is array (0 to 4095) of std_logic_vector (31 downto 0); --32
    
   signal tag,tag_p,tag_p2,tag_write : std_logic_vector(2 downto 0) := '0'&"00";
   signal cache : cache_tag_type := (others => '0'&"00");
   signal cache_data : cache_data_type:= (others => (others => '0'));
   
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal read_addr : std_logic_vector(11 downto 0) := (others => '0');
    signal cmp_addr : std_logic_vector(1 downto 0) := (others => '0');
    signal addr_buf,set_addr_buf : std_logic_vector(13 downto 0) := (others => '0');
    signal hit1,hit2,hit_p,hit_p2,conflict,conflict1,conflict2 : std_logic := '0';
    signal set_data_buf : std_logic_vector(31 downto 0) := (others => '0');

begin

	tag_write <= '1'&set_addr(13 downto 12);
	read_data <= cache_data(conv_integer(read_addr));
	tag <= cache(conv_integer(read_addr));
	hit <= tag(2) and (not conflict) and (not conflict1) when tag(1 downto 0) = cmp_addr(1 downto 0) else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache(conv_integer(set_addr(11 downto 0))) <= tag_write;
	            cache_data(conv_integer(set_addr(11 downto 0))) <= set_data;
	        end if;
	        read_addr <= address(11 downto 0);
	        cmp_addr <= address(13 downto 12);
			
			if set_addr(11 downto 0) = address(11 downto 0) then
			  conflict <= set;
			 else
			  conflict <= '0';
			 end if;
			conflict1 <= conflict;
	    end if;
	end process;
end arch;


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.instruction.all; 

entity block_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(13 downto 0);
		set_addr: in std_logic_vector(13 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set,set_tag : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		jmp_flgs : out std_logic_vector(2 downto 0);
		hit,hit_tag : out std_logic
	);
end block_cache;


architecture arch of block_cache is
    type cache_tag_type is array (0 to 255) of std_logic_vector (3 downto 0);--3 + 1
    type cache_data_type is array (0 to 2047) of std_logic_vector (31 downto 0); --32
    type cache_jmp_flgs_type is array (0 to 2047) of std_logic_vector (2 downto 0);
        
   signal tag,tag_p,tag_p2,tag_write : std_logic_vector(3 downto 0) := '0'&"000";
   signal cache : cache_tag_type := (others => '0'&"000");
   signal cache_data : cache_data_type:= (others => (others => '0'));
   signal cache_jmp_flgs : cache_jmp_flgs_type:= (others => (others => '0'));
   
    signal data : std_logic_vector(31 downto 0) := (others => '0');
    signal read_addr : std_logic_vector(10 downto 0) := (others => '0');
    signal cmp_addr : std_logic_vector(2 downto 0) := (others => '0');
    signal special : std_logic_vector(7 downto 0) := (others => '0');
    signal addr_buf,set_addr_buf : std_logic_vector(13 downto 0) := (others => '0');
    signal special_hit,hit_in,hit1,hit2,hit_p,hit_p2,conflict,conflict1,conflict2 : std_logic := '0';
    signal set_data_buf : std_logic_vector(31 downto 0) := (others => '0');
    signal jr,jal,jmp : std_logic := '0';
    signal write_data,out_data : std_logic_vector(34 downto 0) := (others => '0');
    signal set_d : std_logic_vector(0 downto 0) := (others => '0');

	component cache_2000_35 IS
		port (
		clka: IN std_logic;
		dina: IN std_logic_VECTOR(34 downto 0);
		addra: IN std_logic_VECTOR(10 downto 0);
		wea: IN std_logic_VECTOR(0 downto 0);
		clkb: IN std_logic;
		addrb: IN std_logic_VECTOR(10 downto 0);
		doutb: OUT std_logic_VECTOR(34 downto 0));
	END component;
begin

  CACHE0 : cache_2000_35 port map(
  	clk,write_data,set_addr(10 downto 0),set_d,
  	clk,address(10 downto 0),out_data
  );
  set_d(0) <= set;
  	write_data <=jmp&jal&jr&set_data;
	tag_write <= '1'&set_addr(13 downto 11);
	read_data <= out_data(31 downto 0);
	jmp_flgs <=  out_data(34 downto 32);
	
	tag_p <= cache(conv_integer(address(10 downto 3)));
	--hit <= ((hit_p and hit_p2) or special_hit) and (not conflict1);
	hit <= ((hit_p and hit_p2) or special_hit);
	hit_tag <= ((hit_p and hit_p2) or special_hit);

	jmp <= '1' when set_data(31 downto 26) = op_jmp else '0';
	jal <= '1' when set_data(31 downto 26) = op_jal else '0';
	jr <= '1' when set_data(31 downto 26) = op_jr else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	        	if set_tag = '1' then
	            	cache(conv_integer(set_addr(10 downto 3))) <= tag_write;
	            	special <= (others => '0');
	            else
	            	special(conv_integer(set_addr(2 downto 0))) <= '1';
	            end if;
	            --cache_data(conv_integer(set_addr(10 downto 0))) <= set_data;
	            --cache_jmp_flgs(conv_integer(set_addr(10 downto 0))) <= jmp&jal&jr;
	        end if;
	        read_addr <= address(10 downto 0);
			
			--EARLY RESTART
			if (address(13 downto 3) = set_addr(13 downto 3)) and (special(conv_integer(address(2 downto 0))) = '1') then
				special_hit <= '1';
			else
				special_hit <= '0';
			end if;
			hit_p <= (not (tag_p(1) xor address(12))) and (not (tag_p(0) xor address(11)));
			hit_p2 <= tag_p(3) and (not (tag_p(2) xor address(13)));
--			
--			if set_addr(10 downto 0) = address(10 downto 0) then
--			  	conflict <= set;
--			  	--conflict1 <= conflict or set;
--			 else
--			  	conflict <= '0';
--			  	--conflict1 <= conflict;
--			 end if;
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
	
	hit <= (not conflict1) and hit3 when entry_buf(8 downto 0) = address(19 downto 11) else '0';
	hit_tag <= hit3 when entry_buf(8 downto 0) = address(19 downto 11) else '0';
	
	
	--hit_p1 <= '1' when entry_p(3 downto 0) = address(14 downto 11) else '0';
	--hit_p2 <= '1' when entry_p(8 downto 4) = address(19 downto 15) else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	    	hit1 <= hit_p1;
	    	hit2 <= hit_p2;
	    	hit3 <= entry_p(9);
	    	data <= data_p;
	    	
	    	entry_buf <= entry_p;
	    	address_buf <= address;
	    	
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


