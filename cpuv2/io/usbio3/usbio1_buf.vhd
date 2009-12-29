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
           -- ��������g�p
           USBBUF_RD : in STD_LOGIC;     -- read ����:1�ɂ���ƁA�o�b�t�@����1����
           USBBUF_RData : out STD_LOGIC_VECTOR(7 downto 0);      -- read data
           USBBUF_RC : out STD_LOGIC;    -- read ����:1�̎��ǂ�ł悢
           USBBUF_WD : in STD_LOGIC;     -- write ����:1�ɂ���ƁA�f�[�^����荞��
           USBBUF_WData : in STD_LOGIC_VECTOR(7 downto 0);       -- write data
           USBBUF_WC : out STD_LOGIC;    -- write ����:1�̎���������ł悢
           --ledout : out STD_LOGIC_VECTOR(7 downto 0);
           -- FT245BM ���ɂȂ�
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
           -- ��������g�p
           USBIO_RD : in STD_LOGIC;     -- read ����
           USBIO_RData : out STD_LOGIC_VECTOR(7 downto 0);      -- read data
           USBIO_RC : out STD_LOGIC;    -- read ����
           USBIO_WD : in STD_LOGIC;     -- write ����
           USBIO_WData : in STD_LOGIC_VECTOR(7 downto 0);       -- write data
           USBIO_WC : out STD_LOGIC;    -- write ����
              USBIO_CAN_READ : out STD_LOGIC;    -- read ���S������
              USBIO_CAN_WRITE : out STD_LOGIC;    -- write ���S������
           --ledout : out STD_LOGIC_VECTOR(7 downto 0);
           -- FT245BM ���ɂȂ�
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
	signal USBIO_CAN_READ : STD_LOGIC;    -- read ���S������
	signal USBIO_CAN_WRITE : STD_LOGIC;    -- write ���S������
	
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
	
	signal writebuf_full,readbuf_full : STD_LOGIC:= '0';
	signal writebuf_empty,readbuf_empty : STD_LOGIC:= '1';
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
    -- FT245BM ���ɂȂ�
    USBRD,
    USBRXF,
    USBWR,
    USBTXE,
    USBSIWU,
    USBD
    );
  USBRST <= '1';
  

	writebuf_full <= '1' when writebuf_readaddr = (writebuf_writeaddr + '1') else '0';
	readbuf_full <= '1' when readbuf_readaddr = (readbuf_writeaddr + '1') else '0';
	writebuf_empty <= '1' when writebuf_readaddr = writebuf_writeaddr else '0';
	readbuf_empty <= '1' when readbuf_readaddr = readbuf_writeaddr else '0';
	
  USBBUF_RData <= "00000000" when readbuf_empty = '1' else
  readbuf(conv_integer(readbuf_readaddr));
  
  --�ǂݍ��݉\
  USBBUF_RC <= not readbuf_empty;
  writedata <= writebuf(conv_integer(writebuf_readaddr));
  --�������݉\
  writeflag <= not writebuf_empty;
  --�������ݗ\��\
  USBBUF_WC <= not writebuf_full;
  
  USBIO_RD <= '1' when (state = STATE_WAIT_READ) else '0' ;
  USBIO_WD <= '1' when (state = STATE_WAIT_WRITE) else '0' ;
  USBIO_WData <= writedata;


	
	process(clk,rst)
	begin
	if rst = '1' then
      readbuf_readaddr <= (others=>'0');
      writebuf_writeaddr <= (others=>'0');
    elsif rising_edge(clk) then
        if USBBUF_RD = '1' then
          if readbuf_empty = '0' then
            readbuf_readaddr <= readbuf_readaddr + '1';
          end if;
        end if;
        if USBBUF_WD = '1' then
          if writebuf_full = '0' then
            writebuf(conv_integer(writebuf_writeaddr)) <= USBBUF_WData;
            writebuf_writeaddr <= writebuf_writeaddr + '1';
          end if;
        end if;
      end if;
	end process;
	

  process (clk50, rst)
  begin  -- process
    if rst = '1' then                 -- asynchronous reset (active low)
      lastRC <= '1';
      lastWC <= '1';
      readbuf_writeaddr <= (others=>'0');
      writebuf_readaddr <= (others=>'0');
      state <= STATE_IDLE;
    elsif rising_edge(clk50) then  -- rising clock edge
        lastRC <= USBIO_RC;
        lastWC <= USBIO_WC;
        case state is
          when STATE_IDLE =>
            if (USBIO_CAN_READ = '1') and (USBRXF = '0') and (readbuf_full = '0') then
              state <= STATE_WAIT_READ;
            elsif (USBIO_CAN_WRITE = '1') and (USBTXE = '0') and (writebuf_empty = '0') then
              state <= STATE_WAIT_WRITE;
            else
              state<=STATE_IDLE;
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
  
end Behavioral;

