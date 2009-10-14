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
		ok : out std_logic;
		
		-- FT245BM 側につなぐ
	   USBRD : out  STD_LOGIC;
       USBRXF : in  STD_LOGIC;
       USBWR : out  STD_LOGIC;
       USBTXE : in  STD_LOGIC;
       USBSIWU : out  STD_LOGIC;
       USBD : inout  STD_LOGIC_VECTOR (7 downto 0)
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
	
	signal read : std_logic := '0';
	signal read_end : std_logic := '0';
	
	signal write : std_logic := '0';
	signal write_end : std_logic := '0';
	
	
	signal free : std_logic := '1';--暇だ・・・と思っているかどうか
	
	signal op_buf : std_logic_vector(1 downto 0);
	
	signal readdata_out : std_logic_vector(7 downto 0);
	signal readdata_buf : std_logic_vector(7 downto 0);
	signal writedata_buf : std_logic_vector(7 downto 0);
begin
	readdata <= x"000000"&readdata_buf;
	
	with op_buf select
	 read <= '1' when "10",
	 '0' when others;

	with op_buf select
	 write <= '1' when "11",
	 '0' when others;
	 
	 
   USB : usbio port map (
   	clk,rst,
   	read,readdata_out,read_end,
   	write,writedata_buf,write_end,
   	
	USBRD,USBRXF,USBWR,USBTXE,USBSIWU,USBD
   );

	process(clk)
	begin
		if rising_edge(clk) then
			if (free = '1') and (op_buf(1) = '1') then--命令が来た
				writedata_buf <= writedata(7 downto 0);
				op_buf <= iou_op;
				free <= '0';
				ok <= '0';
			else
				if (read_end='0' or write_end= '0') and free = '0' then
					op_buf <= "00";
					ok <= '1';
					free <= '1';
					readdata_buf <= readdata_out;
				else
					ok <= '0';
				end if;
			end if;
		end if;
	end process;
	

end arch;

