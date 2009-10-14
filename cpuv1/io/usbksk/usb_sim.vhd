
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

begin

USBRXFX <= '0';
USBTXEX <= '0';
USBD <= (others => 'Z');


end sim;
