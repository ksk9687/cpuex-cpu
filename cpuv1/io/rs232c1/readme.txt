This file is written in UTF-8

RS232C モジュール (実機では未テスト) 及びシミュレーションモジュール

[注意]
制御線は使っていません。なので、データがどんどん流れ込んで、バッファオーバーランしますが、read用のバッファが分散RAMになってしまったので、かなり小さいです。バッファにデータをためないでください。バッファオーバーランを検知する線を残しておきます。
今 921.6kbps を想定して作っています。速度を変える場合は、rs232cio1_read.vhd,rs232cio1_write.vhdのconstants両方を変えてください。<-genericにしろよって話だが

[ファイル]
rs232cio1.vhd : RS232C モジュール
	rs232cio1_read.vhd : サブモジュール
	rs232cio1_write.vhd : サブモジュール

rs232ctb2.vhd : シミュレーションモジュール

他のファイルはあくまで参考
上のファイル群中での文字コードはSJISです。(ISEがそれで動くんだもん)

[モジュール]
基本的にUSBモジュールにあわせていますが、こちらは読み込み、書き出しが同時にできることに注意してください。

  Port (
    CLK : in STD_LOGIC;
    RST : in STD_LOGIC;
    -- こちら側を使う
    RSIO_RD : in STD_LOGIC;     -- read 制御線:1にすると、バッファから1個消す
    RSIO_RData : out STD_LOGIC_VECTOR(7 downto 0);  -- read data
    RSIO_RC : out STD_LOGIC;    -- read 完了線:1の時読んでよい
    RSIO_OVERRUN : out STD_LOGIC;    -- readのOVERRUN時1
    RSIO_WD : in STD_LOGIC;     -- write 制御線:1にすると、データを取り込む
    RSIO_WData : in STD_LOGIC_VECTOR(7 downto 0);   -- write data
    RSIO_WC : out STD_LOGIC;    -- write 完了線:1の時書き込んでよい
    --ledout : out STD_LOGIC_VECTOR(7 downto 0);
    -- RS232Cポート 側につなぐ
    RSRXD : in STD_LOGIC;
    RSTXD : out STD_LOGIC
    );

[使い方]
基本的に、1クロックの中で動作させるためには、RSIO_RDやRSIO_WDを1にした状態で、出てきた信号をチェックしてください。
つまり、readしたいときは、
1.RSIO_RDを1にする
2.次のクロックで、RSIO_RData,RSIO_RCを保存、RSIO_RCをチェックして、1だったら有効なデータである
writeしたいときは、
1.RSIO_WDを1にし、RSIO_WDataにデータを出力する
2.次のクロックで、RSIO_WCをみて、1だったら、データの送信が受理されている

バッファの境界にエラーがある可能性があるので、600KBぐらいの読み書きをテストしてください。

[UCFを書くとき]
実機動作はまださせていません。
新基板で動作させた方がいいらしいです。
RSRXD,RSTXDは、間に電圧を調整する石が入っているかどうかを確認してください。入っている場合は、LVTTLで問題ないらしいです。
配線図を見て、どこにつながっているかを確認してください。
NET "RSRXD" LOC = "????" | IOSTANDARD = LVTTL ;
NET "RSTXD" LOC = "????" | IOSTANDARD = LVTTL ;
こんな感じ

もし間に石がない場合、自分で電圧をあわせる必要があります。
RS232Cでは、
1:-12V,
0:+12V
というように、通常とは電圧のHigh,Lowが逆なので注意してください。

[シミュレーションモデル]
rs232ctb2.vhdを見てください。
まず、モジュールの読み込みのところで、echoと書かれているモジュールがありますが、これはrs232c_test.vhd(echo鯖)のテストをするものです。ここをシミュレーションしたいモジュールに置き換えてください。(もちろん下の方も)
次に、62行目辺りのSENDDATAを見てください。その前の行のSENDSIZEの大きさと、ここを書き換えることで、送信内容を書き換えることができます。送信せずに待つなどの機能はないので注意してください。
このモジュールのシミュレーションでOVERRUNがたってしまったときは適宜調整してください。
このまま動かすと、read/writeに55clk/bitかかるので、シミュレーションでは速くするといいでしょう。
