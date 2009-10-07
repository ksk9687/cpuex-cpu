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
		;pc : out std_logic_vector(2 downto 0)
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
    	op : in std_logic_vector(5 downto 0);
    	A, B : in  std_logic_vector(31 downto 0);
    	C    : out std_logic_vector(31 downto 0)
    	);
    end component;
   	
   	component lsu is
   		port (
	    --clk			: in	  std_logic
	    lsop : in std_logic_vector(1 downto 0);
		
		reg : in std_logic_vector(31 downto 0);
		im : in std_logic_vector(15 downto 0);
		
	    loadstore : out std_logic;
		address : out std_logic_vector(31 downto 0)
	    );
   	end component;
   	
 
    component mem is
	port (
	    clk,fastclk,sramclk	: in	  std_logic;
	    
	    pc : in std_logic_vector(31 downto 0);
	    ls_address : in std_logic_vector(31 downto 0);
	    load_store : in std_logic;
	    write_data : in std_logic_vector(31 downto 0);
	    read_inst,read_data : out std_logic_vector(31 downto 0)
    ); 
    end component mem;
    

    
    component io_dummy_led
	port  (
		clk : in std_logic ;
		op : in std_logic_vector(1 downto 0) ;
		reg : in std_logic_vector(31 downto 0);
		data : out std_logic_vector(7 downto 0)
	);
	end component;
   
   signal clk : std_logic;
   
   signal inst : std_logic_vector(31 downto 0);
   signal pc : std_logic_vector(31 downto 0);
  
   signal alu_op : std_logic_vector(5 downto 0);
   signal fpu_op : std_logic_vector(5 downto 0);
   signal lsu_op : std_logic_vector(1 downto 0);
   signal iou_op : std_logic_vector(1 downto 0);
   signal pc_op : std_logic_vector(2 downto 0);
   
   signal im : std_logic_vector(15 downto 0);
   signal ex_im : std_logic_vector(31 downto 0);
   
   signal reg_d,reg_s1,reg_s2 : std_logic_vector(4 downto 0);
   
   signal data_d,data_s1,data_s2,alu_s2 : std_logic_vector(31 downto 0);
   
   signal alu_out,lsu_out,io_out : std_logic_vector(31 downto 0);
   signal s2select : std_logic;
   signal regwrite : std_logic;
   signal reg_write_select : std_logic_vector(2 downto 0);
   
   
   signal ls_f : std_logic;--0:ロード・1:ストア
   signal ls_address : std_logic_vector(31 downto 0);
begin
    ibufg01 : IBUFG PORT MAP (I=>CLKIN, O=>CLK);
	
   MEMORY : mem port map (
   	clk,clk,clk,
   	pc,
   	ls_address,
   	ls_f,
   	data_s1,
   	inst,lsu_out
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
   	pc_op
   );
   	
    -- 符号拡張
	ex_im <= sign_extention(im);
	
	--レジスタに書くものの選択
	with reg_write_select select
	 data_d <= alu_out when "000",
	 --今はない
	 --fpu_out when "001",
	 lsu_out when "010",
	 --今はない
	 --iou_out when "011",
	 pc + '1' when others;
	
	REGISTERS : reg port map (
		clk,
		reg_d,reg_s1,reg_s2,
		regwrite,
		data_d,
		data_s1,data_s2
	);
	
	--ALUに入れるものの選択
	with s2select select
	 alu_s2 <= ex_im when '1',
	 data_s2 when others;
	
	ALU1 : alu port map (
		alu_op,
		data_s1,alu_s2,
		alu_out
	);
	
   	LSU1 : lsu port map (
   		lsu_op,
   		data_s1,
   		im,
   		ls_f,
   		ls_address
   	);

	IOU1 : io_dummy_led port map (
		clk,
		iou_op,
		data_s1,
		ledout
	);

	PC1 : process (clk)
	begin
		if rising_edge(clk)then
			if pc_op = "000" then
				pc <= pc + 1;
			elsif pc_op = "001" then--jmp
				if (reg_s2(3) or (data_s1(2) and reg_s2(2)) or
		    	 (data_s1(1)and reg_s2(1)) or (data_s1(0)and reg_s2(0)) ) = '1' then
					pc <= pc + ex_im;
				else
					pc <= pc + 1;
				end if;
			elsif pc_op = "010" then--jal
				pc <= "00000000000" & reg_s2 & im;
			elsif pc_op = "011" then--jr
				pc <= data_s1;
			else--halt
				pc <= pc;
				--wait;
			end if;
		end if;
	end process PC1;
		
end synth;








