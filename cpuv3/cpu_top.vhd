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
   signal clk,clk66,clk90,clk180,clk270,clk2x,rst,locked0: std_logic := '0';
   signal stall,reg_stall,flush,sleep,stall_b,stall_id,stall_rr,stall_rrx,stall_rd,stall_ex,flushed,bp_write: std_logic := '0';
   signal write_inst_ok,read_inst_ok,inst_ok,lsu_ok,lsu_ok_t,reg_ok,rr_ok,rr_reg_ok,rr_cr_ok,rob_ok,bp_ok,ras_ok : std_logic := '0';
   signal im : std_logic_vector(13 downto 0);
   signal ext_im,data_s1,data_s2,data_s1_p,data_s2_p,data_im : std_logic_vector(31 downto 0);
   --Inst
   signal jr_pc,jmp_addr_next,jmp_addr_pc,next_pc,pc,jmp_addr,jmp_addr_p,pc_p1,next_pc_p1,pc_b,pc_buf0,pc_buf1,jr_addr : std_logic_vector(14 downto 0) := "100"&x"000";
   signal inst,inst_b : std_logic_vector(31 downto 0) := (others=>'0');
   --Ibuf
   signal write_inst_data,read_inst_data : std_logic_vector(62 downto 0) := (others=>'0');
   signal write_inst_im : std_logic_vector(14 downto 0) := (others=>'0');
   signal op_type : std_logic_vector(3 downto 0) := (others=>'0');
   
   --LS
   signal ls_f,ls_f_p : std_logic_vector(1 downto 0) := (others=>'0');
   signal lsu_out,lsu_in,store_data,load_data :std_logic_vector(31 downto 0) := (others=>'0');
   signal ls_address,ls_address_p :std_logic_vector(19 downto 0) := (others=>'0');
   signal lsu_read,lsu_write,lsu_load_ok,lsu_full,lsu_may_full : std_logic := '0';
  
   --register
   signal pd,s1,s2 :std_logic_vector(6 downto 0) := (others=>'0'); 
   signal cr,cr_d,cr_p: std_logic_vector(2 downto 0) := "000";
   signal reg_d,ls_reg_d,reg_d_b,reg_d_buf,reg_s1,reg_s2,reg_num :std_logic_vector(5 downto 0) := (others=>'0');
   signal reg_s1_use,reg_s2_use,regwrite,reg_s1_use_b,reg_s2_use_b,regwrite_b,regwrite_f,rob_reg_write :std_logic := '0';
   signal dflg,cr_flg,cr_flg_b,pcr_flg : std_logic_vector(1 downto 0) := (others=>'0');
   signal data_d,reg_data,data_s1_reg_p,data_s2_reg_p,data_s1_rob_p,data_s2_rob_p,value1,value1_lsu,value2,value3 : std_logic_vector(31 downto 0) := (others=>'0');
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
	signal io_read_buf_overrun :std_logic;
	--FPU
	signal fpu_out,fpu_out_buf1 : std_logic_vector(31 downto 0) := (others=>'0');
	signal fpu_cmp :std_logic_vector(2 downto 0) := "000";
	--pipeline ctrl
	signal write_op :std_logic_vector(5 downto 0) := (others=>'0');
	signal unit_op_buf0,unit_op_buf1,unit_op_buf2,unit_op_buf3,unit_op_buf4 :std_logic_vector(2 downto 0) := (others=>'0');
	signal sub_op_buf0,sub_op_buf1,sub_op_buf2,sub_op_buf3,sub_op_buf4 :std_logic_vector(2 downto 0) := (others=>'0');
	signal reg_write_buf0,reg_write_buf1,reg_write_buf2,reg_write_buf3,reg_write_buf4:std_logic := '0';
	signal cr_flg_buf0,cr_flg_buf1 : std_logic_vector(1 downto 0) := (others=>'0');
	signal mask : std_logic_vector(2 downto 0) := (others=>'1');
	signal im_buf0,ext_im_buf0 :std_logic_vector(31 downto 0) := (others=>'0');
	signal reg_d_buf0,reg_d_buf1,reg_d_buf2,reg_d_buf3,reg_d_buf4,reg_d_write:std_logic_vector(5 downto 0) := (others=>'0');
			
	signal pc_next,jmp_stop,jmp,predict_taken_hist,predict_taken,bp_miss : std_logic :='0';
	
   signal leddata : std_logic_vector(31 downto 0);
   signal leddotdata : std_logic_vector(7 downto 0);
   signal led_buf1,led_buf2,led_buf3 : std_logic_vector(7 downto 0) := (others => '0');
   signal jmp_ex,jmp_op,jal_op,jr_op,jal,jal_ex,jr_miss,jr_ex,cr_mask,cr_mask_p,ib_write,jmp_flg_p2,jmp_flg_p,jmp_flg,jr_buf,jr,jr_p,jmp_taken,jmp_not_taken,jmp_taken_p,jmp_not_taken_p : std_logic := '0';
   signal debug :std_logic_vector(7 downto 0) := (others=>'1');
   signal jmp_num :std_logic_vector(2 downto 0) := (others=>'1');
   
   signal path1_0,path1_1,path1_2,path1_3,path1_4,path1_5,path1_1_write,path1_2_write :std_logic_vector(9 downto 0) := (others=>'0');
   signal path2_0,path2_1,path2_2,path2_3,path2_4,path2_5 :std_logic_vector(9 downto 0) := (others=>'0');
    
   signal path1_ok,path1_1_ok,path1_4_ok : std_logic := '0';
   signal path1_unit : std_logic_vector(1 downto 0) := (others=>'0');

   signal op_is_lsu,reg_alloc,cr_alloc,short_inst,long_inst,load_inst : std_logic := '0';
   signal jmp_flgs : std_logic_vector(2 downto 0) := (others=>'0');
   
   signal reg_d_ok,reg_s1_ok,reg_s2_ok,reg_cr_ok,rob_s1_ok,rob_s2_ok,dec_write : std_logic := '0';
   signal reg_s1_b,reg_s2_b : std_logic := '0';

