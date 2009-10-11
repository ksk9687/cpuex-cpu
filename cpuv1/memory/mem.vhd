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
	inst,inst_w1,inst_w2,inst_w3,inst_w4,data,
	data_w1,data_w2,data_w3,data_w4,load_end
	);
	signal state : mem_state := idle;
	signal count : std_logic_vector(31 downto 0) := (others => '0');
	
	signal RW : std_logic := '0';
	signal DATAIN : std_logic_vector(31 downto 0) := (others => '0');
	signal DATAOUT : std_logic_vector(31 downto 0) := (others => '0');
	signal ADDR : std_logic_vector(19 downto 0) := (others => '0');
	
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
		(--rec fib 10
op_li & "00000" & "00000" & x"0000",
op_li & "00000" & "11110" & x"ffff",
op_li & "00000" & "00011" & x"0001",
op_load & "00000" & "00001" & x"0017",

op_jal & "00000" & "00000" & x"0007",
op_write & "00001" & "00000" & x"0000",
op_halt & "00000" & "00000" & x"0000",
op_cmp & "00001" & "00011" & "00010" & "00000000000",--fib

op_jmp & "00010" & "00100" & x"000E",
op_addi & "11110" & "11110" & x"FFFD",
op_store & "11110" & "11111" & x"0002",
op_store & "11110" & "00001" & x"0001",

op_addi & "00001" & "00001" & x"FFFF",
op_jal & "00000" & "00000" & x"0007",
op_store & "11110" & "00001" & x"0000",
op_load & "11110" & "00001" & x"0001",

op_addi & "00001" & "00001" & x"FFFE",
op_jal & "00000" & "00000" & x"0007",
op_load & "11110" & "00010" & x"0000",
op_add & "00001" & "00010" & "00001" & "00000000000",

op_load & "11110" & "11111" & x"0002",
op_addi & "11110" & "11110" & x"0003",
op_jr & "11111" & "00000" & x"0000",
"000000" & "00000" & "00000" & x"000A",

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
	ls_address(19 downto 0) when state = data else
	(others => '0');
	
	DATAIN <= RAM(conv_integer(count(4 downto 0))) when state = init else
	write_data when (state = data) else
	(others => '0');
	
	RW <= '0' when state = init else--w
	(not load_store(0)) when state = data else
	'1';
	
	read_inst <= DATAOUT when state = data else
	sleep;
	
	read_data_ready <= '1' when state = load_end else
	'0';
	
	read_data <= DATAOUT when state = inst else
	"010101010101"&"0101010101"&"0101010101";
	
	
	process(clk)
	begin
	if rising_edge(clk) then
		if state = idle then
			if count(4 downto 0) = "10000" then
				state <= init;
				count <= (others => '0');
			else
				count <= count + '1';
				state <= state;
			end if;
		elsif state = init then
			count <= count + '1';
			if count(5 downto 0) = "100000" then
				state <= inst;
			else
				state <= state;
			end if;
		elsif state = inst then 
			state <= inst_w1;
		elsif state = inst_w1 then 
			state <= inst_w2;
		elsif state = inst_w2 then 
			--state <= data;
			state <= inst_w3;
		elsif state = inst_w3 then 
			state <= data;
		elsif state = inst_w4 then
			state <= data;
		elsif state = data then
			if (load_store = "10") then--Loadだけ伸びる
				state <= data_w1;
			else
				state <= inst;
			end if;
		elsif state = data_w1 then
			state <= data_w2;
		elsif state = data_w2 then
			--state <= inst;
			state <= data_w3;
		elsif state = data_w3 then
			state <= inst;
		elsif state = load_end then
			state <= inst;
		end if;
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

end synth;









