--命令キャッシュ

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache is
	port  (
		clk : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
end cache;


architecture arch of cache is
    type cache_tag_type is array (0 to 4095) of std_logic_vector (2 downto 0);--2 + 1
    type cache_data_type is array (0 to 4095) of std_logic_vector (31 downto 0); --32
    
   signal tag : std_logic_vector(2 downto 0) := '0'&"00";
   signal cache : cache_tag_type := (others => '0'&"00");
   signal cache_data : cache_data_type;
   
    signal read_addr : std_logic_vector(11 downto 0) := (others => '0');
    signal read : std_logic_vector(31 downto 0) := (others => '0');
begin
	read_data <= read;
	
	tag <= cache(conv_integer(address(11 downto 0)));
	hit <= tag(2) when tag(1 downto 0) = address(13 downto 12) and address(19 downto 14) = "000000" else '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' and address(19 downto 14) = "000000" then
	           cache(conv_integer(address(11 downto 0))) <= '1'&address(13 downto 12);
	        end if;
	    end if;
	end process;
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache_data(conv_integer(address(11 downto 0))) <= set_data;
	        end if;
	        read <= cache_data(conv_integer(address(11 downto 0)));
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
		depth : integer := 2048
	);
	port  (
		clk : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
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
   
    signal entry : std_logic_vector(width downto 0) := (others => '0');
    signal read_addr : std_logic_vector((width - 1) downto 0) := (others => '0');
    signal read : std_logic_vector(31 downto 0) := (others => '0');
begin
	read_data <= read;
	hit <= entry(width) when entry((width - 1) downto 0) = address(19 downto (20 - width)) else '0';
	--hit <= '0';
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache(conv_integer(address((19 - width) downto 0))) <= '1'&address(19 downto (20 - width));
	        end if;
				entry <= cache(conv_integer(address((19 - width) downto 0)));
	    end if;
	end process;
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache_data(conv_integer(address((19 - width) downto 0))) <= set_data;
	        end if;
	        read <= cache_data(conv_integer(address((19 - width)downto 0)));
	    end if;
	end process;
end arch;

