
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
    type ram_type is array (0 to 15) of std_logic_vector (7 downto 0); 
    signal RAM : ram_type := 
    (
    	x"00",x"00",x"00",x"03",
    	x"28",x"00",x"00",x"34",
    	x"44",x"00",x"45",x"00",
    	x"4C",x"00",x"00",x"46"
    );
    signal pointer : std_logic_vector(3 downto 0) := "1111";
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
