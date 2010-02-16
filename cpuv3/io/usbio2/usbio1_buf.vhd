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
signal readbuf_writeaddr : STD_LOGIC_VECTOR((bufreadlen-1) downto 0) := conv_std_logic_vector(0,bufreadlen);
signal readbuf_readaddr : STD_LOGIC_VECTOR((bufreadlen-1) downto 0) := conv_std_logic_vector(0,bufreadlen);
--signal readdata : STD_LOGIC_VECTOR(7 downto 0);

signal writebuf : ram_type;
signal writebuf_writeaddr : STD_LOGIC_VECTOR((buflen-1) downto 0) := conv_std_logic_vector(0,buflen);
signal writebuf_readaddr : STD_LOGIC_VECTOR((buflen-1) downto 0) := conv_std_logic_vector(0,buflen);
signal writedata : STD_LOGIC_VECTOR(7 downto 0);
signal writeflag : STD_LOGIC := '0';

constant STATE_IDLE :integer range 2 downto 0 := 0;
constant STATE_WAIT_READ :integer range 2 downto 0 := 1;
constant STATE_WAIT_WRITE :integer range 2 downto 0 := 2;
signal state : integer range 2 downto 0 := STATE_IDLE;

--signal testdata : STD_LOGIC_VECTOR(7 downto 0);

signal lastRC : STD_LOGIC := '1';
signal lastWC : STD_LOGIC := '1';


begin
  usbio_inst : usbio port map(
    clk,
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
  
  --ledout <= not (writebuf_writeaddr(7 downto 0));
  --ledout <= not testdata;
  --ledout <= not(USBIO_CAN_WRITE & USBIO_CAN_READ & USBTXE & writeflag & USBRXF & conv_std_logic_vector(state,2)&"0");

  USBBUF_RData <= "00000000" when ((readbuf_readaddr = readbuf_writeaddr) or (rst='1')) else readbuf(conv_integer(readbuf_readaddr));
  USBBUF_RC <= '0' when ((readbuf_readaddr = readbuf_writeaddr) or (rst='1')) else '1';
  --writedata <= "00000000" when (writebuf_readaddr = writebuf_writeaddr) else writebuf(conv_integer(writebuf_readaddr));
  writedata <= writebuf(conv_integer(writebuf_readaddr));
  writeflag <= '0' when (writebuf_readaddr = writebuf_writeaddr) else '1';
  USBBUF_WC <= '0' when ((writebuf_readaddr = (writebuf_writeaddr + conv_std_logic_vector(1,buflen)) ) or (rst='1')) else '1';

  USBIO_RD <= '1' when (state = STATE_WAIT_READ) else '0' ;
  USBIO_WD <= '1' when (state = STATE_WAIT_WRITE) else '0' ;
  --USBIO_WData <= writedata when (state = STATE_WAIT_WRITE) else (others=>'0');
  USBIO_WData <= writedata;

  process (clk, rst)
  begin  -- process
    if rst = '1' then                 -- asynchronous reset (active low)
      lastRC<='1';
      lastWC<='1';
      readbuf_readaddr<=conv_std_logic_vector(0,bufreadlen);
      readbuf_writeaddr<=conv_std_logic_vector(0,bufreadlen);
      writebuf_readaddr<=conv_std_logic_vector(0,buflen);
      writebuf_writeaddr<=conv_std_logic_vector(0,buflen);
      state<=STATE_IDLE;
		--testdata <= "00000000";
    elsif clk'event and clk = '1' then  -- rising clock edge
      lastRC<=USBIO_RC;
      lastWC<=USBIO_WC;
      if USBBUF_RD = '1' then
        if readbuf_readaddr /= readbuf_writeaddr then
          readbuf_readaddr <= readbuf_readaddr+conv_std_logic_vector(1,bufreadlen);
        end if;
      end if;
      if USBBUF_WD ='1' then
        if writebuf_readaddr /= (writebuf_writeaddr + conv_std_logic_vector(1,buflen)) then
          writebuf(conv_integer(writebuf_writeaddr)) <= USBBUF_WData;
          writebuf_writeaddr <= writebuf_writeaddr+conv_std_logic_vector(1,buflen);
        end if;
      end if;
      case state is
        when STATE_IDLE =>
          if (USBIO_CAN_READ='1') and (USBRXF = '0') and (readbuf_readaddr /= (readbuf_writeaddr + conv_std_logic_vector(1,buflen))) then
            state<=STATE_WAIT_READ;
          elsif (USBIO_CAN_WRITE='1') and (USBTXE = '0') and (writeflag='1') then
            state<=STATE_WAIT_WRITE;
				--testdata <= "00001111";
          else
            state<=STATE_IDLE;
          end if;
        when STATE_WAIT_READ =>
          --readdata <= USBIO_RData;
          if lastRC = '0' and USBIO_RC = '1' then
            readbuf(conv_integer(readbuf_writeaddr)) <= USBIO_RData;
            readbuf_writeaddr <= readbuf_writeaddr + conv_std_logic_vector(1,bufreadlen);
            state <= STATE_IDLE;
          else
            state <= STATE_WAIT_READ;
          end if;
        when STATE_WAIT_WRITE =>
          if lastWC = '1' and USBIO_WC = '0' then
            writebuf_readaddr <= writebuf_readaddr+1;
            state<=STATE_IDLE;
          else
            state<=STATE_WAIT_WRITE;
				--testdata<=USBIO_WData;
          end if;
        when others => null;
      end case;
    end if;
  end process;
  
end Behavioral;

