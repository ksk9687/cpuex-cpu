--IOƒ†ƒjƒbƒg‚Ì

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 
library UNISIM;
use UNISIM.VComponents.all;
entity IOU is
	port  (
		clk,clk50,enable : in std_logic;
		iou_op : in std_logic_vector(2 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		no : in std_logic_vector(4 downto 0);
		readdata : out std_logic_vector(31 downto 0)
		
		;USBWR : out  STD_LOGIC
		;USBRDX : out  STD_LOGIC
		;USBTXEX : in  STD_LOGIC
		;USBSIWU : out  STD_LOGIC
		;USBRXFX : in  STD_LOGIC
		;USBRSTX : out  STD_LOGIC
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
	);
end IOU;

architecture arch of IOU is
	constant usb: std_logic_vector := "00001";
	constant rs232c: std_logic_vector := "00010";
	constant nop: std_logic_vector := "11111";
	constant error: std_logic_vector := x"0FFFFFFF";

	signal usb_read,usb_read_end,usb_write,usb_write_end,usb_read_p,usb_write_p :std_logic := '0';
	signal usb_readdata_out,usb_writedata_buf: std_logic_vector(7 downto 0);
	signal iou_op_buf: std_logic_vector(2 downto 0);
	signal no_buf: std_logic_vector(4 downto 0);
	signal readdata_p,writedata_buf : std_logic_vector(31 downto 0):= (others => '0');
	
	signal rst :std_logic:= '0';
begin
	 
  	ROC0 : ROC port map (O => rst);
  	
	 
	 readdata_p <= 
	 x"00000"&"000"&(not usb_read_end)&usb_readdata_out when (iou_op = iou_op_read) else
	 x"0000000"&"000"&(not usb_write_end) when (iou_op = iou_op_write) else
	 (others => '1');
	  
	 usb_read_p <= '1' and enable when (iou_op = iou_op_read) and (usb_read_end = '1') else
	 '0';
	 usb_write_p <= '1' and enable when (iou_op = iou_op_write) and (usb_write_end = '1') else
	 '0';
	 usb_writedata_buf <= writedata_buf(7 downto 0);
	 	 
 	 process(clk)
 	 begin
 	 	if rising_edge(clk) then
 	 		if enable = '0' then
 	 			usb_read <= '0';
 	 			usb_write <= '0';
 	 			readdata <= (others => '0');
 	 			writedata_buf <= (others => '0');
 	 		else
 	 			readdata <= readdata_p;
 	 			usb_read <= usb_read_p;
 	 			usb_write <= usb_write_p;
 	 			writedata_buf <= writedata;
 	 		end if;
 	 	end if;
 	 end process;
	 	 
   USB0 : usbbufio port map (
   	clk50,clk,rst,
   	usb_read,usb_readdata_out,usb_read_end,
   	usb_write,usb_writedata_buf,usb_write_end,
   	
   	USBRDX,USBRXFX,USBWR, USBTXEX,USBSIWU,USBRSTX,USBD
   );
	

end arch;

