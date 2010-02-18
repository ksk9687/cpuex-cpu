library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--STOP=1
--PARITY=0

entity rs232cio_write is
  generic (
    WRITEBITLEN : integer := 1157;      -- 1bitにかかるクロックより少し小さい値
    NULLAFTSTOP : integer := 100;       -- STOPを送った後に念のために送る余白
    WRITEBUFLENLOG : integer := 10
    );
  Port (
    CLK : in STD_LOGIC;
--    BUFCLK : in STD_LOGIC;
    RST : in STD_LOGIC;
    -- こちら側を使う
    RSIO_WD : in STD_LOGIC;     -- write 制御線
    RSIO_WData : in STD_LOGIC_VECTOR(7 downto 0);   -- write data
    RSIO_WC : out STD_LOGIC;    -- write 完了線
    -- RS232Cポート 側につなぐ
    RSTXD : out STD_LOGIC
    );
end rs232cio_write;

architecture Behavioral of rs232cio_write is
  -- constants
  constant BITLEN : integer := WRITEBITLEN;      -- 1bitにかかるクロックより少し小さい値(READ側と異なることに注意)
  --constant NULLAFTSTOP : integer := 100;  -- STOPを送った後に念のため送る余白
  constant BITLENTH : integer := BITLEN - 1;      -- 上の閾値
  constant DATALEN : integer := 8;      -- データの長さ
  constant DATALENTH : integer := DATALEN -1;      -- 上の閾値
  constant buflenlog : integer := WRITEBUFLENLOG;     -- バッファの大きさ
  constant buflen : integer := 2**buflenlog;     -- バッファの大きさ
  constant STOPLEN : integer := 1;    -- STOPビットの長さ
  constant TOTALLEN : integer := (1+DATALEN+STOPLEN);    -- 全体の長さ
  constant TOTALLENTH : integer := TOTALLEN -1;    -- 全体の長さ
  
  type RSWRITESTATE is (STATE_WAITDATA , STATE_WRITING, STATE_AFT_STOP);
  signal state : RSWRITESTATE := STATE_WAITDATA;
  signal timecounter : integer range BITLENTH downto 0 := 0;    -- 基点からの時間 - 1
  signal databitpos : integer range (TOTALLEN-1) downto 0 := 0;     -- 書き込みデータのどこにいるか

  signal writedata : STD_LOGIC_VECTOR(7 downto 0);  -- 読み込んだデータの格納場所
  signal writetotaldata : STD_LOGIC_VECTOR((TOTALLEN-1) downto 0);  -- START,STOPをつけた全体の書き込みデータ

  type ram_type is array(natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
  signal writebuf : ram_type((buflen-1) downto 0);
  signal bufreadpos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);
  signal bufwritepos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);
  
  signal writeenable : STD_LOGIC;
  signal writeflag : STD_LOGIC;

  signal writingdata : STD_LOGIC;
  
begin

  writetotaldata <= "1" & writedata & "0";
  --writetotaldata <= "11" & writedata & "0";
  
  writeenable <= '0' when (bufreadpos = (bufwritepos + conv_std_logic_vector(1,buflenlog))) else '1';
  writeflag <= '0' when (bufreadpos = bufwritepos) else '1';

  writingdata <= '1' when state = STATE_WAITDATA else
                 '1' when state = STATE_AFT_STOP else
                 writetotaldata(databitpos);
  
  RSTXD <= writingdata;
  RSIO_WC <= writeenable;

  process (clk, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset
      state <= STATE_WAITDATA;
      timecounter <= 0;
      databitpos <= 0;
      bufreadpos <= conv_std_logic_vector(0,buflenlog);
      bufwritepos <= conv_std_logic_vector(0,buflenlog);
    else
      if clk'event and clk = '1' then  -- rising clock edge
--      if bufclk'event and bufclk = '1' then  -- rising clock edge
        if RSIO_WD = '1' then
          if writeenable = '1' then
            bufwritepos <= bufwritepos + conv_std_logic_vector(1,buflenlog);
            writebuf(conv_integer(bufwritepos)) <= RSIO_WData;
          else
            bufwritepos <= bufwritepos;
          end if;
        end if;
--      end if;
--      if clk'event and clk = '1' then  -- rising clock edge
        case state is
          when STATE_WAITDATA =>
            timecounter <= 0;
            databitpos <= 0;
            if writeflag = '1' then
              writedata <= writebuf(conv_integer(bufreadpos));
              bufreadpos <= bufreadpos + conv_std_logic_vector(1,buflenlog);
              state <= STATE_WRITING;
            else
              state <= STATE_WAITDATA;
            end if;
          when STATE_WRITING =>
            if timecounter = BITLENTH then
              timecounter <= 0;
              if databitpos = TOTALLENTH then
                databitpos <= 0;
                state <= STATE_AFT_STOP;
              else
                databitpos <= databitpos + 1;
                state <= STATE_WRITING;
              end if;
            else
              timecounter <= timecounter + 1;
              databitpos <= databitpos;
              state <= STATE_WRITING;
            end if;
          when STATE_AFT_STOP =>
            if timecounter = (NULLAFTSTOP - 1) then
              timecounter <= 0;
              databitpos <= 0;
              state <= STATE_WAITDATA;
            else
              timecounter <= timecounter + 1;
              databitpos <= databitpos;
              state <= STATE_AFT_STOP;
            end if;
          when others =>null;
        end case;
      end if;
    end if;
  end process;
end Behavioral;

