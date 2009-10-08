--CPUのテストンベンチ


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sram_test is
end sram_test;

architecture Behavioral of sram_test is
	signal CLK : STD_LOGIC := '0';
	
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
begin
	
	process 
	begin
		CLK <= not CLK;
		wait for 10 ns;
	end process;

	SRAMTOP : sram_top port map(
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

	SRAM : sram_model  port map(
		SRAMAA
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


end Behavioral;



