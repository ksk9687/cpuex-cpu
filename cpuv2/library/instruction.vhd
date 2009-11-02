

-- @module : instruction
-- @author : ksk
-- @date   : 2009/10/07


library ieee;
use ieee.std_logic_1164.all;

library work;

package instruction is
   
   constant op_li	:	std_logic_vector(5 downto 0) := o"00";
   constant op_addi	:	std_logic_vector(5 downto 0) := o"01";
   constant op_sll	:	std_logic_vector(5 downto 0) := o"02";
   constant op_cmpi	:	std_logic_vector(5 downto 0) := o"03";
   
   constant op_add	:	std_logic_vector(5 downto 0) := o"10";
   constant op_sub	:	std_logic_vector(5 downto 0) := o"11";
   constant op_cmp	:	std_logic_vector(5 downto 0) := o"12";

   constant op_fsub	:	std_logic_vector(5 downto 0) := o"21";
   constant op_fmul :	std_logic_vector(5 downto 0) := o"22";
   constant op_finv :	std_logic_vector(5 downto 0) := o"23";
   constant op_fsqrt:	std_logic_vector(5 downto 0) := o"24";
   constant op_fcmp	:	std_logic_vector(5 downto 0) := o"25";
   constant op_fabs	:	std_logic_vector(5 downto 0) := o"26";
   constant op_fneg	:	std_logic_vector(5 downto 0) := o"27";
   
   constant op_load :	std_logic_vector(5 downto 0) := o"30";
   constant op_store:	std_logic_vector(5 downto 0) := o"31";
   constant op_loadr :	std_logic_vector(5 downto 0) := o"32";
   
   constant op_hsread :	std_logic_vector(5 downto 0) := o"40";
   constant op_hswrite :std_logic_vector(5 downto 0) := o"41";
   constant op_mv :		std_logic_vector(5 downto 0) := o"42";
   
   constant op_read	:	std_logic_vector(5 downto 0) := o"50";
   constant op_write:	std_logic_vector(5 downto 0) := o"51";
   constant op_led	:	std_logic_vector(5 downto 0) := o"52";
   
   constant op_nop	:	std_logic_vector(5 downto 0) := o"60";
   constant op_halt	:	std_logic_vector(5 downto 0) := o"61";
   
   constant op_jmp	:	std_logic_vector(5 downto 0) := o"70";
   constant op_jal	:	std_logic_vector(5 downto 0) := o"71";
   constant op_jr	:	std_logic_vector(5 downto 0) := o"72"; 	


   constant alui_op_li	:	std_logic_vector(5 downto 0) := o"0";
   constant alui_op_addi	:	std_logic_vector(5 downto 0) := o"1";
   constant alui_op_sll	:	std_logic_vector(5 downto 0) := o"2";
   constant alui_op_cmpi	:	std_logic_vector(5 downto 0) := o"3";
   
	constant alu_op_add	: std_logic_vector(2 downto 0) := o"0";
	constant alu_op_sub	: std_logic_vector(2 downto 0) := o"1";
	constant alu_op_cmp	: std_logic_vector(2 downto 0) := o"2";

end package instruction;  
 







