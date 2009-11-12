-- CPUのトップモジュール

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
  	
  BP0 : branchPredictor　port map (
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
   
   	----------------------------------
	-- 
	-- ID
	-- 
	----------------------------------
    DEC : decoder port map (
   	inst,
   	reg_d,reg_s1,reg_s2,
   	regwrite,
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
		reg_d_buf,reg_d,reg_s1,reg_s2,
		regwrite_f_buf,
		data_d,
		data_s1,data_s2
		cr,reg_ok
	);
	
	ID_RD : process(CLK)
	begin
		if rigind_edge(clk) then
			if reg_ok = '1' then
				unit_op <= inst(31 downto 29);
				sub_op <= inst(28 downto 26);
				im_buf0 <= im;
				reg_d_buf0 <= reg_d;
			else
			end if;
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
	
	ALU0 : alu port map (
		clk,
		sub_op,
		data_in_0,data_in_1,
		alu_out
	);	
	ALU_IM0 : alu_im port map (
		clk,
		sub_op,
		data_s1,im,
		alu_im_out
	);
	



end arch;
