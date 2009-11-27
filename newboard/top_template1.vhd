library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_template is
  Port (
    RS_RX : in STD_LOGIC;
    RS_TX : out STD_LOGIC;
    outdata0 : out std_logic_vector(7 downto 0);
    outdata1 : out std_logic_vector(7 downto 0);
    outdata2 : out std_logic_vector(7 downto 0);
    outdata3 : out std_logic_vector(7 downto 0);
    outdata4 : out std_logic_vector(7 downto 0);
    outdata5 : out std_logic_vector(7 downto 0);
    outdata6 : out std_logic_vector(7 downto 0);
    outdata7 : out std_logic_vector(7 downto 0);

    XE1 : out STD_LOGIC; -- 0
    E2A : out STD_LOGIC; -- 1
    XE3 : out STD_LOGIC; -- 0
    ZZA : out STD_LOGIC; -- 0
    XGA : out STD_LOGIC; -- 0
    XZCKE : out STD_LOGIC; -- 0
    ADVA : out STD_LOGIC; -- we do not use (0)
    XLBO : out STD_LOGIC; -- no use of ADV, so what ever
    ZCLKMA : out STD_LOGIC_VECTOR(1 downto 0); -- clk
    XFT : out STD_LOGIC; -- FT(0) or pipeline(1)
    XWA : out STD_LOGIC; -- read(1) or write(0)
    XZBE : out STD_LOGIC_VECTOR(3 downto 0); -- write pos
    ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
    ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
    ZD : inout STD_LOGIC_VECTOR(31 downto 0); -- bus

    -- CLK_48M : in STD_LOGIC;
    CLK_RST : in STD_LOGIC;
    CLK_66M : in STD_LOGIC
    );
end top_template;

