library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--���̂ق��ɂ���constants���������Ă��������B
--�o�b�t�@�I�[�o�[��������d�l�ł��B
--clock = 20ns!!!
--Little endian !!!

entity rs232cio_read is
  Port (
    CLK : in STD_LOGIC;
    RST : in STD_LOGIC;
    -- �����瑤���g��
    RSIO_RD : in STD_LOGIC;     -- read �����
    RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
    RSIO_RC : out STD_LOGIC;    -- read ������
    RSIO_OVERRUN : out STD_LOGIC;    -- OVERRUN��1
    --ledout : out STD_LOGIC_VECTOR(7 downto 0);
    -- RS232C�|�[�g ���ɂȂ�
    RSRXD : in STD_LOGIC
    );
end rs232cio_read;

architecture Behavioral of rs232cio_read is
  -- constants
  constant BITLEN : integer := 55;      -- 1bit�ɂ�����N���b�N��菭���傫���l
  constant BITLENTH : integer := BITLEN - 1;      -- ���臒l
  constant DATALEN : integer := 8;      -- �f�[�^�̒���
  constant DATALENTH : integer := 7;      -- ���臒l
  constant buflen : integer := 16;     -- �o�b�t�@�̑傫��
  constant buflenlog : integer := 4;     -- �o�b�t�@�̑傫��
  
  type RSREADSTATE is (STATE_WAITSTART , STATE_READINGDATA , STATE_WAITSTOP);
  --type RSREADSTATE is (WAITSTART , READINGDATA , WAITSTOP , WAIT2STOP);  -- STOPBIT�̒���,2�����������炵�����A�Ƃ肠����1�Ńe�X�g
  signal state : RSREADSTATE := STATE_WAITSTART;
  signal timecounter : integer range BITLENTH downto 0 := 0;    -- ��_����̎��� - 1
  signal databitpos : integer range DATALENTH downto 0 := 0;     -- DATA bit�̂ǂ��ɂ��邩

  signal readdata : STD_LOGIC_VECTOR(7 downto 0);  
                                        -- �ǂݍ��񂾃f�[�^�̊i�[�ꏊ
  signal bitbuf : STD_LOGIC_VECTOR(2 downto 0) := "111";

  type ram_type is array(natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
  signal readbuf : ram_type((buflen-1) downto 0);
  signal bufreadpos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);
  signal bufwritepos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);

  signal bitbufand : STD_LOGIC;         
                                        -- not (bitbuf(0) or bitbuf(1) or bitbuf(2))

  signal overflow : std_logic;
  
begin
  bitbuf(0)<=RSRXD;
  bitbufand<=not (bitbuf(0) or bitbuf(1) or bitbuf(2));
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
    elsif clk'event and clk = '1' then  -- rising clock edge
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
          if bitbufand = '1' then
            databitpos <= 0;
            state <= STATE_READINGDATA;
          else
            databitpos <= databitpos;
            state <= STATE_WAITSTART;
          end if;
        when STATE_READINGDATA =>
          if timecounter = BITLENTH then
            timecounter <= 0;
            readdata(databitpos) <= bitbuf(1);
            if databitpos = DATALENTH then
              databitpos <= databitpos;
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
          databitpos <= databitpos;
          if timecounter = BITLENTH then
            timecounter <= 0;
            state <= STATE_WAITSTART;
            --state <= STATE_WAIT2STOP;
          elsif timecounter = 1 then --1�N���b�N�̒x��ɂȂ��邪�߂�ǂ��̂�
            readbuf(conv_integer(bufwritepos)) <= readdata;
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

