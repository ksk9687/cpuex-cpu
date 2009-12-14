
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity usb_sim is
	Port (
		USBWR : in  STD_LOGIC
		;USBRDX : in  STD_LOGIC
		
		;USBTXEX : out  STD_LOGIC
		;USBSIWU : in  STD_LOGIC
		
		;USBRXFX : out  STD_LOGIC
		;USBRSTX : in  STD_LOGIC
		
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
		);
end usb_sim;

architecture sim of usb_sim is 
    type ram_type is array (0 to 127) of std_logic_vector (7 downto 0); 
    signal RAM : ram_type := 
    (
x"00" ,x"00" ,x"00" ,x"14" ,x"00" ,x"00" ,x"00" ,x"00" ,x"00" ,x"0F" ,x"50" ,x"00" ,x"0B" ,x"DF" ,x"40" ,x"04"
,x"0B" ,x"DF" ,x"80" ,x"03" ,x"E0" ,x"00" ,x"00" ,x"05" ,x"60" ,x"00" ,x"40" ,x"13" ,x"00" ,x"00" ,x"80" ,x"00"
,x"00" ,x"00" ,x"C0" ,x"01" ,x"00" ,x"01" ,x"40" ,x"0B" ,x"A4" ,x"1F" ,x"00" ,x"01" ,x"28" ,x"10" ,x"00" ,x"00"
,x"E0" ,x"40" ,x"00" ,x"11" ,x"20" ,x"20" ,x"C4" ,x"00" ,x"04" ,x"30" ,x"80" ,x"00" ,x"04" ,x"40" ,x"C0" ,x"00"

,x"04" ,x"10" ,x"7F" ,x"FF" ,x"E0" ,x"00" ,x"00" ,x"0A" ,x"A4" ,x"2F" ,x"00" ,x"01" ,x"E0" ,x"00" ,x"00" ,x"12"
,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" 
,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" 
,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" ,x"00" ,x"00" ,x"00" ,x"0A" 

);
    signal pointer : std_logic_vector(6 downto 0) := "1111111";
begin
USBRXFX <= '0';

USBTXEX <= '0';
USBD <= RAM(conv_integer(pointer));

	process(USBRDX)
	begin
		if falling_edge(USBRDX) then
			pointer <= pointer + '1';
		end if;
	end process;




end sim;
