

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
   constant op_mov	:	std_logic_vector(5 downto 0) := o"04";
   constant op_add	:	std_logic_vector(5 downto 0) := o"05";
   constant op_sub	:	std_logic_vector(5 downto 0) := o"06";

   constant op_fadd	:	std_logic_vector(5 downto 0) := o"10";
   constant op_fsub	:	std_logic_vector(5 downto 0) := o"11";
   constant op_fmul :	std_logic_vector(5 downto 0) := o"12";
   constant op_finv :	std_logic_vector(5 downto 0) := o"13";
   constant op_fsqrt:	std_logic_vector(5 downto 0) := o"14";
   constant op_fmov	:	std_logic_vector(5 downto 0) := o"15";
   
   
   constant op_load :	std_logic_vector(5 downto 0) := o"40";
   constant op_loadr :	std_logic_vector(5 downto 0) := o"41";
   constant op_store:	std_logic_vector(5 downto 0) := o"42";
   constant op_fload :	std_logic_vector(5 downto 0) := o"44";
   constant op_floadr :	std_logic_vector(5 downto 0) := o"45";
   constant op_fstore:	std_logic_vector(5 downto 0) := o"46";
   constant op_itof :	std_logic_vector(5 downto 0) := o"43";
   constant op_ftoi:	std_logic_vector(5 downto 0) := o"47";
   
   constant op_read	:	std_logic_vector(5 downto 0) := o"30";
   constant op_write:	std_logic_vector(5 downto 0) := o"32";
   constant op_led	:	std_logic_vector(5 downto 0) := o"34";
   constant op_ledi	:	std_logic_vector(5 downto 0) := o"36";
   
   constant op_nop	:	std_logic_vector(5 downto 0) := o"57";
   
   constant op_cmpjmp1	:	std_logic_vector(5 downto 0) := o"61";
   constant op_cmpjmp2	:	std_logic_vector(5 downto 0) := o"60";
   constant op_cmpijmp1	:	std_logic_vector(5 downto 0) := o"62";
   constant op_cmpijmp2	:	std_logic_vector(5 downto 0) := o"63";
   constant op_cmpfjmp1	:	std_logic_vector(5 downto 0) := o"70";
   constant op_cmpfjmp2	:	std_logic_vector(5 downto 0) := o"71";
   
   constant op_call	:	std_logic_vector(5 downto 0) := o"03";
   constant op_ret	:	std_logic_vector(5 downto 0) := o"66"; 	
   
   
   constant nop_inst	:	std_logic_vector(35 downto 0) := x"BC0000000";
   
  
   constant unit_alu	:	std_logic_vector(2 downto 0) := "000";
   constant unit_bru	:	std_logic_vector(2 downto 0) := "110";
   constant unit_nop	:	std_logic_vector(2 downto 0) := "101";
end package instruction;  
 







