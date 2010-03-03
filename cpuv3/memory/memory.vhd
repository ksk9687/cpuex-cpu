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
library UNISIM;
use UNISIM.VComponents.all;

entity memory is 
    Port (
    clk,sramcclk,sramclk,clkfast	: in	  std_logic;
    
    pc : in std_logic_vector(14 downto 0);
    inst : out std_logic_vector(31 downto 0);
    jmp_flgs : out std_logic_vector(2 downto 0);
    inst_ok : out std_logic;
    
    ls_flg : in std_logic_vector(1 downto 0);
    ls_addr : in std_logic_vector(19 downto 0);
    store_data : in std_logic_vector(31 downto 0);
    load_data : out std_logic_vector(31 downto 0);
    ls_ok : out std_logic;

		--SRAM
    XE1 : out STD_LOGIC; -- 0
    E2A : out STD_LOGIC; -- 1
    XE3 : out STD_LOGIC; -- 0
    ZZA : out STD_LOGIC; -- 0
    XGA : out STD_LOGIC; -- 0
    XZCKE : out STD_LOGIC; -- 0
    ADVA : out STD_LOGIC; -- we do not use (0)
    XLBO : out STD_LOGIC; -- no use of ADV, so what ever
    ZCLKMA : out STD_LOGIC_VECTOR(1 downto 0); -- clk
    XFT : out STD_LOGIC; -- FT(0) or pipeline(1)
    XWA : out STD_LOGIC; -- read(1) or write(0)
    XZBE : out STD_LOGIC_VECTOR(3 downto 0); -- write pos
    ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
    ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
    ZD : inout STD_LOGIC_VECTOR(31 downto 0) -- bus
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
	
	signal RW,rst : std_logic := '0';
	signal DATAIN : std_logic_vector(31 downto 0) := (others => '0');
	signal DATAOUT,ls_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal pc_buf,set_addr,pc_buf_p1 : std_logic_vector(13 downto 0) := (others => '0');
	
	signal cache_out,cache_out_buf,store_data_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal cache_hit,cache_hit_b,ipref,dpref : std_logic := '0';
	signal cache_set,cache_set_tag : std_logic := '0';

	signal dcache_out : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_in : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_hit,cache_hit_tag,dcache_hit_buf,dcache_hit_tag : std_logic := '0';
	signal dcache_set,dcache_read : std_logic := '0';
	signal dcache_addr,addr_out,d_set_addr,ADDR : std_logic_vector(19 downto 0) := (others => '0');
	signal ls_addr_buf,ls_addr_buf_p1,ls_addr_buf_pref : std_logic_vector(19 downto 0) := (others => '0');
	signal dac,ls_ok_p : std_logic := '1';
	signal rom_access : std_logic := '0';
    type ram_type is array (0 to 63) of std_logic_vector (31 downto 0); 

	signal ls_buf0,ls_buf1,ls_buf2,ls_buf3,ls_buf4 : std_logic_vector(1 downto 0) := "00";
	signal inst_select : std_logic_vector(2 downto 0) := (others => '0');
	signal i_mem_req,i_halt : std_logic := '0';
	
	signal i_d_out,i_d_in : std_logic_vector(2 downto 0) := "000";
	signal jmp_flgs_ir,jmp_flgs_ic : std_logic_vector(2 downto 0) := "000";

	
	
begin

  	ROC0 : ROC port map (O => rst);

	inst_ok <= 	cache_hit or rom_access;
	inst <= inst_i;
	
	jmp_flgs <= jmp_flgs_ic when rom_access = '0' else
	jmp_flgs_ir;
	inst_i <= cache_out when rom_access = '0' else
	irom_inst;
	
	ls_ok <= --'1' when ls_addr = addr_out else 
	dcache_hit;
	load_data <= --DATAOUT when ls_addr = addr_out else
	dcache_out;
	
	cache_set_tag <= i_d_out(2);
	cache_set <= i_d_out(1);
	set_addr <= addr_out(13 downto 0);
	
	--データキャッシュアドレス
	d_set_addr <= ls_addr when ls_flg(0) = '1' else--store,missload
	 addr_out;
	--データキャッシュデータ
	dcache_in <= store_data  when ls_flg(0) = '1' else--store,missload
	DATAOUT;--Store

	--データキャッシュセット　MissLoad,Store
	dcache_set <= i_d_out(0) or (ls_flg(0));
	
	
	--SRAMアドレス
	ADDR <= ls_addr_buf when dac = '1' else
	"000000"&pc_buf;
	
	--SRAM書き込みデータ
	DATAIN <= store_data_buf;
	
	--SRAM読み書き　1:Read 0:Write
	RW <= not ls_buf0(0);
	
	dac <= ls_buf0(0) or (ls_buf0(1) and (not dcache_hit_tag));
	-- 
	--ICACHE FILL
	i_d_in(2) <= '1' when i_mem_state = inst_w7 else '0';
	
	--ROMでない　かつ　Iキャッシュミス　かつ　Dアクセスでない
	i_d_in(1) <=
	((not rom_access) and ((not cache_hit_tag) or ipref)) and (not dac);
	
	--DCACHE FILL
	---DmissLoad
	i_d_in(0) <= ls_buf0(1) and (not dcache_hit_tag);
	--ls_buf0(1) and (not ls_buf0(0)) and ((not dcache_hit) or dpref);
	
	pc_buf_p1 <= pc_buf(13 downto 3)&(pc_buf(2 downto 0) + '1') when (i_mem_state /= inst_w7) and i_d_in(1) = '1' else
	pc_buf when (i_mem_state /= idle) and ((i_mem_state /= inst_w7) or i_d_in(1) = '0') else
	pc(13 downto 0);
	
	
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
					if i_d_in(1) = '1' then
						ipref <= '0';
						i_mem_state <= idle;
					end if;
				when others =>
					ipref <= '0';
					i_mem_state <= idle;
			end case;
			
			pc_buf <= pc_buf_p1;
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
		elsif rising_edge(clk) then
			case d_mem_state is
				when idle =>
					if i_d_in(0) = '1' then--miss Load
						d_mem_state <= data_w5;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
					else
						ls_addr_buf <= ls_addr;
						ls_buf0 <= ls_flg;
					end if;
				when data_w1 =>
						d_mem_state <= data_w2;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
				when data_w2	=>
						d_mem_state <= data_w5;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
				when data_w3	=>
						d_mem_state <= data_w4;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
				when data_w4	=>
						d_mem_state <= data_w5;
						ls_buf0 <= "10";
						ls_addr_buf <= ls_addr_buf_p1;
				when data_w5	=>
					ls_buf0 <= "00";
					if dcache_hit = '1' then
						d_mem_state <= idle;
					end if;
				when others	=>
					ls_buf0 <= ls_flg;
					d_mem_state <= idle;
				end case;
						
			--ls_buf0 <= ls_flg;
			--ls_addr_buf <= ls_addr;
			
			store_data_buf <= store_data;
		end if;
	end process;
	
	IROM0:IROM port map(
		clk
		,pc(13 downto 0)
		,irom_inst
		,jmp_flgs_ir
	);
	SRAMC : sram_controller port map(
		 sramcclk
		,sramclk
		,ADDR
		,DATAIN
		,DATAOUT
		,RW
		,i_d_in
		,i_d_out
		,addr_out
		,
      XE1,
      E2A,
      XE3,
      ZZA,
      XGA,
      XZCKE,
      ADVA,
      XLBO,
      ZCLKMA,
      XFT,
      XWA,
      XZBE,
      ZA,
      ZDP,
      ZD
	);
	
	ICACHE: block_cache port map(
		clk,clk
		,pc(13 downto 0)
		,set_addr
		,DATAOUT
		,cache_set,cache_set_tag
		,cache_out
		,jmp_flgs_ic
		,cache_hit
		,cache_hit_tag
	);
	
	
	DCACHE0: block_s_dcache port map(
		clk,clkfast
		,ls_addr
		,d_set_addr
		,dcache_in
		,dcache_set
		,dcache_out
		,dcache_hit
		,dcache_hit_tag
	);
end synth;
