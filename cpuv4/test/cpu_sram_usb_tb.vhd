--CPUのテストンベンチ


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity cpu_sram_usb_test is
end cpu_sram_usb_test;

architecture Behavioral of cpu_sram_usb_test is
	signal CLK,RST : STD_LOGIC := '0';
	
	component sram_model is
    Port (
		SRAMAA : in  STD_LOGIC_VECTOR (19 downto 0)	--アドレス
		;SRAMIOA : inout  STD_LOGIC_VECTOR (31 downto 0)	--データ
		;SRAMIOPA : inout  STD_LOGIC_VECTOR (3 downto 0) --パリティー
		
		;SRAMRWA : in  STD_LOGIC	--read=>1,write=>0
		;SRAMBWA : in  STD_LOGIC_VECTOR (3 downto 0)--書き込みバイトの指定

		;SRAMCLKMA0 : in  STD_LOGIC	--SRAMクロック
		;SRAMCLKMA1 : in  STD_LOGIC	--SRAMクロック
		
		;SRAMADVLDA : in  STD_LOGIC	--バーストアクセス
		;SRAMCEA : in  STD_LOGIC --clock enable
		
		;SRAMCELA1X : in  STD_LOGIC	--SRAMを動作させるかどうか
		;SRAMCEHA1X : in  STD_LOGIC	--SRAMを動作させるかどうか
		;SRAMCEA2X : in  STD_LOGIC	--SRAMを動作させるかどうか
		;SRAMCEA2 : in  STD_LOGIC	--SRAMを動作させるかどうか

		;SRAMLBOA : in  STD_LOGIC	--バーストアクセス順
		;SRAMXOEA : in  STD_LOGIC	--IO出力イネーブル
		;SRAMZZA : in  STD_LOGIC	--スリープモードに入る
	);
	end component;
	
	component cpu_top is
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
		end component;
	
	component usb_sim
	Port (
		USBWR : in  STD_LOGIC
		;USBRDX : in  STD_LOGIC
		
		;USBTXEX : out  STD_LOGIC
		;USBSIWU : in  STD_LOGIC
		
		;USBRXFX : out  STD_LOGIC
		;USBRSTX : in  STD_LOGIC
		
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
		);
		end component;

	signal USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRSTX : std_logic := '0';
	signal USBD :STD_LOGIC_VECTOR (7 downto 0);	--アドレス
	
		
	signal SRAMAA :STD_LOGIC_VECTOR (19 downto 0);	--アドレス
	signal SRAMIOA : STD_LOGIC_VECTOR (31 downto 0);	--データ
	signal SRAMIOPA : STD_LOGIC_VECTOR (3 downto 0); --パリティー
		
	signal SRAMRWA : STD_LOGIC;	--read=>1,write=>0
	signal SRAMBWA : STD_LOGIC_VECTOR (3 downto 0);--書き込みバイトの指定

	signal SRAMCLKMA0 : STD_LOGIC;	--SRAMクロック
	signal SRAMCLKMA1 : STD_LOGIC;	--SRAMクロック
	
	signal SRAMCLK :std_logic_vector(1 downto 0) := (others => '0');
		
	signal SRAMADVLDA : STD_LOGIC;	--バーストアクセス
	signal SRAMCEA : STD_LOGIC; --clock enable
		
	signal SRAMCELA1X : STD_LOGIC;	--SRAMを動作させるかどうか
	signal SRAMCEHA1X : STD_LOGIC;	--SRAMを動作させるかどうか
	signal SRAMCEA2X : STD_LOGIC;	--SRAMを動作させるかどうか
	signal SRAMCEA2 : STD_LOGIC;	--SRAMを動作させるかどうか
		
	signal SRAMLBOA : STD_LOGIC;	--バーストアクセス順
	signal SRAMXOEA : STD_LOGIC;	--IO出力イネーブル
	signal SRAMZZA : STD_LOGIC;	--スリープモードに入る
	

	signal XFT : STD_LOGIC;	--スリープモードに入る
	signal RX,TX : STD_LOGIC;	--RS232C
	signal outdata0,outdata1,outdata2,outdata3,outdata4,outdata5,outdata6,outdata7 : std_logic_vector(7 downto 0) := (others => '0');
begin
	RST <= '0';
	process 
	begin
		CLK <= not CLK;
		wait for 10 ns;
	end process;

	CPU_TOP0 : cpu_top port map(
		RX,TX,
		outdata0,outdata1,outdata2,outdata3,outdata4,outdata5,outdata6,outdata7
		
		--SRAM
		
		,SRAMADVLDA
		,SRAMCELA1X
		,SRAMCEHA1X
		,SRAMCEA
		,SRAMCEA2X
		,SRAMCEA2
		
		,SRAMLBOA
		,SRAMXOEA
		
		,SRAMCLK
		,XFT
		
		,SRAMRWA
		,SRAMBWA
		
		,SRAMAA
		,SRAMIOPA
		,SRAMIOA
		
		,RST,CLK
	);

	SRAM : sram_model  port map(
		SRAMAA
		,SRAMIOA
		,SRAMIOPA
		
		,SRAMRWA
		,SRAMBWA

		,SRAMCLK(1)
		,SRAMCLK(0)
		
		,SRAMADVLDA
		,SRAMCEA
		
		,SRAMCELA1X
		,SRAMCEHA1X
		,SRAMCEA2X
		,SRAMCEA2
		
		,SRAMLBOA
		,SRAMXOEA
		,SRAMZZA

	);
--	USB : usb_sim port map (
--		USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRSTX,USBD
--	);

end Behavioral;



