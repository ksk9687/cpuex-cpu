-- CPUのトップモジュール

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.util.all; 
use work.instruction.all; 
use work.SuperScalarComponents.all; 

library UNISIM;
use UNISIM.VComponents.all;

entity cpu_top is
	port  (

    RS_RX : in STD_LOGIC;
    RS_TX : out STD_LOGIC;
    outdata0 : out std_logic_vector(7 downto 0);
    outdata1 : out std_logic_vector(7 downto 0);
    outdata2 : out std_logic_vector(7 downto 0);
    outdata3 : out std_logic_vector(7 downto 0);
    outdata4 : out std_logic_vector(7 downto 0);
    outdata5 : out std_logic_vector(7 downto 0);
    outdata6 : out std_logic_vector(7 downto 0);
    outdata7 : out std_logic_vector(7 downto 0);

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
    -- 
    ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
    ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
    ZD : inout STD_LOGIC_VECTOR(31 downto 0); -- bus

    -- CLK_48M : in STD_LOGIC;
    CLK_RST : in STD_LOGIC;
    CLK_66M : in STD_LOGIC

	);
end cpu_top;

architecture arch of cpu_top is	
   signal clk,clk66,clk180,rst: std_logic := '0';
   signal stall_fetch,stall_front,stall,reg_stall,flush,sleep,stall_ex,flushed,bp_write: std_logic := '0';
   signal write_inst_ok,read_inst_ok,inst_ok,lsu_ok,lsu_ok_t,rob_ok1,rob_ok2,bp_ok,ras_ok : std_logic := '0';
   signal im : std_logic_vector(13 downto 0);
   signal ext_im,data_s1,data_s2,data_s1_p,data_s2_p,data_im : std_logic_vector(31 downto 0);
   --Inst
   signal pc,ret_pc,jmp_addr_next,jmp_addr_pc,next_pc,jmp_addr,jmp_addr_p,pc_p1,next_pc_p1,pc_b,pc_buf0,pc_buf1,ret_addr : std_logic_vector(13 downto 0) := "00"&x"000";
   signal inst1,inst2,inst1_buf,inst2_buf : std_logic_vector(35 downto 0) := nop_inst;

   
   signal inst1A,inst1B,inst0A,inst0B :std_logic_vector(31 downto 0) := (others=>'0');
	signal i1_rob_ok,i2_rob_ok,i1_rs_ok,i2_rs_ok,i1_rs_ok_t,i2_rs_ok_t :std_logic := '0';
	
   --LS
   signal ls_f,ls_f_p : std_logic_vector(2 downto 0) := (others=>'0');
   signal lsu_out,lsu_in,store_data,load_data :std_logic_vector(31 downto 0) := (others=>'0');
   signal ls_address,ls_address_p :std_logic_vector(19 downto 0) := (others=>'0');
   signal lsu_read,lsu_write,lsu_load_ok,lsu_full,lsu_may_full : std_logic := '0';
  
   --register
   signal write_regf,rob_reg_ok,write_reg,rob_next :std_logic := '0';
   signal dflg,cr_flg,cr_flg_b,pcr_flg : std_logic_vector(1 downto 0) := (others=>'0');
   signal write_reg_data,data_s1_reg_p,data_s2_reg_p,data_s12_reg_p,data_s22_reg_p,data_s1_rob_p,data_s2_rob_p,data_s12_rob_p,data_s22_rob_p: std_logic_vector(31 downto 0) := (others=>'0');
   signal rob_tag1,rob_tag2,s1tag,s2tag,s12tag,s22tag : std_logic_vector(2 downto 0) := (others=>'0');
   signal rob_alloc1,rob_alloc2,reg_alloc1,reg_alloc2 :std_logic := '0';
   signal write_reg_num : std_logic_vector(5 downto 0) := (others=>'0');
	signal rob_op :std_logic_vector(1 downto 0) := (others=>'0');
	--ALU
	signal rsalu0_write,rsalu0_ok,alu0_ready,alu0_issue :std_logic := '0';
	signal alu0_ready_tag,rsalu0dtag,alu0_in_tag :std_logic_vector(4 downto 0) := (others=>'0');
	signal alu0_ready_op,rsalu0op,rsalu0_in_op :std_logic_vector(3 downto 0) := (others=>'0');
	signal rsalu0_inA,rsalu0_inB :std_logic_vector(32 downto 0) := (others=>'0');
	signal alu0A,alu0B,alu0O :std_logic_vector(31 downto 0) := (others=>'0');
	
	
	--IO
	signal iou_out : std_logic_vector(31 downto 0) := (others=>'0');
	signal iou_enable :std_logic:='0';
	signal io_read_buf_overrun :std_logic;

	--FPU
	signal fpu_out,fpu_out_buf1 : std_logic_vector(31 downto 0) := (others=>'0');
	--pipeline ctrl
	signal write_op :std_logic_vector(5 downto 0) := (others=>'0');
	signal reg_write_buf0,reg_write_buf1,reg_write_buf2,reg_write_buf3,reg_write_buf4:std_logic := '0';
	signal mask : std_logic_vector(2 downto 0) := (others=>'1');
			
	signal pc_next,jmp_stop,jmp,predict_taken_hist,predict_taken,bp_miss : std_logic :='0';
	
   signal leddata : std_logic_vector(31 downto 0);
   signal leddotdata : std_logic_vector(7 downto 0);
   
   signal pi_valid,pl_valid,pl_valid_i,pf_valid : std_logic := '0';   
   signal pi_dtag,pl_dtag,pf_dtag : std_logic_vector(3 downto 0) := (others=>'0');
   signal pi_value,pl_value,pf_value : std_logic_vector(31 downto 0) := (others=>'0');
   signal pi_0,pi_1,pi_0_write,pi_1_write :std_logic_vector(9 downto 0) := (others=>'0');
   signal pl_0,pl_1,pl_0_write,pl_1_write :std_logic_vector(9 downto 0) := (others=>'0');
   signal pf_0,pf_1,pf_2,pf_3,pf_4,pf_5,pf_0_write,pf_1_write,pf_2_write,pf_3_write,pf_4_write,pf_5_write :std_logic_vector(9 downto 0) := (others=>'0');
 
   signal reg_s1_ok,reg_s2_ok,reg_s12_ok,reg_s22_ok,rob_s1_ok,rob_s2_ok,rob_s12_ok,rob_s22_ok : std_logic := '0';
   signal reg_s1_b,reg_s2_b : std_logic := '0';
   
   signal r11,r12,r21,r22,r11p,r12p,r21p,r22p : std_logic_vector(1 downto 0) := (others=>'0');
   signal d1,d2,d1p,d2p : std_logic_vector(4 downto 0) := (others=>'0');

