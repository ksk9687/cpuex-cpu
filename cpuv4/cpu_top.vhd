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
   signal clk,clk66,clk180,rst,rst0: std_logic := '0';
   signal stall_first,stall_second,stall_id3,stall_id2,stall_fetch,stall_front,flush,flush_jr: std_logic := '0';

   signal rob_ok1,rob_ok2 : std_logic := '0';
   signal frob_ok1,frob_ok2 : std_logic := '0';
   --Inst
   signal pc,ret_pc,jmp_addr_next,jmp_addr_pc,next_pc,jmp_addr,jmp_addr_p,pc_p1,next_pc_p1,pc_b,pc_buf0,pc_buf1,ret_addr,jr_addr : std_logic_vector(13 downto 0) := "00"&x"000";
   signal inst1,inst2,inst1_buf,inst2_buf : std_logic_vector(35 downto 0) := nop_inst;

   --DECODE
   signal r11,r12,r21,r22,r11p,r12p,r21p,r22p : std_logic_vector(1 downto 0) := (others=>'0');
   signal d1,d2,d1p,d2p : std_logic_vector(4 downto 0) := (others=>'0');
   signal dr1,dr2 : std_logic_vector(5 downto 0) := (others=>'0');

	signal alu_inst,alu_inst_p,bru_inst,bru_inst_p :std_logic_vector(35 downto 0) := (others=>'0');
	signal s1_unit_p,s2_unit_p,s3_unit_p,s4_unit_p,s1_unit,s2_unit,s3_unit,s4_unit :std_logic_vector(2 downto 0) := (others=>'0');
	signal sf1_unit_p,sf2_unit_p,sf3_unit_p,sf4_unit_p,sf1_unit,sf2_unit,sf3_unit,sf4_unit :std_logic_vector(2 downto 0) := (others=>'0');
	signal firstunit,secondunit :std_logic_vector(2 downto 0) := (others=>'0');
   signal firstreg,secondreg : std_logic_vector(4 downto 0) := (others=>'0');
	signal canUseFirstUnit,canUseSecondUnit : std_logic := '0';
	signal s1,s2,s3,s4 :std_logic_vector(5 downto 0) := (others=>'0');
	signal ci :std_logic_vector(7 downto 0) := (others=>'0');
   --LS
   signal ls_f,ls_f_p : std_logic_vector(2 downto 0) := (others=>'0');
   signal lsu_out,lsu_in,store_data,load_data :std_logic_vector(31 downto 0) := (others=>'0');
   signal ls_address,ls_address_p :std_logic_vector(19 downto 0) := (others=>'0');
   signal lsu_read,lsu_write,lsu_load_ok,lsu_full,lsu_may_full,lsu_ok : std_logic := '0';
  
   --register
   signal write_regf,rob_reg_ok,frob_reg_ok,write_freg,write_reg,rob_next,frob_next :std_logic := '0';
   signal write_reg_data,data_s1_reg_p,data_s2_reg_p,data_s3_reg_p,data_s4_reg_p,data_s1_rob_p,data_s2_rob_p,data_s3_rob_p,data_s4_rob_p: std_logic_vector(31 downto 0) := (others=>'0');
   signal write_freg_data,data_s1_freg_p,data_s2_freg_p,data_s3_freg_p,data_s4_freg_p,data_s1_frob_p,data_s2_frob_p,data_s3_frob_p,data_s4_frob_p: std_logic_vector(31 downto 0) := (others=>'0');
   signal rob_tag1,rob_tag2,s1tag,s2tag,s3tag,s4tag : std_logic_vector(2 downto 0) := (others=>'0');
   signal frob_tag1,frob_tag2,sf1tag,sf2tag,sf3tag,sf4tag : std_logic_vector(2 downto 0) := (others=>'0');
   signal rob_alloc1,rob_alloc2,reg_alloc1,reg_alloc2,frob_alloc1,frob_alloc2,freg_alloc1,freg_alloc2 :std_logic := '0';
   signal write_reg_num,write_freg_num : std_logic_vector(5 downto 0) := (others=>'0');
	signal rob_op,frob_op :std_logic_vector(1 downto 0) := (others=>'0');
	signal frob_regmode1,frob_regmode2 :std_logic_vector(1 downto 0) := (others=>'0');
	--ALU
	signal rsalu0_write,rsalu0_ok,alu0_ready,alu0_issue :std_logic := '0';
	signal alu0_ready_tag,rsalu0dtag,alu0_in_tag :std_logic_vector(3 downto 0) := (others=>'0');
	signal alu0_ready_op,rsalu0op,rsalu0_in_op :std_logic_vector(1 downto 0) := (others=>'0');
	signal rsalu0_inA,rsalu0_inB :std_logic_vector(32 downto 0) := (others=>'0');
	signal alu0A,alu0B,alu0O :std_logic_vector(31 downto 0) := (others=>'0');
	signal rsalu0im,rsalu0im_p :std_logic_vector(13 downto 0) := (others=>'0');
	--BRANCH
	signal jmp1,jmp2,jr1,jr2,jal1,jal2,jmpflg :std_logic := '0';
	signal rsbru_write,rsbru_ok,bru_ready,bru_issue :std_logic := '0';
	signal bru_ready_tag,rsbrudtag,rsbrudtagf,bru_in_tag :std_logic_vector(3 downto 0) := (others=>'0');
	signal bru_ready_op,rsbruop,rsbru_in_op :std_logic_vector(47 downto 0) := (others=>'0');
	signal rsbru_inA,rsbru_inB :std_logic_vector(32 downto 0) := (others=>'0');
	signal bruA,bruB :std_logic_vector(31 downto 0) := (others=>'0');
	signal newpc :std_logic_vector(13 downto 0) := (others=>'0');
	
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
   
   signal pi_valid,pl_valid,pl_valid_i,pl_valid_f,pf_valid,pb_valid : std_logic := '0';   
   signal pi_dtag,pl_dtag,pf_dtag,pb_dtagi,pb_dtagf : std_logic_vector(3 downto 0) := (others=>'0');
   signal pi_value,pl_value,pf_value,pb_value,pb_valuef : std_logic_vector(31 downto 0) := (others=>'0');
   signal pi_0,pi_1,pi_0_write,pi_1_write :std_logic_vector(9 downto 0) := (others=>'0');
   signal pb_0,pb_1,pb_0_write,pb_1_write :std_logic_vector(9 downto 0) := (others=>'0');
   signal pl_0,pl_1,pl_0_write,pl_1_write :std_logic_vector(9 downto 0) := (others=>'0');
   signal pf_0,pf_1,pf_2,pf_3,pf_4,pf_5,pf_0_write,pf_1_write,pf_2_write,pf_3_write,pf_4_write,pf_5_write :std_logic_vector(9 downto 0) := (others=>'0');
 
   signal reg_s1_ok,reg_s2_ok,reg_s3_ok,reg_s4_ok,rob_s1_ok,rob_s2_ok,rob_s3_ok,rob_s4_ok : std_logic := '0';
   signal reg_s1_b,reg_s2_b : std_logic := '0';
   
   signal freg_s1_ok,freg_s2_ok,freg_s3_ok,freg_s4_ok,frob_s1_ok,frob_s2_ok,frob_s3_ok,frob_s4_ok : std_logic := '0';
   signal freg_s1_b,freg_s2_b : std_logic := '0';
   
   --BRANCH
   --pc + counter + hist
	signal jmp_commit :std_logic:= '0';
   signal jmp_info1,jmp_info2,jmp_info1_p,jmp_info2_p,jmp_info,jmp_info_p :std_logic_vector(14 + 2 + 8 - 1 downto 0) := (others=>'0');
	signal bpc1,bpc2 ,jmp_commit_counter,newcounter :std_logic_vector(1 downto 0) := (others=>'0');
	signal bph1,bph2 ,jmp_commit_hist,newhist :std_logic_vector(7 downto 0) := (others=>'0');
	signal bpk1,bpk2 ,jmp_commit_key,newkey :std_logic_vector(12 downto 0) := (others=>'0');

