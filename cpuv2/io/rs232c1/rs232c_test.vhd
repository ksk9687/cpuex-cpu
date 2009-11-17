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
    RSRXD : in STD_LOGIC;
    RSTXD : out STD_LOGIC;

    clkin : in STD_LOGIC;
    ledout : out STD_LOGIC_VECTOR(7 downto 0)
    );
end echo;

architecture Behavioral of echo is
  component rs232cio
    Port (
      CLK : in STD_LOGIC;
      RST : in STD_LOGIC;
      -- こちら側を使う
      RSIO_RD : in STD_LOGIC;     -- read 制御線
      RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
      RSIO_RC : out STD_LOGIC;    -- read 完了線
      RSIO_OVERRUN : out STD_LOGIC;    -- OVERRUN時1
      RSIO_WD : in STD_LOGIC;     -- write 制御線
      RSIO_WData : in STD_LOGIC_VECTOR(7 downto 0);   -- write data
      RSIO_WC : out STD_LOGIC;    -- write 完了線
      --ledout : out STD_LOGIC_VECTOR(7 downto 0);
      -- RS232Cポート 側につなぐ
      RSRXD : in STD_LOGIC;
      RSTXD : out STD_LOGIC
      );
  end component;

  signal clk : STD_LOGIC;
  signal reset : std_logic;

  constant buf_max : integer := 4;
  type IOBUF is array ((buf_max-1) downto 0) of STD_LOGIC_VECTOR (7 downto 0);
  signal databuf : IOBUF;
  signal buf_i : integer range buf_max downto 0 := 0;
  signal buf_j : integer range buf_max downto 0 := 0;

--signal readdata : STD_LOGIC_VECTOR(7 downto 0);

  constant STATE_WAIT_READ :integer range 2 downto 0 := 0;
  constant STATE_WAIT_WRITE :integer range 2 downto 0 := 1;
  signal echostate : integer range 1 downto 0 := STATE_WAIT_READ;

  signal testdata : STD_LOGIC_VECTOR(7 downto 0);

  signal RSIO_RD : STD_LOGIC;     -- read 制御線
  signal RSIO_RData : STD_LOGIC_VECTOR(7 downto 0);  -- read data
  signal RSIO_RC : STD_LOGIC;    -- read 完了線
  signal RSIO_OVERRUN : STD_LOGIC;    -- OVERRUN時1
  signal RSIO_WD : STD_LOGIC;     -- write 制御線
  signal RSIO_WData : STD_LOGIC_VECTOR(7 downto 0);   -- write data
  signal RSIO_WC : STD_LOGIC;    -- write 完了線

begin
  ibufg_inst : ibufg port map (I => clkin,O => clk);
  roc_inst : roc port map (O => reset);

  rsio_inst : rs232cio port map(
    clk,
    reset,
    --ledout,
    RSIO_RD,
    RSIO_RData,
    RSIO_RC,
    RSIO_OVERRUN,
    RSIO_WD,
    RSIO_WData,
    RSIO_WC,
    --ledout : out STD_LOGIC_VECTOR(7 downto 0);
    -- RS232Cポート 側につなぐ
    RSRXD,
    RSTXD
    );

  ledout <= not testdata;
  --ledout <= not (conv_std_logic_vector(buf_i,5) & "000");

  RSIO_WData<=databuf(buf_j);

  RSIO_RD<='1' when echostate = STATE_WAIT_READ else '0';
  RSIO_WD<='1' when echostate = STATE_WAIT_WRITE else '0';

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
            if RSIO_RC = '1' then
              databuf(buf_i)<=RSIO_RData;
              testdata<=RSIO_RData;
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
            if RSIO_WC = '1' then
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