begin
--  	ROC0 : ROC port map (O => rst);
--	CLOCK0 : CLOCK port map (
--		clkin     => CLKIN,
--		clkout2x    => clk,
--		clkout2x90 => clk90,
--		clkout2x180 => clk180,
--		clkout2x270 => clk270,
--		clkout4x => clk2x,
--		clkout1x => clk66,
--		locked    => locked0);
  clockgenerator_inst : clockgenerator port map(
    CLK_66M,
    CLK_RST,
	clock66    => clk66,
	clock66_90 => clk90,
	clock66_180 => clk180,
	clock66_270 => clk270,
	clock133 => clk2x,
    reset => rst);
    clk <= clk66;
  
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
  
--  RAS0 : returnAddressStack port map (
--  	clk,rst,
--  	jal,jr,
--  	pc_p1,jr_pc
--  );
--  
  MEMORY0 : memory port map (
   	clk,clk,clk180,clk180,
   	next_pc,inst,jmp_flgs,inst_ok,
   	ls_f,ls_address,store_data,load_data,lsu_ok
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

   jmp_ex <= jmp_taken or jmp_not_taken;
   bp_miss <= (jmp_taken and (not predict_taken_hist)) or
   (jmp_not_taken and predict_taken_hist);
   flush <= bp_miss or jr_miss;
   
   pc_next <= (write_inst_ok) and (inst_ok);
   
   ib_write <= (not jmp_flg) and (write_inst_ok) and (inst_ok);

   jmp_op <= jmp_flgs(2);
   jal_op <= jmp_flgs(1);
   jr_op <= jmp_flgs(0);
   jmp <= ib_write and jmp_op;   
   jal <= ib_write and jal_op;
   jr <= ib_write and jr_op;
   
   next_pc <= 
   pc when pc_next = '0' else
   pc_p1;
   
   jmp_addr_next <= jmp_addr when bp_miss = '1' else
   jr_addr when jr_miss = '1' else
   --jr_pc when jr_op = '1' else
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
	   		--jmp_flg <= flush or jal or jr or (jmp and predict_taken);
	   		jmp_flg <= flush or jal or (jmp and predict_taken);
			--if flush = '1' or ((jmp = '1') and (predict_taken = '1')) or (jal = '1') or (jr = '1') then
			if flush = '1' or ((jmp = '1') and (predict_taken = '1')) or (jal = '1') then
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
   	regwrite,cr_flg,op_type
   );
   
    write_inst_im <= pc_p1 when (jmp_op = '1' and predict_taken = '1') or (jal_op = '1') else
    inst(23)&inst(13 downto 0) when jmp_op = '1' else
    '0'&inst(13 downto 0) when inst(31 downto 26) = op_li else
    inst(13)&inst(13 downto 0);
    
   
    
   write_inst_data <=  jr_pc&op_type&write_op & regwrite & reg_d & reg_s1_use & reg_s1 & reg_s2_use & reg_s2 & cr_flg & write_inst_im;
   
   IB0 : instructionBuffer port map (
   	clk,flush,
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
	stall_rrx <= rr_cr_ok and (read_inst_data(47) or (rr_reg_ok and  path1_ok and (not lsu_full)));
	
	reg_alloc <= rr_reg_ok and read_inst_data(37) and path1_ok and (not lsu_full);
	
	--オペランドがそろっているか
	rr_reg_ok <= ((not read_inst_data(30)) or reg_s1_ok or reg_s1_b) and
	((not read_inst_data(23)) or reg_s2_ok or reg_s2_b)
   and (reg_d_ok or (not read_inst_data(37)));
	
	reg_s1_b <= path1_0(3) when path1_0(9 downto 4) = read_inst_data(29 downto 24) else '0';
	reg_s2_b <= path1_0(3) when path1_0(9 downto 4) = read_inst_data(22 downto 17) else '0';
	
	--CRが準備出来ているか
	rr_cr_ok <= reg_cr_ok;
	cr_mask <= ((read_inst_data(26) and cr_p(2)) or (read_inst_data(25) and cr_p(1)) or (read_inst_data(24) and cr_p(0)));
	
	--分岐
	jmp_taken <= (not cr_mask) and rr_cr_ok when read_inst_data(43 downto 38) = op_jmp else '0';
	jmp_not_taken <= cr_mask and rr_cr_ok when read_inst_data(43 downto 38) = op_jmp else '0';
	jmp_addr <= read_inst_data(14 downto 0);
	
	--jr_miss <= jr_ex when jr_addr(13 downto 0) /= read_inst_data(61 downto 48) else '0';
	jr_miss <= jr_ex;
	jr_ex <= '1' when read_inst_data(43 downto 38) = op_jr else '0';
	jal_ex <= '1' when read_inst_data(43 downto 38) = op_jal else '0';
	
	
	RAS1 : returnAddressStack port map (
  		clk,
  		jal_ex,jr_ex,
  		read_inst_data(14 downto 0),
  		jr_addr
  	);
	
	REGISTERS : reg port map (
		clk,reg_alloc,stall_rrx,
		reg_d_write,
		read_inst_data(37 downto 31),
		read_inst_data(30 downto 24),
		read_inst_data(23 downto 17),
		
		write_rob_1,
		cr_flg_buf1,
		read_inst_data(16 downto 15),
		cr_d,
		data_d,
		data_s1_reg_p,data_s2_reg_p,
		cr_p,
		reg_d_ok,reg_s1_ok,reg_s2_ok,reg_cr_ok
	);
	
	data_s1_p <= data_d when reg_s1_b = '1' else
	data_s1_reg_p;
	data_s2_p <= data_d when reg_s2_b = '1' else
	data_s2_reg_p;
	
	ext_im <= sign_extention( read_inst_data(14 downto 0));
	
	short_inst <= read_inst_data(46);
	long_inst <= read_inst_data(45);
	load_inst <= read_inst_data(44);
	
	path1_ok <= (not (short_inst and path1_2(3))) and (not (load_inst and path1_3(3)));
	
	path1_1_write(9 downto 4) <= read_inst_data(36 downto 31) when (path1_2(3) = '0') else path1_2(9 downto 4);
	path1_1_write(3) <= short_inst and reg_alloc when (path1_2(3) = '0') else path1_2(3);
	path1_1_write(2 downto 0) <= read_inst_data(43 downto 41)  when (path1_2(3) = '0') else path1_2(2 downto 0);

	path1_2_write(9 downto 4) <= read_inst_data(36 downto 31) when (path1_3(3) = '0') else path1_3(9 downto 4);
	path1_2_write(3) <= load_inst and reg_alloc when (path1_3(3) = '0') else path1_3(3);
	path1_2_write(2 downto 0) <= read_inst_data(43 downto 41) when (path1_3(3) = '0') else path1_3(2 downto 0);

	path1_5(9 downto 4) <= read_inst_data(36 downto 31);
	path1_5(3) <= long_inst and reg_alloc;
	path1_5(2 downto 0) <= read_inst_data(43 downto 41);
	process(clk)
	begin
		if rising_edge(clk) then
			path1_0 <= path1_1;
			path1_1 <= path1_1_write;
			path1_2 <= path1_2_write;
			path1_3 <= path1_4;
			path1_4 <= path1_5;
		end if;
	end process;
	
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
			reg_d_buf0 <= read_inst_data(36 downto 31);
		end if;
	end process RR;
	
	
	----------------------------------
	-- 
	-- EX
	-- 
	----------------------------------
	

      leddata<=x"00000000";
      leddotdata<="1111111" & (not io_read_buf_overrun);
  led_inst : ledextd2 port map (
      leddata,
      leddotdata,
      outdata0,
      outdata1,
      outdata2,
      outdata3,
      outdata4,
      outdata5,
      outdata6,
      outdata7
    );

	ALU0 : alu port map (
		clk,sub_op_buf0,
		data_s1,data_s2,
		alu_out,alu_cmp
	);	
	ALU_IM0 : alu_im port map (
		clk,sub_op_buf0,
		data_s1,ext_im_buf0,
		alu_im_out,alui_cmp
	);
	
	iou_enable <= '1' when unit_op_buf0 = op_unit_iou else '0';
	IOU0 : IOU port map (
		clk,clk66,iou_enable,
		sub_op_buf0,
		data_s1,ext_im_buf0(4 downto 0),
		iou_out,
		RS_RX,RS_TX,
		io_read_buf_overrun
	);
	FPU0 : FPU port map (
	    clk,sub_op_buf0,
	    data_s1,data_s2,
	    fpu_out,fpu_cmp
    );
	
	
	with sub_op_buf0 select
	ls_address_p <= data_s1(19 downto 0) + data_s2(19 downto 0) when lsu_op_loadr,
	data_s1(19 downto 0) + ext_im_buf0(19 downto 0) when others;--loadr
	
	with sub_op_buf0 select
	lsu_in <= data_s2 when lsu_op_store,
	x"000000"&"00"&reg_d_buf0 when others;--load,loadr
	
    lsu_write <= '1' when unit_op_buf0 = op_unit_lsu else '0';
	LSU0 : LSU port map (
		clk,lsu_write,lsu_ok,
		sub_op_buf0,
    	lsu_load_ok,lsu_full,
    	ls_address_p,ls_address,
    	ls_f,ls_reg_d,lsu_in,lsu_out,load_data,store_data
	);
	

	
	EX : process(CLK,rst)
	begin
		if rst = '1' then
			cr_flg_buf1 <= (others=> '0');
			alu_out_buf1 <= (others=> '0');
			alu_im_out_buf1 <=(others=> '0');
			fpu_out_buf1 <=(others=> '0');
			unit_op_buf1 <= (others=> '0');
		elsif rising_edge(clk) then
			cr_flg_buf1 <= cr_flg_buf0;
			alu_out_buf1 <= alu_out;
			alu_im_out_buf1 <= alu_im_out;
			fpu_out_buf1 <= fpu_out;
			
			unit_op_buf1 <= unit_op_buf0;
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
	 

	data_d <= value1 when path1_0(3) = '1' else
	load_data;
	 write_rob_1 <= path1_0(3) or lsu_load_ok;
	 
	with path1_0(2 downto 0) select
	  value1 <=  alu_im_out_buf1 when op_unit_alui,
	  alu_out_buf1 when op_unit_alu,
	  iou_out when op_unit_iou,
	  load_data when op_unit_lsu,
	  fpu_out_buf1 when others;
	  
    reg_d_write <= path1_0(9 downto 4) when path1_0(3) = '1' else ls_reg_d(5 downto 0);


end arch;
