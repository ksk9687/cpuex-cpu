--IOユニットの

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IOU is
	port  (
		clk : in std_logic;
		rst : in std_logic;
		iou_op : in std_logic_vector(1 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		readdata : out std_logic_vector(31 downto 0);
		ok : out std_logic
		
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
	component usbio
	    Port (
	           CLK : in STD_LOGIC;
	           RST : in STD_LOGIC;
	           -- こちら側を使う
	           USBIO_RD : in STD_LOGIC;     -- read 制御線
	           USBIO_RData : out STD_LOGIC_VECTOR(7 downto 0);      -- read data
	           USBIO_RC : out STD_LOGIC;    -- read 完了線
	           USBIO_WD : in STD_LOGIC;     -- write 制御線
	           USBIO_WData : in STD_LOGIC_VECTOR(7 downto 0);       -- write data
	           USBIO_WC : out STD_LOGIC;    -- write 完了線
	
	           -- FT245BM 側につなぐ
	           USBRD : out  STD_LOGIC;
	           USBRXF : in  STD_LOGIC;
	           USBWR : out  STD_LOGIC;
	           USBTXE : in  STD_LOGIC;
	           USBSIWU : out  STD_LOGIC;
	           USBD : inout  STD_LOGIC_VECTOR (7 downto 0)
	           
	           );
	end component;
	
	
	component usb2
	Port (
		CLK : in  STD_LOGIC
		
		;do : in STD_LOGIC
		;read_write : in STD_LOGIC
		;data_write : in STD_LOGIC_VECTOR (7 downto 0)
		;data_read : out STD_LOGIC_VECTOR (7 downto 0)
		
		;status : out STD_LOGIC_VECTOR (2 downto 0)
		
		;USBWR : out  STD_LOGIC
		;USBRDX : out  STD_LOGIC
		
		;USBTXEX : in  STD_LOGIC
		;USBSIWU : out  STD_LOGIC
		
		;USBRXFX : in  STD_LOGIC
		;USBRSTX : out  STD_LOGIC
		
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
		);
end component;
	signal data: std_logic_vector(7 downto 0);
	signal status: std_logic_vector(2 downto 0);
begin
	
	 
	 
--   USB : usbio port map (
--   	clk,rst,
--   	read,readdata_out,read_end,
--   	write,writedata_buf,write_end,
--   	
--   	USBRD,USBRXF,USBWR,USBTXE,USBSIWU,USBD
--   );

   USB : usb2 port map (
		CLK,
		iou_op(1),iou_op(0),
		writedata(7 downto 0),data,
		status,
		USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRSTX,USBD
		);
	readdata <= x"00000"&"00"&status(2)&status(1)&data;
	ok <= (not status(0)) and (not status(1));
	

end arch;

