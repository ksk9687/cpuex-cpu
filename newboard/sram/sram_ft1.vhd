library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sram_ft1 is
  Port (
    clk : in STD_LOGIC;                 -- <= 133.33MHz
    clk_180 : in STD_LOGIC;
    rst : in STD_LOGIC;
    readmode : in STD_LOGIC; -- read�����
    writemode : in STD_LOGIC; -- write�����,read ���D��
    addr : in STD_LOGIC_VECTOR(19 downto 0);  -- �A�h���X
    writedata : in STD_LOGIC_VECTOR(31 downto 0);  -- �������݃f�[�^
    writedatap : in STD_LOGIC_VECTOR(3 downto 0);  -- �������݃f�[�^�p���e�B
    readcmp : out STD_LOGIC;            -- read������
    readretaddr : out STD_LOGIC_VECTOR(19 downto 0); -- �������Ƀf�[�^�ƂƂ��ɕԂ�
    readdata : out STD_LOGIC_VECTOR(31 downto 0); -- �ǂݍ��񂾃f�[�^
    readdatap : out STD_LOGIC_VECTOR(3 downto 0); -- �ǂݍ��񂾃f�[�^�p���e�B
    
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
end sram_ft1;

architecture Behavioral of sram_ft1 is
  signal oldreadmode : STD_LOGIC;
  signal oldreadaddr : STD_LOGIC_VECTOR(19 downto 0);
  signal oldwritemode : STD_LOGIC;
  signal oldwritedata : STD_LOGIC_VECTOR(31 downto 0);
  signal oldwritedatap : STD_LOGIC_VECTOR(3 downto 0);

  signal old2readmode : STD_LOGIC;
  signal old2readaddr : STD_LOGIC_VECTOR(19 downto 0);
  
  signal busreaddata : STD_LOGIC_VECTOR(31 downto 0);
  signal busreaddatap : STD_LOGIC_VECTOR(3 downto 0);
begin
  XE1<='0';
  E2A<='1';
  XE3<='0';
  ZZA<='0';
  XZCKE<='0';
  ADVA<='0';
  XLBO<='0';
  ZCLKMA(0)<=clk_180;
  ZCLKMA(1)<=clk_180;
  XFT<='0';

  XWA <= '0' when writemode = '1' else '1';
  XZBE <= (others => '0');              -- �������ޗ̈���w�肷��Ȃ炱����ύX
  XGA<= '0' ;
  ZA <= addr;
  
  readdata <= busreaddata;
  readdatap <= busreaddatap;
  ZD <= oldwritedata when oldwritemode = '1' else (others => 'Z');
  ZDP <= oldwritedatap when oldwritemode = '1' else (others => 'Z');
  
  readretaddr <= old2readaddr when old2readmode = '1' else (others => '0');
  readcmp <= old2readmode;
  
  process (clk, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset
      oldreadmode <= '0';
      oldreadaddr <= (others => '0');
      oldwritemode <= '0';
      oldwritedata <= (others => '0');
      oldwritedatap <= (others => '0');
      old2readmode <= '0';
      old2readaddr <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      oldreadmode <= readmode;
      oldreadaddr <= addr;
      oldwritemode <= writemode;
      oldwritedata <= writedata;
      oldwritedatap <= writedatap;
      
      old2readmode <= oldreadmode;
      old2readaddr <= oldreadaddr;
      
      if oldreadmode = '1' then
        busreaddata <= ZD;
        busreaddatap <= ZDP;
      end if;
    end if;
  end process;
  
end Behavioral;