architecture Behavioral of top_template is
  component core_template
    Port (
      leddata   : out std_logic_vector(31 downto 0);
      leddotdata: out std_logic_vector(7 downto 0);

      sramreadmode : out STD_LOGIC; -- 
      sramwritemode : out STD_LOGIC; -- read ���D��
      sramaddr : out STD_LOGIC_VECTOR(19 downto 0);
      sramwritedata : out STD_LOGIC_VECTOR(31 downto 0);
      sramwritedatap : out STD_LOGIC_VECTOR(3 downto 0);
      sramreadcmp : in STD_LOGIC;
      sramreadretaddr : in STD_LOGIC_VECTOR(19 downto 0); -- return address
      sramreaddata : in STD_LOGIC_VECTOR(31 downto 0); -- 
      sramreaddatap : in STD_LOGIC_VECTOR(3 downto 0); -- 

      RSIO_RD : out STD_LOGIC;     -- read �����
      RSIO_RData : in STD_LOGIC_VECTOR(7 downto 0);  -- read data
      RSIO_RC : in STD_LOGIC;    -- read ������
      RSIO_OVERRUN : in STD_LOGIC;    -- OVERRUN��1
      RSIO_WD : out STD_LOGIC;     -- write �����
      RSIO_WData : out STD_LOGIC_VECTOR(7 downto 0);   -- write data
      RSIO_WC : in STD_LOGIC;    -- write ������
      clk66 : in  STD_LOGIC;
      clk133 : in  STD_LOGIC;
      rst : in  STD_LOGIC
      );
  end component;

  signal clk66 : STD_LOGIC;
  signal clk133 : STD_LOGIC;
  signal clk133_180 : STD_LOGIC;
  signal reset : std_logic;
  component clockgenerator
    Port ( globalclk : in  STD_LOGIC;
           globalrst : in  STD_LOGIC;
           clock66 : out  STD_LOGIC;
           clock133 : out  STD_LOGIC;
           clock133_180 : out  STD_LOGIC;
           reset : out  STD_LOGIC);
  end component;

  signal leddata   : std_logic_vector(31 downto 0);
  signal leddotdata: std_logic_vector(7 downto 0);
  component ledextd2
    Port (
      leddata   : in std_logic_vector(31 downto 0);
      leddotdata: in std_logic_vector(7 downto 0);
      outdata0 : out std_logic_vector(7 downto 0);
      outdata1 : out std_logic_vector(7 downto 0);
      outdata2 : out std_logic_vector(7 downto 0);
      outdata3 : out std_logic_vector(7 downto 0);
      outdata4 : out std_logic_vector(7 downto 0);
      outdata5 : out std_logic_vector(7 downto 0);
      outdata6 : out std_logic_vector(7 downto 0);
      outdata7 : out std_logic_vector(7 downto 0)
      );
  end component;

  signal RSIO_RD : STD_LOGIC;     -- read �����
  signal RSIO_RData : STD_LOGIC_VECTOR(7 downto 0);  -- read data
  signal RSIO_RC : STD_LOGIC;    -- read ������
  signal RSIO_OVERRUN : STD_LOGIC;    -- OVERRUN��1
  signal RSIO_WD : STD_LOGIC;     -- write �����
  signal RSIO_WData : STD_LOGIC_VECTOR(7 downto 0);   -- write data
  signal RSIO_WC : STD_LOGIC;    -- write ������
  component rs232cio
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
  end component;



  signal sramreadmode : STD_LOGIC; -- 
  signal sramwritemode : STD_LOGIC; -- read ���D��
  signal sramaddr : STD_LOGIC_VECTOR(19 downto 0);
  signal sramwritedata : STD_LOGIC_VECTOR(31 downto 0);
  signal sramwritedatap : STD_LOGIC_VECTOR(3 downto 0);
  signal sramreadcmp : STD_LOGIC;
  signal sramreadretaddr : STD_LOGIC_VECTOR(19 downto 0); -- return address
  signal sramreaddata : STD_LOGIC_VECTOR(31 downto 0); -- 
  signal sramreaddatap : STD_LOGIC_VECTOR(3 downto 0); -- 
  component sram_pp1
    Port (
      clk : in STD_LOGIC;
      clk_180 : in STD_LOGIC;
      rst : in STD_LOGIC;
      readmode : in STD_LOGIC; -- 
      writemode : in STD_LOGIC; -- read ���D��
      addr : in STD_LOGIC_VECTOR(19 downto 0);
      writedata : in STD_LOGIC_VECTOR(31 downto 0);
      writedatap : in STD_LOGIC_VECTOR(3 downto 0);
      readcmp : out STD_LOGIC;
      readretaddr : out STD_LOGIC_VECTOR(19 downto 0); -- return address
      readdata : out STD_LOGIC_VECTOR(31 downto 0); -- 
      readdatap : out STD_LOGIC_VECTOR(3 downto 0); -- 
      
      XE1 : out STD_LOGIC; -- 0
      E2A : out STD_LOGIC; -- 1
      XE3 : out STD_LOGIC; -- 0
      ZZA : out STD_LOGIC; -- 0
      XGA : out STD_LOGIC; -- 0
      XZCKE : out STD_LOGIC; -- 0
      ADVA : out STD_LOGIC; -- we do not use (0)
      XLBO : out STD_LOGIC; -- no use of ADV, so what ever
      ZCLKMA : out STD_LOGIC_VECTOR(1 downto 0); -- clk
      XFT : out STD_LOGIC; -- FT(0) or pipeline(1)
      XWA : out STD_LOGIC; -- read(1) or write(0)
      XZBE : out STD_LOGIC_VECTOR(3 downto 0); -- write pos
      ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
      ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
      ZD : inout STD_LOGIC_VECTOR(31 downto 0) -- bus
      );
  end component;
  component sram_ft1
    Port (
      clk : in STD_LOGIC;
      clk_180 : in STD_LOGIC;
      rst : in STD_LOGIC;
      readmode : in STD_LOGIC; -- 
      writemode : in STD_LOGIC; -- read ���D��
      addr : in STD_LOGIC_VECTOR(19 downto 0);
      writedata : in STD_LOGIC_VECTOR(31 downto 0);
      writedatap : in STD_LOGIC_VECTOR(3 downto 0);
      readcmp : out STD_LOGIC;
      readretaddr : out STD_LOGIC_VECTOR(19 downto 0); -- return address
      readdata : out STD_LOGIC_VECTOR(31 downto 0); -- 
      readdatap : out STD_LOGIC_VECTOR(3 downto 0); -- 
      
      XE1 : out STD_LOGIC; -- 0
      E2A : out STD_LOGIC; -- 1
      XE3 : out STD_LOGIC; -- 0
      ZZA : out STD_LOGIC; -- 0
      XGA : out STD_LOGIC; -- 0
      XZCKE : out STD_LOGIC; -- 0
      ADVA : out STD_LOGIC; -- we do not use (0)
      XLBO : out STD_LOGIC; -- no use of ADV, so what ever
      ZCLKMA : out STD_LOGIC_VECTOR(1 downto 0); -- clk
      XFT : out STD_LOGIC; -- FT(0) or pipeline(1)
      XWA : out STD_LOGIC; -- read(1) or write(0)
      XZBE : out STD_LOGIC_VECTOR(3 downto 0); -- write pos
      ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
      ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
      ZD : inout STD_LOGIC_VECTOR(31 downto 0) -- bus
      );
  end component;


