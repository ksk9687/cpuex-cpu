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
    clk,rst,sramcclk,sramclk,clkfast	: in	  std_logic;
    
    pc : in std_logic_vector(14 downto 0);
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
		idle,inst_w1,inst_w2,inst_w3,inst_w4,inst_w5,inst_w6,inst_w7
	);
	signal i_mem_state : i_mem_state_t := idle;
	
	type d_mem_state_t is (
		idle,data_w1,data_w2,data_w3,data_w4,data_w5,data_w6,data_w7,data_w8,data_w9
	);
	signal d_mem_state : d_mem_state_t := idle;
	
	signal irom_inst,inst_buf,inst_i: std_logic_vector(31 downto 0) := (others => '0');
	signal count : std_logic_vector(31 downto 0) := (others => '0');
	
	signal RW : std_logic := '0';
	signal DATAIN : std_logic_vector(31 downto 0) := (others => '0');
	signal DATAOUT,ls_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal pc_buf,set_addr,pc_buf_p1 : std_logic_vector(13 downto 0) := (others => '0');
	
	signal cache_out,cache_out_buf,store_data_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal cache_hit,cache_hit_b,ipref,dpref : std_logic := '0';
	signal cache_set : std_logic := '0';

	signal dcache_out : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_in : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_hit,dcache_hit_buf : std_logic := '0';
	signal dcache_set,dcache_read : std_logic := '0';
	signal dcache_addr,addr_out,d_set_addr,ADDR : std_logic_vector(19 downto 0) := (others => '0');
	signal ls_addr_buf,ls_addr_buf_p1,ls_addr_buf_pref : std_logic_vector(19 downto 0) := (others => '0');
	signal dac,ls_ok_p : std_logic := '1';
	signal rom_access : std_logic := '0';
    type ram_type is array (0 to 63) of std_logic_vector (31 downto 0); 

	signal ls_buf0,ls_buf1,ls_buf2,ls_buf3,ls_buf4 : std_logic_vector(1 downto 0) := "00";
	signal inst_select : std_logic_vector(2 downto 0) := (others => '0');
	signal i_mem_req,i_halt : std_logic := '0';
	
	signal i_d_out,i_d_in : std_logic_vector(1 downto 0) := "00";

	
	
