バッファ付きUSB I/Oの説明

[ファイル]usbio1_buf.vhd,usbio1.vhd
[参考]usbio1_test2.vhdという、16byteごとにエコーするプログラムを付しておきます。
【重要】usbio1.vhdを更新しました。前回のものにバグがあったので、修正しておきます。また、このモジュールを作るにあたり、多少信号を増やしています。
【重要】usbio1.vhdは20nsで動作します。

[インターフェース]
clk : in STD_LOGIC; --20nsクロック
RST : in STD_LOGIC; --リセット信号
-- こちらを使用
USBBUF_RD : in STD_LOGIC;     -- read 制御:1にすると、バッファから1個消す
USBBUF_RData : out STD_LOGIC_VECTOR(7 downto 0);      -- read data
USBBUF_RC : out STD_LOGIC;    -- read 完了:1の時読んでよい
USBBUF_WD : in STD_LOGIC;     -- write 制御:1にすると、データを取り込む
USBBUF_WData : in STD_LOGIC_VECTOR(7 downto 0);       -- write data
USBBUF_WC : out STD_LOGIC;    -- write 完了:1の時書き込んでよい
--ledout : out STD_LOGIC_VECTOR(7 downto 0);
-- FT245BM 側につなぐ
USBRD : out  STD_LOGIC;
USBRXF : in  STD_LOGIC;
USBWR : out  STD_LOGIC;
USBTXE : in  STD_LOGIC;
USBSIWU : out  STD_LOGIC;
USBRST : out  STD_LOGIC;
USBD : inout  STD_LOGIC_VECTOR (7 downto 0)

[使い方]
基本的に、1クロックの中で動作させるためには、USBBUF_RDやUSBBUF_WDを1にした状態で、出てきた信号をチェックしてください。
つまり、readしたいときは、
1.USBBUF_RDを1にする
2.次のクロックで、USBBUF_RData,USBBUF_RCを保存、USBBUF_RCをチェックして、1だったら有効なデータである
writeしたいときは、
1.USBBUF_WDを1にし、USBBUF_WDataにデータを出力する
2.次のクロックで、USBBUF_RCをみて、1だったら、データの送信が受理されている

バッファの境界にエラーがある可能性があるので、600KBぐらいの読み書きをテストしてください。


---------------------------------------------------------------------------------------------------
以下中身のメモ

信号
	USBBUF_RD
	USBBUF_RData
	USBBUF_RC
	USBBUF_WD
	USBBUF_WData
	USBBUF_WC
	
	USBIO_RD
	USBIO_RData
	USBIO_RC
	USBIO_WD
	USBIO_WData
	USBIO_WC
	
	USBRXF
	USBTXE

	readbuf
	readbuf_writeaddr
	readbuf_readaddr
	readdata
	--readflag
	
	writebuf
	writebuf_writeaddr
	writebuf_readaddr
	writedata
	writeflag

	state
	
	lastRC
	lastWC



通常
	USBBUF_RData <= "00000000" when (readbuf_readaddr = readbuf_writeaddr) else readbuf(readbuf_readaddr);
	USBBUF_RC <= '0' when (readbuf_readaddr = readbuf_writeaddr) else '1';
	
	writedata <= "00000000" when (writebuf_readaddr = writebuf_writeaddr) else readbuf(writebuf_readaddr);
	writeflag <= '0' when (writebuf_readaddr = writebuf_writeaddr) else '1';
	USBBUF_WData <= writedata;
	USBBUF_WC <= '0' when (writebuf_readaddr = writebuf_writeaddr+1) else '1';
	
バッファへの書き込み
in clk
	on USBBUF_WD
		writebuf(writebuf_writeaddr) <= USBBUF_WData;
	
	on read完了
		readbuf(readbuf_writeaddr) <= USBIO_RData;

バッファ送り
	on USBBUF_RD
		if readbuf_readaddr != readbuf_writeaddr then
			writebuf_readaddr<=writebuf_readaddr+1;
	on USBBUF_WD
		if writebuf_readaddr != writebuf_writeaddr+1 then
			writebuf_writeaddr<=writebuf_writeaddr+1;
	on read完了
		readbuf_readaddr == readbuf_writeaddr+1のときは読まない
		if readbuf_readaddr != readbuf_writeaddr+1 then
			readbuf_writeaddr <= readbuf_writeaddr+1;
	on write完了
		writebuf_readaddr <= writebuf_readaddr+1;

in clk
	lastRC <= USBIO_RC
	lastWC <= USBIO_WC
	
	
	

-------------------------------------------------------------------------------------------------------

通常
	USBBUF_RData <= "00000000" when (readbuf_readaddr = readbuf_writeaddr or 初期状態) else readbuf(readbuf_readaddr);
	USBBUF_RC <= '0' when (readbuf_readaddr = readbuf_writeaddr or 初期状態) else '1';
	
	writedata <= "00000000" when (writebuf_readaddr = writebuf_writeaddr) else writebuf(writebuf_readaddr);
	writeflag <= '0' when (writebuf_readaddr = writebuf_writeaddr) else '1';
	USBBUF_WC <= '0' when (writebuf_readaddr = writebuf_writeaddr+1 or 初期状態) else '1';

各状態の信号
STATE_IDLE
	USBIO_RD<='0';
	USBIO_WD<='0';
	USBIO_WData<=(others=>'Z');
STATE_WAIT_READ
	USBIO_RD<='1';
	USBIO_WD<='0';
	USBIO_WData<=(others=>'Z');
	readdata <=USBIO_RData;
STATE_WAIT_WRITE
	USBIO_RD<='0';
	USBIO_WD<='1';
	USBIO_WData<=writedata;

初期状態
	lastRC <= '1';
	lastWC <= '1';
	readbuf_readaddr<=0;
	readbuf_writeaddr<=0;
	writebuf_readaddr<=0;
	writebuf_writeaddr<=0;
	state <= STATE_IDLE;


クロック
	lastRC <= USBIO_RC
	lastWC <= USBIO_WC
	on USBBUF_RD
		if readbuf_readaddr != readbuf_writeaddr then
			readbuf_readaddr<=readbuf_readaddr+1;
	on USBBUF_WD
		if writebuf_readaddr != writebuf_writeaddr+1 then
			writebuf_writeaddr<=writebuf_writeaddr+1;
		writebuf(writebuf_writeaddr) <= USBBUF_WData;


ステートマシン
STATE_IDLE
	if USBRXF='0' and (readbuf_readaddr != readbuf_writeaddr+1) then
		-- read
		goto STATE_WAIT_READ;
	elsif USBTXE = '0' and writeflag then
		-- write
		goto STATE_WAIT_WRITE;
	else
		goto STATE_IDLE;
	end if;
STATE_WAIT_READ
	if lastRC = '0' and USBIO_RC = '1' then
		-- 完了
		readbuf(readbuf_writeaddr) <= readdata;
		readbuf_writeaddr <= readbuf_writeaddr+1;
		goto STATE_IDLE;
	else
		goto STATE_WAIT_READ;
	end if;
STATE_WAIT_WRITE
	if lastWC = '1' and USBIO_WC = '0'
		-- 完了
		writebuf_readaddr <= writebuf_readaddr+1;
		goto STATE_IDLE;
	else
		goto STATE_WAIT_WRITE;
	end if;





