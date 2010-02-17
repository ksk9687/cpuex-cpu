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
		
		;i_d    : in  std_logic_vector(2 downto 0)
		;i_d_buf    : out  std_logic_vector(2 downto 0)
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

architecture Behavioral of sram_controller is
  signal oldRW : STD_LOGIC;
  signal oldaddr : STD_LOGIC_VECTOR(19 downto 0);
  signal oldwritedata : STD_LOGIC_VECTOR(31 downto 0);
  signal oldi_d : STD_LOGIC_VECTOR(2 downto 0);

  signal old2RW : STD_LOGIC;
  signal old2addr : STD_LOGIC_VECTOR(19 downto 0);
  signal old2i_d : STD_LOGIC_VECTOR(2 downto 0);
  
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
  XFT<='0';

  XWA <= RW;
  XZBE <= (others => '0');              -- 書き込む領域を指定するならここを変更
  XGA<= '0';
  ZA <= ADDR;
  
  --パリティは使わない
  DATAOUT <= busreaddata;
  ZD <= oldwritedata when oldRW = '0' else (others => 'Z');
  ZDP <= (others => 'Z');
  
  ADDRBUF <= old2addr;
  i_d_buf <= old2i_d;
  
  process (clk)
  begin  -- process
    -- rst省略
    if clk'event and clk = '1' then  -- rising clock edge
      oldRW <= RW;
      oldaddr <= ADDR;
      oldwritedata <= DATAIN;
      oldi_d <= i_d;
      
      old2RW <= oldRW;
      old2addr <= oldaddr;
      old2i_d <= oldi_d;
      
      if oldRW = '1' then
        busreaddata <= ZD;
      end if;
    end if;
  end process;

end Behavioral;

