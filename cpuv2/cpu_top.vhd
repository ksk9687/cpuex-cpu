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
	    CLKIN			: in	  std_logic--50Mhz
	    ;ledout		: out	std_logic_vector(7 downto 0)
	    
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
		
		-- USB
		;USBWR : out  STD_LOGIC
		;USBRDX : out  STD_LOGIC
		;USBTXEX : in  STD_LOGIC
		;USBSIWU : out  STD_LOGIC
		;USBRXFX : in  STD_LOGIC
		;USBRST : out  STD_LOGIC
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
	);
end cpu_top;

architecture arch of cpu_top is	
   signal clk,clk50,clk90,clk180,clk270,clk2x,rst,locked0: std_logic := '0';
   signal stall,reg_stall,flush,sleep,stall_b,stall_id,stall_rr,stall_rrx,stall_rd,stall_ex,flushed,bp_write: std_logic := '0';
   signal write_inst_ok,read_inst_ok,inst_ok,lsu_ok,lsu_ok_t,reg_ok,rr_ok,rr_reg_ok,rr_cr_ok,rob_ok,bp_ok,ras_ok : std_logic := '0';
   signal im : std_logic_vector(13 downto 0);
   signal ext_im,data_s1,data_s2,data_s1_p,data_s2_p,data_im : std_logic_vector(31 downto 0);
   --Inst
   signal jr_pc,jmp_addr_next,jmp_addr_pc,next_pc,pc,jmp_addr,jmp_addr_p,pc_p1,next_pc_p1,pc_b,pc_buf0,pc_buf1 : std_logic_vector(14 downto 0) := "100"&x"000";
   signal inst,inst_b : std_logic_vector(31 downto 0) := (others=>'0');
   signal write_inst_data,read_inst_data : std_logic_vector(43 downto 0) := (others=>'0');
   signal write_inst_im : std_logic_vector(14 downto 0) := (others=>'0');
   
   --LS
   signal ls_f,ls_f_p : std_logic_vector(1 downto 0) := (others=>'0');
   signal lsu_out,lsu_in,store_data,load_data :std_logic_vector(31 downto 0) := (others=>'0');
   signal ls_address,ls_address_p :std_logic_vector(19 downto 0) := (others=>'0');
   signal lsu_read,lsu_write,lsu_load_ok,lsu_full,lsu_may_full : std_logic := '0';
  
   --register
   signal pd,s1,s2 :std_logic_vector(6 downto 0) := (others=>'0'); 
   signal cr,cr_d,cr_p: std_logic_vector(2 downto 0) := "000";
   signal reg_d,ls_reg_d,reg_d_b,reg_d_buf,reg_s1,reg_s1_b,reg_s2,reg_s2_b,reg_num :std_logic_vector(5 downto 0) := (others=>'0');
   signal reg_s1_use,reg_s2_use,regwrite,reg_s1_use_b,reg_s2_use_b,regwrite_b,regwrite_f,rob_reg_write :std_logic := '0';
   signal dflg,cr_flg,cr_flg_b,pcr_flg : std_logic_vector(1 downto 0) := (others=>'0');
   signal data_d,reg_data,data_s1_reg_p,data_s2_reg_p,data_s1_rob_p,data_s2_rob_p,value1,value2,value3 : std_logic_vector(31 downto 0) := (others=>'0');
   signal rob_tag,dtag1,dtag2,dtag3,tag_buf0,tag_buf1,tag_buf2,tag_buf3,tag_buf4 : std_logic_vector(2 downto 0) := (others=>'0');
   signal write_rob_1,write_rob_2,write_rob_3,rob_alloc :std_logic := '0';
   
	--ALU
	signal alu_out,alu_out_buf1,alu_out_buf2,alu_out_buf3,alu_out_buf4 :std_logic_vector(31 downto 0) := (others=>'0');
	signal alu_cmp :std_logic_vector(2 downto 0) := "000";
	--ALUI
	signal alu_im_out,alu_im_out_buf1 :std_logic_vector(31 downto 0) := (others=>'0');
	signal alui_cmp :std_logic_vector(2 downto 0) := "000";
	--IO
	signal iou_out : std_logic_vector(31 downto 0) := (others=>'0');
	signal iou_enable :std_logic:='0';
	--FPU
	signal fpu_out : std_logic_vector(31 downto 0) := (others=>'0');
	signal fpu_cmp :std_logic_vector(2 downto 0) := "000";
	--pipeline ctrl
	signal write_op :std_logic_vector(5 downto 0) := (others=>'0');
	signal unit_op_buf0,unit_op_buf1,unit_op_buf2,unit_op_buf3,unit_op_buf4 :std_logic_vector(2 downto 0) := (others=>'0');
	signal sub_op_buf0,sub_op_buf1,sub_op_buf2,sub_op_buf3,sub_op_buf4 :std_logic_vector(2 downto 0) := (others=>'0');
	signal reg_write_buf0,reg_write_buf1,reg_write_buf2,reg_write_buf3,reg_write_buf4:std_logic := '0';
	signal cr_flg_buf0,cr_flg_buf1 : std_logic_vector(1 downto 0) := (others=>'0');
	signal mask : std_logic_vector(2 downto 0) := (others=>'1');
	signal im_buf0,ext_im_buf0 :std_logic_vector(31 downto 0) := (others=>'0');
	signal reg_d_buf0,reg_d_buf1,reg_d_buf2,reg_d_buf3,reg_d_buf4:std_logic_vector(5 downto 0) := (others=>'0');
			
	signal pc_next,jmp_stop,jmp,predict_taken_hist,predict_taken,bp_miss : std_logic :='0';
	
   	signal led_buf1,led_buf2,led_buf3 : std_logic_vector(7 downto 0) := (others => '0');
   signal jmp_ex,jal_op,jr_op,jal,cr_mask,cr_mask_p,ib_write,jmp_flg_p2,jmp_flg_p,jmp_flg,jr_buf,jr,jr_p,jmp_taken,jmp_not_taken,jmp_taken_p,jmp_not_taken_p : std_logic := '0';
   signal debug :std_logic_vector(7 downto 0) := (others=>'1');
   signal jmp_num :std_logic_vector(2 downto 0) := (others=>'1');
   
   signal path1_0,path1_1,path1_2,path1_3,path1_4 :std_logic_vector(3 downto 0) := (others=>'0');
   signal path2_0,path2_1,path2_2,path2_3,path2_4 :std_logic_vector(3 downto 0) := (others=>'0');
      

   
   signal reg_s1_ok,reg_s2_ok,reg_cr_ok,rob_s1_ok,rob_s2_ok,dec_write : std_logic := '0';