begin
  clockgenerator_inst : clockgenerator port map(
    CLK_66M,
    CLK_RST,
	clock66 => clk66,
	clock => clk,
	clock_180 => clk180,
    reset => rst);
  
  
  
  
  	----------------------------------
	-- 
	-- IF
	-- 
	----------------------------------
   PC0:process(clk,rst)
   begin
	   if (rst = '1')then
	   		pc <= "00"&x"000";
	   		pc_p1 <= "00"&x"002";
	   elsif rising_edge(clk) then
			pc <= next_pc;
			if next_pc(0) = '0' then
				pc_p1 <= next_pc + "10";
			else
				pc_p1 <= (next_pc(13 downto 1) + '1')&'0';
			end if;
	   end if;
   end process PC0;
   
	
  	MEMORY0 : memory port map (
   	clk,clk,clk180,clk180,
   	next_pc(13 downto 1),inst1,inst2,
   	ls_f,ls_address,store_data,load_data,lsu_ok,
      XE1,E2A,XE3,ZZA,XGA,XZCKE,ADVA,XLBO,ZCLKMA,XFT,XWA,XZBE,ZA,ZDP,ZD
   );

--  BP0 : branchPredictor port map (
--  	clk,rst,flush,bp_ok,
--  	next_pc(13 downto 1),jmp_num,
--  	jmp,jmp_taken,jmp_not_taken,
--  	predict_taken,predict_taken_hist
--  );
  

   flush <= '0';
   
   next_pc <= pc when stall_front = '1' else
   pc_p1;
   
   DEC0 : decoder port map(
    inst1,r11p,r21p,d1p
    );
   DEC1 : decoder port map(
    inst2,r12p,r22p,d2p
    );

   	process(clk)
	begin
		if rising_edge(clk) then
			if flush = '1' then
				inst1_buf <= nop_inst;
				inst2_buf <= nop_inst;
				r11 <= (others => '0');
				r21 <= (others => '0');
				r12 <= (others => '0');
				r22 <= (others => '0');
				d1 <= (others => '0');
				d2 <= (others => '0');
			elsif stall_front = '1' then--1も２も発行できない
				inst1_buf <= inst1_buf;
				inst2_buf <= inst2_buf;
				r11 <= r11;
				r21 <= r21;
				r12 <= r12;
				r22 <= r22;
				d1 <= d1;
				d2 <= d2;
			elsif stall_fetch = '1' then--１だけ発行できた
				inst1_buf <= inst2_buf;
				inst2_buf <= nop_inst;
				r11 <= r12;
				r21 <= r22;
				r12 <= (others => '0');
				r22 <= (others => '0');
				d1 <= d2;
				d2 <= (others => '0');
			elsif pc(0) = '1' then
				inst1_buf <= inst2;
				inst2_buf <= nop_inst;
				r11 <= r12p;
				r21 <= r22p;
				r12 <= (others => '0');
				r22 <= (others => '0');
				d1 <= d2p;
				d2 <= (others => '0');
			else
				inst1_buf <= inst1;
				inst2_buf <= inst2;
				r11 <= r11p;
				r21 <= r21p;
				r12 <= r12p;
				r22 <= r22p;
				d1 <= d1p;
				d2 <= d2p;
			end if;
		end if;
	end process;

   
   
   	----------------------------------
	-- 
	-- ID
	-- 
	----------------------------------
    
    
    stall_front <= d1(3) and (not rob_ok1);
    stall_fetch <= '1' when ((inst1_buf(35 downto 34) = inst2_buf(35 downto 34)) and (inst1_buf(35 downto 33) /= "101")) else
    stall_front or (d2(3) and (not rob_ok2));
    
    i1_rob_ok <= rob_ok1;
    i2_rob_ok <= (rob_ok2 and rob_ok1);
    with inst1_buf(35 downto 33) select
     i1_rs_ok <= rsalu0_ok when "000",
     '1' when others;
     i2_rs_ok <= i1_rs_ok_t when (inst1_buf(35 downto 34) = inst2_buf(35 downto 34)) and (inst1_buf(35 downto 33) /= "101") else '0';
    with inst1_buf(35 downto 33) select
     i2_rs_ok_t <= rsalu0_ok when "000",
     '1' when others;
    
    reg_alloc1 <= (d1(3) and d1(0)) and rob_alloc1;
    reg_alloc2 <= (d2(3) and d2(0)) and rob_alloc2;
    
    rob_alloc1 <= (not stall_front);
    rob_alloc2 <= (not stall_fetch);
    
    rsalu0_write <= rob_alloc1 when (inst1_buf(35 downto 34) = "00") else
    rob_alloc2 when (inst2_buf(35 downto 34) = "00") else
    '0';
    
    rsalu0_inA <= '1'&data_s1_reg_p when (r11(0) = '1') and (inst1_buf(35 downto 34) = "00") and (reg_s1_ok = '1') else
    '1'&data_s1_rob_p when (r11(0) = '1') and (inst1_buf(35 downto 34) = "00") and (rob_s1_ok = '1') else
    '0'&x"0000000"&'0'&rob_tag1 when (r11(0) = '1') and (inst1_buf(35 downto 34) = "00") else
    '1'&x"0000"&"00"&inst1_buf(13 downto 0) when (inst1_buf(35 downto 34) = "00") else
    '1'&data_s12_reg_p when (r12(0) = '1') and (inst2_buf(35 downto 34) = "00") and (reg_s12_ok = '1') else
    '1'&data_s12_rob_p when (r12(0) = '1') and (inst2_buf(35 downto 34) = "00") and (rob_s12_ok = '1') else
    '0'&x"0000000"&'0'&rob_tag2 when (r11(0) = '1') and (inst2_buf(35 downto 34) = "00") else
    '1'&x"0000"&"00"&inst2_buf(13 downto 0);
    
    rsalu0_inB <= '1'&data_s2_reg_p when (r21(0) = '1') and (inst1_buf(35 downto 34) = "00") and (reg_s2_ok = '1') else
    '1'&data_s2_rob_p when (r21(0) = '1') and (inst1_buf(35 downto 34) = "00") and (rob_s2_ok = '1') else
    '0'&x"0000000"&'0'&rob_tag1 when (r21(0) = '1') and (inst1_buf(35 downto 34) = "00") else
    '1'&x"0000"&"00"&inst1_buf(13 downto 0) when (inst1_buf(35 downto 34) = "00") else
    '1'&data_s22_reg_p when (r22(0) = '1') and (inst2_buf(35 downto 34) = "00") and (reg_s22_ok = '1') else
    '1'&data_s22_rob_p when (r22(0) = '1') and (inst2_buf(35 downto 34) = "00") and (rob_s22_ok = '1') else
    '0'&x"0000000"&'0'&rob_tag2 when (r21(0) = '1') and (inst2_buf(35 downto 34) = "00") else
    '1'&x"0000"&"00"&inst2_buf(13 downto 0);
    
    rsalu0dtag <= "00"&rob_tag1 when (inst1_buf(35 downto 34) = "00") else "00"&rob_tag2;
    rsalu0op <= inst1_buf(33 downto 30) when (inst1_buf(35 downto 34) = "00") else
    inst2_buf(33 downto 30);
    
	IREG0 : reg port map (
		clk,flush,reg_alloc1,reg_alloc2,
		inst1_buf(21 downto 16),inst2_buf(21 downto 16),
		inst1_buf(27 downto 22),inst1_buf(15 downto 10),
		inst2_buf(27 downto 22),inst2_buf(15 downto 10),
		write_reg,write_reg_num,write_reg_data,
		data_s1_reg_p,data_s2_reg_p,data_s12_reg_p,data_s22_reg_p,
		reg_s1_ok,reg_s2_ok,reg_s12_ok,reg_s22_ok
	);
	IROB0 : reorderBuffer port map (
		clk,flush,
		rob_alloc1,rob_alloc2,reg_alloc1,reg_alloc2,
		rob_ok1,rob_ok2,
		d1(2 downto 1),d2(2 downto 1),
		inst1_buf(21 downto 16),inst2_buf(21 downto 16),
		inst1_buf(27 downto 22),inst1_buf(15 downto 10),
		inst2_buf(27 downto 22),inst2_buf(15 downto 10),
	
		rob_s1_ok,rob_s2_ok,rob_s12_ok,rob_s22_ok,
		
		data_s1_rob_p,data_s2_rob_p,data_s12_rob_p,data_s22_rob_p,
		s1tag,s2tag,s12tag,s22tag,
		rob_tag1,rob_tag2,
		
		rob_next,
		rob_reg_ok,
		write_reg_num,
		write_reg_data,
		rob_op,
		
		pi_valid,pl_valid_i,
		pi_dtag,pl_dtag,
		pi_value,pl_value
	);
	write_reg <= rob_reg_ok when rob_op = "00" else '0';
	rob_next <= '1' when rob_op /= "00" else rob_reg_ok;
	
	RSALU0 : reservationStation port map (
		clk,rsalu0_write,rsalu0_ok,
		alu0_issue,alu0_ready,
		rsalu0op,rsalu0dtag,rsalu0_inA,rsalu0_inB,
		alu0_ready_op,alu0_ready_tag,alu0A,alu0B,
		
		pi_valid,pl_valid_i,pi_dtag,pl_dtag,pi_value,pl_value
	);
	alu0_issue <= alu0_ready;
	----------------------------------
	-- 
	-- EX
	-- 
	----------------------------------
	
	ALU0 : ALU port map(
	clk,alu0_ready_op(1 downto 0),alu0A, alu0B,alu0O
	);
		
	----------------------------------
	-- 
	-- WR
	-- 
	----------------------------------	
	pl_value <= (others => '0');
	pl_dtag <= "0000";
	pl_valid <= '0';
	
	pi_value <= alu0O;
	pi_dtag <= pi_0(3 downto 0);
	pi_valid <= pi_0(5);
	process(clk)
	begin
		if rising_edge(clk) then
			pi_0 <= "0000"&alu0_ready&alu0_ready_tag;
		end if;
	end process;
	
end arch;
