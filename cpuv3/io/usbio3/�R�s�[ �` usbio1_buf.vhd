library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity usbbufio is
    Port (
           clk50 : in STD_LOGIC;
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
end usbbufio;

architecture Behavioral of usbbufio is
component usbio
    Port (
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           -- こちらを使用
           USBIO_RD : in STD_LOGIC;     -- read 制御
           USBIO_RData : out STD_LOGIC_VECTOR(7 downto 0);      -- read data
           USBIO_RC : out STD_LOGIC;    -- read 完了
           USBIO_WD : in STD_LOGIC;     -- write 制御
           USBIO_WData : in STD_LOGIC_VECTOR(7 downto 0);       -- write data
           USBIO_WC : out STD_LOGIC;    -- write 完了
              USBIO_CAN_READ : out STD_LOGIC;    -- read 完全完了線
              USBIO_CAN_WRITE : out STD_LOGIC;    -- write 完全完了線
           --ledout : out STD_LOGIC_VECTOR(7 downto 0);
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

	signal USBIO_RD : STD_LOGIC;
	signal USBIO_RData : STD_LOGIC_VECTOR(7 downto 0);
	signal USBIO_RC : STD_LOGIC;
	signal USBIO_WD : STD_LOGIC;
	signal USBIO_WData : STD_LOGIC_VECTOR(7 downto 0);
	signal USBIO_WC : STD_LOGIC;
	signal USBIO_CAN_READ : STD_LOGIC;    -- read 完全完了線
	signal USBIO_CAN_WRITE : STD_LOGIC;    -- write 完全完了線
	
	constant buflen : integer := 9;
	constant bufreadlen : integer := 4;
	type ram_type is array (511 downto 0) of STD_LOGIC_VECTOR(7 downto 0); -- retrieved from http://www.nahitech.com/nahitafu/fpgavhdl/bram/bram.html
	type read_ram_type is array (15 downto 0) of STD_LOGIC_VECTOR(7 downto 0); -- retrieved from http://www.nahitech.com/nahitafu/fpgavhdl/bram/bram.html
	
	signal readbuf : read_ram_type;
	signal readbuf_writeaddr : STD_LOGIC_VECTOR((bufreadlen-1) downto 0) := (others => '0');
	signal readbuf_readaddr : STD_LOGIC_VECTOR((bufreadlen-1) downto 0) := (others => '0');
	--signal readdata : STD_LOGIC_VECTOR(7 downto 0);
	
	signal writebuf : ram_type;
	signal writebuf_writeaddr : STD_LOGIC_VECTOR((buflen-1) downto 0) := (others => '0');
	signal writebuf_readaddr : STD_LOGIC_VECTOR((buflen-1) downto 0) := (others => '0');
	signal writedata : STD_LOGIC_VECTOR(7 downto 0);
	signal writeflag : STD_LOGIC := '0';
	
	constant STATE_IDLE :integer range 2 downto 0 := 0;
	constant STATE_WAIT_READ :integer range 2 downto 0 := 1;
	constant STATE_WAIT_WRITE :integer range 2 downto 0 := 2;
	signal state : integer range 2 downto 0 := STATE_IDLE;
	
	--signal testdata : STD_LOGIC_VECTOR(7 downto 0);
	
	signal lastRC : STD_LOGIC := '1';
	signal lastWC : STD_LOGIC := '1';

	
	signal iou_op : std_logic_vector(1 downto 0) := "00";
begin
  usbio_inst : usbio port map(
    clk50,
    rst,
    USBIO_RD,
    USBIO_RData,
    USBIO_RC,
    USBIO_WD,
    USBIO_WData,
    USBIO_WC,
    USBIO_CAN_READ,
    USBIO_CAN_WRITE,
     --ledout,
    -- FT245BM 側につなぐ
    USBRD,
    USBRXF,
    USBWR,
    USBTXE,
    USBSIWU,
    USBD
    );
  USBRST <= '1';

   USB : usb2 port map (
		CLK50,
		iou_op(1),iou_op(0),
		writedata(7 downto 0),data,
		status,
		USBWR,USBRDX,USBTXEX,USBSIWU,USBRXF,USBRST,USBD
		);
	readdata <= x"00000"&"00"&status(2)&status(1)&data;
	ok <= (not status(0)) and (not status(1));
  

  USBBUF_RData <= readbuf(conv_integer(readbuf_readaddr));
  USBBUF_RC <= '0' when ((readbuf_readaddr = readbuf_writeaddr)) else '1';-- 0:空	1:なにかある
  
  writedata <= writebuf(conv_integer(writebuf_readaddr));
  writeflag <= '0' when (writebuf_readaddr = writebuf_writeaddr) else '1';-- 0:空	1:なにかある
  
  USBBUF_WC <= '0' when ((writebuf_readaddr = (writebuf_writeaddr + '1'))) else '1';-- 0:いっぱい	　1:空きがある
  
  with state select
   iou_op <= "11" when STATE_WAIT_READ,
   "11" when STATE_WAIT_WRITE,
   "00" when others;
   
  
  USBIO_RD <= '1' when (state = STATE_WAIT_READ) else '0' ;--読み出し要求を出す
  USBIO_WD <= '1' when (state = STATE_WAIT_WRITE) else '0' ;--書き込み要求を出す
  USBIO_WData <= writedata;
  


  process (clk50, rst)
  begin  -- process
    if rst = '1' then                 -- asynchronous reset (active low)
      lastRC <= '1';
      lastWC <= '1';
      readbuf_writeaddr <= (others => '0');
      writebuf_readaddr <= (others => '0');
      state <= STATE_IDLE;
    elsif clk50'event and clk50 = '1' then  -- rising clock edge
        lastRC <= USBIO_RC;
        lastWC <= USBIO_WC;
        case state is
          when STATE_IDLE =>
            if (USBIO_CAN_READ = '1') and (USBRXF = '0') and (readbuf_readaddr /= (readbuf_writeaddr + '1')) then
              state <= STATE_WAIT_READ;
            elsif (USBIO_CAN_WRITE = '1') and (USBTXE = '0') and (writeflag = '1') then
              state <= STATE_WAIT_WRITE;
            else
              state <= STATE_IDLE;
            end if;
          when STATE_WAIT_READ =>
            if lastRC = '0' and USBIO_RC = '1' then
              readbuf(conv_integer(readbuf_writeaddr)) <= USBIO_RData;
              readbuf_writeaddr <= readbuf_writeaddr + '1';
              state <= STATE_IDLE;
            else
              state <= STATE_WAIT_READ;
            end if;
          when STATE_WAIT_WRITE =>
            if lastWC = '1' and USBIO_WC = '0' then
              writebuf_readaddr <= writebuf_readaddr + '1';
              state <= STATE_IDLE;
            else
              state <= STATE_WAIT_WRITE;
            end if;
          when others => null;
        end case;
    end if;
  end process;

  process (clk, rst)
  begin  -- process
    if rst = '1' then
      readbuf_readaddr <= (others => '0');
      writebuf_writeaddr <= (others => '0');
    elsif rising_edge(clk) then  -- rising clock edge
    
      	--読み出し要求
        if USBBUF_RD = '1' then
          if readbuf_readaddr /= readbuf_writeaddr then
            readbuf_readaddr <= readbuf_readaddr + '1';
          end if;
        end if;
        
        --書き込み要求
        if USBBUF_WD ='1' then
          if writebuf_readaddr /= (writebuf_writeaddr + '1') then
            writebuf(conv_integer(writebuf_writeaddr)) <= USBBUF_WData;
            writebuf_writeaddr <= writebuf_writeaddr + '1';
          end if;
        end if;
    end if;
  end process;
  
    --ledout <= not (writebuf_writeaddr(7 downto 0));
  --ledout <= not testdata;
  --ledout <= not(USBIO_CAN_WRITE & USBIO_CAN_READ & USBTXE & writeflag & USBRXF & conv_std_logic_vector(state,2)&"0");
  
  
  --  USBBUF_RData <= "00000000" when ((readbuf_readaddr = readbuf_writeaddr) or (rst='1')) else readbuf(conv_integer(readbuf_readaddr));
--  
--  USBBUF_RC <= '0' when ((readbuf_readaddr = readbuf_writeaddr) or (rst='1')) else '1';
--  --writedata <= "00000000" when (writebuf_readaddr = writebuf_writeaddr) else writebuf(conv_integer(writebuf_readaddr));
--  writedata <= writebuf(conv_integer(writebuf_readaddr));
--  writeflag <= '0' when (writebuf_readaddr = writebuf_writeaddr) else '1';
--  USBBUF_WC <= '0' when ((writebuf_readaddr = (writebuf_writeaddr + conv_std_logic_vector(1,buflen)) ) or (rst='1')) else '1';
--
--  USBIO_RD <= '1' when (state = STATE_WAIT_READ) else '0' ;
--  USBIO_WD <= '1' when (state = STATE_WAIT_WRITE) else '0' ;
--  --USBIO_WData <= writedata when (state = STATE_WAIT_WRITE) else (others=>'0');
--  USBIO_WData <= writedata;
  
end Behavioral;

