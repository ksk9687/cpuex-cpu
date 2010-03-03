library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package SuperScalarComponents is

component ALU is
  port (
    clk  : in std_logic;
    op   : in std_logic_vector(1 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));
end component;


component ALU_IM is
  port (
 	clk : in std_logic;
    op : in std_logic_vector(2 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0);
    cmp  : out std_logic_vector(2 downto 0));
end component;


component branchPredictor is
	port  (
		clk,rst,flush :in std_logic;
		bp_ok :out std_logic;
		pc : in std_logic_vector(13 downto 0);
		jmp_num : out std_logic_vector(2 downto 0);
		jmp,b_taken,b_not_taken : in std_logic;
		taken,taken_hist : out std_logic
	);
end component;


component bru is
	port  (
		clk : in std_logic;
    	op   : in std_logic_vector(2 downto 0);-- call ret jmp(1:f,0:i)
    	mask   : in std_logic_vector(2 downto 0);
    	hist   : in std_logic;
    	A, B : in  std_logic_vector(31 downto 0);
    	pc : in  std_logic_vector(13 downto 0);
        jmpflg : out std_logic;
        newpc : out std_logic_vector(13 downto 0)
	);
end component;


component full_cache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(12 downto 0);
		set_addr: in std_logic_vector(12 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data1 : out std_logic_vector(35 downto 0);
		read_data2 : out std_logic_vector(35 downto 0)
	);
end component;

component irom is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(12 downto 0);
		set_addr: in std_logic_vector(12 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data1 : out std_logic_vector(35 downto 0);
		read_data2 : out std_logic_vector(35 downto 0)
	);
end component;

component block_dcache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit,hit_tag : out std_logic
	);
end component;

component block_s_dcache is
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit,hit_tag : out std_logic
	);
end component;

component baka_dcache is
	generic (
		width : integer := 9;
		depth : integer := 2048;
		check_width : integer := 5
	);

		
	port  (
		clk,clkfast : in std_logic;
		address: in std_logic_vector(19 downto 0);
		set_addr: in std_logic_vector(19 downto 0);
		set_data : in std_logic_vector(31 downto 0);
		set : in std_logic;
		--read_f : in std_logic;
		read_data : out std_logic_vector(31 downto 0);
		hit,hit_tag : out std_logic
	);
end component;


component clockgenerator is
  Port ( globalclk : in  STD_LOGIC;
         globalrst : in  STD_LOGIC;
         clock66 : out  STD_LOGIC;
         clock : out  STD_LOGIC;
         clock_180 : out  STD_LOGIC;
         reset : out  STD_LOGIC);
end component;


component decoder is 
port (
    inst : in std_logic_vector(35 downto 0);
    r1,r2 : out std_logic_vector(1 downto 0);
    d : out std_logic_vector(4 downto 0)
    );
end component;


component dff is
    Port (CLK,RST : in  STD_LOGIC;
          D : in  STD_LOGIC;
          Q : out  STD_LOGIC);
end component;


component FPU is

  port (
    clk  : in  std_logic;
    op   : in  std_logic_vector(2 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0);
    cmp  : out std_logic_vector(2 downto 0));

end component;


component instructionBuffer is
	port  (
		clk,flush : in std_logic;        -- input clock, xx MHz.
		read ,write: in std_logic;
		readok,writeok: out std_logic;
		readdata : out std_logic_vector(62 downto 0);
		writedata: in std_logic_vector(62 downto 0)
	);
end component;


