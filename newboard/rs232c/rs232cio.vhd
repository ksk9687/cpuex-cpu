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
    READBITLEN    : integer := 1160;    -- 1bit�ɂ�����N���b�N��菭���傫���l
    MERGINLEN     : integer := 10;      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
    STOPBACK      : integer := 50;     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
    READBUFLENLOG : integer := 4;      -- �o�b�t�@�̑傫��

    WRITEBITLEN : integer := 1157;      -- 1bit�ɂ�����N���b�N��菭���������l
    NULLAFTSTOP : integer := 100;       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
    WRITEBUFLENLOG : integer := 10      -- �o�b�t�@�̑傫��
    );
  Port (
    CLK : in STD_LOGIC;
    RST : in STD_LOGIC;
    -- �����瑤���g��
    RSIO_RD : in STD_LOGIC;     -- read �����
    RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
    RSIO_RC : out STD_LOGIC;    -- read ������
    RSIO_OVERRUN : out STD_LOGIC;    -- OVERRUN��1
    RSIO_WD : in STD_LOGIC;     -- write �����
    RSIO_WData : in STD_LOGIC_VECTOR(7 downto 0);   -- write data
    RSIO_WC : out STD_LOGIC;    -- write ������
    -- ledout : out STD_LOGIC_VECTOR(7 downto 0);
    -- RS232C�|�[�g ���ɂȂ�
    RSRXD : in STD_LOGIC;
    RSTXD : out STD_LOGIC
    );
end rs232cio;

architecture Behavioral of rs232cio is
  component rs232cio_read
    generic (
      READBITLEN    : integer ;    -- 1bit�ɂ�����N���b�N��菭���傫���l
      MERGINLEN     : integer ;      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
      STOPBACK      : integer ;     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
      READBUFLENLOG : integer );      -- �o�b�t�@�̑傫��
    Port (
      CLK : in STD_LOGIC;
      RST : in STD_LOGIC;
      -- �����瑤���g��
      RSIO_RD : in STD_LOGIC;     -- read �����
      RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
      RSIO_RC : out STD_LOGIC;    -- read ������
      RSIO_OVERRUN : out STD_LOGIC;    -- OVERRUN��1
      -- RS232C�|�[�g ���ɂȂ�
      RSRXD : in STD_LOGIC
      );
  end component;
  component rs232cio_write
    generic (
      WRITEBITLEN : integer ;      -- 1bit�ɂ�����N���b�N��菭���������l
      NULLAFTSTOP : integer ;       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
      WRITEBUFLENLOG : integer
      );
    Port (
      CLK : in STD_LOGIC;
      RST : in STD_LOGIC;
      -- �����瑤���g��
      RSIO_WD : in STD_LOGIC;     -- write �����
      RSIO_WData : in STD_LOGIC_VECTOR(7 downto 0);   -- write data
      RSIO_WC : out STD_LOGIC;    -- write ������
      -- RS232C�|�[�g ���ɂȂ�
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

