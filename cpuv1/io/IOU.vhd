--IOユニットの

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IOU is
	port  (
		clk : in std_logic;
		rst : in std_logic;
		iou_op : in std_logic_vector(1 downto 0);--bit1が使用するかどうか、bit0が'1':write,'0':read
		writedata : in std_logic_vector(31 downto 0);
		readdata : out std_logic_vector(31 downto 0);
		ok : out std_logic  -- 1のときok
		
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
	component usbbufio
		Port (
			clk : in STD_LOGIC;
			RST : in STD_LOGIC;
			-- こちらを使用
			USBBUF_RD : in STD_LOGIC;     -- read 制御:1にすると、バッファから1個消す
			USBBUF_RData : out STD_LOGIC_VECTOR(7 downto 0);      -- read data
			USBBUF_RC : out STD_LOGIC;    -- read 完了:1の時読んでよい
			USBBUF_WD : in STD_LOGIC;     -- write 制御:1にすると、データを取り込む
			USBBUF_WData : in STD_LOGIC_VECTOR(7 downto 0);       -- write data
			USBBUF_WC : out STD_LOGIC;    -- write 完了:1の時書き込んでよい
			--ledout : out STD_LOGIC_VECTOR(7 downto 0);
			-- FT245BM 側につなぐ
			USBRD : out  STD_LOGIC;
			USBRXF : in  STD_LOGIC;
			USBWR : out  STD_LOGIC;
			USBTXE : in  STD_LOGIC;
			USBSIWU : out  STD_LOGIC;
			USBRST : out  STD_LOGIC;
			USBD : inout  STD_LOGIC_VECTOR (7 downto 0)
		);
	end component;

--	component usb2
--	Port (
--		CLK : in  STD_LOGIC
--		
--		;do : in STD_LOGIC
--		;read_write : in STD_LOGIC
--		;data_write : in STD_LOGIC_VECTOR (7 downto 0)
--		;data_read : out STD_LOGIC_VECTOR (7 downto 0)
--		
--		;status : out STD_LOGIC_VECTOR (2 downto 0)
--		
--		;USBWR : out  STD_LOGIC
--		;USBRDX : out  STD_LOGIC
--		
--		;USBTXEX : in  STD_LOGIC
--		;USBSIWU : out  STD_LOGIC
--		
--		;USBRXFX : in  STD_LOGIC
--		;USBRSTX : out  STD_LOGIC
--		
--		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
--		);
--	end component;

	signal readedata: std_logic_vector(7 downto 0);
	signal readflag:std_logic;
	signal writeflag:std_logic;
	signal readret : std_logic;
	signal writeret : std_logic;
begin

	readflag <= iou_op(1) and (not iou_op(0));
	writeflag <= iou_op(1) and iou_op(0);

--	USB : usb2 port map (
--		CLK,
--		iou_op(1),iou_op(0),
--		writedata(7 downto 0),data,
--		status,
--		USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRSTX,USBD
--		);

	USB : usbbufio port map (
		CLK,rst,
		
		readflag,
		readedata,
		readret,
		writeflag,
		writedata(7 downto 0),
		writeret,
		
		USBRDX,
		USBRXFX,
		USBWR,
		USBTXEX,
		USBSIWU,
		USBRSTX,
		USBD
		);


	readdata <= x"00000"&"00"&(not readret)&(not writeret)&readedata;
	--status(2):readできない -> readできない
	--status(1):処理中 -> writeできない
	ok <= readret and writeret;
	

end arch;

