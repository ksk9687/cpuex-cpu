

-- @module : instruction
-- @author : ksk
-- @date   : 2009/10/07


library ieee;
use ieee.std_logic_1164.all;

library work;

package instruction is
   
   
   constant op_li	:	std_logic_vector(5 downto 0) := o"00";
   constant op_addi	:	std_logic_vector(5 downto 0) := o"01";
   constant op_subi	:	std_logic_vector(5 downto 0) := o"02";
   constant op_mv	:	std_logic_vector(5 downto 0) := o"04";
   constant op_add	:	std_logic_vector(5 downto 0) := o"05";
   constant op_sub	:	std_logic_vector(5 downto 0) := o"06";

   constant op_fadd	:	std_logic_vector(5 downto 0) := o"10";
   constant op_fsub	:	std_logic_vector(5 downto 0) := o"11";
   constant op_fmul :	std_logic_vector(5 downto 0) := o"12";
   constant op_finv :	std_logic_vector(5 downto 0) := o"13";
   constant op_fsqrt:	std_logic_vector(5 downto 0) := o"14";
   constant op_fmov	:	std_logic_vector(5 downto 0) := o"15";
   
   
   constant op_load :	std_logic_vector(5 downto 0) := o"20";
   constant op_loadr :	std_logic_vector(5 downto 0) := o"21";
   constant op_store:	std_logic_vector(5 downto 0) := o"22";
   constant op_fload :	std_logic_vector(5 downto 0) := o"20";
   constant op_floadr :	std_logic_vector(5 downto 0) := o"21";
   constant op_fstore:	std_logic_vector(5 downto 0) := o"22";
   
   constant op_load :	std_logic_vector(5 downto 0) := o"20";
   constant op_loadr :	std_logic_vector(5 downto 0) := o"31";
   constant op_load :	std_logic_vector(5 downto 0) := o"20";
   constant op_store_inst:	std_logic_vector(5 downto 0) := o"23";
   
   constant op_hsread :	std_logic_vector(5 downto 0) := o"40";
   constant op_hswrite :std_logic_vector(5 downto 0) := o"41";
   constant op_mv :		std_logic_vector(5 downto 0) := o"05";
   
   constant op_read	:	std_logic_vector(5 downto 0) := o"50";
   constant op_write:	std_logic_vector(5 downto 0) := o"51";
   constant op_led	:	std_logic_vector(5 downto 0) := o"52";
   constant op_ledi	:	std_logic_vector(5 downto 0) := o"53";
   
   constant op_nop	:	std_logic_vector(5 downto 0) := o"60";
   constant op_halt	:	std_logic_vector(5 downto 0) := o"61";
   constant op_sleep:	std_logic_vector(5 downto 0) := o"62";
   
   constant op_jmp	:	std_logic_vector(5 downto 0) := o"70";
   constant op_jal	:	std_logic_vector(5 downto 0) := o"71";
   constant op_jr	:	std_logic_vector(5 downto 0) := o"72"; 	


   constant alui_op_li		:	std_logic_vector(2 downto 0) := o"0";
   constant alui_op_addi	:	std_logic_vector(2 downto 0) := o"1";
   constant alui_op_sll		:	std_logic_vector(2 downto 0) := o"2";
   constant alui_op_cmpi	:	std_logic_vector(2 downto 0) := o"3";
   constant alui_op_mv	:	std_logic_vector(2 downto 0) 	 := o"5";
   constant alui_op_fabs	:	std_logic_vector(2 downto 0) := o"6";
   constant alui_op_fneg	:	std_logic_vector(2 downto 0) := o"7";
   
	constant alu_op_add	: std_logic_vector(2 downto 0) := o"0";
	constant alu_op_sub	: std_logic_vector(2 downto 0) := o"1";
	constant alu_op_cmp	: std_logic_vector(2 downto 0) := o"2";
	
	constant iou_op_read	: std_logic_vector(2 downto 0) := o"0";
	constant iou_op_write	: std_logic_vector(2 downto 0) := o"1";
	constant iou_op_led	: std_logic_vector(2 downto 0) := o"2";
	constant iou_op_ledi	: std_logic_vector(2 downto 0) := o"3";
	
	constant lsu_op_load	: std_logic_vector(2 downto 0) := o"0";
	constant lsu_op_loadr	: std_logic_vector(2 downto 0) := o"1";
	constant lsu_op_store	: std_logic_vector(2 downto 0) := o"2";
	constant lsu_op_store_inst	: std_logic_vector(2 downto 0) := o"3";
	
	
	constant sp_op_nop	: std_logic_vector(2 downto 0) := o"0";

end package instruction;  
 







