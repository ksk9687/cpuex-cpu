--�@������

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
	SRAMAA : out  STD_LOGIC_VECTOR (19 downto 0)	--�A�h���X
	;SRAMIOA : inout  STD_LOGIC_VECTOR (31 downto 0)	--�f�[�^
	;SRAMIOPA : inout  STD_LOGIC_VECTOR (3 downto 0) --�p���e�B�[
	
	;SRAMRWA : out  STD_LOGIC	--read=>1,write=>0
	;SRAMBWA : out  STD_LOGIC_VECTOR (3 downto 0)--�������݃o�C�g�̎w��

	;SRAMCLKMA0 : out  STD_LOGIC	--SRAM�N���b�N
	;SRAMCLKMA1 : out  STD_LOGIC	--SRAM�N���b�N
	
	;SRAMADVLDA : out  STD_LOGIC	--�o�[�X�g�A�N�Z�X
	;SRAMCEA : out  STD_LOGIC --clock enable
	
	;SRAMCELA1X : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
	;SRAMCEHA1X : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
	;SRAMCEA2X : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
	;SRAMCEA2 : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���

	;SRAMLBOA : out  STD_LOGIC	--�o�[�X�g�A�N�Z�X��
	;SRAMXOEA : out  STD_LOGIC	--IO�o�̓C�l�[�u��
	;SRAMZZA : out  STD_LOGIC	--�X���[�v���[�h�ɓ���
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
	signal DATAOUT,ls_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal pc_buf,set_addr : std_logic_vector(13 downto 0) := (others => '0');
	
	signal cache_out,cache_out_buf,store_data_buf : std_logic_vector(31 downto 0) := (others => '0');
	signal cache_hit,cache_hit_b : std_logic := '0';
	signal cache_set : std_logic := '0';

	signal dcache_out : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_in : std_logic_vector(31 downto 0) := (others => '0');
	signal dcache_hit,dcache_hit_buf : std_logic := '0';
	signal dcache_set,dcache_read : std_logic := '0';
	signal dcache_addr,addr_out,d_set_addr,ADDR : std_logic_vector(19 downto 0) := (others => '0');
	signal ls_addr_buf : std_logic_vector(19 downto 0) := (others => '0');
	signal ls_ok_p : std_logic := '1';
		
    type ram_type is array (0 to 63) of std_logic_vector (31 downto 0); 

	signal ls_buf0,ls_buf1,ls_buf2,ls_buf3,ls_buf4 : std_logic_vector(1 downto 0) := "00";
	signal inst_select : std_logic_vector(2 downto 0) := (others => '0');
	signal i_mem_req,i_halt : std_logic := '0';
	
	signal i_d_out,i_d_in : std_logic_vector(1 downto 0) := "00";
	
	
	constant sleep_inst : std_logic_vector(31 downto 0):= op_nop&"00"&x"000000";
	constant halt_inst : std_logic_vector(31 downto 0):= op_nop&"00"&x"000000";
	
	
begin
	
	inst_ok <= cache_hit or inst_select(1);
	inst <= inst_i;
	
	inst_i <= cache_out when inst_select(1) = '0' else
	irom_inst;
	
	ls_ok <= dcache_hit;
	
	load_data <= DATAOUT when ls_buf4 = "10" else
	dcache_out;
	
	cache_set <= i_d_out(1);
	set_addr <= addr_out(13 downto 0);
	
	
	--�f�[�^�L���b�V���A�h���X
	d_set_addr <= addr_out when ls_buf4 = "10" else--missload
	ls_addr;
	--�f�[�^�L���b�V���f�[�^
	dcache_in <= DATAOUT when ls_buf4 = "10" else--missload
	store_data;--Store

	--�f�[�^�L���b�V���Z�b�g�@MissLoad,Store
	dcache_set <= i_d_out(0) or (ls_flg(0));
	
	dcache_read <= (ls_flg(1) and (not ls_flg(0))) or 
	(ls_buf0(1) and (not ls_buf0(0))) or
	(ls_buf1(1) and (not ls_buf1(0))) or
	(ls_buf2(1) and (not ls_buf2(0)));

	--SRAM�A�h���X
	ADDR <= ls_addr_buf when (ls_buf0(1) = '1' and (dcache_hit = '0' or ls_buf0(0) = '1')) else
	"000000"&pc_buf;
	--SRAM�������݃f�[�^
	DATAIN <= store_data_buf when ls_buf0 = "11" else
	(others => '0');
	--SRAM�ǂݏ����@1:Read 0:Write
	RW <= '0' when ls_buf0 = "11" else
	'1';
	
	i_d_in(1) <= i_mem_req;
	i_d_in(0) <= ls_buf0(1) and (not dcache_hit);
	
	process(clk)
	begin
		if rising_edge(clk) then
			pc_buf <= pc(13 downto 0);
			inst_select(1) <= pc(14);
			inst_select(0) <= cache_hit;
		end if;
	end process;

	--I�L���b�V���~�X����(D�L���b�V���~�X�܂���Store�łȂ�)
	i_mem_req <= (not pc(14)) and (not cache_hit) and (not (ls_buf0(1) and ((not dcache_hit) or ls_buf0(0))));



	DMEM_STATE : process(clk)
	begin
		if rising_edge(clk) then
			ls_buf0 <= ls_flg;
			store_data_buf <= store_data;
			  
			if (ls_flg /= "00") then
			  ls_addr_buf <= ls_addr;
			end if;
			
			if dcache_hit = '0' then
			 ls_buf1 <= ls_buf0;
			else
			 ls_buf1 <= "00";
			end if;
			ls_buf2 <= ls_buf1;
			ls_buf3 <= ls_buf2;
			ls_buf4 <= ls_buf3;
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
	
	ICACHE:cache port map(
		clk,clk
		,pc(13 downto 0)
		,set_addr
		,DATAOUT
		,cache_set
		,cache_out
		,cache_hit
	);
	
	
	DCACHE0:dcache port map(
		clk,clk
		,ls_addr
		,d_set_addr
		,dcache_in
		,dcache_set
		,dcache_read
		,dcache_out
		,dcache_hit
	);
end synth;
