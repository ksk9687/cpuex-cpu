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
end sram_controller;

architecture Behavioral of sram_controller is

  signal data_buf0 : std_logic_vector(31 downto 0);
  signal data_buf1 : std_logic_vector(31 downto 0);
  signal rw_buf0 :  std_logic := '0';
  signal rw_buf1 :  std_logic := '0';
  
  signal data_out : std_logic_vector(31 downto 0);
  
  --xor計算　パリティ用
  function br_xor(a: std_logic_vector) return std_logic is
    variable tmp:std_logic := '0';
  begin
    for i in a'range loop
      tmp := tmp xor a(i);
    end loop;
    return (tmp);
  end br_xor;
begin
  
	--固定する信号たち
  SRAMLBOA   <= '1';
  SRAMXOEA   <= '0';
  SRAMADVLDA <= '0';
  SRAMZZA    <= '0';
  SRAMCEA    <= '0';
  SRAMCLKMA0 <= sramclk;
  SRAMCLKMA1 <= sramclk;
  SRAMCEHA1X <= '0';
  SRAMCELA1X <= '0';
  SRAMCEA2   <= '1';
  SRAMCEA2X  <= '0';
  SRAMBWA    <= "0000";

  process (clk)
  begin
    if clk'event and clk = '1' then
      if rw_buf1 = '0' then
        --Write
		--2clock後にデータを渡す
        SRAMIOA  <= data_buf1;
        SRAMIOPA <=br_xor(data_buf1(31 downto 24))&
		br_xor(data_buf1(23 downto 16))&
		br_xor(data_buf1(15 downto 8))&
		br_xor(data_buf1(7 downto 0));
      else
        -- Read
        SRAMIOA  <= (others => 'Z');
        SRAMIOPA <= (others => 'Z');
      end if;

      SRAMAA  <= ADDR;
      SRAMRWA <= RW;

	  --バッファ
      rw_buf0    <= RW;
      rw_buf1    <= rw_buf0;
	  
      data_buf0    <= DATAIN;
      data_buf1    <= data_buf0;
	  
	   DATAOUT <= data_out;
    end if;
  end process;
  
  --sramに与えるクロックに合わせてsramの出力を保存
  process (sramclk)
  begin
    if sramclk'event and sramclk = '1' then
		data_out <= SRAMIOA;
	end if;
  end process;

end Behavioral;

