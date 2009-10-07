--------------------------------------------------------------------------------
-- Entity: io_dummy_led
--------------------------------------------------------------------------------
-- Copyright ... 2009
-- Filename          : io_dummy_led.vhd
-- Creation date     : 2009-10-08
-- Author(s)         : ksk
-- Version           : 1.00
-- Description       : <short description>
--------------------------------------------------------------------------------
-- File History:
-- Date         Version  Author   Comment
-- 2009-10-08   1.00     ksk     Creation of File
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package io_dummy_ledPCK is

	component io_dummy_led
	port  (
		clk : in std_logic ;
		op : in std_logic_vector(1 downto 0);
		reg : in std_logic_vector(31 downto 0);
		data : out std_logic_vector(7 downto 0)
	);
	end component;

end package;


--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity io_dummy_led is
	port  (
		clk : in std_logic ;
		op : in std_logic_vector(1 downto 0);
		reg : in std_logic_vector(31 downto 0);
		data : out std_logic_vector(7 downto 0)
	);
end io_dummy_led;

architecture arch of io_dummy_led is
	signal buf :std_logic_vector(31 downto 0) := (others => '0');
begin
	
	process(clk)
	begin
		if rising_edge(clk) then
			if op = "11" then
				buf <= reg;
			end if;
		end if;
	end process;
		
	data <= not buf;

end arch;

