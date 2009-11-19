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
   signal clk,clk90,clk180,clk270,clk2x,rst,locked0: std_logic := '0';
   signal stall,flush: std_logic := '0';
   signal inst_ok,lsu_ok,reg_ok : std_logic := '0';
   signal im : std_logic_vector(13 downto 0);
   signal ext_im,data_s1,data_s2,data_s1_p,data_s2_p,data_im : std_logic_vector(31 downto 0);
   --Inst
   signal nextpc,pc,jmp_addr,pc_p1 : std_logic_vector(20 downto 0) := '1'&x"00000";
   signal inst,inst_b : std_logic_vector(31 downto 0) := (others=>'0');
   --LS
   signal ls_f : std_logic_vector(1 downto 0) := (others=>'0');
   signal ls_addr,lsu_out,ls_data :std_logic_vector(31 downto 0) := (others=>'0');
   signal ls_address :std_logic_vector(20 downto 0) := (others=>'0');
   --register
   signal pd,s1,s2 :std_logic_vector(6 downto 0) := (others=>'0'); 
   signal cr,cr_d: std_logic_vector(2 downto 0) := "000";
   signal reg_d,reg_d_b,reg_d_buf,reg_s1,reg_s1_b,reg_s2,reg_s2_b :std_logic_vector(5 downto 0) := (others=>'0');
   signal reg_s1_use,reg_s2_use,regwrite,reg_s1_use_b,reg_s2_use_b,regwrite_b,regwrite_f :std_logic := '0';
   signal dflg,cr_flg,cr_flg_b,pcr_flg : std_logic_vector(1 downto 0) := (others=>'0');
   signal data_d : std_logic_vector(31 downto 0) := (others=>'0');
   
	--ALU
	signal alu_out :std_logic_vector(31 downto 0) := (others=>'0');
	signal alu_cmp :std_logic_vector(2 downto 0) := "000";
	--ALUI
	signal alu_im_out :std_logic_vector(31 downto 0) := (others=>'0');
	signal alui_cmp :std_logic_vector(2 downto 0) := "000";
	--pipeline crtl
	signal unit_op_buf0,unit_op_buf1,unit_op_buf2,unit_op_buf3 :std_logic_vector(2 downto 0) := (others=>'0');
	signal sub_op_buf0,sub_op_buf1,sub_op_buf2,sub_op_buf3 :std_logic_vector(2 downto 0) := (others=>'0');
	signal reg_write_buf0,reg_write_buf1,reg_write_buf2,reg_write_buf3:std_logic := '0';
	signal cr_flg_buf0,cr_flg_buf1,cr_flg_buf2,cr_flg_buf3 : std_logic_vector(1 downto 0) := (others=>'0');
	signal mask : std_logic_vector(2 downto 0) := (others=>'1');
	signal im_buf0,ext_im_buf0 :std_logic_vector(31 downto 0) := (others=>'0');
	signal reg_d_buf0,reg_d_buf1,reg_d_buf2,reg_d_buf3:std_logic_vector(5 downto 0) := (others=>'0');
			
   	
   signal jmp_taken,taken : std_logic := '0';
