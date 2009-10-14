




�M��
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



�ʏ�
	USBBUF_RData <= "00000000" when (readbuf_readaddr = readbuf_writeaddr) else readbuf(readbuf_readaddr);
	USBBUF_RC <= '0' when (readbuf_readaddr = readbuf_writeaddr) else '1';
	
	writedata <= "00000000" when (writebuf_readaddr = writebuf_writeaddr) else readbuf(writebuf_readaddr);
	writeflag <= '0' when (writebuf_readaddr = writebuf_writeaddr) else '1';
	USBBUF_WData <= writedata;
	USBBUF_WC <= '0' when (writebuf_readaddr = writebuf_writeaddr+1) else '1';
	
�o�b�t�@�ւ̏�������
in clk
	on USBBUF_WD
		writebuf(writebuf_writeaddr) <= USBBUF_WData;
	
	on read����
		readbuf(readbuf_writeaddr) <= USBIO_RData;

�o�b�t�@����
	on USBBUF_RD
		if readbuf_readaddr != readbuf_writeaddr then
			writebuf_readaddr<=writebuf_readaddr+1;
	on USBBUF_WD
		if writebuf_readaddr != writebuf_writeaddr+1 then
			writebuf_writeaddr<=writebuf_writeaddr+1;
	on read����
		readbuf_readaddr == readbuf_writeaddr+1�̂Ƃ��͓ǂ܂Ȃ�
		if readbuf_readaddr != readbuf_writeaddr+1 then
			readbuf_writeaddr <= readbuf_writeaddr+1;
	on write����
		writebuf_readaddr <= writebuf_readaddr+1;

in clk
	lastRC <= USBIO_RC
	lastWC <= USBIO_WC
	
	
	

-------------------------------------------------------------------------------------------------------

�ʏ�
	USBBUF_RData <= "00000000" when (readbuf_readaddr = readbuf_writeaddr or �������) else readbuf(readbuf_readaddr);
	USBBUF_RC <= '0' when (readbuf_readaddr = readbuf_writeaddr or �������) else '1';
	
	writedata <= "00000000" when (writebuf_readaddr = writebuf_writeaddr) else writebuf(writebuf_readaddr);
	writeflag <= '0' when (writebuf_readaddr = writebuf_writeaddr) else '1';
	USBBUF_WC <= '0' when (writebuf_readaddr = writebuf_writeaddr+1 or �������) else '1';

�e��Ԃ̐M��
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

�������
	lastRC <= '1';
	lastWC <= '1';
	readbuf_readaddr<=0;
	readbuf_writeaddr<=0;
	writebuf_readaddr<=0;
	writebuf_writeaddr<=0;
	state <= STATE_IDLE;


�N���b�N
	lastRC <= USBIO_RC
	lastWC <= USBIO_WC
	on USBBUF_RD
		if readbuf_readaddr != readbuf_writeaddr then
			readbuf_readaddr<=readbuf_readaddr+1;
	on USBBUF_WD
		if writebuf_readaddr != writebuf_writeaddr+1 then
			writebuf_writeaddr<=writebuf_writeaddr+1;
		writebuf(writebuf_writeaddr) <= USBBUF_WData;


�X�e�[�g�}�V��
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
		-- ����
		readbuf(readbuf_writeaddr) <= readdata;
		readbuf_writeaddr <= readbuf_writeaddr+1;
		goto STATE_IDLE;
	else
		goto STATE_WAIT_READ;
	end if;
STATE_WAIT_WRITE
	if lastWC = '1' and USBIO_WC = '0'
		-- ����
		writebuf_readaddr <= writebuf_readaddr+1;
		goto STATE_IDLE;
	else
		goto STATE_WAIT_WRITE;
	end if;





