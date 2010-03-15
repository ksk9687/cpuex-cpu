library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 

--���̂ق��ɂ���constants���������Ă��������B
--�o�b�t�@�I�[�o�[��������d�l�ł��B

-- ���URAM�g�p�ɕt������!!

entity rs232cio_read is
  generic (
    READBITLEN    : integer := 1160;    -- 1bit�ɂ�����N���b�N��菭���傫���l
    READPADBITLEN : integer := 100;     -- �f�[�^�̍̎�Ԋu
    MERGINLEN     : integer := 10;      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
    STOPBACK      : integer := 200;     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
    READBUFLENLOG : integer := 4);      -- �o�b�t�@�̑傫��,���URAM�Ȃ̂ő傫�����Ă͂����Ȃ�
  Port (
    CLK : in STD_LOGIC;    -- ����Ɏg���N���b�N
--    BUFCLK : in STD_LOGIC; -- �o�b�t�@�ւ̃A�N�Z�X�Ɏg���N���b�N
    RST : in STD_LOGIC;
    -- �����瑤���g��
    RSIO_RD : in STD_LOGIC;     -- read �����
    RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
    RSIO_RC : out STD_LOGIC;    -- read ������
    RSIO_OVERRUN : out STD_LOGIC;    -- OVERRUN��1
    -- RS232C�|�[�g ���ɂȂ�
    RSRXD : in STD_LOGIC
    ;rp,wp: out STD_LOGIC_VECTOR(READBUFLENLOG - 1 downto 0)
    );
end rs232cio_read;

architecture Behavioral of rs232cio_read is
  -- constants
  constant BITLEN : integer := READBITLEN;      -- 1bit�ɂ�����N���b�N��菭���傫���l
  constant BITLENTH : integer := BITLEN - 1;
  constant BITLENREADPAD1TH : integer := BITLEN - READPADBITLEN - 1;
  constant BITLENREADPAD2TH : integer := BITLEN - READPADBITLEN*2 - 1;
  constant MERGINLENTH : integer := MERGINLEN-1;
  constant PREPARETH : integer := READPADBITLEN*2 -1;
  constant DATALEN : integer := 8;      -- �f�[�^�̒���
  constant DATALENTH : integer := DATALEN-1;
  constant STOPWAITLENTH : integer := BITLEN - STOPBACK - READPADBITLEN*2 - 1;
  constant buflenlog : integer := READBUFLENLOG;     -- �o�b�t�@�̑傫��
  constant buflen : integer := 2**buflenlog;     -- �o�b�t�@�̑傫��
  
  type RSREADSTATE is (STATE_WAITSTART,STATE_WAITMERGIN , STATE_WAITPREPARE , STATE_READINGDATA , STATE_WAITSTOP);
  signal state : RSREADSTATE := STATE_WAITSTART;
  signal timecounter : integer range BITLENTH downto 0 := 0;    -- ��_����̎��� - 1
  signal databitpos : integer range DATALENTH downto 0 := 0;     -- DATA bit�̂ǂ��ɂ��邩

  signal readdata : STD_LOGIC_VECTOR(7 downto 0);  -- �ǂݍ��񂾃f�[�^�̊i�[�ꏊ

  signal bitbuf : STD_LOGIC_VECTOR(4 downto 0) := "11111"; -- �M�������肳����
  signal readbit : STD_LOGIC;  -- ���肵���f�[�^(��̍Ō�)

  type ram_type is array(natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
  signal readbuf : ram_type((buflen-1) downto 0);
  signal bufreadpos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);
  signal bufwritepos : STD_LOGIC_VECTOR((buflenlog-1) downto 0) := conv_std_logic_vector(0,buflenlog);

  signal bitbufmlt : STD_LOGIC_VECTOR(2 downto 0) := "111"; -- �N���b�N�̍̎�_
  signal bitbufmany : STD_LOGIC;  -- (bitbufmlt(0) and bitbufmlt(1)) or (bitbufmlt(1) and bitbufmlt(2)) or (bitbufmlt(2) and bitbufmlt(0))

  signal overflow : std_logic;
  
  --for debug
  --signal totalreadbyte : integer := 0;
  
begin
	rp <= bufreadpos;
	wp <= bufwritepos;
  bitbuf(0)<=RSRXD;
  readbit<=(bitbuf(2) and bitbuf(3)) or (bitbuf(3) and bitbuf(4)) or (bitbuf(2) and bitbuf(4));
  bitbufmlt(0)<=readbit;
  bitbufmany<=(bitbufmlt(0) and bitbufmlt(1)) or (bitbufmlt(1) and bitbufmlt(2)) or (bitbufmlt(2) and bitbufmlt(0));
  RSIO_RData <= readbuf(conv_integer(bufreadpos));        -- distributed RAM!!
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
    else
      if clk'event and clk = '1' then  -- rising clock edge
--      if bufclk'event and bufclk = '1' then  -- rising clock edge
        if RSIO_RD = '1' then
          if bufreadpos = bufwritepos then
            bufreadpos <= bufreadpos;
          else
            bufreadpos <= bufreadpos + conv_std_logic_vector(1,buflenlog);
          end if;
        end if;
--      end if;
--      if clk'event and clk = '1' then  -- rising clock edge
        bitbuf(4)<=bitbuf(3);
        bitbuf(3)<=bitbuf(2);
        bitbuf(2)<=bitbuf(1);
        bitbuf(1)<=bitbuf(0);
        case state is
          when STATE_WAITSTART =>
            timecounter <= 0;
            databitpos <= 0;
            if readbit = '0' then
              state <= STATE_WAITMERGIN;
            else
              state <= STATE_WAITSTART;
            end if;
          when STATE_WAITMERGIN =>
            databitpos <= 0;
            if timecounter = MERGINLENTH then
              timecounter <= 0;
              if readbit = '0' then      -- �����ł́AMERGINLENTH�����҂��Ă܂�0��������start bit�Ƃ���
                state <= STATE_WAITPREPARE;
              else
                state <= STATE_WAITSTART;
              end if;
            else
              timecounter <= timecounter + 1;
              state <= STATE_WAITMERGIN;
            end if;
          when STATE_WAITPREPARE =>
            databitpos <= 0;
            if timecounter = PREPARETH then
              timecounter <= 0;
              state <= STATE_READINGDATA;
            else
              timecounter <= timecounter + 1;
              state <= STATE_WAITPREPARE;
            end if;
          when STATE_READINGDATA =>
            if timecounter = BITLENTH then
              timecounter <= 0;
              readdata(databitpos) <= bitbufmany;
              if databitpos = DATALENTH then
                databitpos <= 0;
                state <= STATE_WAITSTOP;
              else
                databitpos <= databitpos + 1;
                state <= STATE_READINGDATA;
              end if;
            else
              if (timecounter = BITLENREADPAD1TH) or (timecounter = BITLENREADPAD2TH) then
                bitbufmlt(2)<=bitbufmlt(1);
                bitbufmlt(1)<=bitbufmlt(0);
              end if;
              databitpos <= databitpos;
              timecounter <= timecounter + 1;
              state <= STATE_READINGDATA;
            end if;
          when STATE_WAITSTOP =>
            databitpos <= 0;
            if timecounter = STOPWAITLENTH then
              timecounter <= 0;
              state <= STATE_WAITSTART;
            else
              if timecounter = 0 then --1�N���b�N�̒x��ɂȂ��邪�߂�ǂ��̂�
                readbuf(conv_integer(bufwritepos)) <= readdata;
                if (bufwritepos + conv_std_logic_vector(1,buflenlog)) = bufreadpos then
                  overflow <= '1';
                end if;
                bufwritepos <= bufwritepos + conv_std_logic_vector(1,buflenlog);
              end if;
              timecounter <= timecounter + 1;
              state <= STATE_WAITSTOP;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;
end Behavioral;

