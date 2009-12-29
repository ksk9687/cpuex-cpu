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
   signal stall,reg_stall,flush,sleep,stall_b,stall_id,stall_rrx,stall_rd,stall_ex,flushed: std_logic := '0';
   signal write_inst_ok,read_inst_ok,inst_ok,lsu_ok,lsu_ok_t,reg_ok : std_logic := '0';
   signal im : std_logic_vector(13 downto 0);
   signal ext_im,data_s1,data_s2,data_s1_p,data_s2_p,data_im : std_logic_vector(31 downto 0);
   --Inst
   signal jmp_addr_next,jmp_addr_pc,next_pc,pc,jmp_addr,jmp_addr_p,pc_p1,next_pc_p1,pc_b,pc_buf0,pc_buf1 : std_logic_vector(14 downto 0) := "100"&x"000";
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
   signal reg_d,ls_reg_d,reg_d_b,reg_d_buf,reg_s1,reg_s1_b,reg_s2,reg_s2_b :std_logic_vector(5 downto 0) := (others=>'0');
   signal reg_s1_use,reg_s2_use,regwrite,reg_s1_use_b,reg_s2_use_b,regwrite_b,regwrite_f :std_logic := '0';
   signal dflg,cr_flg,cr_flg_b,pcr_flg : std_logic_vector(1 downto 0) := (others=>'0');
   signal data_d : std_logic_vector(31 downto 0) := (others=>'0');
   
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
	signal unit_op_buf0,unit_op_buf1,unit_op_buf2,unit_op_buf3,unit_op_buf4 :std_logic_vector(2 downto 0) := (others=>'0');
	signal sub_op_buf0,sub_op_buf1,sub_op_buf2,sub_op_buf3,sub_op_buf4 :std_logic_vector(2 downto 0) := (others=>'0');
	signal reg_write_buf0,reg_write_buf1,reg_write_buf2,reg_write_buf3,reg_write_buf4:std_logic := '0';
	signal cr_flg_buf0,cr_flg_buf1 : std_logic_vector(1 downto 0) := (others=>'0');
	signal mask : std_logic_vector(2 downto 0) := (others=>'1');
	signal im_buf0,ext_im_buf0 :std_logic_vector(31 downto 0) := (others=>'0');
	signal reg_d_buf0,reg_d_buf1,reg_d_buf2,reg_d_buf3,reg_d_buf4:std_logic_vector(5 downto 0) := (others=>'0');
			
   	signal led_buf1,led_buf2,led_buf3 : std_logic_vector(7 downto 0) := (others => '0');
   signal cr_mask,ib_write,jmp_flg_p2,jmp_flg_p,jmp_flg,jr_buf,jr,jr_p,jmp_taken,jmp_not_taken,predict_taken,jmp_taken_p,jmp_not_taken_p : std_logic := '0';
   signal debug :std_logic_vector(7 downto 0) := (others=>'1');
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

  BP0 : branchPredictor port map (
  	clk,rst,
  	pc(13 downto 0),inst(13 downto 0),
  	predict_taken
  );
  
  	----------------------------------
	-- 
	-- IF
	-- 
	----------------------------------

  MEMORY0 : memory port map (
   	clk,rst,clk,clk180,clk90,
   	next_pc,inst,inst_ok,
   	ls_f,ls_address,store_data,load_data,lsu_ok
	,SRAMAA,SRAMIOA,SRAMIOPA
	,SRAMRWA,SRAMBWA
	,SRAMCLKMA0,SRAMCLKMA1
	,SRAMADVLDA,SRAMCEA
	,SRAMCELA1X,SRAMCEHA1X,SRAMCEA2X,SRAMCEA2
	,SRAMLBOA,SRAMXOEA,SRAMZZA
   );
   
   ledout <= debug;
