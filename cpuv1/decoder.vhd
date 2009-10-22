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
    
    ;alu : out std_logic_vector(5 downto 0)
	;fpu : out std_logic_vector(5 downto 0)
    
    ;regd,regs1,regs2 : out std_logic_vector(4 downto 0)
    ;reg_write : out std_logic
    ;reg_write_select : out std_logic_vector(2 downto 0)-- ALU,FPU,LS,IO,PC
    
    ;s2select : out std_logic
    ;im : out std_logic_vector(15 downto 0)
	
	;ls : out std_logic_vector(1 downto 0)
	;io : out std_logic_vector(1 downto 0)
	;led : out std_logic_vector(1 downto 0)
	;pc : out std_logic_vector(2 downto 0)
	;delay : out std_logic_vector(2 downto 0)
    );
end decoder;     
        

architecture synth of decoder is
	--OPCODE
	alias op : std_logic_vector(5 downto 0) is inst(31 downto 26);
	
begin

	alu <= op;
	fpu <= op;
	
	im <= inst(15 downto 0);
	
	--Load Store
	lsdec : with op select
	 ls <= "10" when op_load,
	 "11" when op_store,
	 "00" when others;
	
	--IO
	iodec : with op select
	 io <= "10" when op_read,
	 "11" when op_write,
	 "00" when others;
	 
	--IO
	leddec : with op select
	 led <= "11" when op_led,
	 "00" when others;
	 
	--PC
	pcdec : with op select
	pc <= "001" when op_jmp,
	"010" when op_jal,
	"011" when op_jr,
	"111" when op_halt,
	"000" when others;
	
	--書き込みレジスタの指定
	with op select
	regd <= 
	"11111" when op_jal, --JALではr31のみ
	inst(20 downto 16) when op_addi | op_srl | op_sll | op_load | op_li | op_read | op_write,--Rt
	inst(15 downto 11) when others;--Rd
	
	-- レジスタに書き込むかどうか
	with op select
	 reg_write <=  '0' when op_store | op_jmp | op_jr | op_nop | op_halt | op_led,--書きこまない
	 '1' when others;
	 
	--遅延
	with op select
	 delay <= "111" when op_load ,
	 "011" when op_fadd | op_fsub ,
	 "010" when op_finv ,
	 "010" when op_fmul ,
	 "010" when op_fcmp ,
	 "111" when op_read | op_write,
	 "001" when op_add | op_sub | op_cmp ,
	 "000" when op_addi | op_srl | op_sll | op_li,
	 "000" when others;
	 
	--レジスタに何を書き込むか
	with op select
	 reg_write_select <= "001" when op_fadd | op_fsub | op_fmul | op_finv | op_fcmp,--fpu_out
	 "010" when op_load,--ls_out
	 "011" when op_read | op_write,--iou_out
	 "100" when op_jal,--pc_out
	 "101" when op_addi | op_srl | op_sll | op_li,--alu im
	 "000" when others;

	--Rs
	regs1 <= inst(25 downto 21);
	
	--Rt
	regs2 <= inst(20 downto 16);

	--ALUの二番目の入力(!廃止!)
	s2dec : with op select
	 s2select <= '1' when op_addi | op_srl | op_sll | op_li,--即値
	 '0' when others;--レジスタ値
	
			

end synth;








