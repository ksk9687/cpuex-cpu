--SRAM動作確認用モジュール

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sram_top is
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
end sram_top;

architecture Behavioral of sram_top is

	component sram_controller is
    Port (
		CLK : in STD_LOGIC
		;SRAMCLK : in STD_LOGIC
		;ADDR    : in  std_logic_vector(19 downto 0)
		;DATAIN  : in  std_logic_vector(31 downto 0)
		;DATAOUT : out std_logic_vector(31 downto 0)
		;RW      : in  std_logic
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
	
	signal ADDR    : std_logic_vector(19 downto 0) := (others => '0');
	signal DATAIN  : std_logic_vector(31 downto 0):= (others => '0');
	signal DATAOUT : std_logic_vector(31 downto 0):= (others => '0');
	signal RW      : std_logic := '0';--書き込みから
	
	signal f : STD_LOGIC := '0';
	signal fr : STD_LOGIC := '0';
	
    signal CLK: std_logic;
    signal CLK1 : std_logic;
    signal CLK11 : std_logic := '0';
    signal CLK12 : std_logic := '0';
	
	--結果を確認するためのアドレス保存用バッファ
	signal ADDRB0    : std_logic_vector(19 downto 0) := (others => '0');	
	signal ADDRB1    : std_logic_vector(19 downto 0) := (others => '0');
	signal ADDRB2    : std_logic_vector(19 downto 0) := (others => '0');
	signal ADDRB3    : std_logic_vector(19 downto 0) := (others => '0');
	
	
	signal counter : std_logic_vector(31 downto 0):= (others => '0');
	
	signal state : std_logic_vector(2 downto 0):= (others => '0');

	signal max : std_logic_vector(20 downto 0):= "0"&"1111111111"&"1111111111";
begin
    ibufg01 : IBUFG PORT MAP (I=>CLKIN, O=>CLK);
	

	LEDOUT <= not (fr&f&CLK11&DATAOUT(4 downto 0));
	
	
	process (CLK) begin
		if (CLK'event and CLK = '1') then
			counter <= counter+'1'; 
			if state = "110" then--ゆっくり確認するモード
				if counter(25 downto 0) = "100000"&"0000000000"&"0000000000" then
					CLK1 <= not CLK1;
				end if; 
			else
				if counter(0) = '1' then
					CLK1 <= not CLK1;
				end if; 
			end if; 
		end if;
	end process;
	
	CLK11 <= CLK1 when state = "110" else CLK;
	CLK12 <= not CLK11;
	
	process (CLK11)
	begin
		if (CLK11'event and CLK11 = '1') then
			if state = "000" then--初期化
				RW <= '0';
				state <= "001";
				ADDR <= (others => '0');
			elsif state = "001" then--書き込み
				--一巡したら読み込み開始
				if ADDR = max  then
					state <= "010" ;
				else
					ADDR <= ADDR + 1;
				end if;
			elsif state = "010" then--読み出し準備
				RW <= '1';
				state <= "011";
				ADDR <= (others => '0');
			elsif state = "011" then--読み出し
				if ADDR = max then
					state <= "100" ;
					ADDR <= (others => '0');
				else
					ADDR <= ADDR + 1;
				end if;
				ADDRB0 <= ADDR;
				ADDRB1 <= ADDRB0;
				ADDRB2 <= ADDRB1;
				ADDRB3 <= ADDRB2;
			elsif state = "100" then--ゆっくり読み出し準備
				RW <= '1';
				state <= "110";
				ADDR <= (others => '0');
			elsif state = "110" then--ゆっくり読み出し
				if ADDR = max then
					state <= "110" ;
					ADDR <= (others => '0');
				else
					ADDR <= ADDR + 1;
				end if;
				ADDRB0 <= ADDR;
				ADDRB1 <= ADDRB0;
				ADDRB2 <= ADDRB1;
				ADDRB3 <= ADDRB2;
			elsif state = "111" then--おわり
				RW <= '1';
			end if;
		end if;
		
		--正しく読めているかの確認
		if (CLK11'event and CLK11 = '1') then
			if DATAOUT = (ADDRB3(11 downto 0))&(ADDRB3(19 downto 0)) then
				f <= '1';
			else
				f <='0';
			end if;
		end if;
		
		--正しく読めているかの確認
		if (CLK11'event and CLK11 = '1') then
			if (DATAOUT = (ADDRB3(11 downto 0))&(ADDRB3(19 downto 0))) then
				fr <= '1';
			elsif (fr = '1') and state = "011" then
				fr <='0';
			else
				fr <= fr;
			end if;
		end if;
	end process;
	
	--書き込むデータ
	DATAIN <= ADDR(11 downto 0)&ADDR(19 downto 0) when RW = '0' else
	"00000000000000000000000000000000";
	

	SRAMC : sram_controller port map(
		CLK11
		,CLK12
		,ADDR(19 downto 0)
		,DATAIN
		,DATAOUT
		,RW
	
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

end Behavioral;