--   DEB:process(clk,rst)
--   begin
--	   if (rst = '1')then
--	   	debug <= (others=>'1');
--	   elsif rising_edge(clk) then
--	   	if inst_ok = '1' and pc = "000000000000000" then
--	   		debug <= inst(31 downto 24);
--	   	end if;
--	   end if;
--   end process DEB; 
   
   flush <= (jmp_taken or jr);
   
   ib_write <= ((not jmp_flg) and (write_inst_ok) and (inst_ok));
	
   jmp_addr_next <= jmp_addr when (jmp_taken = '1') or (jr = '1') else
   inst(14 downto 0);
   
   jmp_flg_p <= '1' when (jmp_taken or jr) = '1' else --jr,jmp
   ((not jmp_flg) and (write_inst_ok) and (inst_ok)) when (inst(31 downto 26) = op_jal) else--jal
   '0';
   
   next_pc <= pc when (write_inst_ok = '0') or inst_ok = '0'else
   pc_p1;
   
	process(clk)
	begin
	    if (rst = '1')then
	    	jr_buf <= '0'; 
		elsif rising_edge(clk) then
			if jr = '1' or jmp_taken = '1' or jmp_not_taken = '1' then
				jr_buf <= '0';
			elsif ((inst(31 downto 26) = op_jr) or (inst(31 downto 26) = op_jmp)) and (write_inst_ok = '1') and (inst_ok = '1') and (jmp_flg = '0') then
				jr_buf <= '1';
			end if;
		end if;
	end process;
	
   
   PC0:process(clk,rst)
   begin
	   if (rst = '1')then
	   		pc <= "100"&x"000";
	   		pc_p1 <= "100"&x"001";
	   		jmp_flg <= '0';
	   		flushed <= '0';
	   elsif rising_edge(clk) then
	   		jmp_flg <= jmp_flg_p;
			if jmp_flg_p = '1' then
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
   	inst,
   	reg_d,reg_s1,reg_s2,
   	reg_s1_use,reg_s2_use,
   	regwrite,cr_flg
   );
   with inst(31 downto 26) select
    write_inst_im <= pc_p1 when op_jal,
    inst(23)&inst(13 downto 0) when op_jmp,
    inst(14 downto 0) when others;
    
   write_inst_data <=  inst(31 downto 26) & regwrite & reg_d & reg_s1_use & reg_s1 & reg_s2_use & reg_s2 & cr_flg & write_inst_im;
   
   IB0 : instructionBuffer port map (
   	clk,rst,flush,
   	stall_rrx,ib_write,
   	read_inst_ok,write_inst_ok,
	  read_inst_data,write_inst_data
   );
   

   --TODO 変更
    stall_rrx <= (reg_ok and (not lsu_may_full) and (not lsu_full));
	reg_stall <= flush or lsu_may_full or lsu_full;

	----------------------------------
	-- 
	-- RD
	-- 
	----------------------------------
	
	REGISTERS : reg port map (
		clk,rst,flush,reg_stall,
		reg_d_buf,
		read_inst_data(37 downto 31),
		read_inst_data(30 downto 24),
		read_inst_data(23 downto 17),
		regwrite_f,
		cr_flg_buf1,
		read_inst_data(16 downto 15),
		cr_d,
		data_d,
		data_s1_p,data_s2_p,
		cr_p,reg_ok
	);
	
	ext_im <= "00"&x"0000"&read_inst_data(13 downto 0) when read_inst_data(43 downto 38) = op_li else
	sign_extention(read_inst_data(13 downto 0));

	cr_mask <= ((read_inst_data(26) and cr_p(2)) or (read_inst_data(25) and cr_p(1)) or (read_inst_data(24) and cr_p(0)));
	jmp_taken_p <= not cr_mask when read_inst_data(43 downto 38) = op_jmp else '0';
	jmp_not_taken_p <= cr_mask when read_inst_data(43 downto 38) = op_jmp else '0';
	
	jmp_addr_p <= read_inst_data(14 downto 0) when read_inst_data(43 downto 38) = op_jmp else
	data_s1_p(14 downto 0);--jr
	
	jr_p <= '1' when read_inst_data(43 downto 38) = op_jr else '0';
	
	RR : process(CLK,rst)
	begin
		if rst = '1' then
			unit_op_buf0 <= op_unit_sp;
			sub_op_buf0 <= sp_op_nop;
			reg_write_buf0 <= '0';
			cr_flg_buf0 <= "00";
			jmp_taken <= '0';
			jmp_not_taken <= '0';
			jr <= '0';
			jmp_addr <= (others=> '0');
			mask <= (others=> '0');
			ext_im_buf0 <= (others=> '0');
			reg_d_buf0 <= (others=> '0');
			data_s1 <= (others=> '0');
			data_s2 <= (others=> '0');
			cr <= (others=> '0');
			pc_buf0 <= (others=> '0');
		elsif rising_edge(clk) then
			if stall_rrx = '0' or flush = '1' then--nop
				unit_op_buf0 <= op_unit_sp;
				sub_op_buf0 <= sp_op_nop;
				reg_write_buf0 <= '0';
				cr_flg_buf0 <= "00";
				jmp_taken <= '0';
				jmp_not_taken <= '0';
				jr <= '0';
			else
				unit_op_buf0 <= read_inst_data(43 downto 41);
				sub_op_buf0 <= read_inst_data(40 downto 38);
				reg_write_buf0 <= read_inst_data(37);
				cr_flg_buf0 <= read_inst_data(16 downto 15);
				jmp_taken <= jmp_taken_p;
				jmp_not_taken <= jmp_not_taken_p;
				jr <= jr_p;
			end if;
			jmp_addr <= jmp_addr_p;
			mask <= read_inst_data(26 downto 24);
			ext_im_buf0 <= ext_im;
			reg_d_buf0 <= read_inst_data(36 downto 31);
			data_s1 <= data_s1_p;
			data_s2 <= data_s2_p;
			cr <= cr_p;
			pc_buf0 <= read_inst_data(14 downto 0);
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
				--ledout <= not led_buf1;
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
	data_s1(19 downto 0) + data_s2(19 downto 0) when others;
		
	with sub_op_buf0 select
	lsu_in <= data_s2 when lsu_op_store,
	x"000000"&"00"&reg_d_buf0 when others;
	
    lsu_write <= '1' when unit_op_buf0 = op_unit_lsu else '0';
	LSU0 : LSU port map (
		clk,rst,lsu_read,lsu_write,lsu_ok,
		sub_op_buf0,
    	lsu_load_ok,lsu_full,lsu_may_full,
    	ls_address_p,ls_address,
    	ls_f,ls_reg_d,lsu_in,lsu_out,load_data,store_data
	);
	
	
	EX1 : process(CLK)
	begin
		if rst = '1' then
			unit_op_buf1 <= (others=> '0');
			sub_op_buf1 <= (others=> '0');
			reg_d_buf1 <= (others=> '0');
			reg_write_buf1 <= '0';
			cr_flg_buf1 <= (others=> '0');
			alu_out_buf1 <= (others=> '0');
		elsif rising_edge(clk) then
			unit_op_buf1 <= unit_op_buf0;
			sub_op_buf1 <= sub_op_buf0;
			reg_d_buf1 <= reg_d_buf0;
			cr_flg_buf1 <= cr_flg_buf0;
			if unit_op_buf0 = op_unit_lsu then
				reg_write_buf1 <= '0';
			else
				reg_write_buf1 <= reg_write_buf0;
			end if;
			alu_out_buf1 <= alu_out;
			alu_im_out_buf1 <= alu_im_out;
			pc_buf1 <= pc_buf0;
		end if;
	end process EX1;
	
	EX2 : process(CLK,rst)
	begin
		if rst = '1' then
			unit_op_buf2 <= (others=> '0');
			sub_op_buf2 <= (others=> '0');
			reg_d_buf2 <= (others=> '0');
			reg_write_buf2 <= '0';
			alu_out_buf2 <= (others=> '0');
		elsif rising_edge(clk) then
			unit_op_buf2 <= unit_op_buf1;
			sub_op_buf2 <= sub_op_buf1;
			reg_d_buf2 <= reg_d_buf1;
			reg_write_buf2 <= reg_write_buf1;
			
			if unit_op_buf1 = op_unit_iou then
				alu_out_buf2 <= iou_out;
			elsif unit_op_buf1 = op_unit_alu then
				alu_out_buf2 <= alu_out_buf1;
			elsif unit_op_buf1 = op_unit_jmp then
				alu_out_buf2 <= x"0000"&'0'&pc_buf1;
			else
				alu_out_buf2 <= alu_im_out_buf1;
			end if;
		end if;
	end process EX2;
	
	
	EX3 : process(CLK,rst)
	begin
		if rst = '1' then
			reg_write_buf3 <= '0';
			unit_op_buf3 <= (others=> '0');
			alu_out_buf3 <= (others=> '0');
			reg_d_buf3 <= (others=> '0');
			sub_op_buf3 <= (others=> '0');
		elsif rising_edge(clk) then
			reg_write_buf3 <= reg_write_buf2;
			unit_op_buf3 <= unit_op_buf2;
			alu_out_buf3 <= alu_out_buf2;
			reg_d_buf3 <= reg_d_buf2;
			sub_op_buf3 <= sub_op_buf2;
		end if;
	end process EX3;
	
	lsu_read <= lsu_load_ok and (not reg_write_buf3);
	
	EX4 : process(CLK,rst)
	begin
		if rst = '1' then
			reg_write_buf4 <= '0';
			unit_op_buf4 <= (others=> '0');
			alu_out_buf4 <= (others=> '0');
			reg_d_buf4 <= (others=> '0');
			sub_op_buf4 <= (others=> '0');
		elsif rising_edge(clk) then
			if (lsu_load_ok = '1') and (reg_write_buf3 = '0') then
				reg_write_buf4 <= '1';
				alu_out_buf4 <= lsu_out;
				reg_d_buf4 <= ls_reg_d;
			else
				if unit_op_buf3 = op_unit_fpu then
					alu_out_buf4 <= fpu_out;
				else
					alu_out_buf4 <= alu_out_buf3;
				end if;
				reg_write_buf4 <= reg_write_buf3;
				reg_d_buf4 <= reg_d_buf3;
			end if;
			
			unit_op_buf4 <= unit_op_buf3;
			sub_op_buf4 <= sub_op_buf3;
		end if;
	end process EX4;
	
	----------------------------------
	-- 
	-- WR
	-- 
	----------------------------------
	
	--コンディションレジスタ
	with unit_op_buf1 select
	 cr_d <= alui_cmp when op_unit_alui,
	 fpu_cmp when op_unit_fpu,
	 alu_cmp when others;
	 
	 
	 
	reg_d_buf <= reg_d_buf4;
	regwrite_f <= reg_write_buf4;
	data_d <= alu_out_buf4;
		
	

end arch;
