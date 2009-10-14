--　メモリ

-- @module : mem
-- @author : ksk
-- @date   : 2009/10/06



library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.instruction.all;

entity mem is 
port (
    clk,sramcclk,sramclk	: in	  std_logic;
    
    pc : in std_logic_vector(31 downto 0);
    ls_address : in std_logic_vector(31 downto 0);
    load_store : in std_logic_vector(1 downto 0);
    write_data : in std_logic_vector(31 downto 0);
    ok : in std_logic;
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
	type mem_state is (idle,init,
	inst,inst_w1,inst_w2,inst_w3,inst_w4,
	exec,exec_hit,wait_ok,store_w1,
	data_w1,data_w2,data_w3,data_w4,load_end
	);
	signal state : mem_state := idle;
	signal count : std_logic_vector(31 downto 0) := (others => '0');
	
	signal RW : std_logic := '0';
	signal DATAIN : std_logic_vector(31 downto 0) := (others => '0');
	signal DATAOUT : std_logic_vector(31 downto 0) := (others => '0');
	signal ADDR : std_logic_vector(19 downto 0) := (others => '0');
	
	signal cache_out : std_logic_vector(31 downto 0) := (others => '0');
	signal cache_hit : std_logic := '0';
	signal cache_set : std_logic := '0';
		
    type ram_type is array (0 to 31) of std_logic_vector (31 downto 0); 
	signal RAM : ram_type :=
--	(--fib10
--	op_li & "00000" & "00000" & x"0000",
--	op_li & "00000" & "00001" & x"0000",
--	op_li & "00000" & "00010" & x"0001",
--	op_li & "00000" & "00011" & x"000A",
--	
--	op_li & "00000" & "00100" & x"0001",
--	op_add & "00001" & "00010" & "00000" & "00000000000",
--	op_addi & "00010" & "00001" & x"0000",
--	op_addi & "00000" & "00010" & x"0000",
--	
--	op_addi & "00011" & "00011" & x"FFFF",
--	op_cmp & "00011" & "00100" & "00101" & "00000000000",
--	op_jmp & "00101" & "00011" & x"FFFB",-- -5\
--	--op_write & "00000" & "00000" & x"0000",
--	op_store & "00011" & "00000" & x"0000",
--
--
--	--op_store & "00011" & "00000" & x"0001",
--	--op_nop & "00000" & "00000" & x"0000",
--	op_load & "00011" & "00000" & x"0000",
--	op_write & "00000" & "00000" & x"0000",
--	--op_halt & "00000" & "00000" & x"0000",
--	--op_halt & "00000" & "00000" & x"0000",
--	op_halt & "00000" & "00000" & x"0000",
--	op_halt & "00000" & "00000" & x"0000"
--	);
--		(--rec fib 10
--op_li & "00000" & "00000" & x"0000",
--op_li & "00000" & "11110" & x"ffff",
--op_li & "00000" & "00011" & x"0001",
--op_load & "00000" & "00001" & x"0017",
--
--op_jal & "00000" & "00000" & x"0007",
--op_write & "00001" & "00000" & x"0000",
--op_halt & "00000" & "00000" & x"0000",
--op_cmp & "00001" & "00011" & "00010" & "00000000000",--fib
--
--op_jmp & "00010" & "00100" & x"000E",
--op_addi & "11110" & "11110" & x"FFFD",
--op_store & "11110" & "11111" & x"0002",
--op_store & "11110" & "00001" & x"0001",
--
--op_addi & "00001" & "00001" & x"FFFF",
--op_jal & "00000" & "00000" & x"0007",
--op_store & "11110" & "00001" & x"0000",
--op_load & "11110" & "00001" & x"0001",
--
--op_addi & "00001" & "00001" & x"FFFE",
--op_jal & "00000" & "00000" & x"0007",
--op_load & "11110" & "00010" & x"0000",
--op_add & "00001" & "00010" & "00001" & "00000000000",
--
--op_load & "11110" & "11111" & x"0002",
--op_addi & "11110" & "11110" & x"0003",
--op_jr & "11111" & "00000" & x"0000",
--"000000" & "00000" & "00000" & x"000A",
--
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001",
--
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001"
--	);
--			(--rec float fib 16
--"00101000000111100111111111111111",
--"00100100000000110000000000011010",
--"00100100000000010000000000011000",
--"00100100000001000000000000011010",
--
--"01000000110000000000000000000000",
--"00111000000000000000000000001000",
--"01000100001000000000000000000000",
--"01001100000000000000000000000000",
--
--"00110000001000110001000000000000",
--"00110100010001000000000000001110",
--"00000111110111101111111111111101",
--"00101111110111110000000000000010",
--
--"00101111110000010000000000000001",
--"00011000001001000000100000000000",
--"00111000000000000000000000001000",
--"00101111110000010000000000000000",
--
--"00100111110000010000000000000001",
--"00011000001001000000100000000000",
--"00111000000000000000000000001000",
--"00100111110000100000000000000000",
--
--"00010100001000100000100000000000",
--"00100111110111110000000000000010",
--"00000111110111100000000000000011",
--"00111111111000000000000000000000",
--
--"01000011000000000000000000000000",
--"00000000000000000000000000000000",
--"00111111000000000000000000000000",
--"01000000000000000000000000000000",
--
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001",
--op_halt & "00000" & "00000" & x"0001"
--	);
	
	(--io out 
--		op_li & "00000" & "00000" & x"0000",
--		op_li & "00000" & "10000" & x"0000",
--		op_li & "00000" & "10001" & x"000C",
--		op_li & "00000" & "10010" & x"0100",
--		
--		op_load & "10001" & "10100" & x"0000",
--		op_store & "10000" & "10100" & x"0000",
--		op_addi & "10000" & "10000" & x"0001",
--		op_addi & "10001" & "10001" & x"0001",
		
--		op_cmp & "10001" & "10010" & "10011" & "00000000000",
--		op_jmp & "10011" & "00110" & x"FFFB",
--		op_jr & "00000" & "00000" & x"0000",
--		op_halt & "00000" & "00000" & x"0001",
		
		op_li & "00000" & "00000" & x"0000",
		op_li & "00000" & "00010" & x"0100",
		op_li & "00000" & "00001" & x"0000",
		op_read & "00001" & "00001" & x"0000",
		
		op_cmp & "00001" & "00010" & "00011" & "00000000000",
		op_jmp & "00011" & "00001" & x"0002",-- if r1 > r2 then jump
		op_write & "00001" & "00000" & x"0000",
		op_jmp & "00000" & "00000" & x"FFFB",
		
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001",
		op_halt & "00000" & "00000" & x"0001"
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
	
	component cache is
	port  (
		clk : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit : out std_logic
	);
	end component;

begin
	
	ADDR <= count(19 downto 0) when state = init else
	pc(19 downto 0) when state = inst else
	ls_address(19 downto 0) when (state = exec) or (state = exec_hit) else
	(others => '0');
	
	with state select
	DATAIN <= RAM(conv_integer(count(4 downto 0))) when init,
	write_data when exec | exec_hit,
	(others => '0') when others;
	
	with state select
	 RW <= '0' when init,--初めのメモリ書き込み
	 (not load_store(0)) when exec | exec_hit,
	 '1' when others;

	with state select
	read_inst <= cache_out when exec_hit,
	DATAOUT when exec,
	sleep when others;
	
	read_data_ready <= '1' when state = load_end else
	'0';
	
	read_data <= DATAOUT when state = inst else
	"010101010101"&"0101010101"&"0101010101";
	
	cache_set <= '1' when state = exec else --ミスじのみセット
	'0';
	
	
	process(clk)
	begin
	if rising_edge(clk) then
		case state is
			when idle => --初期化？のせいでクロックがおかしくなるの対策（主にmodelsim）
				if count(4 downto 0) = "10000" then
					state <= init;
					count <= (others => '0');
				else
					count <= count + '1';
					state <= state;
				end if;
			when init =>
				if count(5 downto 0) = "100000" then
					state <= inst;
				else
					count <= count + '1';
					state <= state;
				end if;
			when inst =>
				if cache_hit = '1' then--ヒット時
					state <= exec_hit;
				else--ミス時
					state <= inst_w1;
				end if;
			when inst_w1 =>
				state <= inst_w2;
			when inst_w2 =>
				--state <= data;
				state <= inst_w3;
			when inst_w3 =>
				state <= exec;
			when exec_hit =>--キャッシュヒット
				if (load_store = "10") then--Loadだけ伸びる
					state <= data_w1;
				elsif (load_store = "11") then--Store
					state <= store_w1;
				elsif (ok = '0') then--FPU,IO待ち
					state <= wait_ok;
				else
					state <= inst;
				end if;
			when exec =>--キャッシュミス
				if (load_store = "10") then--Load
					state <= data_w1;
				elsif (load_store = "11") then--Store
					state <= store_w1;
				elsif (ok = '0') then--FPU,IO待ち
					state <= wait_ok;
				else
					state <= inst;
				end if;
			when store_w1 =>
				state <= inst;
			when data_w1 =>
				state <= data_w2;
			when data_w2 =>
				--state <= inst;
				state <= data_w3;
			when data_w3 =>
				state <= inst;
			when load_end =>
				state <= inst;
			when wait_ok =>--終わるまで待つ
				if ok = '1' then
					state <= inst;
				else
					state <= state;
				end if;
			when others =>
				state <= inst;
			end case;
		end if;
	end process;

	SRAMC : sram_controller port map(
		 sramcclk
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
	
	ICACHE:cache port map(
		clk
		,pc(19 downto 0)
		,DATAOUT
		,cache_set
		,cache_out
		,cache_hit
	);
	
end synth;









