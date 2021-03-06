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
	type mem_state is (
	idle,load_cache_check,
	inst,inst_w1,inst_w2,inst_w3,inst_w4,inst_load,
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

	signal dcache_out : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_in : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_hit : std_logic := '0';
	signal dcache_set : std_logic := '0';
	signal dcache_addr : std_logic_vector(19 downto 0) := (others => '0');
	signal addr_buf : std_logic_vector(19 downto 0) := (others => '0');
		
    type ram_type is array (0 to 15) of std_logic_vector (31 downto 0); 
	signal RAM : ram_type :=
	(
	op_li& "00000" & "01110" & x"0100",
	op_read&"00010" & "00010" & x"0000",
	op_cmp&"00010" & "01110" & "00110" & "000" & x"00",
	op_jmp&"00110" & "00001" & x"fffE",
	
	op_li& "00000" & "00000" & x"0000",
	op_li& "00000" & "01101" & x"0000",
	op_load& "01101" & "00001" & x"0000",
	op_write&"00001" & "00010" & x"0000",
	
	op_cmp&"00010" & "00000" & "00110" & "000" & x"00",
	op_jmp&"00110" & "00011" & x"fffE",
	op_addi& "01101" & "01101" & x"0001",
	op_cmp&"01101" & "01110" & "00110" & "000" & x"00",
	
	op_jmp&"00110" & "00001" & x"0002",
	op_jmp&"00110" & "00000" & x"fff9",
	op_halt&"11111" & "00000" & x"0000",
	op_halt&"11111" & "00000" & x"0000"
	);
--		(--read program
--op_li& "00000" & "00000" & x"0000",
--op_li& "00000" & "01111" & x"0000",
--op_li& "00000" & "01110" & x"0100",
--op_li& "00000" & "01101" & x"0000",
--
--op_li& "00000" & "01100" & x"00aa",
--op_jal& "00" & x"10" & x"0010",
----op_li& "00000" & "00001" & x"001A",
--op_addi& "00001" & "01011" & x"0000",
--op_cmp& "01011" & "00000" & "00010" & "000" & x"00",
--
--op_jmp& "00010" & "00100" & x"0006",
--op_jal& "00" & x"10" & x"0010",
--op_store& "01101" & "00001" & x"0000",
--op_addi& "01101" & "01101" & x"0001",
--
--op_addi& "01011" & "01011" & x"ffff",
--op_jmp& "00000" & "00000" & x"fffA",
--op_write& "01100" & "11100" & x"0000",
--op_jr& "00000" & "00000" & x"0000",
--
----readword
--op_read&"00010" & "00010" & x"0000",
--op_cmp&"00010" & "01110" & "00110" & "000" & x"00",
--op_jmp&"00110" & "00001" & x"fffE",
--
--op_read&"00011" & "00011" & x"0000",
--op_cmp&"00011" & "01110" & "00110" & "000" & x"00",
--op_jmp&"00110" & "00001" & x"fffE",
--
--op_read&"00100" & "00100" & x"0000",
--op_cmp&"00100" & "01110" & "00110" & "000" & x"00",
--op_jmp&"00110" & "00001" & x"fffE",
--
--op_read&"00101" & "00101" & x"0000",
--op_cmp&"00101" & "01110" & "00110" & "000" & x"00",--1A
--op_jmp&"00110" & "00001" & x"fffE",
--
--op_sll& "00010" & "00010" & x"0018",
--op_sll& "00011" & "00011" & x"0010",
--op_sll& "00100" & "00100" & x"0008",
--op_li& "00000" & "00001" & x"0000",
--
--op_add&"00001" & "00010" & "00001" & "000" & x"00",
--op_add&"00001" & "00011" & "00001" & "000" & x"00",
--op_add&"00001" & "00100" & "00001" & "000" & x"00",
--op_add&"00001" & "00101" & "00001" & "000" & x"00",
--
--op_jr&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000",
--op_halt&"11111" & "00000" & x"0000"
--		);
		
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
	
	component dcache is
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
	
	ADDR <= pc(19 downto 0) when state = inst or state = inst_load or state = load_cache_check else
	ls_address(19 downto 0) when (state = exec) or (state = exec_hit) else
	(others => '0');
	
	with state select
	DATAIN <= write_data when exec | exec_hit,
	(others => '0') when others;
	
	with state select
	 RW <= (not load_store(0)) when exec | exec_hit,
	 '1' when others;
	 
	read_inst <= RAM(conv_integer(pc(3 downto 0))) when pc(20) = '1' and state = exec else
	cache_out when state = exec_hit else
	DATAOUT when state = exec else
	sleep;
	
	read_data_ready <= '1' when (state = load_cache_check and dcache_hit = '1') or state = inst_load else
	'0';
	
	read_data <= DATAOUT when state = inst_load else
	dcache_out when state = load_cache_check else
	"010101010101"&"0101010101"&"0011001100";
	
	cache_set <= 
	'0' when pc(20) = '1' else
	'1' when state = exec else --ミスじのみセット
	'0';
	
	dcache_set <= '1' when (load_store = "11") or state = inst_load else '0';--store,load
	
	dcache_in <= write_data when (load_store(1) = '1') else DATAOUT;
	
	dcache_addr <= ls_address(19 downto 0) when (load_store(1) = '1') else addr_buf;
	
	process(clk)
	begin
	if rising_edge(clk) then
		case state is
			when idle => --初期化？のせいでクロックがおかしくなるの対策（主にmodelsim）
				if count(4 downto 0) = "10000" then
					state <= inst;
					count <= (others => '0');
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
			when inst_load =>
				if cache_hit = '1' then--ヒット時
					state <= exec_hit;
				else--ミス時
					state <= inst_w1;
				end if;
			when load_cache_check =>
				if dcache_hit = '1' then--DCacheHit
					if cache_hit = '1' then--ヒット時
						state <= exec_hit;
					else--ミス時
						state <= inst_w1;
					end if;
				else--DCacheMiss
					state <= data_w2;
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
					state <= load_cache_check;
					addr_buf <= ls_address(19 downto 0);
				elsif (load_store = "11") then--Store
					state <= inst;
				elsif (ok = '0') then--ALU,FPU,IO待ち
					state <= wait_ok;
				else
					state <= inst;
				end if;
			when exec =>--キャッシュミス
				if (load_store = "10") then--Load
					state <= load_cache_check;
					addr_buf <= ls_address(19 downto 0);
				elsif (load_store = "11") then--Store
					state <= inst;
				elsif (ok = '0') then--ALU,FPU,IO待ち
					state <= wait_ok;
				else--おわり
					state <= inst;
				end if;
			when data_w1 =>
			
			when data_w2 =>
				state <= data_w3;
			when data_w3 =>
				state <= inst_load;
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
	
	DCACHE0:dcache port map(
		clk
		,dcache_addr
		,dcache_in
		,dcache_set
		,dcache_out
		,dcache_hit
	);
end synth;
