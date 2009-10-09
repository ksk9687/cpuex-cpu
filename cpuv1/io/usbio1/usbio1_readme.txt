This file is written in UTF-8

[note]現在バッファを待つ方式の物を書いています。

第1期USB用I/Oモジュール
動作クロック:20ns

[インターフェース]
in:クロック・RTS,   read:read制御    write:write制御,writedata
out:read:read完了線,readdata       write:write完了線

FT245BM側
RD:out:こちらが出す受信要求
RXF:in:受信可能
WR:out:こちらが出す送信要求
TXE:in:送信可能
SIWU:out:1だっけ(0はsend immediate)
D:inout:データ、使わないときは(others=>'Z')を入れておく

[使い方]
使わないとき:
read制御=0,write制御=0,writedataは任意
出力は、read完了線・write完了線は1

read:
readは、readdataの接続先を指定して、
read制御を0から1に上げる。
しばらく待つと、read完了線が0になってから1に戻る。
ユーザー側はこれを監視して、1に戻るまでread制御やreaddataの先を変えてはならない
1に戻ったら、データを取り出したり、read先を変えたりしてよい。
read完了線が戻ってから、しばらく後始末をするので、この後すぐにはread処理は始まりません。

write:
writedataにデータを指定してwrite制御線を1にする。
しばらくするとwrite完了線が0になるので、それを確認したら、write制御線を戻したりdataを変えてよい。
write完了線がまた1に戻るのは、処理が完了したときで、それより前にデータなどをセットしておいてよい。

基本的に、直前のクロックでの完了線を記憶しておいて、対応した変化がおきたかどうかを見ればいいと思います。

両方同時になにかしようとすると多分バグるのでやめてね。

---------------------------------------------------------------------------------------------------------
以下中身に関するメモ

variable:state,timecounter
初期化:state=0,timecounter=0
通常時:RD=1,WR=0,D='Z'

read時
RXFが1なら0になるのを待つ。(RDを1にする)
RXFが0になる:読めるぞ
RDを0にする
30ns待つ
Dを読む('Z'の出力はする)
20ns待つ
RDを1に戻す
25ns待つ
RXFが1に戻るのを確認する
RDを1にするのは、50ns後にするといいかもしれない

write時
TXEが1なら0になるまで待つ
TXEが0なら送信可
WRを1にする
Dに書き込む(この後しばらく)
50ns待つ
WRを0にする
10ns待つ
Dへの書き込みをやめる
15ns待つ
TXEが戻る監視はいい加減でいいかもしれない





ステートマシンは全ての信号を記述した方がいいのでは？
ステート名を、各信号の集合にして取り出すと面白いかも

具体的な処理
read時
0:	命令を待っている状態
	各クロックでread制御が立つのを監視
	もし立った場合
		read完了線を0にする。
		RXFを見て、1なら
			1へ
		0なら
			RDを0にする
			timecounter=clock;//initialize
			2へ
1:	RXFが0になるのを待つ状態
	RXFを見て、1なら
		そのまま
	0なら
		RDを0にする
		timecounter=clock;//initialize
		2へ
2:	RDを0にしてから30ns待つ状態
	if timecounter>=30ns then
		Dをreadに取り込む('Z'の出力はする)
		read完了線を1にする。
		timecounter=clock;//initialize
		3へ
	else
		timecounter+=clock;
		2へ
3:	Dを読んだあと20ns待つ状態
	if timecounter>=20ns then
		timecounter=clock;//initialize
		RD=1
		4へ
	else
		timecounter+=clock;
		3へ
4:	RDを1に戻した後、25ns待つ状態
	if timecounter>=25ns--75ns then
		//read完了線を1にする。(上に移した)
		0へ//どうせこの後待つことになるので、オーバーヘッドにならない
	else
		timecounter+=clock;
		4へ


write時
TXEが1なら0になるまで待つ
TXEが0なら送信可
WRを1にする
Dに書き込む(この後しばらく)
50ns待つ
WRを0にする
10ns待つ
Dへの書き込みをやめる
15ns待つ
TXEが戻る監視はいい加減でいいかもしれない

write時
0:	命令を待っている状態
	各クロックでwrite制御が立つのを監視
	もし立った場合
		write完了線を0にする。
		TXEを見て、1なら
			1へ
		0なら
			WRを1にする
			Dにデータを出力
			timecounter=clock;//initialize
			2へ
1:	TXFが0になるのを待つ状態
	TXFを見て、1なら
		そのまま
	0なら
		WRを1にする
		Dにデータを出力
		timecounter=clock;//initialize
		2へ
