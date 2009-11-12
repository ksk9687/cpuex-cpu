-- CPU�̃g�b�v���W���[��

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.util.all; 
use work.instruction.all; 
use work.SuperScalarComponents.all; 


entity cpu_top is
	port  (
	    CLKIN			: in	  std_logic--50Mhz
	    ;ledout		: out	std_logic_vector(7 downto 0)
	    
		--SRAM
		;SRAMAA : out  STD_LOGIC_VECTOR (19 downto 0)	--�A�h���X
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
   signal clk,clk90,clk180,clk2x,rst: std_logic := '0';
   signal stall,flush: std_logic := '0';
   signal cr: std_logic_vector(2 downto 0) := "000";
   
   signal reg_d,reg_s1,reg_s2 :std_logic_vector(5 downto 0) := (others=>'0');
begin
  	ROC0 : ROC port map (O => rst);
  	
	CLOCK0 : CLOCK port map (
  		clkin     => CLKIN,
        clkout2x    => clk,
		clkout2x90 => clk90,
		clkout2x180 => clk180,
		clkout2x270 => clk270,
		clkout4x => clk2x,
  		locked    => locked);
  	
  BP0 : branchPredictor�@port map (
  	clk,rst,
  	pc,
  	taken
  );
  
  
  	----------------------------------
	-- 
	-- IF
	-- 
	----------------------------------

	
  MEMORY : mem port map (
   	clk,clk,clk180,
   	pc,ls_address,
   	ls_f,data_s2,ok,
   	inst,lsu_out,lsu_ok
	,SRAMAA,SRAMIOA,SRAMIOPA
	,SRAMRWA,SRAMBWA
	,SRAMCLKMA0,SRAMCLKMA1
	,SRAMADVLDA,SRAMCEA
	,SRAMCELA1X,SRAMCEHA1X,SRAMCEA2X,SRAMCEA2
	,SRAMLBOA,SRAMXOEA,SRAMZZA
   );
   
   PC0:process(clk)
   begin
   	if rising_edge(clk) then
   		if jmp_taken then
   			pc <= jmp_addr;
   		else
   			pc <= pc + '1';
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
   	regwrite,cr_flg,
   	im,
   	reg_write_select
   );
  
	----------------------------------
	-- 
	-- RD
	-- 
	----------------------------------
  	REGISTERS : reg port map (
		clk,rst
		reg_d_buf,regwrite&reg_d,reg_s1_use&reg_s1,reg_s2_use&reg_s2,
		regwrite_f,cr_flg_buf1,cr_flg,
		cr_d,
		data_d,
		data_s1,data_s2
		cr,reg_ok
	);
	ext_im <= sign_extention(im);
	
	
	ID_RD : process(CLK)
	begin
		if rigind_edge(clk) then
			if reg_ok = '1' then
				unit_op <= inst(31 downto 29);
				sub_op <= inst(28 downto 26);
				reg_write_buf0 <= regwrite;
				cr_flg_buf0 <= cr_flg;
			else
				unit_op <= op_unit_sp;--STALL
				sub_op <= sp_op_nop;
				reg_write_buf0 <= '0';
			end if;
			mask <= data_s1(2 downto 0);
			im_buf0 <= im;
			ext_im_buf0 <= ext_im;
			reg_d_buf0 <= reg_d;
			jmp_addr <= reg_s1(5 downto 3)&reg_s2&im;
		end if;
	end process ID_RD;
	
	
	----------------------------------
	-- 
	-- EX
	-- 
	----------------------------------
	
	LED_OUT :process(clk)
	begin
		if rigind_edge(clk) then
			if (unit_op = op_unit_iou) and (sub_op = iou_op_led) then
				ledout <= not data_s1(7 downto 0);
			end if;
		end if;
	end process LED_OUT;
	
	--JMP
	jmp_taken <= not (((mask(2) and cr(2)) or (mask(1) and cr(1)) or (mask(0) and cr(0))));
	
	ALU0 : alu port map (
		clk,
		sub_op,
		data_in_0,data_in_1,
		alu_out,alu_cmp
	);	
	ALU_IM0 : alu_im port map (
		clk,
		sub_op,
		data_s1,im,
		alu_im_out,alui_cmp
	);
	
	EX1 : process(CLK)
	begin
		if rigind_edge(clk) then
			unit_op_buf1 <= unit_op;
			sub_op_buf1 <= sub_op;
			reg_d_buf1 <= reg_d_buf0;
			cr_flg_buf1 <= cr_flg_buf0;
		end if;
	end process ID_RD;
	
	EX2 : process(CLK)
	begin
		if rigind_edge(clk) then
			unit_op_buf2 <= unit_op_buf1;
			sub_op_buf2 <= sub_op_buf1;
			reg_d_buf2 <= reg_d_buf1;
		end if;
	end process ID_RD;
	
	EX3 : process(CLK)
	begin
		if rigind_edge(clk) then
			unit_op_buf3 <= unit_op_buf2;
			sub_op_buf3 <= sub_op_buf2;
			reg_d_buf3 <= reg_d_buf2;
		end if;
	end process ID_RD;
	
	----------------------------------
	-- 
	-- WR
	-- 
	----------------------------------
	
	with unit_op_buf1 select
	 cr_d <= alui_cmp when op_unit_alui,
	 --fpu_cmp when op_unit_fpu,
	 alu_cmp when others;
	 
	

end arch;