begin
	inst_ok <= 	cache_hit or rom_access;
	inst <= inst_i;
	
	inst_i <= cache_out when rom_access = '0' else
	irom_inst;
	
	ls_ok <= --'1' when ls_addr = addr_out else 
	dcache_hit;
	load_data <= --DATAOUT when ls_addr = addr_out else
	dcache_out;
	
	cache_set <= i_d_out(1);
	set_addr <= addr_out(13 downto 0);
	
	--データキャッシュアドレス
	d_set_addr <= addr_out when i_d_out(0) = '1' else--missload
	ls_addr;
	--データキャッシュデータ
	dcache_in <= DATAOUT when i_d_out(0) = '1' else--missload
	store_data;--Store

	--データキャッシュセット　MissLoad,Store
	dcache_set <= i_d_out(0) or (ls_flg(0));
	
	
	--SRAMアドレス
	ADDR <= ls_addr_buf when dac = '1' else
	"000000"&pc_buf;
	
	--SRAM書き込みデータ
	DATAIN <= store_data_buf;
	
	--SRAM読み書き　1:Read 0:Write
	RW <= '0' when ls_buf0 = "11" else
	'1';
	
	dac <= 
	(ls_buf0(1) and (ls_buf0(0) or (not dcache_hit)));
	--ls_buf0(1) and (ls_buf0(0) or ((not dcache_hit) or dpref));
	--ICACHE FILL
	--ROMでない　かつ　Iキャッシュミス　かつ　Dアクセスでない
	i_d_in(1) <=
	(not rom_access) and ((not cache_hit) or ipref) and (not (ls_buf0(1) and (ls_buf0(0) or (not dcache_hit))));
	
	--DCACHE FILL
	---DmissLoad
	i_d_in(0) <= 
	ls_buf0(1) and (not ls_buf0(0)) and (not dcache_hit);
	--ls_buf0(1) and (not ls_buf0(0)) and ((not dcache_hit) or dpref);
	
	pc_buf_p1 <= pc_buf + '1';
	
	IMEM : process(clk,rst)
	begin
		if rst = '1' then
			i_mem_state <= idle;
			ipref <= '0';
			rom_access <= '1';
		elsif rising_edge(clk) then
			case i_mem_state is
				when idle		=>
					if i_d_in(1) = '1' then
						ipref <= '1';
						i_mem_state <= inst_w1;
					else
						ipref <= '0';
					end if;
				when inst_w1	=>
					if i_d_in(1) = '1' then
						i_mem_state <= inst_w2;
					end if;
				when inst_w2	=>
					if i_d_in(1) = '1' then
						i_mem_state <= inst_w3;
					end if;
				when inst_w3	=>
					if i_d_in(1) = '1' then
						i_mem_state <= inst_w4;
					end if;
				when inst_w4	=>
					if i_d_in(1) = '1' then
						i_mem_state <= inst_w5;
					end if;
				when inst_w5	=>
					if i_d_in(1) = '1' then
						i_mem_state <= inst_w6;
					end if;
				when inst_w6	=>
					if i_d_in(1) = '1' then
						i_mem_state <= inst_w7;
					end if;
				when inst_w7	=>
					ipref <= '0';
					i_mem_state <= idle;
				when others =>
					ipref <= '0';
					i_mem_state <= idle;
			end case;
			
			if (i_mem_state /= inst_w7) and (i_d_in(1) = '1') then
				pc_buf <= pc_buf_p1;
			else
				pc_buf <= pc(13 downto 0);
			end if;	
			--ipref <= '0';
			--pc_buf <= pc(13 downto 0);
			rom_access <= pc(14);
		end if;
	end process;
	
	ls_addr_buf_p1 <= ls_addr_buf + '1';
	
	DMEM : process(clk,rst)
	begin
		if rst = '1' then
			d_mem_state <= idle;
			ls_buf0 <= "00";
			dpref <= '0';
		elsif rising_edge(clk) then
			case d_mem_state is
				when idle		=>
					if i_d_in(0) = '1' then--miss Load
						d_mem_state <= data_w1;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
					else
						ls_addr_buf <= ls_addr;
						ls_buf0 <= ls_flg;
					end if;
				when data_w1	=>
						d_mem_state <= data_w2;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
				when data_w2	=>
						d_mem_state <= data_w3;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
				when data_w3	=>
					ls_buf0 <= "00";
					if dcache_hit = '1' then
						d_mem_state <= idle;
					end if;
				when others	=>
					ls_buf0 <= ls_flg;
					d_mem_state <= idle;
				end case;
			
			dpref <= '0';
			--ls_buf0 <= ls_flg;
			
			store_data_buf <= store_data;
		end if;
	end process;
	
	IROM0:IROM port map(
		clk
		,pc(13 downto 0)
		,irom_inst
	);
	SRAMC : sram_controller port map(
		 sramcclk
		,sramclk
		,i_d_in
		,ADDR
		,DATAIN
		,DATAOUT
		,RW
		,i_d_out,addr_out
		,SRAMAA,SRAMIOA,SRAMIOPA
		,SRAMRWA,SRAMBWA
		,SRAMCLKMA0,SRAMCLKMA1
		,SRAMADVLDA,SRAMCEA
		,SRAMCELA1X,SRAMCEHA1X,SRAMCEA2X,SRAMCEA2
		,SRAMLBOA,SRAMXOEA,SRAMZZA
	);
	
	ICACHE: block_cache port map(
		clk,clk
		,pc(13 downto 0)
		,set_addr
		,DATAOUT
		,cache_set
		,cache_out
		,cache_hit
	);
	
	
	DCACHE0: block_dcache port map(
		clk,clk
		,ls_addr
		,d_set_addr
		,dcache_in
		,dcache_set
		,dcache_out
		,dcache_hit
	);
end synth;
