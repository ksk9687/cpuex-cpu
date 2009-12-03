
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
x"00"  ,x"00"  ,x"00"  ,x"1F" 
,x"00"  ,x"00"  ,x"00"  ,x"00" 
,x"00"  ,x"0F"  ,x"50"  ,x"00"  
,x"0B"  ,x"DF"  ,x"40"  ,x"04" 

,x"0B"  ,x"DF"  ,x"80"  ,x"03"  
,x"E0"  ,x"00"  ,x"00"  ,x"05"  
,x"00"  ,x"0F"  ,x"80"  ,x"1E"  
,x"00"  ,x"00"  ,x"40"  ,x"01" 

,x"60"  ,x"00"  ,x"80"  ,x"1D"  
,x"E4"  ,x"00"  ,x"00"  ,x"0D"  
,x"A8"  ,x"20"  ,x"00"  ,x"00"  
,x"A4"  ,x"2F"  ,x"00"  ,x"01" 

,x"C4"  ,x"00"  ,x"00"  ,x"00"  
,x"C4"  ,x"00"  ,x"00"  ,x"00"  
,x"28"  ,x"20"  ,x"40"  ,x"00"  
,x"E0"  ,x"40"  ,x"00"  ,x"1C" 

,x"07"  ,x"EF"  ,x"80"  ,x"03"  
,x"6B"  ,x"E0"  ,x"BF"  ,x"FD"  
,x"6B"  ,x"EF"  ,x"FF"  ,x"FF"  
,x"04"  ,x"20"  ,x"BF"  ,x"FF" 
,x"E4"  ,x"00"  ,x"00"  ,x"0D"  ,x"6B"  ,x"E0"  ,x"BF"  ,x"FE"  ,x"63"  ,x"E0"  ,x"BF"  ,x"FD"  ,x"04"  ,x"20"  ,x"BF"  ,x"FE" 
,x"E4"  ,x"00"  ,x"00"  ,x"0D"  ,x"63"  ,x"E0"  ,x"FF"  ,x"FE"  ,x"20"  ,x"20"  ,x"C2"  ,x"00"  ,x"63"  ,x"EF"  ,x"FF"  ,x"FF" 
,x"07"  ,x"EF"  ,x"BF"  ,x"FD"  ,x"EB"  ,x"F0"  ,x"00"  ,x"00"  ,x"00"  ,x"00"  ,x"00"  ,x"0A"  ,x"00"  ,x"00"  ,x"00"  ,x"00" 
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
