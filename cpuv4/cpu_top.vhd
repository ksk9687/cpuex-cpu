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
   signal clk,clk66,clk180,rst,rst0,locked0: std_logic := '0';
   signal stall_first,stall_second,stall_id3,stall_id2,stall_fetch,stall_front,flush,flush_jr: std_logic := '0';

   signal rob_ok1,rob_ok2 : std_logic := '0';
   signal frob_ok1,frob_ok2 : std_logic := '0';
   --Inst
   signal pc,ret_pc,jmp_addr_next,jmp_addr_pc,next_pc,jmp_addr,jmp_addr_p,pc_p1,next_pc_p1,pc_b,pc_buf0,pc_buf1,ret_addr,jr_addr : std_logic_vector(13 downto 0) := "00"&x"000";
   signal inst1,inst2,inst1_buf,inst2_buf : std_logic_vector(35 downto 0) := nop_inst;

   --DECODE
   signal r11,r12,r21,r22,r11p,r12p,r21p,r22p : std_logic_vector(1 downto 0) := (others=>'0');
   signal d1,d2,d1p,d2p : std_logic_vector(4 downto 0) := (others=>'0');
   signal dr1,dr2,df1,df2,dr1p,dr2p,df1p,df2p : std_logic_vector(5 downto 0) := (others=>'0');
   signal drop1,drop2,dfop1,dfop2,drop1p,drop2p,dfop1p,dfop2p : std_logic_vector(1 downto 0) := (others=>'0');

	signal alu_inst,alu_inst_p,bru_inst,bru_inst_p,lsu_inst,lsu_inst_p,fpu_inst,fpu_inst_p :std_logic_vector(35 downto 0) := (others=>'0');
	signal s1_unit_p,s2_unit_p,s3_unit_p,s4_unit_p,s1_unit,s2_unit,s3_unit,s4_unit :std_logic_vector(2 downto 0) := (others=>'0');
	signal sf1_unit_p,sf2_unit_p,sf3_unit_p,sf4_unit_p,sf1_unit,sf2_unit,sf3_unit,sf4_unit :std_logic_vector(2 downto 0) := (others=>'0');
	signal firstunit,secondunit :std_logic_vector(2 downto 0) := (others=>'0');
   signal firstregmsk,firstregmskp,secondregmsk,secondregmskp : std_logic_vector(4 downto 0) := (others=>'0');
   signal tf1,tf2,ftf1,ftf2,tf1p,tf2p,ftf1p,ftf2p : std_logic := '0';
	signal canUseFirstUnit,canUseSecondUnit : std_logic := '0';
	signal s1,s2,s3,s4 :std_logic_vector(5 downto 0) := (others=>'0');
	signal ci :std_logic_vector(7 downto 0) := (others=>'0');
  
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
	--LSU
	signal rslsu_write,rslsu_ok,lsu_ready,lsu_issue :std_logic := '0';
	signal lsu_ready_tag,rslsudtag,lsu_in_tag,lsu_out_tag :std_logic_vector(3 downto 0) := (others=>'0');
	signal lsu_ready_op,rslsuop,rslsu_in_op :std_logic_vector(19 downto 0) := (others=>'0');
	signal rslsu_inA,rslsu_inB :std_logic_vector(32 downto 0) := (others=>'0');
	signal lsuA,lsuB,lsuO,ioO :std_logic_vector(31 downto 0) := (others=>'0');
	signal rslsuim,rslsuim_p :std_logic_vector(13 downto 0) := (others=>'0');
	--FPU
	signal rsfpu_write,rsfpu_ok,fpu_ready,fpu_issue :std_logic := '0';
	signal fpu_ready_tag,rsfpudtag,fpu_in_tag,fpu_tag,fpu_out_tag :std_logic_vector(3 downto 0) := (others=>'0');
	signal fpu_ready_op,rsfpuop,rsfpu_in_op :std_logic_vector(4 downto 0) := (others=>'0');
	signal rsfpu_inA,rsfpu_inB :std_logic_vector(32 downto 0) := (others=>'0');
	signal fpuA,fpuB,fpuO :std_logic_vector(31 downto 0) := (others=>'0');
   --LS
   signal ls_f : std_logic_vector(2 downto 0) := (others=>'0');
   signal lsu_out,store_data,load_data :std_logic_vector(31 downto 0) := (others=>'0');
   signal ls_address :std_logic_vector(19 downto 0) := (others=>'0');
   signal lsu_read,lsu_write,load_hit,lsu_full,lsu_ok,io_ok,store_ok,io_end,load_ok,ioexec,load_end,storeexec : std_logic := '0';
	--FPU
	signal fpu_out,fpu_out_buf1 : std_logic_vector(31 downto 0) := (others=>'0');
	--pipeline ctrl
	signal write_op :std_logic_vector(5 downto 0) := (others=>'0');
	signal reg_write_buf0,reg_write_buf1,reg_write_buf2,reg_write_buf3,reg_write_buf4:std_logic := '0';
	signal mask : std_logic_vector(2 downto 0) := (others=>'1');
			
	signal pc_next,jmp_stop,jmp,predict_taken_hist,predict_taken,bp_miss : std_logic :='0';

   
   signal pi_valid,pl_valid,pl_validi,pl_validf,pf_valid,pb_valid : std_logic := '0';   
   signal pi_dtag,pl_dtag,pl_dtagi,pl_dtagf,pf_dtag,pf_dtagf,pb_dtagi,pb_dtagf : std_logic_vector(3 downto 0) := (others=>'0');
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
--  clockgenerator_inst : clockgenerator port map(
--    CLK_66M,
--    CLK_RST,
--	clock66 => clk66,
--	clock => clk,
--	clock_180 => clk180,
--    reset => rst);
 CLOCK0 : CLOCK port map (
    clkin => CLK_66M,
    clkout0 => clk,
    clkout180 => clk180,
    locked =>locked0); 
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
	
	jmp1 <= inst1(35) and inst1(34) and (not inst1(33)) and (not (inst1(32) and inst1(31))) and (not pc(0));
	jmp2 <= inst2(35) and inst2(34) and (not inst2(33)) and (not (inst2(32) and inst2(31)));
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
   	next_pc(12 downto 1),inst1,inst2,
   	ls_f,ls_address,store_data,load_data,load_hit,
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
  		clk,stall_fetch,flush_jr,jmp1,jal1,jal2,jr1,jr2,pc,jr_addr
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
   
   jmp_info1_p <= jr_addr&x"00"&"00" when jr1 = '1' else pc&bph1&bpc1;
   jmp_info2_p <= jr_addr&x"00"&"00" when jr2 = '1' else pc(13 downto 1)&'1'&bph2&bpc2;
   
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
				if jr2 = '1' then
					jmp_info1 <= jr_addr&x"00"&"00";
				else
					jmp_info1 <= pc&bph2&bpc2;
				end if;
				jmp_info2 <= (others => '0');
			elsif ((jmp1 = '1') and (bpc1(1) = '1')) or (jal1 = '1') or (jr1 = '1') then--1のみデコード
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
	stall_id2 <= '1' when (inst1_buf(35 downto 34) = inst2_buf(35 downto 34)) and ((inst1_buf(35 downto 33) /= "101") or (inst2_buf(35 downto 33) /= "101"))else
	'0';
	
	alu_inst_p <= inst1_buf when inst1_buf(35 downto 33) = unit_alu else
	inst2_buf when (inst2_buf(35 downto 33) = unit_alu) and (stall_id2 = '0') else
	nop_inst;
	
	bru_inst_p <= inst1_buf when inst1_buf(35 downto 33) = unit_bru else
	inst2_buf when (inst2_buf(35 downto 33) = unit_bru) and (stall_id2 = '0') else
	nop_inst;
	
	lsu_inst_p <= inst1_buf when inst1_buf(35 downto 34) = unit_lsiou else
	inst2_buf when (inst2_buf(35 downto 34) = unit_lsiou) and (stall_id2 = '0') else
	nop_inst;
	
	fpu_inst_p <= inst1_buf when inst1_buf(35 downto 33) = unit_fpu else
	inst2_buf when (inst2_buf(35 downto 33) = unit_fpu) and (stall_id2 = '0') else
	nop_inst;
	
	rsalu0im_p <= (jmp_info1(23 downto 10) + '1') when (inst1_buf(35 downto 33) = unit_alu) and (inst1_buf(31 downto 30)= "11") else
	inst1_buf(13 downto 0) when (inst1_buf(35 downto 33) = unit_alu) else
	(jmp_info2(23 downto 10)+ '1') when (inst2_buf(35 downto 33) = unit_alu) and (inst2_buf(31 downto 30)= "11") else
	 inst2_buf(13 downto 0);
	 
	jmp_info_p <= jmp_info1 when inst1_buf(35 downto 33) = unit_bru else jmp_info2;
	
	rslsuim_p <= lsu_inst_p(13 downto 0) when lsu_inst_p(31 downto 28) = "0000" else
	lsu_inst_p(21 downto 18)&lsu_inst_p(9 downto 0);
	
	s1_unit_p <= inst1_buf(35 downto 33) when r11 = "01" else unit_nop;
	s2_unit_p <= inst1_buf(35 downto 33) when r21 = "01" else unit_nop;
	s3_unit_p <= inst2_buf(35 downto 33) when r12 = "01" else unit_nop;
	s4_unit_p <= inst2_buf(35 downto 33) when r22 = "01" else unit_nop;
	
	sf1_unit_p <= inst1_buf(35 downto 33) when r11 = "10" else unit_nop;
	sf2_unit_p <= inst1_buf(35 downto 33) when r21 = "10" else unit_nop;
	sf3_unit_p <= inst2_buf(35 downto 33) when r12 = "10" else unit_nop;
	sf4_unit_p <= inst2_buf(35 downto 33) when r22 = "10" else unit_nop;
	
	dr1p <= inst1_buf(21 downto 16) when d1(3) = '1' else inst2_buf(21 downto 16);
	dr2p <= inst2_buf(21 downto 16);
	df1p <= inst1_buf(21 downto 16) when d1(4) = '1' else inst2_buf(21 downto 16);
	df2p <= inst2_buf(21 downto 16);
	
	drop1p <= d1(2 downto 1) when d1(3) = '1' else d2(2 downto 1);
	drop2p <= d2(2 downto 1);
	dfop1p <= d1(2 downto 1) when d1(4) = '1' else d2(2 downto 1);
	dfop2p <= d2(2 downto 1);
	
	--f2,f2,i2,i1
	firstregmskp <= d1(0)&'0'&d1(4)&'0'&d1(3);
	secondregmskp(0) <= d2(3) when d1(3) = '0' else '0';
	secondregmskp(1) <= d2(3) when d1(3) = '1' else '0';
	secondregmskp(2) <= d2(4) when d1(4) = '0' else '0';
	secondregmskp(3) <= d2(4) when d1(4) = '1' else '0';
	secondregmskp(4) <= d2(0);
	
	--inst1のdがinst2のs
	tf1p <= d1(0) when (inst1_buf(21 downto 16) = inst2_buf(27 downto 22)) and (d1(3) = r12(0)) else '0';
	tf2p <= d1(0) when (inst1_buf(21 downto 16) = inst2_buf(15 downto 10)) and (d1(3) = r22(0)) else '0';
	ftf1p <= d1(0) when (inst1_buf(21 downto 16) = inst2_buf(27 downto 22)) and (d1(4) = r12(1)) else '0';
	ftf2p <= d1(0) when (inst1_buf(21 downto 16) = inst2_buf(15 downto 10)) and (d1(4) = r22(1)) else '0';
				
   	process(clk,rst)
	begin
		if rst = '1' then
				alu_inst <= nop_inst;
				bru_inst <= nop_inst;
				lsu_inst <= nop_inst;
				fpu_inst <= nop_inst;
				
				firstunit <= unit_nop;
				secondunit <= unit_nop;
				firstregmsk  <= (others => '0');
				secondregmsk  <= (others => '0');
				s1_unit <= unit_nop;
				s2_unit <= unit_nop;
				s3_unit <= unit_nop;
				s4_unit <= unit_nop;
				
				sf1_unit <= unit_nop;
				sf2_unit <= unit_nop;
				sf3_unit <= unit_nop;
				sf4_unit <= unit_nop;
				jmp_info <= (others => '0');
			
		elsif rising_edge(clk) then
			if flush = '1' then
				alu_inst <= nop_inst;
				bru_inst <= nop_inst;
				lsu_inst <= nop_inst;
				fpu_inst <= nop_inst;
				
				firstunit <= unit_nop;
				secondunit <= unit_nop;
			
				firstregmsk  <= (others => '0');
				secondregmsk  <= (others => '0');
				
				s1_unit <= unit_nop;
				s2_unit <= unit_nop;
				s3_unit <= unit_nop;
				s4_unit <= unit_nop;
				
				sf1_unit <= unit_nop;
				sf2_unit <= unit_nop;
				sf3_unit <= unit_nop;
				sf4_unit <= unit_nop;
				
				jmp_info <= (others => '0');
			elsif stall_first = '1' then--完全ストール
				
			elsif stall_second = '1' then--第二命令のみストール
				if firstunit = unit_alu then
					alu_inst <= nop_inst;
				elsif firstunit = unit_bru then
					bru_inst <= nop_inst;
				elsif firstunit(2 downto 1) = unit_lsiou then
					lsu_inst <= nop_inst;
				elsif firstunit = unit_fpu then
					fpu_inst <= nop_inst;
				else
					bru_inst <= nop_inst;
					alu_inst <= nop_inst;
					lsu_inst <= nop_inst;
					fpu_inst <= nop_inst;
				end if;
				firstunit <= secondunit;
				s1 <= s3;
				s2 <= s4;
				s3 <= s3;
				s4 <= s4;
				
				firstregmsk <= secondregmsk(4)&'0'&(secondregmsk(3) or secondregmsk(2))&'0'&(secondregmsk(1) or secondregmsk(0));
				secondregmsk <= (others => '0');
				if secondregmsk(0) = '1' then
					drop1 <= drop1;
					dr1 <= dr1;
				else
					drop1 <= drop2;
					dr1 <= dr2;
				end if;
				if secondregmsk(2) = '1' then
					dfop1 <= dfop1;
					df1 <= df1;
				else
					dfop1 <= dfop2;
					df1 <= df2;
				end if;
				drop2 <= (others => '0');
				dfop2 <= (others => '0');
				dr2 <= (others => '0');
				df2 <= (others => '0');
				
				s1_unit <= s3_unit;
				s2_unit <= s4_unit;
				s3_unit <= s3_unit;
				s4_unit <= s4_unit;
				
				sf1_unit <= sf3_unit;
				sf2_unit <= sf4_unit;
				sf3_unit <= sf3_unit;
				sf4_unit <= sf4_unit;
				
				tf1 <= '0';
				tf2 <= '0';
				ftf1 <= '0';
				ftf2 <= '0';
				
				secondunit <= unit_nop;
				jmp_info <= jmp_info;
			else
				alu_inst <= alu_inst_p;
				bru_inst <= bru_inst_p;
				lsu_inst <= lsu_inst_p;
				fpu_inst <= fpu_inst_p;
				
				firstunit <= inst1_buf(35 downto 33);
				s1 <= inst1_buf(27 downto 22);
				s2 <= inst1_buf(15 downto 10);
				s3 <= inst2_buf(27 downto 22);
				s4 <= inst2_buf(15 downto 10);
				s1_unit <= s1_unit_p;
				s2_unit <= s2_unit_p;
				sf1_unit <= sf1_unit_p;
				sf2_unit <= sf2_unit_p;
				
				dr1 <= dr1p;	
				dr2 <= dr2p;
				df1 <= df1p;	
				df2 <= df2p;
				
				drop1 <= drop1p;
				drop2 <= drop2p;
				dfop1 <= dfop1p;
				dfop2 <= dfop2p;
				
				tf1 <= tf1p;
				tf2 <= tf2p;
				ftf1 <= ftf1p;
				ftf2 <= ftf2p;
				
				firstregmsk <= firstregmskp;
				
				rsalu0im <= rsalu0im_p;
				jmp_info <= jmp_info_p;
				rslsuim <= rslsuim_p;
				
				if stall_id2 = '1' then
					secondunit <= unit_nop;
					s3_unit <= unit_nop;
					s4_unit <= unit_nop;
					sf3_unit <= unit_nop;
					sf4_unit <= unit_nop;
					secondregmsk <= (others => '0');
				else
					s3_unit <= s3_unit_p;
					s4_unit <= s4_unit_p;
					sf3_unit <= sf3_unit_p;
					sf4_unit <= sf4_unit_p;
					secondunit <= inst2_buf(35 downto 33);
					secondregmsk <= secondregmskp;
				end if;
			end if;
		end if;
	end process;
   
   
   	----------------------------------
	-- 
	-- ID3
	-- 
	----------------------------------
    
    
    stall_first <= (firstregmsk(0) and (not rob_ok1)) or (firstregmsk(2) and (not frob_ok1)) or (not canUseFirstUnit);
    stall_second <= stall_first or (secondregmsk(0) and (not rob_ok1)) or (secondregmsk(1) and (not rob_ok2)) or 
    (secondregmsk(2) and (not frob_ok1)) or (secondregmsk(3) and (not frob_ok2)) or (not canUseSecondUnit);
    
    with firstunit select
     canUseFirstUnit <= rsalu0_ok when unit_alu,
     rsbru_ok when unit_bru,
     rslsu_ok when unit_lsu,
     rslsu_ok when unit_iou,
     rsfpu_ok when unit_fpu,
     '1' when others;
     
    with secondunit select
     canUseSecondUnit <= rsalu0_ok when unit_alu,
     rsbru_ok when unit_bru,
     rslsu_ok when unit_lsu,
     rslsu_ok when unit_iou,
     rsfpu_ok when unit_fpu,
     '1' when others;
    
    rob_alloc1 <= (not stall_first) and (firstregmsk(0) or ((not stall_second) and secondregmsk(0)));
    rob_alloc2 <= (not stall_second) and secondregmsk(1);
    frob_alloc1 <= (not stall_first) and (firstregmsk(2) or ((not stall_second) and secondregmsk(2)));
    frob_alloc2 <= (not stall_second) and secondregmsk(3);

    reg_alloc1 <= ((firstregmsk(4) and firstregmsk(0)) or (secondregmsk(4) and secondregmsk(0))) and rob_alloc1 ;
    reg_alloc2 <= (secondregmsk(4) and secondregmsk(1)) and rob_alloc2;
    freg_alloc1 <= ((firstregmsk(4) and firstregmsk(2)) or (secondregmsk(4) and secondregmsk(2))) and frob_alloc1;
    freg_alloc2 <= (secondregmsk(4) and secondregmsk(3)) and frob_alloc2;
    
    
     rsalu0_write <=  not stall_first when firstunit = unit_alu else
     not stall_second when secondunit = unit_alu else
     '0';
     rsbru_write <= not stall_first when firstunit = unit_bru else
     not stall_second when secondunit = unit_bru else
     '0';
     rslsu_write <= not stall_first when firstunit(2 downto 1) = unit_lsiou else
     not stall_second when secondunit(2 downto 1) = unit_lsiou else
     '0';
     rsfpu_write <= not stall_first when firstunit = unit_fpu else
     not stall_second when secondunit = unit_fpu else
     '0';
     
    rsalu0_inA <= '1'&data_s1_reg_p when (s1_unit = unit_alu) and (reg_s1_ok = '1') else
    '1'&data_s1_rob_p when  (s1_unit = unit_alu) and (rob_s1_ok = '1') else
    '0'&x"0000000"&'0'&s1tag when (s1_unit = unit_alu) else
    '1'&data_s3_reg_p when (s3_unit = unit_alu) and (reg_s3_ok = '1') and (tf1 = '0') else
    '1'&data_s3_rob_p when  (s3_unit = unit_alu) and (rob_s3_ok = '1') and (tf1 = '0') else
    '0'&x"0000000"&'0'&s3tag when (s3_unit = unit_alu) else
    '1'&x"0000"&"00"&rsalu0im;

    rsalu0_inB <= '1'&data_s2_reg_p when (s2_unit = unit_alu) and (reg_s2_ok = '1') else
    '1'&data_s2_rob_p when  (s2_unit = unit_alu) and (rob_s2_ok = '1') else
    '0'&x"0000000"&'0'&s2tag when (s2_unit = unit_alu) else
    '1'&data_s4_reg_p when (s4_unit = unit_alu) and (reg_s4_ok = '1') and (tf2 = '0')else
    '1'&data_s4_rob_p when  (s4_unit = unit_alu) and (rob_s4_ok = '1') and (tf2 = '0') else
    '0'&x"0000000"&'0'&s4tag when (s4_unit = unit_alu) else
    '1'&x"0000"&"00"&rsalu0im;
    
    rsalu0dtag <= "0"&rob_tag1 when (firstunit = unit_alu) or (secondregmsk(0) = '1') else "0"&rob_tag2;
    rsalu0op <= alu_inst(31 downto 30);
    
    
    rsbru_inA <= '1'&data_s1_reg_p when (s1_unit = unit_bru) and (reg_s1_ok = '1') else
    '1'&data_s1_rob_p when  (s1_unit = unit_bru) and (rob_s1_ok = '1') else
    '0'&x"0000000"&'0'&s1tag when (s1_unit = unit_bru) else
    '1'&data_s1_freg_p when (sf1_unit = unit_bru) and (freg_s1_ok = '1') else
    '1'&data_s1_frob_p when  (sf1_unit = unit_bru) and (frob_s1_ok = '1') else
    '0'&x"0000000"&'1'&sf1tag when (sf1_unit = unit_bru) else
    '1'&data_s3_reg_p when (s3_unit = unit_bru) and (reg_s3_ok = '1') and (tf1 = '0') else
    '1'&data_s3_rob_p when  (s3_unit = unit_bru) and (rob_s3_ok = '1') and (tf1 = '0') else
    '0'&x"0000000"&'0'&s3tag when (s3_unit = unit_bru) else
    '1'&data_s3_freg_p when (sf3_unit = unit_bru) and (freg_s3_ok = '1') and (ftf1 = '0') else
    '1'&data_s3_frob_p when  (sf3_unit = unit_bru) and (frob_s3_ok = '1') and (ftf1 = '0') else
    '0'&x"0000000"&'1'&sf3tag;

    rsbru_inB <= '1'&data_s2_reg_p when ((s2_unit = unit_bru) and (reg_s2_ok = '1')) else
    '1'&data_s2_rob_p when  ((s2_unit = unit_bru) and (rob_s2_ok = '1')) else
    '0'&x"0000000"&'0'&s2tag when (s2_unit = unit_bru) else
    '1'&data_s2_freg_p when ((sf2_unit = unit_bru) and (freg_s2_ok = '1')) else
    '1'&data_s2_frob_p when  ((sf2_unit = unit_bru) and (frob_s2_ok = '1')) else
    '0'&x"0000000"&'1'&sf2tag when (sf2_unit = unit_bru) else
    '1'&data_s4_reg_p when ((s4_unit = unit_bru) and (reg_s4_ok = '1')) and (tf2 = '0') else
    '1'&data_s4_rob_p when  ((s4_unit = unit_bru) and (rob_s4_ok = '1')) and (tf2 = '0') else
    '0'&x"0000000"&'0'&s4tag when (s4_unit = unit_bru) else
    '1'&data_s4_freg_p when ((sf4_unit = unit_bru) and (freg_s4_ok = '1')) and (ftf2 = '0') else
    '1'&data_s4_frob_p when  ((sf4_unit = unit_bru) and (frob_s4_ok = '1')) and (ftf2 = '0') else
    '0'&x"0000000"&'1'&sf4tag when (sf4_unit = unit_bru) else
    '1'&sign_extention(ci);
    ci <= bru_inst(17 downto 10);
    rsbrudtag <= "0"&rob_tag1 when (firstunit = unit_bru) or (secondregmsk(0) = '1') else "0"&rob_tag2;
    rsbrudtagf <= "0"&frob_tag1 when (firstunit = unit_bru) or (secondregmsk(2) = '1') else "0"&frob_tag2;
    
    --jmp先,mask
    rsbruop <= rsbrudtagf&jmp_info&bru_inst(21 downto 18)&bru_inst(9 downto 0)&bru_inst(33 downto 28);
    
    rslsu_inA <= '1'&data_s1_reg_p when (s1_unit(2 downto 1) = unit_lsiou) and (reg_s1_ok = '1') else
    '1'&data_s1_rob_p when  (s1_unit(2 downto 1) = unit_lsiou) and (rob_s1_ok = '1') else
    '0'&x"0000000"&'0'&s1tag when (s1_unit(2 downto 1) = unit_lsiou) else
    '1'&data_s3_reg_p when (s3_unit(2 downto 1) = unit_lsiou) and (reg_s3_ok = '1') and (tf1 = '0') else
    '1'&data_s3_rob_p when  (s3_unit(2 downto 1) = unit_lsiou) and (rob_s3_ok = '1') and (tf1 = '0') else
    '0'&x"0000000"&'0'&s3tag when (s3_unit(2 downto 1) = unit_lsiou) else
    '1'&x"00000000";

    rslsu_inB <= '1'&data_s2_reg_p when ((s2_unit(2 downto 1) = unit_lsiou) and (reg_s2_ok = '1')) else
    '1'&data_s2_rob_p when  ((s2_unit(2 downto 1) = unit_lsiou) and (rob_s2_ok = '1')) else
    '0'&x"0000000"&'0'&s2tag when (s2_unit(2 downto 1) = unit_lsiou) else
    '1'&data_s2_freg_p when ((sf2_unit(2 downto 1) = unit_lsiou) and (freg_s2_ok = '1')) else
    '1'&data_s2_frob_p when  ((sf2_unit(2 downto 1) = unit_lsiou) and (frob_s2_ok = '1')) else
    '0'&x"0000000"&'1'&sf2tag when (sf2_unit(2 downto 1) = unit_lsiou) else
    '1'&data_s4_reg_p when ((s4_unit(2 downto 1) = unit_lsiou) and (reg_s4_ok = '1')) and (tf2 = '0') else
    '1'&data_s4_rob_p when  ((s4_unit(2 downto 1) = unit_lsiou) and (rob_s4_ok = '1')) and (tf2 = '0') else
    '0'&x"0000000"&'0'&s4tag when (s4_unit(2 downto 1) = unit_lsiou) else
    '1'&data_s4_freg_p when ((sf4_unit(2 downto 1) = unit_lsiou) and (freg_s4_ok = '1')) and (ftf2 = '0') else
    '1'&data_s4_frob_p when  ((sf4_unit(2 downto 1) = unit_lsiou) and (frob_s4_ok = '1')) and (ftf2 = '0') else
    '0'&x"0000000"&'1'&sf4tag when (sf4_unit(2 downto 1) = unit_lsiou) else
    '1'&x"00000000";
    
    rslsudtag <= "0"&rob_tag1 when ((firstunit(2 downto 1) = unit_lsiou) and (firstregmsk(0) = '1')) or ((secondunit(2 downto 1) = unit_lsiou) and (secondregmsk(0) = '1')) else
    "1"&frob_tag1 when ((firstunit(2 downto 1) = unit_lsiou) and (firstregmsk(2) = '1')) or ((secondunit(2 downto 1) = unit_lsiou) and (secondregmsk(2) = '1')) else
    "0"&rob_tag2 when ((secondunit(2 downto 1) = unit_lsiou) and (secondregmsk(1) = '1')) else
    "1"&frob_tag2;
    rslsuop <= rslsuim&lsu_inst(33 downto 28);
     
    rsfpu_inA <= '1'&data_s1_freg_p when (sf1_unit = unit_fpu) and (freg_s1_ok = '1') else
    '1'&data_s1_frob_p when  (sf1_unit = unit_fpu) and (frob_s1_ok = '1') else
    '0'&x"0000000"&'1'&sf1tag when (sf1_unit = unit_fpu) else
    '1'&data_s3_freg_p when (sf3_unit = unit_fpu) and (freg_s3_ok = '1') and (ftf1 = '0') else
    '1'&data_s3_frob_p when  (sf3_unit = unit_fpu) and (frob_s3_ok = '1') and (ftf1 = '0') else
    '0'&x"0000000"&'1'&sf3tag;

    rsfpu_inB <= '1'&data_s2_freg_p when (sf2_unit = unit_fpu) and (freg_s2_ok = '1') else
    '1'&data_s2_frob_p when  (sf2_unit = unit_fpu) and (frob_s2_ok = '1') else
    '0'&x"0000000"&'1'&sf2tag when (sf2_unit = unit_fpu) else
    '1'&data_s4_freg_p when (sf4_unit = unit_fpu) and (freg_s4_ok = '1') and (ftf2 = '0') else
    '1'&data_s4_frob_p when (sf4_unit = unit_fpu) and (frob_s4_ok = '1') and (ftf2 = '0') else
    '0'&x"0000000"&'1'&sf4tag when (sf4_unit = unit_fpu) else
    '1'&x"00000000";
   
    
    rsfpudtag <= "1"&frob_tag1 when (firstunit = unit_fpu) or (secondregmsk(2) = '1') else "1"&frob_tag2;
    rsfpuop <= fpu_inst(32 downto 28);
    
    
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
		tf1,tf2,
		drop1,drop2,
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
		
		pi_valid,pl_validi,pb_valid,
		pi_dtag,pl_dtagi,pb_dtagi,
		pi_value,pl_value,pb_value
	);
	write_reg <= rob_reg_ok when rob_op = "00" else 
	rob_reg_ok when rob_op = "11" else '0';
	write_freg <= frob_reg_ok when frob_op = "00" else '0';
	
	flush <= rob_reg_ok and frob_reg_ok when (write_reg_data(0) = '1') and (rob_op = "01") and (write_freg_data(0) = '1') and (frob_op = "01") else '0';
	flush_jr <= flush and write_reg_data(25);
	jmp_commit <= ((not write_reg_data(0)) and (not write_reg_data(25)) and rob_reg_ok) or flush when (rob_op = "01") else
	'0';
	ioexec <= io_ok and (not rob_reg_ok) when rob_op = "11" else '0';
	storeexec <= store_ok when rob_op = "10" else '0';

	jmp_addr <= write_reg_data(14 downto 1);
	jmp_commit_counter <= write_reg_data(16 downto 15);
	jmp_commit_hist <= write_reg_data(24 downto 17);
	jmp_commit_key <= write_freg_data(13 downto 1);
	
	rob_next <=
	rob_reg_ok and ((not write_reg_data(0)) or write_freg_data(0)) when rob_op = "01"and frob_op = "01" else--jmp
	rob_reg_ok and (not write_reg_data(0)) when rob_op = "01" else--jmp
	store_ok when rob_op = "10" else--store
	rob_reg_ok when rob_op = "11" else--io
	rob_reg_ok;
	
	frob_next <= 
	frob_reg_ok and ((not write_freg_data(0)) or write_reg_data(0)) when (rob_op = "01") and (frob_op = "01") else--jmp miss
	frob_reg_ok and (not write_freg_data(0)) when frob_op = "01" else--jmp hit
	frob_reg_ok;
	
	FREG0 : reg port map (
		clk,flush,freg_alloc1,freg_alloc2,
		df1,df2,
		s1,s2,s3,s4,
		write_freg,write_freg_num,write_freg_data,
		data_s1_freg_p,data_s2_freg_p,data_s3_freg_p,data_s4_freg_p,
		freg_s1_ok,freg_s2_ok,freg_s3_ok,freg_s4_ok
	);
	FROB0 : reorderBuffer port map (
		clk,flush,
		frob_alloc1,frob_alloc2,freg_alloc1,freg_alloc2,
		frob_ok1,frob_ok2,
		ftf1,ftf2,
		dfop1,dfop2,
		df1,df2,
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
		
		pf_valid,pl_validf,pb_valid,
		pf_dtagf,pl_dtagf,pb_dtagf,
		pf_value,pl_value,pb_valuef
	);
	
	
	RSALU0 : reservationStation
	port map (
		clk,flush,rsalu0_write,rsalu0_ok,
		alu0_issue,alu0_ready,
		rsalu0op,rsalu0dtag,rsalu0_inA,rsalu0_inB,
		alu0_ready_op,alu0_ready_tag,alu0A,alu0B,
		
		pi_valid,pl_validi,
		pi_dtag,pl_dtagi,
		pi_value,pl_value
	);
	alu0_issue <= alu0_ready;
	
	RSFPU : reservationStation
	generic map (
		opbits => 5
	)
	port map (
		clk,flush,rsfpu_write,rsfpu_ok,
		fpu_issue,fpu_ready,
		rsfpuop,rsfpudtag,rsfpu_inA,rsfpu_inB,
		fpu_ready_op,fpu_ready_tag,fpuA,fpuB,
		
		pf_valid,pl_validf,
		pf_dtag,pl_dtag,
		pf_value,pl_value
	);
	
	
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
	
	RSLSU0 : reservationStationLsu
	generic map (
		opbits => 20
	)
	port map (
		clk,flush,rslsu_write,rslsu_ok,
		lsu_issue,lsu_ready,
		rslsuop,rslsudtag,rslsu_inA,rslsu_inB,
		lsu_ready_op,lsu_ready_tag,lsuA,lsuB,
		
		pi_valid,pl_valid,pf_valid,
		pi_dtag,pl_dtag,pf_dtag,
		pi_value,pl_value,pf_value
	);
	lsu_issue <= lsu_ready and (not lsu_full);
	----------------------------------
	-- 
	-- EX
	-- 
	----------------------------------
	
	ALU0 : ALU port map(
	clk,alu0_ready_op,alu0A,alu0B,alu0O
	);
	
	BRU0 : bru port map  (
		clk,bru_ready_op(4 downto 3),bru_ready_op(2 downto 0),bru_ready_op(21 downto 20),
    	bru_ready_op(29 downto 22),
    	bruA, bruB,bru_ready_op(19 downto 6),bru_ready_op(43 downto 30),
       jmpflg,newpc,newcounter,newkey,newhist
	);
	
	LSU0 : LSU port map (
		clk,flush,lsu_issue,
		load_end,store_ok,io_ok,io_end,lsu_full,
		storeexec,ioexec,
		pc,
		lsu_ready_op(5 downto 0),lsu_ready_op(19 downto 6),
		lsuA,lsuB,lsuO,
		lsu_ready_tag,lsu_out_tag,
		
		ls_f,load_hit,load_data,ls_address,store_data,
    	RS_RX,RS_TX,
      	outdata0,outdata1,outdata2,outdata3,outdata4,outdata5,outdata6,outdata7
	);
	FPU0 : fpu port map (
	    clk,flush,fpu_ready,
	    fpu_ready_op,fpu_ready_tag,
	    fpuA, fpuB, pf_value,fpu_out_tag,
	    pf_valid,fpu_issue
    );
		
	----------------------------------
	-- 
	-- WR
	-- 
	----------------------------------	
	pl_value <= lsuO;
	pl_dtagf <= '0'&lsu_out_tag(2 downto 0);
	pl_dtagi <= '0'&lsu_out_tag(2 downto 0);
	pl_dtag <= lsu_out_tag;
	pl_valid <= io_end or load_end;
	pl_validf <= pl_valid and lsu_out_tag(3);
	pl_validi <= pl_valid and (not lsu_out_tag(3));
	
	--pf_value <= fpuO;
	pf_dtag <= fpu_out_tag;
	pf_dtagf <= '0'&fpu_out_tag(2 downto 0);
	--pf_valid <= pf_0(4);
	
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
				pb_0 <= (bru_ready_op(4) and bru_ready_op(3))&bru_ready_op(47 downto 44)&bru_ready&bru_ready_tag;
			end if;
		end if;
	end process;
	
end arch;
