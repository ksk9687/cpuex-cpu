--���߃L���b�V��

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
    type cache_type is array (0 to 1023) of std_logic_vector (10 downto 0); --10 + 1
    type cache_data_type is array (0 to 1023) of std_logic_vector (31 downto 0); --32
    
    signal cache : cache_type :=(
    	others => "0"&"0000000000"
    );
   signal cache_data : cache_data_type;
   
    signal entry : std_logic_vector(10 downto 0) := "00000000000";
    signal read_addr : std_logic_vector(9 downto 0) := (others => '0');
    signal read : std_logic_vector(31 downto 0) := (others => '0');
begin
	read_data <= read;
	
	entry <= cache(conv_integer(address(9 downto 0)));
	hit <= '1' when entry(9 downto 0) = address(19 downto 10) and entry(10) = '1' else '0';
	
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache(conv_integer(address(9 downto 0))) <= '1'&address(19 downto 10);
	        end if;
	    end if;
	end process;
	
	process (clk)
	begin
	    if rising_edge(clk) then
	        if set = '1' then
	            cache_data(conv_integer(address(9 downto 0))) <= set_data;
	        end if;
	        read <= cache_data(conv_integer(address(9 downto 0)));
	    end if;
	end process;
	
	
end arch;