begin
  	ROC0 : ROC port map (O => rst);
  	
--	CLOCK0 : CLOCK port map (
--  		clkin     => CLKIN,
--    	clkout2x    => clk,
--		clkout2x90 => clk90,
--		clkout2x180 => clk180,
--		clkout2x270 => clk270,
--		clkout4x => clk2x,
--		clkout1x => clk50,
--  		locked    => locked0);
  		
  	CLOCK0 : CLOCK port map (
  		clkin     => CLKIN,
    	clkout0    => clk,
		clkout90 => clk90,
		clkout180 => clk180,
		clkout270 => clk270,
		clkout2x => clk2x,
  		locked    => locked0);
  	clk50 <= not clk;


  
  	----------------------------------
	-- 
	-- IF
	-- 
	----------------------------------
  BP0 : branchPredictor port map (
  	clk,rst,flush,bp_ok,
  	next_pc(13 downto 0),jmp_num,
  	jmp,jmp_taken,jmp_not_taken,
  	predict_taken,predict_taken_hist
  );
  
  RAS0 : returnAddressStack port map (
  	clk,rst,flush,ras_ok,
  	jal,jr,jmp_ex,
  	pc_p1,jmp_num,jr_pc
  );
  
  MEMORY0 : memory port map (
   	clk,rst,clk,clk180,clk270,
   	next_pc,inst,inst_ok,
   	ls_f,ls_address,store_data,load_data,lsu_ok
	,SRAMAA,SRAMIOA,SRAMIOPA
	,SRAMRWA,SRAMBWA
	,SRAMCLKMA0,SRAMCLKMA1
	,SRAMADVLDA,SRAMCEA
	,SRAMCELA1X,SRAMCEHA1X,SRAMCEA2X,SRAMCEA2
	,SRAMLBOA,SRAMXOEA,SRAMZZA
   );

   jmp_ex <= jmp_taken or jmp_not_taken;
   bp_miss <= (jmp_taken and (not predict_taken_hist)) or
   (jmp_not_taken and predict_taken_hist);
   flush <= bp_miss;
   
   pc_next <= 
   (((not (jr_op or jal_op)) and  write_inst_ok) or (bp_ok and (jr_op or jal_op))) 
   and (inst_ok);
   ib_write <= (not jmp_flg) and (write_inst_ok) and (inst_ok) and (not jal_op) and (not jr_op);

   jmp <= ib_write when (inst(31 downto 26) = op_jmp) else '0';   
   jal <= (not jmp_flg) and (inst_ok) and bp_ok and jal_op;
   jr <= (not jmp_flg) and (inst_ok) and bp_ok and jr_op;
   jal_op <= '1' when (inst(31 downto 26) = op_jal) else '0';
   jr_op <= '1' when (inst(31 downto 26) = op_jr) else '0';
   
   next_pc <= 
   pc when pc_next = '0' else
   pc_p1;
   
   jmp_addr_next <= jmp_addr when flush = '1' else
   jr_pc when jr_op = '1' else
   inst(14 downto 0) when jal_op = '1'else
   inst(23)&inst(13 downto 0);
   
   dec_write <= ib_write and (not flush);
   
   PC0:process(clk,rst)
   begin
	   if (rst = '1')then
	   		pc <= "100"&x"000";
	   		pc_p1 <= "100"&x"001";
	   		jmp_flg <= '0';
	   elsif rising_edge(clk) then
	   		jmp_flg <= flush or jal or jr or (jmp and predict_taken);
			if flush = '1' or ((jmp = '1') and (predict_taken = '1')) or (jal = '1') or (jr = '1') then
				pc <= jmp_addr_next;
				pc_p1 <= jmp_addr_next;
			else
				pc <= next_pc;
				pc_p1 <= next_pc + '1';
			end if;
	   end if;
   end process PC0;
   
   
   	----------------------------------
	-- 
	-- ID
	-- 
	----------------------------------
    DEC : decoder port map (
   	clk,dec_write,inst,write_op,
   	reg_d,reg_s1,reg_s2,
   	reg_s1_use,reg_s2_use,
   	regwrite,cr_flg
   );
   
    write_inst_im <= pc_p1 when inst(31 downto 26) = op_jmp and predict_taken = '1' else
    inst(23)&inst(13 downto 0) when inst(31 downto 26) = op_jmp else
    '0'&inst(13 downto 0) when inst(31 downto 26) = op_li else
    inst(13)&inst(13 downto 0);
    
   
    
   write_inst_data <=  write_op & regwrite & reg_d & reg_s1_use & reg_s1 & reg_s2_use & reg_s2 & cr_flg & write_inst_im;
   
   IB0 : instructionBuffer port map (
   	clk,rst,flush,
   	stall_rrx,ib_write,
   	read_inst_ok,write_inst_ok,
	read_inst_data,write_inst_data
   );

	----------------------------------
	-- 
	-- RR
	-- 
	----------------------------------
	
	--命令発行するかどうか
    stall_rr <= not stall_rrx;
	stall_rrx <= rr_reg_ok and rr_cr_ok and
	 ((not read_inst_data(37)) or (rob_ok)) and (not lsu_full) and (not lsu_may_full);
	
	--リオーダバッファにエントリを確保するか
	rob_alloc <= rr_reg_ok and read_inst_data(37) and rob_ok and (not lsu_full) and (not lsu_may_full);
	
	--オペランドがそろっているか
	rr_reg_ok <=  ((not read_inst_data(30)) or reg_s1_ok or rob_s1_ok) and
	((not read_inst_data(23)) or reg_s2_ok or rob_s2_ok);
	
	--CRが準備出来ているか
	rr_cr_ok <= reg_cr_ok;
	cr_mask <= ((read_inst_data(26) and cr_p(2)) or (read_inst_data(25) and cr_p(1)) or (read_inst_data(24) and cr_p(0)));
	
	--分岐
	jmp_taken <= (not cr_mask) and rr_cr_ok when read_inst_data(43 downto 38) = op_jmp else '0';
	jmp_not_taken <= cr_mask and rr_cr_ok when read_inst_data(43 downto 38) = op_jmp else '0';
	jmp_addr <= read_inst_data(14 downto 0);
	
	REGISTERS : reg port map (
		clk,rst,rob_alloc,rr_reg_ok,
		reg_num,
		read_inst_data(37 downto 31),
		read_inst_data(30 downto 24),
		read_inst_data(23 downto 17),
		
		rob_reg_write,
		cr_flg_buf1,
		read_inst_data(16 downto 15),
		cr_d,
		data_d,
		data_s1_reg_p,data_s2_reg_p,
		cr_p,reg_s1_ok,reg_s2_ok,reg_cr_ok
	);
	
	ROB0 : reorderBuffer port map (
		clk,rst,
		rob_alloc,rob_ok,
		
		read_inst_data(36 downto 31),
		read_inst_data(29 downto 24),
		read_inst_data(22 downto 17),
		
		rob_s1_ok,rob_s2_ok,
		data_s1_rob_p,data_s2_rob_p,
		rob_tag,
		
		rob_reg_write,
		reg_num,
		data_d,
		
		write_rob_1,write_rob_2,write_rob_3,
		dtag1,dtag2,dtag3,
		value1,value2,value3
	);
	
	data_s1_p <= data_s1_reg_p when reg_s1_ok = '1' else data_s1_rob_p;
	data_s2_p <= data_s2_reg_p when reg_s2_ok = '1' else data_s2_rob_p;
	
	ext_im <= sign_extention( read_inst_data(14 downto 0) );
	
	
	RR : process(CLK,rst)
	begin
		if rst = '1' then
			unit_op_buf0 <= op_unit_sp;
			sub_op_buf0 <= sp_op_nop;
			reg_write_buf0 <= '0';
			cr_flg_buf0 <= "00";
			ext_im_buf0 <= (others=> '0');
			reg_d_buf0 <= (others=> '0');
			data_s1 <= (others=> '0');
			data_s2 <= (others=> '0');
		elsif rising_edge(clk) then
			if stall_rrx = '0' then--nop
				unit_op_buf0 <= op_unit_sp;
				sub_op_buf0 <= sp_op_nop;
				reg_write_buf0 <= '0';
				cr_flg_buf0 <= "00";
			else
				unit_op_buf0 <= read_inst_data(43 downto 41);
				sub_op_buf0 <= read_inst_data(40 downto 38);
				reg_write_buf0 <= read_inst_data(37);
				cr_flg_buf0 <= read_inst_data(16 downto 15);
			end if;
			ext_im_buf0 <= ext_im;
			data_s1 <= data_s1_p;
			data_s2 <= data_s2_p;
			tag_buf0 <= rob_tag;
		end if;
	end process RR;
	
	
	----------------------------------
	-- 
	-- EX
	-- 
	----------------------------------
	


	LED_OUT :process(clk)
	begin
		if rising_edge(clk) then
			if sub_op_buf0 = iou_op_ledi then
				led_buf1 <= ext_im_buf0(7 downto 0);
			else
				led_buf1 <= data_s1(7 downto 0);
			end if;
			if (unit_op_buf1 = op_unit_iou) and (sub_op_buf1(2 downto 1) = iou_op_led(2 downto 1)) then
				ledout <= not led_buf1;
			end if;
		end if;
	end process LED_OUT;

	ALU0 : alu port map (
		clk,
		sub_op_buf0,
		data_s1,data_s2,
		alu_out,alu_cmp
	);	
	ALU_IM0 : alu_im port map (
		clk,
		sub_op_buf0,
		data_s1,ext_im_buf0,
		alu_im_out,alui_cmp
	);
	
	iou_enable <= '1' when unit_op_buf0 = op_unit_iou else '0';
	IOU0 : IOU port map (
		clk,clk50,rst,iou_enable,
		sub_op_buf0,
		data_s1,ext_im_buf0(4 downto 0),
		iou_out,
		USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRST,USBD
	);
	
	FPU0 : FPU port map (
	    clk,sub_op_buf0,
	    data_s1,data_s2,
	    fpu_out,fpu_cmp
    );
	
	
	with sub_op_buf0 select
	ls_address_p <= data_s1(19 downto 0) + ext_im_buf0(19 downto 0) when lsu_op_store | lsu_op_load,
	data_s1(19 downto 0) + data_s2(19 downto 0) when others;--loadr
	
	with sub_op_buf0 select
	lsu_in <= data_s2 when lsu_op_store,
	x"0000000"&"0"&tag_buf0 when others;--load,loadr
	
    lsu_write <= '1' when unit_op_buf0 = op_unit_lsu else '0';
	LSU0 : LSU port map (
		clk,rst,lsu_read,lsu_write,lsu_ok,
		sub_op_buf0,
    	lsu_load_ok,lsu_full,lsu_may_full,
    	ls_address_p,ls_address,
    	ls_f,ls_reg_d,lsu_in,lsu_out,load_data,store_data
	);
	

	
	EX : process(CLK,rst)
	begin
		if rst = '1' then
			unit_op_buf1 <= op_unit_sp;
			sub_op_buf1 <= sp_op_nop;
			cr_flg_buf1 <= (others=> '0');
			alu_out_buf1 <= (others=> '0');
			alu_im_out_buf1 <=(others=> '0');
			reg_write_buf1 <= '0';
			
			unit_op_buf2 <= op_unit_sp;
			sub_op_buf2 <= sp_op_nop;
			reg_write_buf2 <= '0';
			
			unit_op_buf3 <= op_unit_sp;
			sub_op_buf3 <= sp_op_nop;
			reg_write_buf3 <= '0';
		elsif rising_edge(clk) then
			unit_op_buf1 <= unit_op_buf0;
			sub_op_buf1 <= sub_op_buf0;
			cr_flg_buf1 <= cr_flg_buf0;
			alu_out_buf1 <= alu_out;
			alu_im_out_buf1 <= alu_im_out;
			tag_buf1 <= tag_buf0;
			reg_write_buf1 <= reg_write_buf0;
			
			unit_op_buf2 <= unit_op_buf1;
			sub_op_buf2 <= sub_op_buf1;
			tag_buf2 <= tag_buf1;
			reg_write_buf2 <= reg_write_buf1;
			
			unit_op_buf3 <= unit_op_buf2;
			sub_op_buf3 <= sub_op_buf2;
			tag_buf3 <= tag_buf2;
			reg_write_buf3 <= reg_write_buf2;
			
			unit_op_buf4 <= unit_op_buf3;
			sub_op_buf4 <= sub_op_buf3;
			tag_buf4 <= tag_buf3;
			reg_write_buf4 <= reg_write_buf3;
		end if;
	end process EX;
	
	
	----------------------------------
	-- 
	-- WR
	-- 
	----------------------------------
	
	--　コンディションレジスタ
	with unit_op_buf1 select
	 cr_d <= alui_cmp when op_unit_alui,
	 fpu_cmp when op_unit_fpu,
	 alu_cmp when others;
	
	--パス１ALU系
	with unit_op_buf1 select
	 write_rob_1 <= reg_write_buf1 when op_unit_iou | op_unit_alu | op_unit_alui,
	 '0' when others;
	value1 <= iou_out when unit_op_buf1 = op_unit_iou else
	 alu_out_buf1 when unit_op_buf1 = op_unit_alu else
	 alu_im_out_buf1;
	dtag1 <= tag_buf1;

	--パス2　FPU
	write_rob_2 <= reg_write_buf3 when unit_op_buf3 = op_unit_fpu else '0';
	value2 <= fpu_out;
	dtag2 <= tag_buf3;

	--パス3　メモリ
	write_rob_3 <= lsu_load_ok;
	value3 <= load_data;
	dtag3 <= ls_reg_d(2 downto 0);

--
--	process(clk)
--	begin
--		if rising_edge(clk) then
--			path1_0 <= path1_1;
--			path1_1 <= path1_2;
--			path1_2 <= path1_3;
--			path1_3 <= path1_4;
--			
--			path2_0 <= path2_1;
--			path2_1 <= path2_2;
--			path2_2 <= path2_3;
--			path2_3 <= path2_4;
--		end if;
--	end process;
	
	
--	
--	--　コンディションレジスタ
--	with unit_op_buf1 select
--	 cr_d <= alui_cmp when op_unit_alui,
--	 fpu_cmp when op_unit_fpu,
--	 alu_cmp when others;
--	
--	
--	
--	--パス１
--	 write_rob_1 <= path1_0(3);
--	with path1_0(2 downto 0) select
--	  value1 <= alu_out_buf1 when "000",
--	  alu_im_out_buf1 when "001",
--	  iou_out when others;
--    dtag1 <= tag_buf1;

end arch;
