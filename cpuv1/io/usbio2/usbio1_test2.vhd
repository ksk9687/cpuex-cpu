library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity echo is
    Port (
           USBRD : out  STD_LOGIC;
           USBRXF : in  STD_LOGIC;
           USBWR : out  STD_LOGIC;
           USBTXE : in  STD_LOGIC;
           USBSIWU : out  STD_LOGIC;
           USBRST : out  STD_LOGIC;
           USBD : inout  STD_LOGIC_VECTOR (7 downto 0);

           clkin : in STD_LOGIC;
           ledout : out STD_LOGIC_VECTOR(7 downto 0)
           );
end echo;

architecture Behavioral of echo is
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

signal clk : STD_LOGIC;
signal reset : std_logic;

signal USBBUF_RD : STD_LOGIC;     -- read 制御:1にすると、バッファから1個消す
signal USBBUF_RData : STD_LOGIC_VECTOR(7 downto 0);      -- read data
signal USBBUF_RC : STD_LOGIC;    -- read 完了:1の時読んでよい
signal USBBUF_WD : STD_LOGIC;     -- write 制御:1にすると、データを取り込む
signal USBBUF_WData : STD_LOGIC_VECTOR(7 downto 0);       -- write data
signal USBBUF_WC : STD_LOGIC;    -- write 完了:1の時書き込んでよい

constant buf_max : integer := 16;
type IOBUF is array (15 downto 0) of STD_LOGIC_VECTOR (7 downto 0);
signal databuf : IOBUF;
signal buf_i : integer range 16 downto 0 := 0;
signal buf_j : integer range 16 downto 0 := 0;

signal readdata : STD_LOGIC_VECTOR(7 downto 0);

constant STATE_WAIT_READ :integer range 2 downto 0 := 0;
constant STATE_WAIT_WRITE :integer range 2 downto 0 := 1;
signal echostate : integer range 1 downto 0 := STATE_WAIT_READ;

signal testdata : STD_LOGIC_VECTOR(7 downto 0);

begin
  ibufg_inst : ibufg port map (I => clkin,O => clk);
  roc_inst : roc port map (O => reset);

  usbbufio_inst : usbbufio port map(
    clk,
    reset,
    USBBUF_RD,
    USBBUF_RData,
    USBBUF_RC,
    USBBUF_WD,
    USBBUF_WData,
    USBBUF_WC,
	 --ledout,
    -- FT245BM 側につなぐ
    USBRD,
    USBRXF,
    USBWR,
    USBTXE,
	USBRST,
    USBSIWU,
    USBD
    );

  ledout <= not testdata;
  --ledout <= not (conv_std_logic_vector(buf_i,5) & "000");

  USBBUF_WData<=databuf(buf_j);

  USBBUF_RD<='1' when echostate = STATE_WAIT_READ else '0';
  USBBUF_WD<='1' when echostate = STATE_WAIT_WRITE else '0';

  process (clk, reset)
  begin  -- process
    if reset = '1' then                 -- asynchronous reset (active low)
      buf_i<=0;
      buf_j<=0;
      echostate<=STATE_WAIT_READ;
		testdata <= "00000000";
    elsif clk'event and clk = '1' then  -- rising clock edge
      --readdata<=USBBUF_RData;
      case echostate is
        when STATE_WAIT_READ =>
          if buf_i = buf_max then
            buf_i<=buf_i;
            buf_j<=buf_j;
            echostate<=STATE_WAIT_WRITE;
          else
            if USBBUF_RC = '1' then
              databuf(buf_i)<=USBBUF_RData;
              testdata<=USBBUF_RData;
              buf_i<=buf_i+1;
              buf_j<=buf_j;
            else
              buf_i<=buf_i;
              buf_j<=buf_j;
            end if;
            echostate<=STATE_WAIT_READ;
          end if;
        when STATE_WAIT_WRITE =>
          if buf_j+1 = buf_i then
            buf_i<=0;
            buf_j<=0;
            echostate<=STATE_WAIT_READ;
          else
            if USBBUF_WC = '1' then
              buf_i<=buf_i;
              buf_j<=buf_j+1;
            else
              buf_i<=buf_i;
              buf_j<=buf_j;
            end if;
            echostate<=STATE_WAIT_WRITE;
          end if;
        when others => null;            --error
      end case;
    end if;
  end process;
  
end Behavioral;

