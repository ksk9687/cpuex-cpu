--IOユニットの

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
		clk,clk66,enable : in std_logic;
		iou_op : in std_logic_vector(2 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		no : in std_logic_vector(4 downto 0);
		readdata : out std_logic_vector(31 downto 0)
		
		;RSRXD : in STD_LOGIC
		;RSTXD : out STD_LOGIC
		
		;io_read_buf_overrun : out STD_LOGIC
	);
end IOU;

architecture arch of IOU is
	constant rs: std_logic_vector := "00001";
	constant rs232c: std_logic_vector := "00010";
	constant nop: std_logic_vector := "11111";
	constant error: std_logic_vector := x"0FFFFFFF";

	signal rs_read,rs_read_end,rs_write,rs_write_end,rs_read_p,rs_write_p :std_logic := '0';
	signal rs_readdata_out,rs_writedata_buf: std_logic_vector(7 downto 0);
	signal iou_op_buf: std_logic_vector(2 downto 0);
	signal no_buf: std_logic_vector(4 downto 0);
	signal readdata_p,writedata_buf : std_logic_vector(31 downto 0):= (others => '0');
	
	signal rst :std_logic:= '0';
begin
	 
  	ROC0 : ROC port map (O => rst);
  	
	 
	 readdata_p <= 
	 x"00000"&"000"&(not rs_read_end)&rs_readdata_out when (iou_op = iou_op_read) else
	 x"0000000"&"000"&(not rs_write_end) when (iou_op = iou_op_write) else
	 (others => '1');
	  
	 rs_read_p <= '1' and enable when (iou_op = iou_op_read) and (rs_read_end = '1') else
	 '0';
	 rs_write_p <= '1' and enable when (iou_op = iou_op_write) and (rs_write_end = '1') else
	 '0';
	 rs_writedata_buf <= writedata_buf(7 downto 0);
	 	 
 	 process(clk)
 	 begin
 	 	if rising_edge(clk) then
 	 		if enable = '0' then
 	 			rs_read <= '0';
 	 			rs_write <= '0';
 	 			readdata <= (others => '0');
 	 			writedata_buf <= (others => '0');
 	 		else
 	 			readdata <= readdata_p;
 	 			rs_read <= rs_read_p;
 	 			rs_write <= rs_write_p;
 	 			writedata_buf <= writedata;
 	 		end if;
 	 	end if;
 	 end process;
	 	 
   RS232C0 : rs232cio
    generic map( -- 115200,66.66MHz
    READBITLEN    => 580,    -- 1bitにかかるクロックより少し大きい値
    READPADBITLEN => 50,     -- データの採取間隔
    MERGINLEN     => 10,      -- データの読み込み開始の余白
    STOPBACK      => 50,     -- STOPBITをどれぐらい待たないか
    READBUFLENLOG => 4,      -- バッファの大きさ

    WRITEBITLEN => 575,      -- 1bitにかかるクロックより少し小さい値
    NULLAFTSTOP => 100,       -- STOPを送った後に念のために送る余白
    WRITEBUFLENLOG => 10      -- バッファの大きさ
    )
   port map (
   	clk66,clk,rst,
   	rs_read,rs_readdata_out,rs_read_end,io_read_buf_overrun,
   	rs_write,rs_writedata_buf,rs_write_end,
   	
	RSRXD,RSTXD
   );
	

end arch;

