--SRAMのコントローラ

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity sram_controller is
    Port (
		CLK : in STD_LOGIC
		;CLK_180 : in STD_LOGIC
		
		;ADDR    : in  std_logic_vector(19 downto 0)
		;DATAIN  : in  std_logic_vector(31 downto 0)
		;DATAOUT : out std_logic_vector(31 downto 0)
		;RW      : in  std_logic --0ならwrite,1ならread
		
		;i_d    : in  std_logic_vector(0 downto 0)
		;i_d_buf    : out  std_logic_vector(0 downto 0)
		;ADDRBUF    : out  std_logic_vector(19 downto 0)
	;
		--SRAM
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
end sram_controller;

-- pp mode

architecture Behavioral of sram_controller is
  signal old0RW,old1RW,old2RW,old3RW : STD_LOGIC;
  signal old0addr,old1addr,old2addr,old3addr : STD_LOGIC_VECTOR(19 downto 0);
  signal old0writedata,old1writedata,old2writedata : STD_LOGIC_VECTOR(31 downto 0);
  signal old0i_d,old1i_d,old2i_d,old3i_d : STD_LOGIC_VECTOR(0 downto 0);
  signal state,clk1,clk2 :std_logic := '0';
  
  signal busreaddata : STD_LOGIC_VECTOR(31 downto 0);
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

  XWA <= old0RW;
  XZBE <= (others => '0');              -- 書き込む領域を指定するならここを変更
  XGA<= '0';
  ZA <= old0addr;
  
  
  
 
  --パリティは使わない
--  DATAOUT <= busreaddata;
--  ZD <= old2writedata when old2RW = '0' else (others => 'Z');
--  ZDP <= (others => 'Z');
  
  ADDRBUF <= old3addr;
  i_d_buf <= old3i_d;
  
  
  
   	ZD <= old2writedata when old2RW = '0' and clk1 /= clk2 else
	(others => 'Z');
	
	ZDP <= "0000" when old2RW = '0' and clk1 /= clk2 else
	(others => 'Z');
  
    process (clk)
  begin
  if rising_edge(clk) then
    	clk1 <= not clk2;
  end if;
  end process;
  
  process (clk_180)
  begin
  if rising_edge(clk_180) then
    	clk2 <= clk1;
  end if;
  end process;
  
  
  
  process (clk)
  begin  -- process
    -- rst省略
    if clk'event and clk = '1' then  -- rising clock edge
      old0RW <= RW;
      old0addr <= ADDR;
      old0writedata <= DATAIN;
      --old0i_d <= i_d;
      
      old1RW <= old0RW;
      old1addr <= old0addr;
      old1writedata <= old0writedata;
      old1i_d <= i_d;
      
      
      old2RW <= old1RW;
      old2addr <= old1addr;
      old2writedata <= old1writedata;
      old2i_d <= old1i_d;

      old3RW <= old2RW;
      old3addr <= old2addr;
      old3i_d <= old2i_d;
      
      DATAOUT <= busreaddata;
    end if;
  end process;
  
  process (clk_180)
  begin
    if rising_edge(clk_180) then
		busreaddata <= ZD;
		--DATAOUT <= SRAMIOA;
	end if;
  end process;



end Behavioral;

