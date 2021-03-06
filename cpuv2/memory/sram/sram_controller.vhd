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
		
		;i_d    : in  std_logic_vector(2 downto 0)
		;ADDR    : in  std_logic_vector(19 downto 0)
		
		;DATAIN  : in  std_logic_vector(31 downto 0)
		;DATAOUT : out std_logic_vector(31 downto 0)
		
		;RW      : in  std_logic
		
		;i_d_buf    : out  std_logic_vector(2 downto 0)
		;ADDRBUF    : out  std_logic_vector(19 downto 0)
		
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

  signal data_buf0 : std_logic_vector(31 downto 0) := (others => '0');
  signal data_buf1 : std_logic_vector(31 downto 0) := (others => '0');
  signal data_buf2 : std_logic_vector(31 downto 0) := (others => '0');
  signal rw_buf0 :  std_logic := '0';
  signal rw_buf1 :  std_logic := '0';
  signal rw_buf2 :  std_logic := '0';
  
  signal rst :  std_logic := '0';
  
  signal i_d_buf0,i_d_buf1,i_d_buf2,i_d_buf3,i_d_buf4 : std_logic_vector(2 downto 0) := "000";
  signal ADDR_BUF0,ADDR_BUF1,ADDR_BUF2,ADDR_BUF3,ADDR_BUF4 : std_logic_vector(19 downto 0) := (others => '0');
  
  signal state,clk1,clk2 :std_logic := '0';
  signal data_out : std_logic_vector(31 downto 0) := (others => '0');
  
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
  
  ROC0 : ROC
    port map (
      O => rst);
  
  
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

	SRAMIOA <= data_buf2 when rw_buf2 = '0' and clk1 /= clk2 else
	(others => 'Z');
	
	SRAMIOPA <= "0000" when rw_buf2 = '0' and clk1 /= clk2 else
	(others => 'Z');
	
--	SRAMIOA <= data_buf2 when rw_buf2 = '0' else
--	(others => 'Z');
--	
--	SRAMIOPA <= "0000" when rw_buf2 = '0'  else
--	(others => 'Z');
	

	i_d_buf <= i_d_buf3;
	ADDRBUF <= ADDR_BUF3;

  process (clk)
  begin
  if rising_edge(clk) then
    	clk1 <= not clk2;
  end if;
  end process;
  
  process (sramclk)
  begin
  if rising_edge(sramclk) then
    	clk2 <= clk1;
  end if;
  end process;
   
   SRAMAA <= ADDR_BUF0;
   SRAMRWA <= rw_buf0;

  process (clk,rst)
  begin
  	if rst = '1' then
  		rw_buf0 <= '1';
  		rw_buf1 <= '1';
  		rw_buf2 <= '1';
  		i_d_buf0 <= (others => '0');
  		i_d_buf1 <= (others => '0');
  		i_d_buf2 <= (others => '0');
  		i_d_buf3 <= (others => '0');
  		i_d_buf4 <= (others => '0');
  		ADDR_BUF0 <= (others => '0');
  		ADDR_BUF1 <= (others => '0');
  		ADDR_BUF2 <= (others => '0');
  		ADDR_BUF3 <= (others => '0');
  		ADDR_BUF4 <= (others => '0');
    elsif rising_edge(clk) then

	  --バッファ
      rw_buf0    <= RW;
      rw_buf1    <= rw_buf0;
      rw_buf2    <= rw_buf1;
	  
      data_buf0    <= DATAIN;
      data_buf1    <= data_buf0;
      data_buf2    <= data_buf1;
      
      i_d_buf0 <= i_d;
      i_d_buf1 <= i_d_buf0;
      i_d_buf2 <= i_d_buf1;
      i_d_buf3 <= i_d_buf2;
      
      ADDR_BUF0 <= ADDR;
      ADDR_BUF1 <= ADDR_BUF0;
      ADDR_BUF2 <= ADDR_BUF1;
      ADDR_BUF3 <= ADDR_BUF2;
      
	  
	  DATAOUT <= data_out;
	end if;
  end process;
 
  
  --sramに与えるクロックに合わせてsramの出力を保存
  process (sramclk)
  begin
    if rising_edge(sramclk) then
		data_out <= SRAMIOA;
		--DATAOUT <= SRAMIOA;
	end if;
  end process;

end Behavioral;

