library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sram_pp1 is
  Port (
    clk : in STD_LOGIC;                 -- <= 150MHz
    clk_180 : in STD_LOGIC;
    rst : in STD_LOGIC;
    readmode : in STD_LOGIC; -- read制御線
    writemode : in STD_LOGIC; -- write制御線,read が優先
    addr : in STD_LOGIC_VECTOR(19 downto 0);  -- アドレス
    writedata : in STD_LOGIC_VECTOR(31 downto 0);  -- 書き込みデータ
    writedatap : in STD_LOGIC_VECTOR(3 downto 0);  -- 書き込みデータパリティ
    readcmp : out STD_LOGIC;            -- read完了線
    readretaddr : out STD_LOGIC_VECTOR(19 downto 0); -- 完了時にデータとともに返す
    readdata : out STD_LOGIC_VECTOR(31 downto 0); -- 読み込んだデータ
    readdatap : out STD_LOGIC_VECTOR(3 downto 0); -- 読み込んだデータパリティ
    
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
end sram_pp1;

architecture Behavioral of sram_pp1 is
  signal oldreadmode : STD_LOGIC;
  signal oldreadaddr : STD_LOGIC_VECTOR(19 downto 0);
  signal oldwritemode : STD_LOGIC;
  signal oldwritedata : STD_LOGIC_VECTOR(31 downto 0);
  signal oldwritedatap : STD_LOGIC_VECTOR(3 downto 0);

  signal old2readmode : STD_LOGIC;
  signal old2readaddr : STD_LOGIC_VECTOR(19 downto 0);
  signal old2writemode : STD_LOGIC;
  signal old2writedata : STD_LOGIC_VECTOR(31 downto 0);
  signal old2writedatap : STD_LOGIC_VECTOR(3 downto 0);

  signal old3readmode : STD_LOGIC;
  signal old3readaddr : STD_LOGIC_VECTOR(19 downto 0);
  
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
  XFT<='1';

  XWA <= '0' when writemode = '1' else '1';
  XZBE <= (others => '0');              -- 書き込む領域を指定するならここを変更
  XGA<= '0' ;
  ZA <= addr;
  
  readdata <= busreaddata;
  readdatap <= busreaddatap;
  ZD <= old2writedata when old2writemode = '1' else (others => 'Z');
  ZDP <= old2writedatap when old2writemode = '1' else (others => 'Z');
  
  readretaddr <= old3readaddr when old3readmode = '1' else (others => '0');
  readcmp <= old3readmode;
  
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
      old2writemode <= '0';
      old2writedata <= (others => '0');
      old2writedatap <= (others => '0');
      old3readmode <= '0';
      old3readaddr <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      oldreadmode <= readmode;
      oldreadaddr <= addr;
      oldwritemode <= writemode;
      oldwritedata <= writedata;
      oldwritedatap <= writedatap;
      
      old2readmode <= oldreadmode;
      old2readaddr <= oldreadaddr;
      old2writemode <= oldwritemode;
      old2writedata <= oldwritedata;
      old2writedatap <= oldwritedatap;

      old3readmode <= old2readmode;
      old3readaddr <= old2readaddr;
      
      if old2readmode = '1' then
        busreaddata <= ZD;
        busreaddatap <= ZDP;
      end if;
    end if;
  end process;
  
end Behavioral;
