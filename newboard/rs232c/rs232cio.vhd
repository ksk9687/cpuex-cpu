library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rs232cio is
  generic (
    READBITLEN    : integer := 1160;    -- 1bitにかかるクロックより少し大きい値
    MERGINLEN     : integer := 10;      -- データの読み込み開始の余白
    STOPBACK      : integer := 50;     -- STOPBITをどれぐらい待たないか
    READBUFLENLOG : integer := 4;      -- バッファの大きさ

    WRITEBITLEN : integer := 1157;      -- 1bitにかかるクロックより少し小さい値
    NULLAFTSTOP : integer := 100;       -- STOPを送った後に念のために送る余白
    WRITEBUFLENLOG : integer := 10      -- バッファの大きさ
    );
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
    -- ledout : out STD_LOGIC_VECTOR(7 downto 0);
    -- RS232Cポート 側につなぐ
    RSRXD : in STD_LOGIC;
    RSTXD : out STD_LOGIC
    );
end rs232cio;

architecture Behavioral of rs232cio is
  component rs232cio_read
    generic (
      READBITLEN    : integer ;    -- 1bitにかかるクロックより少し大きい値
      MERGINLEN     : integer ;      -- データの読み込み開始の余白
      STOPBACK      : integer ;     -- STOPBITをどれぐらい待たないか
      READBUFLENLOG : integer );      -- バッファの大きさ
    Port (
      CLK : in STD_LOGIC;
      RST : in STD_LOGIC;
      -- こちら側を使う
      RSIO_RD : in STD_LOGIC;     -- read 制御線
      RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
      RSIO_RC : out STD_LOGIC;    -- read 完了線
      RSIO_OVERRUN : out STD_LOGIC;    -- OVERRUN時1
      -- RS232Cポート 側につなぐ
      RSRXD : in STD_LOGIC
      );
  end component;
  component rs232cio_write
    generic (
      WRITEBITLEN : integer ;      -- 1bitにかかるクロックより少し小さい値
      NULLAFTSTOP : integer ;       -- STOPを送った後に念のために送る余白
      WRITEBUFLENLOG : integer
      );
    Port (
      CLK : in STD_LOGIC;
      RST : in STD_LOGIC;
      -- こちら側を使う
      RSIO_WD : in STD_LOGIC;     -- write 制御線
      RSIO_WData : in STD_LOGIC_VECTOR(7 downto 0);   -- write data
      RSIO_WC : out STD_LOGIC;    -- write 完了線
      -- RS232Cポート 側につなぐ
      RSTXD : out STD_LOGIC
      );
  end component;
begin
  RSREAD: rs232cio_read
    generic map (
      READBITLEN    => READBITLEN,
      MERGINLEN     => MERGINLEN,
      STOPBACK      => STOPBACK,
      READBUFLENLOG => READBUFLENLOG)
    port map (
      CLK,
      RST,
      RSIO_RD,
      RSIO_RData,
      RSIO_RC,
      RSIO_OVERRUN,
      RSRXD
      );
  RSWRITE: rs232cio_write
    generic map (
      WRITEBITLEN => WRITEBITLEN,
      NULLAFTSTOP    => NULLAFTSTOP,
      WRITEBUFLENLOG => WRITEBUFLENLOG)
    port map (
      CLK,
      RST,
      RSIO_WD,
      RSIO_WData,
      RSIO_WC,
      RSTXD
      );
end Behavioral;

