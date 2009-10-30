-- CPUのトップモジュール

-- @module : cpu_top
-- @author : ksk
-- @date   : 2009/10/06

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.util.all; 
use work.instruction.all; 

library UNISIM;
use UNISIM.VComponents.all;

entity cpu_top is 
port (
    CLKIN			: in	  std_logic
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
        

architecture synth of cpu_top is
    component decoder
    	port(
	    inst : in std_logic_vector(31 downto 0)
	    
	    ;alu : out std_logic_vector(5 downto 0)
		;fpu : out std_logic_vector(5 downto 0)
	    
	    ;regd,regs1,regs2 : out std_logic_vector(4 downto 0)
	    ;reg_write : out std_logic
	    ;reg_write_select : out std_logic_vector(2 downto 0)-- ALU,FPU,LS,IO,PC
	    
	    ;s2select : out std_logic
	    ;im : out std_logic_vector(15 downto 0)
		
		;ls : out std_logic_vector(1 downto 0)
		;io : out std_logic_vector(1 downto 0)
		;led : out std_logic_vector(1 downto 0)
		;pc : out std_logic_vector(2 downto 0)
		;delay : out std_logic_vector(2 downto 0)
    	);
    end component;
    
    component reg
        port (
            clk		: in	  std_logic;
            d,s1,s2 : in std_logic_vector(4 downto 0);
            dflg : in std_logic;
            
            data_d : in std_logic_vector(31 downto 0);
            data_s1,data_s2 : out std_logic_vector(31 downto 0)
           	);          
    end component;
    	

	component alu
    	port (
 		clk : in std_logic;
    	op : in std_logic_vector(5 downto 0);
    	A0, B0 : in  std_logic_vector(31 downto 0);
    	C    : out std_logic_vector(31 downto 0)
    	);
    end component;

	component alu_im
    	port (
 		clk : in std_logic;
    	op : in std_logic_vector(5 downto 0);
    	A0, B0 : in  std_logic_vector(31 downto 0);
    	C    : out std_logic_vector(31 downto 0)
    	);
    end component;
    
   	component FPU
	  port (
		clk  : in  std_logic;
	    op   : in  std_logic_vector(5 downto 0);
	    A, B : in  std_logic_vector(31 downto 0);
	    O    : out std_logic_vector(31 downto 0)
	  );
	end component;
   	
   	
   	component lsu is
   		port (
	    --clk			: in	  std_logic
	    lsop : in std_logic_vector(1 downto 0);
		
		reg : in std_logic_vector(31 downto 0);
		im : in std_logic_vector(15 downto 0);
		
	    loadstore : out std_logic_vector(1 downto 0);
		address : out std_logic_vector(31 downto 0)
	    );
   	end component;
   	
 
    component mem is
	port (
	    clk,sramcclk,sramclk	: in	  std_logic;
	    
	    pc : in std_logic_vector(31 downto 0);
	    ls_address : in std_logic_vector(31 downto 0);
	    load_store : in std_logic_vector(1 downto 0);
	    write_data : in std_logic_vector(31 downto 0);
		ok	:in std_logic;
	    read_inst,read_data : out std_logic_vector(31 downto 0);
	    read_data_ready : out std_logic
    
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
    ); 
    end component mem;
   

   
   component IOU
	port  (
		clk : in std_logic;
		rst : in std_logic;
		iou_op : in std_logic_vector(1 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		readdata : out std_logic_vector(31 downto 0);
		ok : out std_logic
		
		;USBWR : out  STD_LOGIC
		;USBRDX : out  STD_LOGIC
		
		;USBTXEX : in  STD_LOGIC
		;USBSIWU : out  STD_LOGIC
		
		;USBRXFX : in  STD_LOGIC
		;USBRSTX : out  STD_LOGIC
		
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
	);
	end component;
   
    component clock
  port (
    clkin       : in  std_logic;
    clkout0     : out std_logic;
    clkout90    : out std_logic;
    clkout180   : out std_logic;
    clkout270   : out std_logic;
    clkout2x    : out std_logic;
    clkout2x180 : out std_logic;
    clkout2x270 : out std_logic;
    locked      : out std_logic);
	end component;

   
   signal clk,clk90,clk180,clk270,clk2x,clk2x180,clk2x270: std_logic := '0';
   signal rst : std_logic;
   
   signal sramc_clk : std_logic;
   signal sram_clk : std_logic;
   
   signal inst : std_logic_vector(31 downto 0) := op_halt&"00"&x"000000";
   signal pc,nextpc,jmp_pc : std_logic_vector(31 downto 0) := x"00100000";
  
   signal alu_op : std_logic_vector(5 downto 0) := (others => '0');
   signal fpu_op : std_logic_vector(5 downto 0) := (others => '0');
   signal lsu_op : std_logic_vector(1 downto 0) := (others => '0');
   signal iou_op : std_logic_vector(1 downto 0) := (others => '0');
   signal ledu_op : std_logic_vector(1 downto 0) := (others => '0');
   signal pc_op : std_logic_vector(2 downto 0) := (others => '0');
   
   signal im : std_logic_vector(15 downto 0) := (others => '0');
   signal ex_im : std_logic_vector(31 downto 0) := (others => '0');
   
   signal reg_d,reg_s1,reg_s2,reg_d_buf,reg_d_now : std_logic_vector(4 downto 0) := (others => '0');
   
   signal data_d,data_s1,data_s2,alu_s2,data_d_delay,data_d_now : std_logic_vector(31 downto 0) := (others => '0');
   
   signal alu_out,alu_im_out,fpu_out,lsu_out,iou_out : std_logic_vector(31 downto 0) := (others => '0');
   signal s2select : std_logic := '0';
   signal regwrite,regwrite_buf : std_logic := '0';
   signal regwrite_f : std_logic := '0';
   signal reg_write_select,reg_write_select_buf,reg_write_select_now : std_logic_vector(2 downto 0) := (others => '0');
   signal delay,inst_delay,tmp : std_logic_vector(2 downto 0) := (others => '0');
   
   signal ls_f : std_logic_vector(1 downto 0) := "00";--10:ロード・11:ストア
   signal ls_address : std_logic_vector(31 downto 0) := (others => '0');
   signal read_data_ready : std_logic := '0';
   
   signal counter : std_logic_vector(31 downto 0) := (others => '0');
   signal io_led : std_logic_vector(7 downto 0) := (others => '0');
   signal ok,lsu_ok,fpu_ok,iou_ok   : std_logic := '0';
   
   
	signal locked   : std_logic;
	signal logicl : std_logic := '0';
begin

  ROC0 : ROC
    port map (
      O => rst);
      
    --参考
    --http://svn.assembla.com/svn/cpu_egi_han/cpu/vhdl/io/sram-test/sram-test2/clock.vhdl
  		CLOCK0 : CLOCK port map (
        clkin     => CLKIN,
        clkout0   => clk,
        clkout90  => clk90,
        clkout180 => clk180,
        clkout270 => clk270,
        --clkout2x    => clk,
    	--clkout2x180 => clk180,
    	--clkout2x270 => clk270,
        locked    => locked
        );
        
    
    ledout <= not io_led;
    
    
--	process (CLK1) begin
--		if (CLK1'event and CLK1 = '1') then
--			counter <= counter+'1'; 
--			--if counter(21 downto 0) = "10"&"0000000000"&"0000000000" then
--				CLK <= not CLK;
--			--end if;
--		end if;
--	end process;
	
   MEMORY : mem port map (
   	clk,clk,clk180,
   	pc,
   	ls_address,
   	ls_f,
   	data_s2,
   	ok,
   	inst,lsu_out,lsu_ok
	,SRAMAA,SRAMIOA,SRAMIOPA
	,SRAMRWA,SRAMBWA
	,SRAMCLKMA0,SRAMCLKMA1
	,SRAMADVLDA,SRAMCEA
	,SRAMCELA1X,SRAMCEHA1X,SRAMCEA2X,SRAMCEA2
	,SRAMLBOA,SRAMXOEA,SRAMZZA
   );
   

   DEC : decoder port map (
   	inst,
   	alu_op,
   	fpu_op,
   	reg_d,reg_s1,reg_s2,
   	regwrite,
   	reg_write_select,
   	s2select,
   	im,
   	lsu_op,
   	iou_op,
   	ledu_op,
   	pc_op,
   	delay
   );
   	
    -- 符号拡張
	ex_im <= sign_extention(im);
	 
	 with reg_write_select_now select
	  data_d_delay <= alu_out when "000",
	  alu_im_out when "101",
	  fpu_out when "001",
	  lsu_out when "010", 
	  iou_out when "011",
	  pc + '1' when others;


   ok <= '0' when iou_ok = '0' and reg_write_select_now = "011" else
   '0' when lsu_ok = '0' and reg_write_select_now = "010" else
   '0' when inst_delay /= "000" and inst_delay /= "001" and inst_delay /= "111" else
   '0' when delay /= "000" else
   '1';
   
	reg_write_select_now <= reg_write_select_buf when inst_delay /= "000" else
	reg_write_select;
	
	reg_d_now <= reg_d_buf when inst_delay /= "000" else
	reg_d;
	
	regwrite_f <= regwrite when inst_delay = "000" and delay = "000" else
	regwrite_buf when ok = '1' else
	'0';
	
	REGISTERS : reg port map (
		clk,
		reg_d_now,reg_s1,reg_s2,
		regwrite_f,
		data_d_delay,
		data_s1,data_s2
	);
	
	
	ALU1 : alu port map (
		clk,
		alu_op,
		data_s1,data_s2,
		alu_out
	);	
	ALU2 : alu_im port map (
		clk,
		alu_op,
		data_s1,ex_im,
		alu_im_out
	);
	FPU1 : fpu port map (
	clk,
		fpu_op,
		data_s1,data_s2,
		fpu_out
	);
	
   	LSU1 : lsu port map (
   		lsu_op,
   		data_s1,
   		im,
   		ls_f,
   		ls_address
   	);

	IOU2 : io_dummy_led port map (
		clk,
		ledu_op,
		data_s1,
		io_led
	);

	IOU1 : iou port map (
		clk,rst,
		iou_op,
		data_s1,
		iou_out,
		iou_ok,
		USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRST,USBD
	);

	--プログラムカウンタ
	jmp_pc <= pc + ex_im when (((data_s1(2) and reg_s2(2)) or (data_s1(1) and reg_s2(1)) or (data_s1(0) and reg_s2(0)))) = '0' else
	pc + 1;
	
	with pc_op select
	 nextpc <= pc + 1 when "000",
	 jmp_pc when "001",
	 "000000" & reg_s1 & reg_s2 & im when "010",--jal
	 data_s1 when "011",--jr
	 pc when others;

	PC1 : process (clk,rst)
	begin
		if rst = '1' then
		 	pc <= x"00100000";
		elsif rising_edge(clk)then
			pc <= nextpc;
		end if;
	end process PC1;

	--１クロックで終了しない命令のために・・・	
	ContDown : process (clk)
	begin
		if rising_edge(clk)then
			if (delay /= "000") then--新しい遅延のある命令が発行された。
				inst_delay <= delay;
				reg_d_buf <= reg_d;
				regwrite_buf <= regwrite;
				reg_write_select_buf <= reg_write_select;
			elsif inst_delay = "111" then
				if ok = '1' then
					inst_delay <= "000";
				else
					inst_delay <= inst_delay;
				end if;
			elsif inst_delay /= "000" then
				inst_delay <= inst_delay - '1';
			end if;
		end if;
	end process ContDown;
	
end synth;








