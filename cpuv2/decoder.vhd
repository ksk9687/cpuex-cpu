-- �f�R�[�_�̎���

-- @module : decoder
-- @author : ksk
-- @date   : 2009/10/06


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.instruction.all;

entity decoder is 
port (
    --clk			: in	  std_logic;
    inst : in std_logic_vector(31 downto 0)
    
    --���W�X�^�̎w��
    ;reg_d,reg_s1,reg_s2 : out std_logic_vector(5 downto 0)
    ;reg_s1_use,reg_s2_use : out std_logic
    ;reg_write : out std_logic
    
    ;cr_flg : out std_logic_vector(1 downto 0)
	;im : out std_logic_vector(13 downto 0)
    ;reg_write_select : out std_logic_vector(2 downto 0)
    );
end decoder;     
        

architecture synth of decoder is
	--OPCODE
	alias op : std_logic_vector(5 downto 0) is inst(31 downto 26);
	
begin
	im <= inst(13 downto 0);
	
	--�������݃��W�X�^�̎w��
	with op select
	regd <= 
	"111111" when op_jal, --JAL�ł�r63�̂�
	inst(19 downto 14) when op_addi | op_sll | op_load | op_li | op_read | op_write | | op_hsread ,--Rt
	inst(13 downto 8) when others;--Rd
	
	-- ���W�X�^�ɏ������ނ��ǂ���
	with op select
	 reg_write <=  '0' when op_cmp | op_cmpi | op_fcmp | op_store | op_hs_write | op_jmp | op_jr | op_nop | op_halt | op_led,--�������܂Ȃ�
	 '1' when others;
	 
	 --���W�X�^��ǂݍ��ނ��ǂ���
	 with op select
	 reg_s1_use <=  '0' when op_jmp ,--�ǂݍ��܂Ȃ�
	 '1' when others;
	 with op select
	 reg_s2_use <=  '0' when op_jmp | op_led | op_cmpi | op_li,--�ǂݍ��܂Ȃ�
	 '1' when others;
	 
	 
	 with op select
	 cr_flg <= "11" when op_fcmp | op_cmp | op_cmpi | ,--��������
	 "10" when op_jmp,--�ǂݍ���
	 "00" when others;

	--Rs
	regs1 <= inst(25 downto 20);
	
	--Rt
	regs2 <= inst(19 downto 14);

	
			

end synth;








