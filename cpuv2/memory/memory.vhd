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

entity memory is 
port (
    clk,rst,sramcclk,sramclk	: in	  std_logic;
    
    pc : in std_logic_vector(20 downto 0);
    inst : out std_logic_vector(31 downto 0);
    inst_ok : out std_logic;
    
    ls_flg : in std_logic_vector(1 downto 0);
    ls_addr : in std_logic_vector(31 downto 0);
    store_data : in std_logic_vector(31 downto 0);
    load_data : out std_logic_vector(31 downto 0);
    ls_ok : out std_logic;
    
	--SRAM
	SRAMAA : out  STD_LOGIC_VECTOR (19 downto 0)	--アドレス
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
     
end memory;
        

architecture synth of mem is
	type mem_state_t is (
		idle,inst_w1,inst_w2,inst_w3,inst_w4,inst_w5
	);
	signal mem_state : mem_state_t := idle;
	
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
		
    type ram_type is array (0 to 63) of std_logic_vector (31 downto 0); 

		
begin


	inst <= cache_out when cache_hit = '1' else
	DATAOUT when inst_state = inst_w4 else
	;
	
	inst_ok <= '1' when cache_hit = '1' else
	'1' when inst_state = inst_read_end else
	'0';
	
	cache_set <= '1' when inst_state = inst_read_end else
	'0';
	
	
	process(clk)
	begin
		if rising_edge(clk) then
		case mem_state is
			when idle =>
				if ls_flg = "11" then--Store
					mem_state <= inst_w1;
				elsif ls_flg = "10" then--Load
					mem_state <= inst_w1;
				elsif cache_hit = '0' then--Inst
					mem_state <= inst_w1;
				end if;
			when inst_w1 => mem_state <= inst_w2;
			when inst_w2 => mem_state <= inst_w3;
			when inst_w3 => mem_state <= inst_w4;
			when inst_w4 => mem_state <= inst_w5;
			when others => mem_state <= idle;
		end case;
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