begin
  core_inst : sram_ft1_core port map(
    leddata,
    leddotdata,
    sramreadmode,
    sramwritemode,
    sramaddr,
    sramwritedata,
    sramwritedatap,
    sramreadcmp,
    sramreadretaddr,
    sramreaddata,
    sramreaddatap,
    RSIO_RD,
    RSIO_RData,
    RSIO_RC,
    RSIO_OVERRUN,
    RSIO_WD,
    RSIO_WData,
    RSIO_WC,
    clk66,
    clk133,
    reset
    );

  clockgenerator_inst : clockgenerator port map(
    CLK_66M,
    CLK_RST,
    clk66,
    clk133,
    clk133_180,
    reset);

  led_inst : ledextd2 port map (
      leddata,
      leddotdata,
      outdata0,
      outdata1,
      outdata2,
      outdata3,
      outdata4,
      outdata5,
      outdata6,
      outdata7
    );
  rsio_inst : rs232cio
    generic map (
    READBITLEN => 1160,    -- 1bit�ɂ�����N���b�N��菭���傫���l
    MERGINLEN => 10,      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
    STOPBACK  => 50,     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
    READBUFLENLOG => 4,      -- �o�b�t�@�̑傫��

    WRITEBITLEN => 1157,      -- 1bit�ɂ�����N���b�N��菭���������l
    NULLAFTSTOP => 100,       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
    WRITEBUFLENLOG => 10      -- �o�b�t�@�̑傫��
    )
    port map(
    clk133,
    reset,
    RSIO_RD,
    RSIO_RData,
    RSIO_RC,
    RSIO_OVERRUN,
    RSIO_WD,
    RSIO_WData,
    RSIO_WC,
    -- leddata,
    -- RS232C�|�[�g ���ɂȂ�
    RS_RX,
    RS_TX
    );
  --sram_ft1_inst : sram_ft1
  sram_pp1_inst : sram_pp1
    port map (
      clk133,
      clk133_180,
      reset,
      sramreadmode,
      sramwritemode,
      sramaddr,
      sramwritedata,
      sramwritedatap,
      sramreadcmp,
      sramreadretaddr,
      sramreaddata,
      sramreaddatap,
      
      XE1,
      E2A,
      XE3,
      ZZA,
      XGA,
      XZCKE,
      ADVA,
      XLBO,
      ZCLKMA,
      XFT,
      XWA,
      XZBE,
      ZA,
      ZDP,
      ZD
    );
  
end Behavioral;

