-- デコーダの実装

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
    ;reg_write : out std_logic
	;im : out std_logic_vector(13 downto 0)
    ;reg_write_select : out std_logic_vector(2 downto 0)
    );
end decoder;     
        

architecture synth of decoder is
	--OPCODE
	alias op : std_logic_vector(5 downto 0) is inst(31 downto 26);
	
begin
	im <= inst(13 downto 0);
	
	--書き込みレジスタの指定
	with op select
	regd <= 
	"111111" when op_jal, --JALではr63のみ
	inst(20 downto 16) when op_addi | op_sll | op_load | op_li | op_read | op_write | | op_hsread ,--Rt
	inst(15 downto 11) when others;--Rd
	
	-- レジスタに書き込むかどうか
	with op select
	 reg_write <=  '0' when op_cmp | op_cmpi | op_fcmp | op_store | op_hs_write | op_jmp | op_jr | op_nop | op_halt | op_led,--書きこまない
	 '1' when others;
	 
	--レジスタに何を書き込むか
	with op select
	 reg_write_select <= op(5 downto 3);

	--Rs
	regs1 <= inst(25 downto 20);
	
	--Rt
	regs2 <= inst(19 downto 14);

	
			

end synth;








