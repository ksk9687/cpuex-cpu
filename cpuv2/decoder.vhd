-- デコーダ の

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
    
    --レジスタの指定
    ;reg_d,reg_s1,reg_s2 : out std_logic_vector(5 downto 0)
    ;reg_s1_use,reg_s2_use : out std_logic
    ;reg_write : out std_logic
    
    ;cr_flg : out std_logic_vector(1 downto 0)
    );
end decoder;     
        

architecture synth of decoder is
	--OPCODE
	alias op : std_logic_vector(5 downto 0) is inst(31 downto 26);
	
begin
	
	--書き込みレジスタの指定
	with op select
	reg_d <= "111111" when op_jal, --JALではr63のみ
	inst(19 downto 14) when op_load | op_mv | 
	 op_addi | op_sll | op_li | op_read | op_write | op_hsread ,--Rt
	inst(13 downto 8) when others;--Rd
	
	-- レジスタに書き込むかどうか
	with op select
	 reg_write <=  '0' when  op_cmp | op_cmpi | op_fcmp | 
	 op_store | op_hswrite | op_jmp | op_jr | op_nop | op_halt |op_sleep| op_ledi | op_led,--書きこまない
	 '1' when others;
	 
	 --レジスタを読み込むかどうか
	 with op select
	 reg_s1_use <=  '0' when op_read | op_jmp | op_jal | op_ledi | op_li | op_halt| op_nop | op_sleep,--読み込まない
	 '1' when others;
	 
	 --レジスタを読み込むかどうか その２
	 with op select
	 reg_s2_use <=  '0' when op_write | op_read | op_load |
	 op_jmp | op_jal| op_jr | op_ledi |op_led | op_cmpi 
	 | op_addi | op_li | op_mv | op_fneg | op_fabs
	 | op_sleep | op_halt | op_nop,--読み込まない
	 '1' when others;
	 
	 --コンディションレジスタを使うか
	 with op select
	 cr_flg <= "11" when op_fcmp | op_cmp | op_cmpi ,--書きこむ
	 "10" when op_jmp,--読む
	 "00" when others;

	--Rs
	reg_s1 <= inst(25 downto 20);
	
	--Rt
	reg_s2 <= inst(19 downto 14);

	
			

end synth;