component IOU is
	port  (
--		clk66,
		clk,enable : in std_logic;
		iou_op : in std_logic_vector(2 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		no : in std_logic_vector(4 downto 0);
		readdata : out std_logic_vector(31 downto 0)
		
		;RSRXD : in STD_LOGIC
		;RSTXD : out STD_LOGIC
		
		;io_read_buf_overrun : out STD_LOGIC
	);
end component;


component ledextd2 is
  Port (
    leddata   : in std_logic_vector(31 downto 0);
    leddotdata: in std_logic_vector(7 downto 0);
    outdata0 : out std_logic_vector(7 downto 0);
    outdata1 : out std_logic_vector(7 downto 0);
    outdata2 : out std_logic_vector(7 downto 0);
    outdata3 : out std_logic_vector(7 downto 0);
    outdata4 : out std_logic_vector(7 downto 0);
    outdata5 : out std_logic_vector(7 downto 0);
    outdata6 : out std_logic_vector(7 downto 0);
    outdata7 : out std_logic_vector(7 downto 0)
    );
end component;


component lsu is
	port  (
		clk,write,load_ok : in std_logic;
		op : in std_logic_vector(2 downto 0);
    	lsu_ok,lsu_full : out std_logic;--
    	
    	ls_addr_in : in std_logic_vector(19 downto 0);--
    	ls_addr_out : out std_logic_vector(19 downto 0);--
    	
    	ls_flg : out std_logic_vector(2 downto 0);--
    	reg_d : out std_logic_vector(5 downto 0);
    	
    	lsu_in : in std_logic_vector(31 downto 0);--
    	lsu_out : out std_logic_vector(31 downto 0);--
    	load_data : in std_logic_vector(31 downto 0);--
    	store_data : out std_logic_vector(31 downto 0)--
	);
end component;


component memory is 
    Port (
    clk,sramcclk,sramclk,clkfast	: in	  std_logic;
    
    pc : in std_logic_vector(12 downto 0);
    inst1 : out std_logic_vector(35 downto 0);
    inst2 : out std_logic_vector(35 downto 0);
    
    ls_flg : in std_logic_vector(2 downto 0);
    ls_addr : in std_logic_vector(19 downto 0);
    store_data : in std_logic_vector(31 downto 0);
    load_data : out std_logic_vector(31 downto 0);
    ls_ok : out std_logic;

		--SRAM
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
    ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
    ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
    ZD : inout STD_LOGIC_VECTOR(31 downto 0) -- bus
	);
end component;


component reg is 
port (
    clk,flush,rob_alloc1,rob_alloc2: in	  std_logic;

    pd,pd2 : in std_logic_vector(5 downto 0);
    s1,s2,s12,s22 : in std_logic_vector(5 downto 0);
       
    dflg: in std_logic;
    d: in std_logic_vector(5 downto 0);
    data_d : in std_logic_vector(31 downto 0);
    data_s1,data_s2,data_s12,data_s22 : out std_logic_vector(31 downto 0);
    
    s1_ok,s2_ok,s12_ok,s22_ok: out std_logic
    ); 
    
end component;


component reorderBuffer is
	port  (
		clk,flush : in std_logic;
		write1,write2,regwrite1,regwrite2 : in std_logic;
		write1ok,write2ok: out std_logic;
		
		op,op2 : in std_logic_vector(1 downto 0);
		reg_d,reg_d2,reg_s1,reg_s2,reg_s12,reg_s22 : in std_logic_vector(5 downto 0);
		
		reg_s1_ok,reg_s2_ok,reg_s12_ok,reg_s22_ok : out std_logic;
		reg_s1_data,reg_s2_data,reg_s12_data,reg_s22_data : out std_logic_vector(31 downto 0);
		s1tag,s2tag,s12tag,s22tag : out std_logic_vector(2 downto 0);
		newtag1,newtag2 : out std_logic_vector(2 downto 0);
		
		read: in std_logic;
		readok: out std_logic;
		reg_num : out std_logic_vector(5 downto 0);
		reg_data : out std_logic_vector(31 downto 0);
		outop : out std_logic_vector(1 downto 0);
		
		dwrite1,dwrite2,dwrite3 : in std_logic;
		dtag1,dtag2,dtag3 : in std_logic_vector(3 downto 0);
		value1,value2,value3 : in std_logic_vector(31 downto 0)
	);
end component;


component reservationStation is
	generic (
		opbits : integer := 2
	);
	port  (
		clk,flush : in std_logic;
		write : in std_logic;
		writeok: out std_logic;
		read : in std_logic;
		readok : out std_logic;
			
		inop: in std_logic_vector(opbits - 1 downto 0);
		indtag: in std_logic_vector(3 downto 0);
		ins1: in std_logic_vector(32 downto 0);
		ins2: in std_logic_vector(32 downto 0);

		outop: out std_logic_vector(opbits - 1 downto 0);
		outdtag: out std_logic_vector(3 downto 0);
		outs1: out std_logic_vector(31 downto 0);
		outs2: out std_logic_vector(31 downto 0);
		
		write1,write2 : in std_logic;
		dtag1,dtag2 : in std_logic_vector(3 downto 0);
		value1,value2 : in std_logic_vector(31 downto 0)
	);
end component;


component reservationStationBru is
	generic (
		opbits : integer := 3 + 3 + 14 + 1
	);
	port  (
		clk,flush : in std_logic;
		write : in std_logic;
		writeok: out std_logic;
		read : in std_logic;
		readok : out std_logic;
			
		inop: in std_logic_vector(opbits - 1 downto 0);
		indtag: in std_logic_vector(3 downto 0);
		ins1: in std_logic_vector(32 downto 0);
		ins2: in std_logic_vector(32 downto 0);

		outop: out std_logic_vector(opbits - 1 downto 0);
		outdtag: out std_logic_vector(3 downto 0);
		outs1: out std_logic_vector(31 downto 0);
		outs2: out std_logic_vector(31 downto 0);
		
		write1,write2,write3 : in std_logic;
		dtag1,dtag2,dtag3 : in std_logic_vector(3 downto 0);
		value1,value2,value3 : in std_logic_vector(31 downto 0)
	);
end component;


component returnAddressStack is
	port  (
		clk : in std_logic;
		jal,jr : in std_logic;
		pc : in std_logic_vector(14 downto 0);
		new_pc : out std_logic_vector(14 downto 0)
	);
end component;


component rs232cio is
  generic (
    READBITLEN    : integer := 1160;    -- 1bitにかかるクロックより少し大きい値
    READPADBITLEN : integer := 100;     -- データの採取間隔
    MERGINLEN     : integer := 10;      -- データの読み込み開始の余白
    STOPBACK      : integer := 50;     -- STOPBITをどれぐらい待たないか
    READBUFLENLOG : integer := 4;      -- バッファの大きさ

    WRITEBITLEN : integer := 1157;      -- 1bitにかかるクロックより少し小さい値
    NULLAFTSTOP : integer := 100;       -- STOPを送った後に念のために送る余白
    WRITEBUFLENLOG : integer := 10      -- バッファの大きさ
    );
  Port (
    CLK : in STD_LOGIC;
--    BUFCLK : in STD_LOGIC;
    RST : in STD_LOGIC;
    -- こちら側を使う
    RSIO_RD : in STD_LOGIC;     -- read 制御線
    RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
    RSIO_RC : out STD_LOGIC;    -- read 完了線
    RSIO_OVERRUN : out STD_LOGIC;    -- OVERRUN時1
    RSIO_WD : in STD_LOGIC;     -- write 制御線
    RSIO_WData : in STD_LOGIC_VECTOR(7 downto 0);   -- write data
    RSIO_WC : out STD_LOGIC;    -- write 完了線
    -- ledout : out STD_LOGIC_VECTOR(7 downto 0);
    -- RS232Cポート 側につなぐ
    RSRXD : in STD_LOGIC;
    RSTXD : out STD_LOGIC
    );
end component;


component sram_controller is
    Port (
		CLK : in STD_LOGIC
		;CLK_180 : in STD_LOGIC
		
		;ADDR    : in  std_logic_vector(19 downto 0)
		;DATAIN  : in  std_logic_vector(31 downto 0)
		;DATAOUT : out std_logic_vector(31 downto 0)
		;RW      : in  std_logic --0ならwrite,1ならread
		
		;i_d    : in  std_logic_vector(0 downto 0)
		;i_d_buf    : out  std_logic_vector(0 downto 0)
		;ADDRBUF    : out  std_logic_vector(19 downto 0)
	;
		--SRAM
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
    ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
    ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
    ZD : inout STD_LOGIC_VECTOR(31 downto 0) -- bus
	);
end component;

end package;