begin
	USBWR <= '0';
	USBRDX <= '0';
	USBSIWU <= '0';
	USBRST <= '0';
	USBD <= (others => 'Z');


  	ROC0 : ROC port map (O => rst);
  	
	CLOCK0 : CLOCK port map (
  		clkin     => CLKIN,
    	clkout2x    => clk,
		clkout2x90 => clk90,
		clkout2x180 => clk180,
		clkout2x270 => clk270,
		clkout4x => clk2x,
  		locked    => locked0);
  	
  BP0 : branchPredictor port map (
  	clk,rst,
  	pc(19 downto 0),inst(13 downto 0),
  	taken
  );
  
  	----------------------------------
	-- 
	-- IF
	-- 
	----------------------------------

  MEMORY0 : memory port map (
   	clk,rst,clk,clk180,
   	pc,inst,inst_ok,
   	ls_f,ls_address(19 downto 0),ls_data,lsu_out,lsu_ok
	,SRAMAA,SRAMIOA,SRAMIOPA
	,SRAMRWA,SRAMBWA
	,SRAMCLKMA0,SRAMCLKMA1
	,SRAMADVLDA,SRAMCEA
	,SRAMCELA1X,SRAMCEHA1X,SRAMCEA2X,SRAMCEA2
	,SRAMLBOA,SRAMXOEA,SRAMZZA
   );
   
   

   
   stall <= '1' when inst(31 downto 26) = op_halt else
   '1' when inst(31 downto 26) = op_jmp else
   '0';
   
   PC0:process(clk,rst)
   begin
   if (rst = '1')then
   		pc <= '1'&x"00000";
   elsif rising_edge(clk) then
   		if jmp_taken = '1' then
   			pc <= jmp_addr;
   		elsif stall = '1' then 
   			pc <= pc;
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
   	regwrite,cr_flg
   );
   
  	IF_ID : process(CLK)
	begin
		if rising_edge(clk) then
			inst_b <= inst;
			reg_d_b <= reg_d;
			reg_s1_b <= reg_s1;
			reg_s2_b <= reg_s2;
			reg_s1_use_b <= reg_s1_use;
			reg_s1_use_b <= reg_s2_use;
			regwrite_b <= regwrite;
			cr_flg_b <= cr_flg;
			im <= inst(13 downto 0);
		end if;
	end process IF_ID;
	----------------------------------
	-- 
	-- RD
	-- 
	----------------------------------
	
	pd <= regwrite_b&reg_d_b;
	s1 <= reg_s1_use_b&reg_s1_b;
	s2 <= reg_s2_use_b&reg_s2_b;
	
	REGISTERS : reg port map (
		clk,rst,
		reg_d_buf,pd,s1,s2,
		regwrite_f,cr_flg_buf1,cr_flg_b,
		cr_d,
		data_d,
		data_s1_p,data_s2_p,
		cr,reg_ok
	);
	ext_im <= sign_extention(im);
	
	
	RD : process(CLK)
	begin
		if rising_edge(clk) then
			if reg_ok = '1' then
				unit_op_buf0 <= inst_b(31 downto 29);
				sub_op_buf0 <= inst_b(28 downto 26);
				reg_write_buf0 <= regwrite;
				cr_flg_buf0 <= cr_flg;
			else--STALL
				unit_op_buf0 <= op_unit_sp;
				sub_op_buf0 <= sp_op_nop;
				reg_write_buf0 <= '0';
				cr_flg_buf0 <= "00";
			end if;
			mask <= data_s1_p(2 downto 0);
			im_buf0 <= "00"&x"0000"&im;
			ext_im_buf0 <= ext_im;
			reg_d_buf0 <= reg_d;
			jmp_addr <= reg_s1(3)&reg_s2&im;--21bit
			data_s1 <= data_s1_p;
			data_s2 <= data_s1_p;
		end if;
	end process RD;
	
	
	----------------------------------
	-- 
	-- EX
	-- 
	----------------------------------
	
	LED_OUT :process(clk)
	begin
		if rising_edge(clk) then
			if (unit_op_buf0 = op_unit_iou) and (sub_op_buf0 = iou_op_led) then
				ledout <= not data_s1(7 downto 0);
			end if;
		end if;
	end process LED_OUT;
	
	--JMP
	jmp_taken <= not (((mask(2) and cr(2)) or (mask(1) and cr(1)) or (mask(0) and cr(0)))) when unit_op_buf0&sub_op_buf0 = op_jmp else
	'0';
	
	ALU0 : alu port map (
		clk,
		sub_op_buf0,
		data_s1,data_s2,
		alu_out,alu_cmp
	);	
	
	data_im <= "00"&x"0000"&im;
	--TODO 拡張符号
	ALU_IM0 : alu_im port map (
		clk,
		sub_op_buf0,
		data_s1,data_im,
		alu_im_out,alui_cmp
	);
	
	EX1 : process(CLK)
	begin
		if rising_edge(clk) then
			unit_op_buf1 <= unit_op_buf0;
			sub_op_buf1 <= sub_op_buf0;
			reg_d_buf1 <= reg_d_buf0;
			cr_flg_buf1 <= cr_flg_buf0;
		end if;
	end process EX1;
	
	EX2 : process(CLK)
	begin
		if rising_edge(clk) then
			unit_op_buf2 <= unit_op_buf1;
			sub_op_buf2 <= sub_op_buf1;
			reg_d_buf2 <= reg_d_buf1;
		end if;
	end process EX2;
	
	EX3 : process(CLK)
	begin
		if rising_edge(clk) then
			unit_op_buf3 <= unit_op_buf2;
			sub_op_buf3 <= sub_op_buf2;
			reg_d_buf3 <= reg_d_buf2;			
		end if;
	end process EX3;
	
	----------------------------------
	-- 
	-- WR
	-- 
	----------------------------------
	
	--コンディションレジスタ
	with unit_op_buf1 select
	 cr_d <= alui_cmp when op_unit_alui,
	 --fpu_cmp when op_unit_fpu,
	 alu_cmp when others;
	 
	--@TODO 書き込みスケジューリング
	-- ぶつかったときどうするの？
	reg_d_buf <= reg_d_buf0 when unit_op_buf0 = op_unit_alu else
	"000000";
	
	with unit_op_buf1 select
	 data_d <= alu_im_out when op_unit_alui,
	 --fpu_out when op_unit_fpu,
	 --lsu_out when op_unit_fpu,
	 alu_out when others;
	
		
	regwrite_f <= '1' when unit_op_buf1 = op_unit_alu else
	'1' when unit_op_buf1 = op_unit_alui else
	'0';

end arch;
