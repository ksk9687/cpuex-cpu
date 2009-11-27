library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--下のほうにあるconstantsをいじってください。
--バッファオーバーランする仕様です。

entity rs232cio_read is
  generic (
    READBITLEN    : integer := 1180;    -- 1bitにかかるクロックより少し大きい値
    MERGINLEN     : integer := 10;      -- データの読み込み開始の余白
    STOPBACK      : integer := 200;     -- STOPBITをどれぐらい待たないか
    READBUFLENLOG : integer := 4);      -- バッファの大きさ
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
end rs232cio_read;

architecture Behavioral of rs232cio_read is
  -- constants
  constant BITLEN : integer := READBITLEN;      -- 1bitにかかるクロックより少し大きい値
  constant BITLENTH : integer := BITLEN - 1;      -- 上の閾値
  --constant MERGINLEN : integer := 10;    -- 念のためずらす
  constant MERGINLENTH : integer := MERGINLEN-1;    -- 念のためずらす
  --constant STOPBACK : integer := 200;    -- STOPBITを全ては待たない,どれぐらい待たないか
  constant DATALEN : integer := 8;      -- データの長さ
  constant DATALENTH : integer := DATALEN-1;      -- 上の閾値
  constant buflenlog : integer := READBUFLENLOG;     -- バッファの大きさ
  constant buflen : integer := 2**buflenlog;     -- バッファの大きさ
  
  type RSREADSTATE is (STATE_WAITSTART,STATE_WAITMERGIN , STATE_READINGDATA , STATE_WAITSTOP);
  --type RSREADSTATE is (WAITSTART ,STATE_WAITMERGIN, READINGDATA , WAITSTOP , WAIT2STOP);  -- STOPBITの長さ,2が推奨されるらしいが、とりあえず1でテスト
  signal state : RSREADSTATE := STATE_WAITSTART;
  signal timecounter : integer range BITLENTH downto 0 := 0;    -- 基点からの時間 - 1
  signal databitpos : integer range DATALENTH downto 0 := 0;     -- DATA bitのどこにいるか

  signal readdata : STD_LOGIC_VECTOR(7 downto 0);  
                                        -- 読み込んだデータの格納場所
  signal bitbuf : STD_LOGIC_VECTOR(4 downto 0) := "11111";

  type ram_type is array(natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
  signal readbuf : ram_type((buflen-1) downto 0);
  signal bufreadpos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);
  signal bufwritepos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);

  signal bitbufand : STD_LOGIC;         
                                        -- not (bitbuf(0) or bitbuf(1) or bitbuf(2))

  signal overflow : std_logic;
  
  --signal testdata : STD_LOGIC_VECTOR(7 downto 0);
  
  --signal testint : integer;
  
begin
  bitbuf(0)<=RSRXD;
  bitbufand<=not (bitbuf(0) or bitbuf(1) or bitbuf(2) or bitbuf(3) or bitbuf(4));
  RSIO_RData <= readbuf(conv_integer(bufreadpos));
  RSIO_RC <= '0' when bufreadpos = bufwritepos else '1';
  RSIO_OVERRUN <= overflow;
  process (clk, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset
      state <= STATE_WAITSTART;
      timecounter <= 0;
      databitpos <= 0;
      bufreadpos <= conv_std_logic_vector(0,buflenlog);
      bufwritepos <= conv_std_logic_vector(0,buflenlog);
      overflow <= '0';
      --testdata <= "00000000";
    elsif clk'event and clk = '1' then  -- rising clock edge
      bitbuf(4)<=bitbuf(3);
      bitbuf(3)<=bitbuf(2);
      bitbuf(2)<=bitbuf(1);
      bitbuf(1)<=bitbuf(0);
      if RSIO_RD = '1' then
        if bufreadpos = bufwritepos then
          bufreadpos <= bufreadpos;
        else
          bufreadpos <= bufreadpos + conv_std_logic_vector(1,buflenlog);
        end if;
      end if;
      case state is
        when STATE_WAITSTART =>
          timecounter <= 0;
          databitpos <= 0;
          if bitbufand = '1' then
            state <= STATE_WAITMERGIN;
          else
            state <= STATE_WAITSTART;
          end if;
        when STATE_WAITMERGIN =>
          databitpos <= 0;
          if timecounter = MERGINLENTH then
            timecounter <= 0;
            state <= STATE_READINGDATA;
          else
            timecounter <= timecounter + 1;
            state <= STATE_WAITMERGIN;
          end if;
        when STATE_READINGDATA =>
          if timecounter = BITLENTH then
            timecounter <= 0;
            readdata(databitpos) <= (bitbuf(1) and bitbuf(2)) or (bitbuf(2) and bitbuf(3)) or (bitbuf(1) and bitbuf(3));
            if databitpos = DATALENTH then
              databitpos <= 0;
              state <= STATE_WAITSTOP;
            else
              databitpos <= databitpos + 1;
              state <= STATE_READINGDATA;
            end if;
          else
            databitpos <= databitpos;
            timecounter <= timecounter + 1;
            state <= STATE_READINGDATA;
          end if;
        when STATE_WAITSTOP =>
          databitpos <= 0;
          if timecounter = (BITLENTH-STOPBACK) then
            timecounter <= 0;
            state <= STATE_WAITSTART;
            --state <= STATE_WAIT2STOP;
          elsif timecounter = 0 then --1クロックの遅れにつながるがめんどいので
            readbuf(conv_integer(bufwritepos)) <= readdata;
            --testdata <= readdata;
            if (bufwritepos + conv_std_logic_vector(1,buflenlog)) = bufreadpos then
              overflow <= '1';
            end if;
            bufwritepos <= bufwritepos + conv_std_logic_vector(1,buflenlog);
            timecounter <= timecounter + 1;
            state <= STATE_WAITSTOP;
          else
            timecounter <= timecounter + 1;
            state <= STATE_WAITSTOP;
          end if;
          --when STATE_WAIT2STOP =>
          --  databitpos <= databitpos;
          --  if timecounter = BITLENTH then
          --    timecounter <= 0;
          --    state <= STATE_WAITSTART;
          --  else
          --    timecounter <= timecounter + 1;
          --    state <= STATE_WAIT2STOP;
          --  end if;
        when others => null;
      end case;
    end if;
  end process;
end Behavioral;

