
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
   --x"00",x"00",x"00",x"1C",x"28",x"1D",x"7F",x"FF",x"13",x"BE",x"00",x"02",x"24",x"03",x"00",x"1A",x"24",x"01",x"00",x"18",x"24",x"04",x"00",x"1A",x"38",x"00",x"00",x"08",x"44",x"20",x"00",x"00",x"4C",x"00",x"00",x"00",x"50",x"23",x"90",x"00",x"36",x"44",x"00",x"0E",x"07",x"DE",x"FF",x"FD",x"2F",x"DF",x"00",x"02",x"2F",x"C1",x"00",x"01",x"18",x"24",x"08",x"00",x"38",x"00",x"00",x"08",x"2F",x"C1",x"00",x"00",x"27",x"C1",x"00",x"01",x"18",x"24",x"08",x"00",x"38",x"00",x"00",x"08",x"27",x"C2",x"00",x"00",x"14",x"22",x"08",x"00",x"27",x"DF",x"00",x"02",x"07",x"DE",x"00",x"03",x"3F",x"E0",x"00",x"00",x"40",x"40",x"00",x"00",x"00",x"00",x"00",x"00",x"3F",x"80",x"00",x"00",x"40",x"00",x"00",x"00"
   
   x"00" ,x"00" ,x"00" ,x"1D" ,x"28" ,x"1D" ,x"7F" ,x"FF" ,x"13" ,x"BE" ,x"00" ,x"04" ,x"24" ,x"03" ,x"00" ,x"1B" ,x"24" ,x"01" ,x"00" ,x"19" ,x"24" ,x"04" ,x"00" ,x"1B" ,x"24" ,x"05" ,x"00" ,x"1C" ,x"38" ,x"00" ,x"00" ,x"09" ,x"44" ,x"24" ,x"00" ,x"00" ,x"4C" ,x"00" ,x"00" ,x"00" ,x"50" ,x"23" ,x"90" ,x"00" ,x"36" ,x"44" ,x"00" ,x"0E" ,x"07" ,x"DE" ,x"FF" ,x"FD" ,x"2F" ,x"DF" ,x"00" ,x"02" ,x"2F" ,x"C1" ,x"00" ,x"01" ,x"18" ,x"24" ,x"08" ,x"00" ,x"38" ,x"00" ,x"00" ,x"09" ,x"2F" ,x"C1" ,x"00" ,x"00" ,x"27" ,x"C1" ,x"00" ,x"01" ,x"18" ,x"25" ,x"08" ,x"00" ,x"38" ,x"00" ,x"00" ,x"09" ,x"27" ,x"C2" ,x"00" ,x"00" ,x"14" ,x"22" ,x"08" ,x"00" ,x"27" ,x"DF" ,x"00" ,x"02" ,x"07" ,x"DE" ,x"00" ,x"03" ,x"3F" ,x"E0" ,x"00" ,x"00" 
   ,x"42" ,x"01" ,x"00" ,x"00" 
   ,x"00" ,x"00" ,x"00" ,x"00" 
   ,x"3F" ,x"80" ,x"00" ,x"00" 
   ,x"40" ,x"00" ,x"00" ,x"00"
   
  -- ,x"4C",x"4C",x"4C",x"4C",
   ,x"4C",x"4C",x"4C",x"4C",
   x"4C",x"4C",x"4C",x"4C"
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
