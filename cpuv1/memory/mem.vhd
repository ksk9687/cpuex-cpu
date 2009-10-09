

-- @module : mem
-- @author : ksk
-- @date   : 2009/10/06

---SRAMを実装した場合の予定
-- 二倍速
-- 一回目は 命令フェッチ
-- 二回目は ロードストア

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.instruction.all;

entity mem is 
port (
    clk,fastclk,sramclk	: in	  std_logic;
    
    pc : in std_logic_vector(31 downto 0);
    ls_address : in std_logic_vector(31 downto 0);
    load_store : in std_logic;
    write_data : in std_logic_vector(31 downto 0);
    read_inst,read_data : out std_logic_vector(31 downto 0);
    read_data_ready : out std_logic
    
    
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
     
     constant sleep : std_logic_vector(31 downto 0):= op_halt&"00"&"00000000"&"00000000"&"00000000";
end mem;
        

architecture synth of mem is
	type mem_state is (init,
	inst,inst_w1,inst_w2,inst_w3,inst_w4,
	data,data_w1,data_w2,data_w3,data_w4,write_end
	);
	signal state : mem_state := init;
	signal count : std_logic_vector(31 downto 0) := (others => '0');
	
	signal RW : std_logic := '0';
	signal DATAIN : std_logic_vector(31 downto 0) := (others => '0');
	signal DATAOUT : std_logic_vector(31 downto 0) := (others => '0');
	signal ADDR : std_logic_vector(19 downto 0) := (others => '0');
	
    type ram_type is array (0 to 15) of std_logic_vector (31 downto 0); 
	signal RAM : ram_type :=
	(--fib10
	op_li & "00000" & "00000" & x"0000",
	op_li & "00000" & "00001" & x"0000",
	op_li & "00000" & "00010" & x"0001",
	op_li & "00000" & "00011" & x"000A",
	
	op_li & "00000" & "00100" & x"0001",
	op_add & "00001" & "00010" & "00000" & "00000000000",
	op_addi & "00010" & "00001" & x"0000",
	op_addi & "00000" & "00010" & x"0000",
	
	op_addi & "00011" & "00011" & x"FFFF",
	op_cmp & "00011" & "00100" & "00101" & "00000000000",
	op_jmp & "00101" & "00011" & x"FFFB",-- -5
	op_write & "00000" & "00000" & x"0000",
	
	op_halt & "00000" & "00000" & x"0000",
	op_halt & "00000" & "00000" & x"0000",
	op_halt & "00000" & "00000" & x"0000",
	op_halt & "00000" & "00000" & x"0000"
	);
	
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
begin

	--とりあえず分散RAMをメモリとして利用する
	  
--	--データ
--	process (clk)
--	begin
--	    if rising_edge(clk) then
--	        if load_store = '1' then
--	            RAM(conv_integer(ls_address(3 downto 0))) <= write_data;
--	        end if;
--	    end if;
--	end process;
--	read_data <= RAM(conv_integer(ls_address(3 downto 0)));
--	
--	-- 命令
--	read_inst <= RAM(conv_integer(pc(3 downto 0)));


	
	ADDR <= count(19 downto 0) when state = init else
	pc(19 downto 0) when state = inst else
	(others => '0');
	
	DATAIN <= RAM(conv_integer(count(3 downto 0))) when state = init else
	write_data when (state = data) else
	(others => '0');
	
	RW <= '0' when state = init else
	(not load_store) when state = data else
	'1';		
	
	read_inst <= DATAOUT when state = data else
	sleep;
	
	read_data_ready <= '1' when state = data_w4 else
	'0';
	
	process(fastclk)
	begin
	if rising_edge(fastclk) then
		if state = init then
			if count(4 downto 0) = "10000" then
				state <= inst;
			else
				state <= state;
			end if;
		elsif state = inst then 
			state <= inst_w1;
		elsif state = inst_w1 then 
			state <= inst_w2;
		elsif state = inst_w2 then 
			state <= inst_w3;
		elsif state = inst_w3 then 
			state <= data;
		elsif state = inst_w4 then 
			state <= data;
		elsif state = data then
			if (load_store = '1') then--STOREだけ伸びる
				state <= data_w1;
			else
				state <= inst;
			end if;
		elsif state = data_w1 then
			state <= data_w2;
		elsif state = data_w2 then
			state <= data_w3;
		elsif state = data_w3 then
			state <= write_end;
		elsif state = write_end then
			state <= inst;
		end if;
		count <= count + '1';
	end if;
	end process;

	SRAMC : sram_controller port map(
		 fastclk
		,sramclk
		,ADDR
		,DATAIN
		,DATAOUT
		,RW
		,SRAMAA,SRAMIOA,SRAMIOPA
		,SRAMRWA,SRAMBWA
		,SRAMCLKMA0,SRAMCLKMA1
		,SRAMADVLDA,SRAMCEA
		,SRAMCELA1X,SRAMCEHA1X,SRAMCEA2X,SRAMCEA2
		,SRAMLBOA,SRAMXOEA,SRAMZZA
	);

end synth;