2:	WRを1にしてから50ns待つ状態
	Dにデータを出力
	if timecounter>=50ns then
		WRを0にする
		timecounter=clock;//initialize
		3へ
	else
		timecounter+=clock;
		2へ
3:	WRを0にしたあと10ns待つ状態
	if timecounter>=10ns then
		timecounter=clock;//initialize
		Dへの出力をやめる('Z'を出力する)
		4へ
	else
		timecounter+=clock;
		3へ
4:	出力をやめた後、15ns待つ状態
	if timecounter>=15ns then
		write完了線を1にする。
		0へ//どうせこの後待つことになるので、オーバーヘッドにならない
	else
		timecounter+=clock;
		4へ




------------------------------------------------------------------



read完了線
readdata
write完了線
RD
WR
SIWU
D
state
timecounter


非依存
SIWU=1

初期化
read完了線=1
write完了線=1
RD=1
WR=0

readdata=0//no reason
D='Z'
timecounter=0
state="1110"

state形式
「read完了線,write完了線,RD,WR,識別子(2)」
識別子の2bit目は、Dに'Z'を出力するかデータを出力するかにしてみた。
->
if 2bit目 = 1 then
	D = write
else
	D='Z'



ステートマシンは全ての信号を記述した方がいいのでは？
ステート名を、各信号の集合にして取り出すと面白いかも

具体的な処理
read時
0:	命令を待っている状態
	WAIT_INST="111000"
	if read制御 = 1 then
		if RXF = 1 then
			timecounter=0
			state=WAIT_RXF
		else
			timecounter=clock;//initialize
			state=WAIT_AFT_RD_L
	else
		timecounter=0
		state=WAIT_INST
1:	RXFが0になるのを待つ状態
	WAIT_RXF="011000"
	if RXF = 1 then
		timecounter=0
		state=WAIT_RXF
	else
		timecounter=clock;//initialize
		state=WAIT_AFT_RD_L
2:	RDを0にしてからT1=30ns待つ状態
	WAIT_AFT_RD_L="010000"
	if timecounter>=30ns then
		read=D;
		timecounter=clock;//initialize
		state=WAIT_AFT_READ_D
	else
		timecounter+=clock;
		state=WAIT_AFT_RD_L
3:	Dを読んだあとT2=20ns待つ状態
	WAIT_AFT_READ_D="110010"
	if timecounter>=20ns then
		timecounter=clock;//initialize
		WAIT_AFT_RD_Hへ
	else
		timecounter+=clock;
		WAIT_AFT_READ_Dへ
4:	RDを1に戻した後、T3=25ns待つ状態
	WAIT_AFT_RD_H="111010"
	if timecounter>=25ns--75ns then
		timecounter=0
		WAIT_INSTへ//どうせこの後待つことになるので、オーバーヘッドにならない
	else
		timecounter+=clock;
		WAIT_AFT_RD_Hへ


write時
0:	命令を待っている状態
	WAIT_INST="111000"
	if write制御 = 1 then
		if TXE = 1 then
			write=writedata
			timecounter=0
			state=WAIT_TXF
		else
			timecounter=clock;//initialize
			state=WAIT_AFT_WR_H
	else
		timecounter=0
		state=WAIT_INST
1:	TXFが0になるのを待つ状態
	WAIT_TXF="101000"
	if TXF = 1 then
		timecounter=0
		state=WAIT_TXF
	else
		timecounter=clock;//initialize
		state=WAIT_AFT_WR_H
2:	WRを1にしてからT4=50ns待つ状態
	WAIT_AFT_WR_H="101101"
	if timecounter>=50ns then
		timecounter=clock;//initialize
		WAIT_AFT_WR_Lへ
	else
		timecounter+=clock;
		WAIT_AFT_WR_Hへ
3:	WRを0にしたあとT5=10ns待つ状態
	WAIT_AFT_WR_L="101001"
	if timecounter>=10ns then
		timecounter=clock;//initialize
		WAIT_AFT_WRITEへ
	else
		timecounter+=clock;
		WAIT_AFT_WR_Lへ
4:	出力をやめた後、T6=15ns待つ状態
	WAIT_AFT_WRITE="101010"
	if timecounter>=15ns then
		timecounter=0
		WAIT_INSTへ//どうせこの後待つことになるので、オーバーヘッドにならない
	else
		timecounter+=clock;
		WAIT_AFT_WRITEへ
