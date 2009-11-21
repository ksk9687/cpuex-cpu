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

use work.SuperScalarComponents.all; 
entity memory is 
port (
    clk,rst,sramcclk,sramclk,stall	: in	  std_logic;
    
    pc : in std_logic_vector(20 downto 0);
    inst : out std_logic_vector(31 downto 0);
    inst_ok : out std_logic;
    
    ls_flg : in std_logic_vector(1 downto 0);
    ls_addr : in std_logic_vector(19 downto 0);
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
        

architecture synth of memory is
	type i_mem_state_t is (
		idle,inst_w1,inst_w2,inst_w3,inst_w4,inst_w5
	);
	signal i_mem_state : i_mem_state_t := idle;
	
	type d_mem_state_t is (
		idle,data_w1,data_w2,data_w3,data_w4,data_w5
	);
	signal d_mem_state : d_mem_state_t := idle;
	
	signal irom_inst,inst_buf,inst_i: std_logic_vector(31 downto 0) := (others => '0');
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
	signal ls_addr_buf : std_logic_vector(19 downto 0) := (others => '0');
		
    type ram_type is array (0 to 63) of std_logic_vector (31 downto 0); 

	signal inst_select : std_logic_vector(2 downto 0) := (others => '0');
		
begin
	--!@TODO 少なくともデータキャッシュはおかしい。
	inst <= inst_i;
	with inst_select select
	inst_i <= 
	inst_buf when "100",
	irom_inst when "000",
	cache_out when "001",
	DATAOUT when "010",
	op_sleep&"00"&x"000000" when others;
	
--	inst_ok <= 
--	'1' when pc(20) = '1' else
--	'1' when cache_hit = '1' else
--	'1' when i_mem_state = inst_w4 else
--	'0';

	inst_ok <= '0' when inst_select = "11" else
	'1';
	
	ls_ok <= '1' when ls_flg = "11"  else
	 '1' when dcache_hit = '1' else
	 '1' when d_mem_state = data_w4 else
	 '0';
	
	cache_set <= '1' when i_mem_state = inst_w4 else
	'0';
	
	--データキャッシュアドレス
	dcache_addr <= ls_addr_buf when d_mem_state = data_w4 else
	ls_addr;--Store
	--データキャッシュデータ
	dcache_in <= DATAOUT when d_mem_state = data_w4 else--missload
	store_data;--Store
	--データキャッシュセット　MissLoad,Store
	dcache_set <= '1' when d_mem_state = data_w4 or ls_flg = "11" else
	'0';
	
	--SRAMアドレス
	ADDR <= ls_addr when (ls_flg(1) = '1' and (dcache_hit = '0' or ls_flg(0) = '1')) else
	pc(19 downto 0);
	--SRAM書き込みデータ
	DATAIN <= store_data when ls_flg = "11" else
	(others => '0');
	--SRAM読み書き　1:Read 0:Write
	RW <= '0' when ls_flg = "11" else
	'1';
	
	process(clk)
	begin
		if rising_edge(clk) then
			inst_buf <= inst_i;
			if stall = '1' then
				inst_select <= "100";
			elsif pc(20) = '1' then
				inst_select <= "000";
			elsif cache_hit = '1' then
				inst_select <= "001";
			elsif i_mem_state = inst_w4 then
				inst_select <= "010";
			else
				inst_select <= "000";
			end if;
		
		end if;
	end process;

	
	IMEM_STATE : process(clk)
	begin
		if rising_edge(clk) then
		case i_mem_state is
			when idle =>
				if (ls_flg(1) = '1' and (dcache_hit = '0' or ls_flg(0) = '1')) then--Loadキャッシュミス or Store
					i_mem_state <= idle;
				elsif cache_hit = '0' then--Instメモリアクセス要求があり、キャッシュミス
					i_mem_state <= inst_w1;
				else
					i_mem_state <= idle;
				end if;
			when inst_w1 => i_mem_state <= inst_w2;
			when inst_w2 => i_mem_state <= inst_w3;
			when inst_w3 => i_mem_state <= inst_w4;
			when inst_w4 => i_mem_state <= idle;
			when others => i_mem_state <= idle;
		end case;
		end if;
	end process;


	DMEM_STATE : process(clk)
	begin
		if rising_edge(clk) then
		case d_mem_state is
			when idle =>
				if ls_flg = "11" then--Store
					d_mem_state <= idle;
				elsif (ls_flg(1) = '1') and (dcache_hit = '0') then--Loadキャッシュミス
					d_mem_state <= data_w1;
					ls_addr_buf <= ls_addr;
				end if;
			when data_w1 => d_mem_state <= data_w2;
			when data_w2 => d_mem_state <= data_w3;
			when data_w3 => d_mem_state <= data_w4;
			when data_w4 => d_mem_state <= idle;
			when others => d_mem_state <= idle;
		end case;
		end if;
	end process;
	
	IROM0:IROM port map(
		clk
		,pc(19 downto 0)
		,irom_inst
	);
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
