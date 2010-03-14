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
    
    pc : in std_logic_vector(11 downto 0);
    inst1 : out std_logic_vector(35 downto 0);
    inst2 : out std_logic_vector(35 downto 0);
    
    ls_flg : in std_logic_vector(2 downto 0);
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
	type d_mem_state_t is (
		idle,data_w1,data_w2,data_w3,data_w4,data_w5,data_w6,data_w7,data_w8,data_w9
	);
	signal d_mem_state : d_mem_state_t := idle;
	
	signal RW,rst : std_logic := '0';
	signal DATAIN : std_logic_vector(31 downto 0) := (others => '0');
	signal DATAOUT,ls_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal set_addr : std_logic_vector(13 downto 0) := (others => '0');
	
	signal cache_out1,cache_out2 : std_logic_vector(35 downto 0) := (others => '0');
	signal cache_set : std_logic := '0';

	signal dcache_in,dcache_out,store_data_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_hit,dhit_check,cache_hit_tag,dcache_hit_buf,dcache_hit_tag : std_logic := '0';
	signal dcache_set,dcache_read : std_logic := '0';
	signal dcache_addr,addr_out,d_set_addr,ADDR : std_logic_vector(19 downto 0) := (others => '0');
	signal ls_addr_buf,ls_addr_buf_p1,ls_addr_buf_pref : std_logic_vector(19 downto 0) := (others => '0');
	signal dac,ls_ok_p : std_logic := '1';
	
	signal ls_buf0 : std_logic_vector(1 downto 0) := "00";
	signal i_mem_req,i_halt : std_logic := '0';
	
	signal i_d_out,i_d_in : std_logic_vector(0 downto 0) := "0";
begin

  	ROC0 : ROC port map (O => rst);

	inst1 <= cache_out1;
	inst2 <= cache_out2;
	
	ls_ok <= --'1' when ls_addr = addr_out else 
	dcache_hit and dhit_check;
	load_data <= --DATAOUT when ls_addr = addr_out else
	dcache_out;
	
	cache_set <= ls_flg(2);
	set_addr <= ls_addr(13 downto 0);
	
	--データキャッシュアドレス
	d_set_addr <= ls_addr when ls_flg(0) = '1' else--store
	addr_out;
	
	--データキャッシュデータ
	dcache_in <= store_data(31 downto 0) when ls_flg(0) = '1' else--store
	DATAOUT;

	--データキャッシュセット　MissLoad,Store
	dcache_set <= i_d_out(0) or (ls_flg(0));
	
	--SRAMアドレス
	ADDR <= ls_addr_buf;
	
	--SRAM書き込みデータ
	DATAIN <= store_data_buf;
	
	--SRAM読み書き　1:Read 0:Write
	RW <= not ls_buf0(0);
	
	--DCACHE FILL
	---DmissLoad
	i_d_in(0) <= ls_buf0(1) and (not dcache_hit_tag);
	
	
	DMEM : process(clk,rst)
	begin
		if rst = '1' then
			ls_buf0 <= "00";
			dhit_check <= '0';
		elsif rising_edge(clk) then
			dhit_check <= ls_flg(1);
			ls_addr_buf <= ls_addr;
			ls_buf0 <= ls_flg(1 downto 0);
			store_data_buf <= store_data;
		end if;
	end process;	

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
	
	ICACHE: full_cache port map(
		clk,clk
		,pc
		,set_addr(11 downto 0)
		,store_data
		,cache_set
		,cache_out1
		,cache_out2
	);
	
	
	DCACHE0: block_s_dcache_array port map(
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
