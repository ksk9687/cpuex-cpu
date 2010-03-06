--IO���j�b�g��

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 
library UNISIM;
use UNISIM.VComponents.all;
entity IOU is
	port  (
--		clk66,
		clk,enable : in std_logic;
		iou_op : in std_logic_vector(1 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		readdata : out std_logic_vector(31 downto 0)
		
		;RSRXD : in STD_LOGIC
		;RSTXD : out STD_LOGIC
		
		;io_read_buf_overrun : out STD_LOGIC
	);
end IOU;

architecture arch of IOU is
	constant usb: std_logic_vector := "00001";
	constant rs232c: std_logic_vector := "00010";
	constant nop: std_logic_vector := "11111";
	constant error: std_logic_vector := x"0FFFFFFF";
	constant iou_op_read : std_logic_vector := "00";
	constant iou_op_write : std_logic_vector := "01";

	signal rs_read,rs_read_end,rs_write,rs_write_end,rs_read_p,rs_write_p :std_logic := '0';
	signal rs_readdata_out,rs_writedata_buf: std_logic_vector(7 downto 0);
	signal iou_op_buf: std_logic_vector(2 downto 0);
	signal no_buf: std_logic_vector(4 downto 0);
	signal readdata_p,writedata_buf : std_logic_vector(31 downto 0):= (others => '0');
	
	signal rst :std_logic:= '0';
begin
	 
  	ROC0 : ROC port map (O => rst);
  	
	 
	 readdata_p <= 
	 x"00000"&"000"&(not rs_read_end)&rs_readdata_out when (iou_op = iou_op_read) else
	 x"0000000"&"000"&(not rs_write_end) when (iou_op = iou_op_write) else
	 (others => '1');
	  
	 rs_read_p <= '1' and enable when (iou_op = iou_op_read) and (rs_read_end = '1') else
	 '0';
	 rs_write_p <= '1' and enable when (iou_op = iou_op_write) and (rs_write_end = '1') else
	 '0';
	 rs_writedata_buf <= writedata_buf(7 downto 0);
	 	 
 	 process(clk)
 	 begin
 	 	if rising_edge(clk) then
 	 		if enable = '0' then
 	 			rs_read <= '0';
 	 			rs_write <= '0';
 	 			readdata <= (others => '0');
 	 			writedata_buf <= (others => '0');
 	 		else
 	 			readdata <= readdata_p;
 	 			rs_read <= rs_read_p;
 	 			rs_write <= rs_write_p;
 	 			writedata_buf <= writedata;
 	 		end if;
 	 	end if;
 	 end process;
	 	 
--   RS232C0 : rs232cio
--    generic map( -- 115200,66.66MHz
--    READBITLEN    => 590,    -- 1bit�ɂ�����N���b�N��菭���傫���l
--    READPADBITLEN => 50,     -- �f�[�^�̍̎�Ԋu
--    MERGINLEN     => 10,      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
--    STOPBACK      => 50,     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
--    READBUFLENLOG => 8,      -- �o�b�t�@�̑傫��
--
--    WRITEBITLEN => 578,      -- 1bit�ɂ�����N���b�N��菭���������l
--    NULLAFTSTOP => 100,       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
--    WRITEBUFLENLOG => 10      -- �o�b�t�@�̑傫��
--    )
--   port map (
----   	clk66,
--		clk,rst,
--   	rs_read,rs_readdata_out,rs_read_end,io_read_buf_overrun,
--   	rs_write,rs_writedata_buf,rs_write_end,
--   	
--	RSRXD,RSTXD
--   );

   RS232C0 : rs232cio
--    generic map( -- 115200,100MHz
--    READBITLEN    => 880,    -- 1bit�ɂ�����N���b�N��菭���傫���l
--    READPADBITLEN => 50,     -- �f�[�^�̍̎�Ԋu
--    MERGINLEN     => 10,      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
--    STOPBACK      => 50,     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
--    READBUFLENLOG => 8,      -- �o�b�t�@�̑傫��
--
--    WRITEBITLEN => 868,      -- 1bit�ɂ�����N���b�N��菭���������l
--    NULLAFTSTOP => 100,       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
--    WRITEBUFLENLOG => 10      -- �o�b�t�@�̑傫��
--    )
--    generic map( -- 115200,133MHz
--    READBITLEN    => 1170,    -- 1bit�ɂ�����N���b�N��菭���傫���l
--    READPADBITLEN => 50,     -- �f�[�^�̍̎�Ԋu
--    MERGINLEN     => 10,      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
--    STOPBACK      => 50,     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
--    READBUFLENLOG => 8,      -- �o�b�t�@�̑傫��
--
--    WRITEBITLEN => 1157,      -- 1bit�ɂ�����N���b�N��菭���������l
--    NULLAFTSTOP => 100,       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
--    WRITEBUFLENLOG => 10      -- �o�b�t�@�̑傫��
--    )
--    generic map( -- 115200,150MHz
--    READBITLEN    => 1320,    -- 1bit�ɂ�����N���b�N��菭���傫���l
--    READPADBITLEN => 50,     -- �f�[�^�̍̎�Ԋu
--    MERGINLEN     => 10,      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
--    STOPBACK      => 50,     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
--    READBUFLENLOG => 8,      -- �o�b�t�@�̑傫��
--
--    WRITEBITLEN => 1302,      -- 1bit�ɂ�����N���b�N��菭���������l
--    NULLAFTSTOP => 100,       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
--    WRITEBUFLENLOG => 10      -- �o�b�t�@�̑傫��
--    )
    generic map( -- 460800,150MHz
    READBITLEN    => 330,    -- 1bit�ɂ�����N���b�N��菭���傫���l
    READPADBITLEN => 50,     -- �f�[�^�̍̎�Ԋu
    MERGINLEN     => 10,      -- �f�[�^�̓ǂݍ��݊J�n�̗]��
    STOPBACK      => 70,     -- STOPBIT���ǂꂮ�炢�҂��Ȃ���
    READBUFLENLOG => 8,      -- �o�b�t�@�̑傫��

    WRITEBITLEN => 325,      -- 1bit�ɂ�����N���b�N��菭���������l
    NULLAFTSTOP => 50,       -- STOP�𑗂�����ɔO�̂��߂ɑ���]��
    WRITEBUFLENLOG => 10      -- �o�b�t�@�̑傫��
    )
   port map (
--   	clk66,
		clk,rst,
   	rs_read,rs_readdata_out,rs_read_end,io_read_buf_overrun,
   	rs_write,rs_writedata_buf,rs_write_end,
   	
	RSRXD,RSTXD
   );
	

end arch;

