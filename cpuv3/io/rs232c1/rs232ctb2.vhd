library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity rs232ctb2 is
end rs232ctb2;

architecture Behavioral of rs232ctb2 is
  component echo
  Port (
    RSRXD : in STD_LOGIC;
    RSTXD : out STD_LOGIC;

    clkin : in STD_LOGIC;
    ledout : out STD_LOGIC_VECTOR(7 downto 0)
    );
  end component;
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
  
  signal clk : std_logic;
  signal reset : std_logic;
  
  signal ledout : std_logic_vector(7 downto 0);
  
  signal RSRXD : STD_LOGIC;
  signal RSTXD : STD_LOGIC;

  signal RSIO_RD : STD_LOGIC;     -- read 制御線
  signal RSIO_RData : STD_LOGIC_VECTOR(7 downto 0);  -- read data
  signal RSIO_RC : STD_LOGIC;    -- read 完了線
  signal RSIO_OVERRUN : STD_LOGIC;    -- OVERRUN時1
  signal RSIO_WD : STD_LOGIC;     -- write 制御線
  signal RSIO_WData : STD_LOGIC_VECTOR(7 downto 0);   -- write data
  signal RSIO_WC : STD_LOGIC;    -- write 完了線
  
  type ram_type is array(natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
  
  constant SENDSIZE : integer := 20;
  constant SENDDATA : ram_type(0 to SENDSIZE) :=
  (
  "00000001",
  "00000011",
  "00000101",
  "00001001",
  "00010001",
  "00000001",
  "00000011",
  "00000101",
  "00001001",
  "00010001",
  "00000001",
  "00000011",
  "00000101",
  "00001001",
  "00010001",
  "00000001",
  "00000011",
  "00000101",
  "00001001",
  "00010001",
  "XXXXXXXX"
  );
  signal sendpos : integer range 0 to SENDSIZE := 0;
  
  constant RECVSIZE : integer := 20;
  signal RECVDATA : ram_type(0 to (RECVSIZE-1));
  signal recvpos : integer range 0 to RECVSIZE := 0;
  
begin
  roc_inst : roc port map (O => reset);
  test_inst : echo port map(
    RSRXD => RSRXD,
    RSTXD => RSTXD,
    ledout => ledout,
    clkin => clk
  );
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
    RSTXD, -- 入れ替え
    RSRXD
    );
  
  process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;
  
  RSIO_WData <= SENDDATA(sendpos);
  
  RSIO_RD <= '1' when (recvpos < RECVSIZE) else '0';
  RSIO_WD <= '1' when (sendpos < SENDSIZE) else '0';
  
  process(clk)
  begin
    if reset = '1' then
      sendpos <= 0;
      recvpos <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sendpos < SENDSIZE then
        if RSIO_WC = '1' then
          sendpos <= sendpos + 1;
        end if;
      end if;
      if recvpos < RECVSIZE then
        if RSIO_RC = '1' then
          RECVDATA(recvpos) <= RSIO_RData;
          recvpos <= recvpos + 1;
        end if;
      end if;
    end if;
  end process;
end Behavioral;


