--CPUのテストンベンチ



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu_tb is
end cpu_tb;

architecture arch of cpu_tb is
component cpu_top is
    Port (
		CLKIN : in STD_LOGIC
		--led
		;LEDOUT		: out  STD_LOGIC_VECTOR (7 downto 0)
		--SRAM
		;SRAMAA : out  STD_LOGIC_VECTOR (19 downto 0)	--アドレス
		;SRAMIOA : inout  STD_LOGIC_VECTOR (31 downto 0)	--データ
		;SRAMIOPA : inout  STD_LOGIC_VECTOR (3 downto 0) --パリティー
		
		;SRAMRWA : out  STD_LOGIC	--read=>1,write=>0
		;SRAMBWA : out  STD_LOGIC_VECTOR (3 downto 0)--書き込みバイトの指定

		;SRAMCLKMA0 : out  STD_LOGIC	--SRAMクロック
		;SRAMCLKMA1 : out  STD_LOGIC	--SRAMクロック
		
		;SRAMADVLDA : out  STD_LOGIC	--バーストアクセス
		;SRAMCEA : out  STD_LOGIC --clock enable
		
		;SRAMCELA1X : out  STD_LOGIC	--SRAMを動作させるかどうか
		;SRAMCEHA1X : out  STD_LOGIC	--SRAMを動作させるかどうか
		;SRAMCEA2X : out  STD_LOGIC	--SRAMを動作させるかどうか
		;SRAMCEA2 : out  STD_LOGIC	--SRAMを動作させるかどうか

		;SRAMLBOA : out  STD_LOGIC	--バーストアクセス順
		;SRAMXOEA : out  STD_LOGIC	--IO出力イネーブル
		;SRAMZZA : out  STD_LOGIC	--スリープモードに入る
	);
	end component;
	
	signal SRAMAA :STD_LOGIC_VECTOR (19 downto 0);	--アドレス
	signal SRAMIOA : STD_LOGIC_VECTOR (31 downto 0);	--データ
	signal SRAMIOPA : STD_LOGIC_VECTOR (3 downto 0); --パリティー
		
	signal SRAMRWA : STD_LOGIC;	--read=>1,write=>0
	signal SRAMBWA : STD_LOGIC_VECTOR (3 downto 0);--書き込みバイトの指定

	signal SRAMCLKMA0 : STD_LOGIC;	--SRAMクロック
	signal SRAMCLKMA1 : STD_LOGIC;	--SRAMクロック
		
	signal SRAMADVLDA : STD_LOGIC;	--バーストアクセス
	signal SRAMCEA : STD_LOGIC; --clock enable
		
	signal SRAMCELA1X : STD_LOGIC;	--SRAMを動作させるかどうか
	signal SRAMCEHA1X : STD_LOGIC;	--SRAMを動作させるかどうか
	signal SRAMCEA2X : STD_LOGIC;	--SRAMを動作させるかどうか
	signal SRAMCEA2 : STD_LOGIC;	--SRAMを動作させるかどうか
		
	signal SRAMLBOA : STD_LOGIC;	--バーストアクセス順
	signal SRAMXOEA : STD_LOGIC;	--IO出力イネーブル
	signal SRAMZZA : STD_LOGIC;	--スリープモードに入る
	

	signal LEDOUT   : std_logic_vector(7 downto 0) := (others => '0');
	signal CLK : STD_LOGIC := '0';
begin
	process 
	begin
		CLK <= not CLK;
		wait for 20 ns;--25Mhz
	end process;
	
	CPU : cpu_top port map(
		CLK
		,LEDOUT
	
		--SRAM
		,SRAMAA
		,SRAMIOA
		,SRAMIOPA
		
		,SRAMRWA
		,SRAMBWA

		,SRAMCLKMA0
		,SRAMCLKMA1
		
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


end arch;

