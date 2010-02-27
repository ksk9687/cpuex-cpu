library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity usbio is 
  generic (
    READBUFLENLOG : integer := 4;      -- バッファの大きさ
    WRITEBUFLENLOG : integer := 10      -- バッファの大きさ
    );
port (
    clk48			: in	  std_logic;
    clk48_180		: in	  std_logic;
    rst				: in	  std_logic;
    clk_buf         : in      std_logic;
    
    USBIO_RD : in STD_LOGIC;     -- read 制御線
    USBIO_RData : out STD_LOGIC_VECTOR(15 downto 0);  -- read data
    USBIO_RC : out STD_LOGIC;    -- read 完了線
    USBIO_WD : in STD_LOGIC;     -- write 制御線
    USBIO_WData : in STD_LOGIC_VECTOR(15 downto 0);   -- write data
    USBIO_WC : out STD_LOGIC;    -- write 完了線
    
    U_D : inout STD_LOGIC_VECTOR(15 downto 0);
    U_A : in STD_LOGIC_VECTOR(11 downto 0);
    XU_CE : in STD_LOGIC;
    XU_RD : in STD_LOGIC;
    XU_WE : in STD_LOGIC;
    XU_RYBY : out STD_LOGIC
	 
	 ;usbwritedata : out STD_LOGIC_VECTOR(15 downto 0)
    );
     
end usbio;

architecture Behavioral of usbio is
  -- constants
  constant READBUFLEN : integer := 2**READBUFLENLOG;     -- バッファの大きさ
  constant WRITEBUFLEN : integer := 2**WRITEBUFLENLOG;     -- バッファの大きさ
  
  type ram_type is array(natural range <>) of STD_LOGIC_VECTOR(15 downto 0);
  signal readbuf : ram_type((READBUFLEN-1) downto 0);
  signal readbufreadpos : STD_LOGIC_VECTOR((READBUFLENLOG-1) downto 0) := (others=>'0');
  signal readbufwritepos : STD_LOGIC_VECTOR((READBUFLENLOG-1) downto 0) := (others=>'0');
  signal writebuf : ram_type((WRITEBUFLEN-1) downto 0);
  signal writebufreadpos : STD_LOGIC_VECTOR((WRITEBUFLENLOG-1) downto 0) := (others=>'0');
  signal writebufwritepos : STD_LOGIC_VECTOR((WRITEBUFLENLOG-1) downto 0) := (others=>'0');
  
  signal writeenable : STD_LOGIC;
  signal writeflag : STD_LOGIC;
  
  signal readdataenable : STD_LOGIC;
  
  signal readdata : STD_LOGIC_VECTOR(15 downto 0);
  signal writedata : STD_LOGIC_VECTOR(15 downto 0);

  signal ryby : STD_LOGIC;
  
  type USBSTATE is (STATE_IDLE,STATE_READING,STATE_READEND1,STATE_READEND2,STATE_READEND3,STATE_WAITSETWRITEDATA1,STATE_WAITSETWRITEDATA2,STATE_SETWRITEDATA,STATE_WRITINGDATA0,STATE_WRITINGDATA1,STATE_WRITINGDATA2);
  signal state : USBSTATE := STATE_IDLE;
  
begin

  usbwritedata <= writedata;

  writeenable <= '0' when (writebufreadpos = (writebufwritepos + 1)) else '1';
  writeflag <= '0' when (writebufreadpos = writebufwritepos) else '1';
  
  readdataenable <= '0' when (readbufreadpos = (readbufwritepos + 1)) else '1';

  USBIO_RData <= readbuf(conv_integer(readbufreadpos));        -- distributed RAM!!
  USBIO_RC <= '0' when readbufreadpos = readbufwritepos else '1';
  USBIO_WC <= writeenable;
  
--  U_D <= writedata when ((state = STATE_WAITSETWRITEDATA1) or (state = STATE_WAITSETWRITEDATA2) or (state = STATE_SETWRITEDATA) or (state = STATE_WRITINGDATA0) or (state = STATE_WRITINGDATA1) or (state = STATE_WRITINGDATA2)) else (others=>'Z');
    U_D <= writedata when ((state = STATE_WRITINGDATA0) or (state = STATE_WRITINGDATA1) or (state = STATE_WRITINGDATA2)) else (others=>'Z');
	 XU_RYBY<=not ryby;
  ryby <= readdataenable when state = STATE_IDLE else  -- readの暴走を防ぐが、はっきり言って頭悪い
             '0' when state = STATE_READING else
             '0' when state = STATE_READEND1 else
             readdataenable when state = STATE_READEND2 else
             readdataenable when state = STATE_READEND3 else
             '0' when state = STATE_WAITSETWRITEDATA1 else
             '0' when state = STATE_WAITSETWRITEDATA2 else
             '0' when state = STATE_SETWRITEDATA else
             '0' when state = STATE_WRITINGDATA0 else
             '1' when state = STATE_WRITINGDATA1 else
             '1'; -- when state = STATE_WRITINGDATA2

  process (clk48, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset
      readbufreadpos <= (others=>'0');
      readbufwritepos <= (others=>'0');
      writebufreadpos <= (others=>'0');
      writebufwritepos <= (others=>'0');
      state <= STATE_IDLE;
    else
      if clk_buf'event and clk_buf = '1' then  -- rising clock edge
        if USBIO_RD = '1' then
          if readbufreadpos = readbufwritepos then
            readbufreadpos <= readbufreadpos;
          else
            readbufreadpos <= readbufreadpos + conv_std_logic_vector(1,READBUFLENLOG);
          end if;
        end if;
        if USBIO_WD = '1' then
          if writeenable = '1' then
            writebuf(conv_integer(writebufwritepos)) <= USBIO_WData;
            writebufwritepos <= writebufwritepos + conv_std_logic_vector(1,WRITEBUFLEN);
          else
            writebufwritepos <= writebufwritepos;
          end if;
        end if;
      end if;
      if clk48'event and clk48 = '1' then  -- rising clock edge
        case state is
          when STATE_IDLE =>
            if XU_CE = '0' and XU_WE = '0' then -- get write data
              readdata<=U_D;
              state<=STATE_READING;
            end if;
            if XU_CE = '0' and XU_RD = '0' then
              state<=STATE_WAITSETWRITEDATA1;
            end if;
          when STATE_READING =>
            readbuf(conv_integer(readbufwritepos)) <= readdata;
            readbufwritepos <= readbufwritepos + 1; -- will not overflow
            state<=STATE_READEND1;
          when STATE_READEND1 =>
            state<=STATE_READEND2;
          when STATE_READEND2 =>
            state<=STATE_READEND3;
          when STATE_READEND3 =>
            state<=STATE_IDLE;
          when STATE_WAITSETWRITEDATA1 =>
            state<=STATE_WAITSETWRITEDATA2;
          when STATE_WAITSETWRITEDATA2 =>
            state<=STATE_SETWRITEDATA;
          when STATE_SETWRITEDATA =>
            if writeflag = '1' then
              writedata <= writebuf(conv_integer(writebufreadpos));
              writebufreadpos <= writebufreadpos + 1;
              state <= STATE_WRITINGDATA0;
            else
              state <= STATE_SETWRITEDATA;
            end if;
          when STATE_WRITINGDATA0 =>
            state <= STATE_WRITINGDATA1;
          when STATE_WRITINGDATA1 =>
            state <= STATE_WRITINGDATA2;
          when STATE_WRITINGDATA2 =>
			   if XU_RD = '1' then
              state <= STATE_IDLE;
				else
              state <= STATE_WRITINGDATA2;
				end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;
end Behavioral;