begin
  clockgenerator_inst : clockgenerator port map(
    CLK_66M,
    CLK_RST,
	clock66 => clk66,
	clock => clk,
	clock_180 => clk180,
    reset => rst0);
  
  
  	ROC0 : ROC port map (O => rst);
  
  
   next_pc <= 
   jmp_addr when flush = '1' else
   pc when stall_fetch = '1' else
   inst1(21 downto 18)&inst1(9 downto 0) when ((jmp1 = '1') and (bpc1(1) = '1')) else
   inst1(13 downto 0) when (jal1 = '1') else
   jr_addr when (jr1 = '1') else
   inst2(21 downto 18)&inst2(9 downto 0) when ((jmp2 = '1') and (bpc2(1) = '1')) else
   inst2(13 downto 0) when (jal2 = '1') else
   jr_addr when (jr2 = '1') else
   pc_p1;
  	----------------------------------
	-- 
	-- IF
	-- 
	----------------------------------
	
	jmp1 <= inst1(35) and inst1(34) and (not inst1(33)) and (not pc(0));
	jmp2 <= inst2(35) and inst2(34) and (not inst2(33));
	jal1 <= (not inst1(35)) and (not inst1(34)) and inst1(31) and inst1(30) and (not pc(0));
	jal2 <= (not inst2(35)) and (not inst2(34)) and inst2(31) and inst2(30);
	jr1 <= inst1(35) and inst1(34) and inst1(32) and inst1(31) and (not pc(0));
	jr2 <= inst2(35) and inst2(34) and inst2(32) and inst2(31);
	
   PC0:process(clk,rst)
   begin
	   if (rst = '1')then
	   		pc <= "00"&x"000";
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

  BP0 : branchPredictor port map (
  	clk,flush,stall_fetch,next_pc(13 downto 0),
  	jmp1,jmp2,
  	jmp_commit,jmp_commit_counter,jmp_commit_key,jmp_commit_hist,
  	bpc1,bpc2,
  	bph1,bph2
  );
  	
	RAS0 : returnAddressStack port map (
  		clk,stall_fetch,flush_jr,jal1,jal2,jr1,jr2,pc,jr_addr
  	);
	
	
   
   	----------------------------------
	-- 
	-- ID1
	-- 
	----------------------------------
   DEC0 : decoder port map(
    inst1,r11p,r21p,d1p
    );
   DEC1 : decoder port map(
    inst2,r12p,r22p,d2p
    );

   stall_fetch <= stall_first or stall_second or stall_id2;
   
   jmp_info1_p <= pc&bph1&bpc1;
   jmp_info2_p <= pc(13 downto 1)&'1'&bph2&bpc2;
   
   	process(clk,rst)
	begin
		if rst = '1' then
			inst1_buf <= nop_inst;
			inst2_buf <= nop_inst;
			r11 <= (others => '0');
			r21 <= (others => '0');
			r12 <= (others => '0');
			r22 <= (others => '0');
			d1 <= (others => '0');
			d2 <= (others => '0');
			jmp_info1 <= (others => '0');
			jmp_info2 <= (others => '0');
		elsif rising_edge(clk) then
			if flush = '1' then
				inst1_buf <= nop_inst;
				inst2_buf <= nop_inst;
				r11 <= (others => '0');
				r21 <= (others => '0');
				r12 <= (others => '0');
				r22 <= (others => '0');
				d1 <= (others => '0');
				d2 <= (others => '0');
				jmp_info1 <= (others => '0');
				jmp_info2 <= (others => '0');
			elsif (stall_first = '1') or (stall_second = '1') then--1も２も発行できない
				inst1_buf <= inst1_buf;
				inst2_buf <= inst2_buf;
				r11 <= r11;
				r21 <= r21;
				r12 <= r12;
				r22 <= r22;
				d1 <= d1;
				d2 <= d2;
				jmp_info1 <= jmp_info1;
				jmp_info2 <= jmp_info2;
			elsif stall_id2 = '1' then--１だけ発行できた
				inst1_buf <= inst2_buf;
				inst2_buf <= nop_inst;
				r11 <= r12;
				r21 <= r22;
				r12 <= (others => '0');
				r22 <= (others => '0');
				d1 <= d2;
				d2 <= (others => '0');
				jmp_info1 <= jmp_info2;
				jmp_info2 <= (others => '0');
			elsif pc(0) = '1' then--２のみデコード
				inst1_buf <= inst2;
				inst2_buf <= nop_inst;
				r11 <= r12p;
				r21 <= r22p;
				r12 <= (others => '0');
				r22 <= (others => '0');
				d1 <= d2p;
				d2 <= (others => '0');
				jmp_info1 <= jmp_info1_p;
				jmp_info2 <= (others => '0');
			elsif ((jmp1 = '1') and (bpc1(1) = '1') ) or (jal1 = '1') or (jr1 = '1') then--1のみデコード
				inst1_buf <= inst1;
				inst2_buf <= nop_inst;
				r11 <= r11p;
				r21 <= r21p;
				r12 <= (others => '0');
				r22 <= (others => '0');
				d1 <= d1p;
				d2 <= (others => '0');
				jmp_info1 <= jmp_info1_p;
				jmp_info2 <= (others => '0');
			else
				inst1_buf <= inst1;
				inst2_buf <= inst2;
				r11 <= r11p;
				r21 <= r21p;
				r12 <= r12p;
				r22 <= r22p;
				d1 <= d1p;
				d2 <= d2p;
				jmp_info1 <= jmp_info1_p;
				jmp_info2 <= jmp_info2_p;
			end if;
		end if;
	end process;
	
	
   	----------------------------------
	-- 
	-- ID2
	-- 
	----------------------------------
	
	--実行ユニットが重なったらストール
	stall_id2 <= '1' when (inst1_buf(35 downto 33) = inst2_buf(35 downto 33)) and (inst1_buf(35 downto 33) /= "101") else
	'0';
	
	alu_inst_p <= inst1_buf when inst1_buf(35 downto 33) = unit_alu else
	inst2_buf when (inst2_buf(35 downto 33) = unit_alu) and (stall_id2 = '0') else
	nop_inst;
	
	bru_inst_p <= inst1_buf when inst1_buf(35 downto 33) = unit_bru else
	inst2_buf when (inst2_buf(35 downto 33) = unit_bru) and (stall_id2 = '0') else
	nop_inst;
	
	rsalu0im_p <= (jmp_info1(23 downto 10) + '1') when (inst1_buf(35 downto 33) = unit_alu) and (inst1_buf(31 downto 30)= "11") else
	(jmp_info2(23 downto 10)+ '1') when (inst2_buf(35 downto 33) = unit_alu) and (inst2_buf(31 downto 30)= "11") else
	 alu_inst_p(13 downto 0);
	 
	jmp_info_p <= jmp_info1 when inst1_buf(35 downto 33) = unit_bru else jmp_info2;
	
	s1_unit_p <= inst1_buf(35 downto 33) when r11 = "01" else unit_nop;
	s2_unit_p <= inst1_buf(35 downto 33) when r21 = "01" else unit_nop;
	s3_unit_p <= inst2_buf(35 downto 33) when r12 = "01" else unit_nop;
	s4_unit_p <= inst2_buf(35 downto 33) when r22 = "01" else unit_nop;
	
	sf1_unit_p <= inst1_buf(35 downto 33) when r11 = "10" else unit_nop;
	sf2_unit_p <= inst1_buf(35 downto 33) when r21 = "10" else unit_nop;
	sf3_unit_p <= inst2_buf(35 downto 33) when r12 = "10" else unit_nop;
	sf4_unit_p <= inst2_buf(35 downto 33) when r22 = "10" else unit_nop;
	
   	process(clk,rst)
	begin
		if rst = '1' then
		elsif rising_edge(clk) then
			if flush = '1' then
				alu_inst <= nop_inst;
				bru_inst <= nop_inst;
				
				firstunit <= unit_nop;
				secondunit <= unit_nop;
			
				firstreg <= (others => '0');
				secondreg <= (others => '0');
				
				dr1 <=  (others => '0');
				dr2 <=  (others => '0');
				
				s1_unit <= unit_nop;
				s2_unit <= unit_nop;
				s3_unit <= unit_nop;
				s4_unit <= unit_nop;
				
				sf1_unit <= unit_nop;
				sf2_unit <= unit_nop;
				sf3_unit <= unit_nop;
				sf4_unit <= unit_nop;
				
				jmp_info <= (others => '0');
			elsif stall_first = '1' then
				
			elsif stall_second = '1' then
				if secondunit = unit_alu then
					bru_inst <= nop_inst;
				elsif secondunit = unit_bru then
					alu_inst <= nop_inst;
				else
					bru_inst <= nop_inst;
					alu_inst <= nop_inst;
				end if;
				firstunit <= secondunit;
				firstreg <= secondreg;
				s1 <= s3;
				s2 <= s4;
				s3 <= s3;
				s4 <= s4;
				
				s1_unit <= s3_unit;
				s2_unit <= s4_unit;
				s3_unit <= s3_unit;
				s4_unit <= s4_unit;
				
				sf1_unit <= sf3_unit;
				sf2_unit <= sf4_unit;
				sf3_unit <= sf3_unit;
				sf4_unit <= sf4_unit;
				
				dr1 <= dr2;
				dr2 <= dr2;
				secondunit <= unit_nop;
				secondreg <= (others => '0');
				jmp_info <= jmp_info;
			else
				alu_inst <= alu_inst_p;
				bru_inst <= bru_inst_p;
				firstunit <= inst1_buf(35 downto 33);
				firstreg <= d1;
				s1 <= inst1_buf(27 downto 22);
				s2 <= inst1_buf(15 downto 10);
				s3 <= inst2_buf(27 downto 22);
				s4 <= inst2_buf(15 downto 10);
				s1_unit <= s1_unit_p;
				s2_unit <= s2_unit_p;
				sf1_unit <= sf1_unit_p;
				sf2_unit <= sf2_unit_p;
				
				dr1 <= inst1_buf(21 downto 16);
				dr2 <= inst2_buf(21 downto 16);
				
				rsalu0im <= rsalu0im_p;
				jmp_info <= jmp_info_p;
				
				if stall_id2 = '1' then
					secondunit <= unit_nop;
					secondreg <= (others => '0');
					s3_unit <= unit_nop;
					s4_unit <= unit_nop;
					sf3_unit <= unit_nop;
					sf4_unit <= unit_nop;
				else
					s3_unit <= s3_unit_p;
					s4_unit <= s4_unit_p;
					sf3_unit <= sf3_unit_p;
					sf4_unit <= sf4_unit_p;
					secondunit <= inst2_buf(35 downto 33);
					secondreg <= d2;
				end if;
			end if;
		end if;
	end process;
   
   
   	----------------------------------
	-- 
	-- ID3
	-- 
	----------------------------------
    
    
    stall_first <= (firstreg(3) and (not rob_ok1)) or (firstreg(4) and (not frob_ok1)) or (not canUseFirstUnit);
    stall_second <= stall_first or (secondreg(3) and (not rob_ok2)) or (secondreg(4) and (not frob_ok2)) or (not canUseFirstUnit);
    
    with firstunit select
     canUseFirstUnit <= rsalu0_ok when unit_alu,
     rsbru_ok when unit_bru,
     '1' when others;
     
    with secondunit select
     canUseSecondUnit <= rsalu0_ok when unit_alu,
     rsbru_ok when unit_bru,
     '1' when others;
    
    rob_alloc1 <= (not stall_first) and firstreg(3);
    rob_alloc2 <= (not stall_second) and secondreg(3);
    frob_alloc1 <= (not stall_first) and firstreg(4);
    frob_alloc2 <= (not stall_second) and secondreg(4);

    reg_alloc1 <= (firstreg(0)) and rob_alloc1;
    reg_alloc2 <= (secondreg(0)) and rob_alloc2;
    freg_alloc1 <= (firstreg(0)) and frob_alloc1;
    freg_alloc2 <= (secondreg(0)) and frob_alloc2;
    
    
     rsalu0_write <= rob_alloc1 and frob_alloc1 when firstunit = unit_alu else
     rob_alloc2 and frob_alloc2 when secondunit = unit_alu else
     '0';
     rsbru_write <= rob_alloc1 and frob_alloc1 when firstunit = unit_bru else
     rob_alloc2 and frob_alloc2 when secondunit = unit_bru else
     '0';
     
    rsalu0_inA <= '1'&data_s1_reg_p when (s1_unit = unit_alu) and (reg_s1_ok = '1') else
    '1'&data_s1_rob_p when  (s1_unit = unit_alu) and (rob_s1_ok = '1') else
    '0'&x"0000000"&'0'&s1tag when (s1_unit = unit_alu) else
    '1'&data_s3_reg_p when (s3_unit = unit_alu) and (reg_s3_ok = '1') else
    '1'&data_s3_rob_p when  (s3_unit = unit_alu) and (rob_s3_ok = '1') else
    '0'&x"0000000"&'0'&s3tag when (s3_unit = unit_alu) else
    '1'&x"0000"&"00"&rsalu0im;

    rsalu0_inB <= '1'&data_s2_reg_p when (s2_unit = unit_alu) and (reg_s2_ok = '1') else
    '1'&data_s2_rob_p when  (s2_unit = unit_alu) and (rob_s2_ok = '1') else
    '0'&x"0000000"&'0'&s2tag when (s2_unit = unit_alu) else
    '1'&data_s4_reg_p when (s4_unit = unit_alu) and (reg_s4_ok = '1') else
    '1'&data_s4_rob_p when  (s4_unit = unit_alu) and (rob_s4_ok = '1') else
    '0'&x"0000000"&'0'&s4tag when (s4_unit = unit_alu) else
    '1'&x"0000"&"00"&rsalu0im;
    
    rsalu0dtag <= "0"&rob_tag1 when (firstunit = unit_alu) else "0"&rob_tag2;
    rsalu0op <= alu_inst(31 downto 30);
    
    
    rsbru_inA <= '1'&data_s1_reg_p when (s1_unit = unit_bru) and (reg_s1_ok = '1') else
    '1'&data_s1_rob_p when  (s1_unit = unit_bru) and (rob_s1_ok = '1') else
    '1'&data_s1_freg_p when (sf1_unit = unit_bru) and (freg_s1_ok = '1') else
    '1'&data_s1_frob_p when  (sf1_unit = unit_bru) and (frob_s1_ok = '1') else
    '0'&x"0000000"&'0'&s1tag when (s1_unit = unit_bru) else
    '1'&data_s3_freg_p when (sf3_unit = unit_bru) and (freg_s3_ok = '1') else
    '1'&data_s3_frob_p when  (sf3_unit = unit_bru) and (frob_s3_ok = '1') else
    '0'&x"0000000"&'0'&s3tag;

    rsbru_inB <= '1'&data_s2_reg_p when ((s2_unit = unit_bru) and (reg_s2_ok = '1')) else
    '1'&data_s2_rob_p when  ((s2_unit = unit_bru) and (rob_s2_ok = '1')) else
    '1'&data_s2_freg_p when ((sf2_unit = unit_bru) and (freg_s2_ok = '1')) else
    '1'&data_s2_frob_p when  ((sf2_unit = unit_bru) and (frob_s2_ok = '1')) else
    '0'&x"0000000"&'0'&s2tag when (s2_unit = unit_bru) else
    '1'&data_s4_reg_p when ((s4_unit = unit_bru) and (reg_s4_ok = '1')) else
    '1'&data_s4_rob_p when  ((s4_unit = unit_bru) and (rob_s4_ok = '1')) else
    '1'&data_s4_freg_p when ((sf4_unit = unit_bru) and (freg_s4_ok = '1')) else
    '1'&data_s4_frob_p when  ((sf4_unit = unit_bru) and (frob_s4_ok = '1')) else
    '0'&x"0000000"&'0'&s4tag when (s4_unit = unit_bru) else
    '1'&sign_extention(ci);
    
    ci <= bru_inst(17 downto 10);
    rsbrudtag <= "0"&rob_tag1 when (firstunit = unit_bru) else "0"&rob_tag2;
    rsbrudtagf <= "0"&frob_tag1 when (firstunit = unit_bru) else "0"&frob_tag2;
    rsbruop <= rsbrudtagf&jmp_info&bru_inst(21 downto 18)&bru_inst(9 downto 0)&bru_inst(33 downto 28);
    --jmp先,mask
    
	IREG0 : reg port map (
		clk,flush,reg_alloc1,reg_alloc2,
		dr1,dr2,
		s1,s2,s3,s4,
		write_reg,write_reg_num,write_reg_data,
		data_s1_reg_p,data_s2_reg_p,data_s3_reg_p,data_s4_reg_p,
		reg_s1_ok,reg_s2_ok,reg_s3_ok,reg_s4_ok
	);
	IROB0 : reorderBuffer port map (
		clk,flush,
		rob_alloc1,rob_alloc2,reg_alloc1,reg_alloc2,
		rob_ok1,rob_ok2,
		firstreg(2 downto 1),secondreg(2 downto 1),
		dr1,dr2,
		s1,s2,s3,s4,
	
		rob_s1_ok,rob_s2_ok,rob_s3_ok,rob_s4_ok,
		
		data_s1_rob_p,data_s2_rob_p,data_s3_rob_p,data_s4_rob_p,
		s1tag,s2tag,s3tag,s4tag,
		rob_tag1,rob_tag2,
		
		rob_next,
		rob_reg_ok,
		write_reg_num,
		write_reg_data,
		rob_op,
		
		pi_valid,pl_valid_i,pb_valid,
		pi_dtag,pl_dtag,pb_dtagi,
		pi_value,pl_value,pb_value
	);
	write_reg <= rob_reg_ok when rob_op = "00" else '0';
	flush <= rob_reg_ok and frob_reg_ok when (write_reg_data(0) = '1') and (rob_op = "01") and (write_freg_data(0) = '1') and (frob_op = "01") else '0';
	flush_jr <= flush and write_reg_data(25);
	jmp_commit <= ((not write_reg_data(0)) and (not write_reg_data(25)) and rob_reg_ok) or flush when (rob_op = "01") else
	'0';

	jmp_addr <= write_reg_data(14 downto 1);
	jmp_commit_counter <= write_reg_data(16 downto 15);
	jmp_commit_hist <= write_reg_data(24 downto 17);
	jmp_commit_key <= write_freg_data(13 downto 1);
	rob_next <= rob_reg_ok and (frob_reg_ok or (not write_reg_data(0))) when rob_op = "01" else--jmp
	rob_reg_ok when rob_op = "10" else--store
	rob_reg_ok when rob_op = "11" else--io
	rob_reg_ok;
	frob_next <= frob_reg_ok and (rob_reg_ok or (not write_reg_data(0))) when frob_op = "01" else--jmp
	frob_reg_ok when frob_op = "10" else--store
	frob_reg_ok when frob_op = "11" else--io
	frob_reg_ok;
	
	FREG0 : reg port map (
		clk,flush,freg_alloc1,freg_alloc2,
		dr1,dr2,
		s1,s2,s3,s4,
		write_freg,write_freg_num,write_freg_data,
		data_s1_freg_p,data_s2_freg_p,data_s3_freg_p,data_s4_freg_p,
		freg_s1_ok,freg_s2_ok,freg_s3_ok,freg_s4_ok
	);
	FROB0 : reorderBuffer port map (
		clk,flush,
		frob_alloc1,frob_alloc2,freg_alloc1,freg_alloc2,
		frob_ok1,frob_ok2,
		firstreg(2 downto 1),secondreg(2 downto 1),
		dr1,dr2,
		s1,s2,s3,s4,
	
		frob_s1_ok,frob_s2_ok,frob_s3_ok,frob_s4_ok,
		
		data_s1_frob_p,data_s2_frob_p,data_s3_frob_p,data_s4_frob_p,
		sf1tag,sf2tag,sf3tag,sf4tag,
		frob_tag1,frob_tag2,
		
		frob_next,
		frob_reg_ok,
		write_freg_num,
		write_freg_data,
		frob_op,
		
		pf_valid,pl_valid_i,pb_valid,
		pf_dtag,pl_dtag,pb_dtagf,
		pf_value,pl_value,pb_valuef
	);
	
	
	RSALU0 : reservationStation
	port map (
		clk,flush,rsalu0_write,rsalu0_ok,
		alu0_issue,alu0_ready,
		rsalu0op,rsalu0dtag,rsalu0_inA,rsalu0_inB,
		alu0_ready_op,alu0_ready_tag,alu0A,alu0B,
		
		pi_valid,pl_valid_i,
		pi_dtag,pl_dtag,
		pi_value,pl_value
	);
	alu0_issue <= alu0_ready;
	
	RSBRU0 : reservationStationBru
	generic map (
		opbits => 48
	)
	port map (
		clk,flush,rsbru_write,rsbru_ok,
		bru_issue,bru_ready,
		rsbruop,rsbrudtag,rsbru_inA,rsbru_inB,
		bru_ready_op,bru_ready_tag,bruA,bruB,
		
		pi_valid,pl_valid,pf_valid,
		pi_dtag,pl_dtag,pf_dtag,
		pi_value,pl_value,pf_value
	);
	bru_issue <= bru_ready;
	----------------------------------
	-- 
	-- EX
	-- 
	----------------------------------
	
	ALU0 : ALU port map(
	clk,alu0_ready_op,alu0A,alu0B,alu0O
	);
	
	BRU0 : bru port map  (
		clk,bru_ready_op(5 downto 4),bru_ready_op(3 downto 1),bru_ready_op(21 downto 20),
    	bru_ready_op(29 downto 22),
    	bruA, bruB,bru_ready_op(19 downto 6),bru_ready_op(43 downto 30),
       jmpflg,newpc,newcounter,newkey,newhist
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
	pi_valid <= pi_0(4);
	
	pb_value <= "000000"&pb_0(9)&newhist&newcounter&newpc&jmpflg;
	pb_valuef <=  "00"&x"0000"&newkey&jmpflg;
	pb_dtagi <= pb_0(3 downto 0);
	pb_dtagf <= pb_0(8 downto 5);
	pb_valid <= pb_0(4);
	process(clk)
	begin
		if rising_edge(clk) then
			if flush = '1' then
				pi_0 <= (others => '0');
				pb_0 <= (others => '0');
			else
				pi_0 <= "00000"&alu0_ready&alu0_ready_tag;
				pb_0 <= (bru_ready_op(5) and bru_ready_op(4))&bru_ready_op(47 downto 44)&bru_ready&bru_ready_tag;
			end if;
		end if;
	end process;
	
end arch;
