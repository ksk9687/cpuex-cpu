-- �f�R�[�_ ��

-- @module : decoder
-- @author : ksk
-- @date   : 2009/10/06


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.instruction.all;
library UNISIM;
use UNISIM.VComponents.all;
entity decoder is 
port (
    clk,write			: in	  std_logic;
    inst : in std_logic_vector(31 downto 0)
    ;write_op : out std_logic_vector(5 downto 0)
    
    --���W�X�^�̎w��
    ;reg_d,reg_s1,reg_s2 : out std_logic_vector(5 downto 0)
    ;reg_s1_use,reg_s2_use : out std_logic
    ;reg_write : out std_logic
    
    ;cr_flg : out std_logic_vector(1 downto 0)
    ;op_type : out std_logic_vector(3 downto 0)
    );
end decoder;     
        

architecture synth of decoder is
	--OPCODE
	alias op : std_logic_vector(5 downto 0) is inst(31 downto 26);
	
	signal reg_d_in,mov_reg_rename_from,mov_reg_rename_to :std_logic_vector(5 downto 0) := (others=>'0');
   signal mov_reg_rename_flg1,mov_reg_rename_flg2,rst :std_logic := '0';
begin
  	ROC0 : ROC port map (O => rst);
	write_op <= op;
	
	reg_d <= reg_d_in;
	--�������݃��W�X�^�̎w��
	with op select
	reg_d_in <= inst(19 downto 14) when op_load | op_mv | 
	 op_addi | op_sll | op_li | op_read | op_write | op_hsread ,--Rt
	inst(13 downto 8) when others;--Rd
	
	-- ���W�X�^�ɏ������ނ��ǂ���
	with op select
	 reg_write <=  '0' when  op_cmp | op_cmpi | op_fcmp | 
	 op_store | op_hswrite | op_jmp | op_jr | op_jal | op_nop | op_halt |op_sleep| op_ledi | op_led,--�������܂Ȃ�
	 '1' when others;
	 
	 --���W�X�^��ǂݍ��ނ��ǂ���
	 with op select
	 reg_s1_use <=  '0' when op_read | op_jmp | op_jal | op_jr | op_ledi | op_li | op_halt| op_nop | op_sleep,--�ǂݍ��܂Ȃ�
	 '1' when others;
	 
	 --���W�X�^��ǂݍ��ނ��ǂ��� ���̂Q
	 with op select
	 reg_s2_use <=  '0' when op_write | op_read | op_load |
	 op_jmp | op_jal| op_jr | op_ledi |op_led | op_cmpi 
	 | op_addi | op_li | op_mv | op_fneg | op_fabs| op_finv| op_fsqrt
	 | op_sleep | op_halt | op_nop,--�ǂݍ��܂Ȃ�
	 '1' when others;
	 
	 --�R���f�B�V�������W�X�^���g����
	 with op select
	 cr_flg <= "11" when op_fcmp | op_cmp | op_cmpi ,--��������
	 "10" when op_jmp,--�ǂ�
	 "00" when others;
	 
	 op_type(3) <= '0';
	 with op select
	 op_type(2) <= '1' when op_li |op_addi|op_sll|op_cmpi
	 |op_add |op_sub|op_fabs|op_fneg
	 |op_read|op_write |op_mv
	 ,--�ǂݍ��܂Ȃ�
	 '0' when others;
	 
	 
	 with op select
	 op_type(1) <= '1' when op_fadd |op_fsub|op_fmul|op_finv|op_fsqrt,--�ǂݍ��܂Ȃ�
	 '0' when others;
	 
	 with op select
	 op_type(0) <=  '1' when op_load|op_loadr|op_store,--�ǂݍ��܂Ȃ�
	 '0' when others;
	 
	 

--	reg_s1 <= mov_reg_rename_to when ((mov_reg_rename_flg1 = '1') or (mov_reg_rename_flg2 = '1')) and (mov_reg_rename_from = inst(25 downto 20)) and (op /= op_jmp) else
--	inst(25 downto 20);
--	reg_s2 <= mov_reg_rename_to when ((mov_reg_rename_flg1 = '1') or (mov_reg_rename_flg2 = '1')) and (mov_reg_rename_from = inst(19 downto 14)) and (op /= op_jmp) else
--	inst(19 downto 14);
--	
	reg_s1 <= inst(25 downto 20);
	reg_s2 <= inst(19 downto 14);
	process(clk)
	begin
		if rst = '1' then
			mov_reg_rename_flg1 <= '0';
			mov_reg_rename_flg2 <= '0';
		elsif rising_edge(clk) then
			if (op = op_mv) and (write = '1') then
				mov_reg_rename_from <= inst(25 downto 20);
				mov_reg_rename_to <= reg_d_in;
				mov_reg_rename_flg1 <= '1';
			else
				mov_reg_rename_flg1 <= '0';
			end if;
			if (reg_d_in = mov_reg_rename_from) or (reg_d_in = mov_reg_rename_to) then
				mov_reg_rename_flg2 <= '0';
			else
				mov_reg_rename_flg2 <= mov_reg_rename_flg1;		
			end if;
		end if;
	end process;
	
			

end synth;








