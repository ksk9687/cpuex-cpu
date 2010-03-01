

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
   constant op_fload :	std_logic_vector(5 downto 0) := o"24";
   constant op_floadr :	std_logic_vector(5 downto 0) := o"25";
   constant op_fstore:	std_logic_vector(5 downto 0) := o"26";
   constant op_itof :	std_logic_vector(5 downto 0) := o"23";
   constant op_ftoi:	std_logic_vector(5 downto 0) := o"27";
   
   constant op_read	:	std_logic_vector(5 downto 0) := o"30";
   constant op_write:	std_logic_vector(5 downto 0) := o"32";
   constant op_led	:	std_logic_vector(5 downto 0) := o"34";
   constant op_ledi	:	std_logic_vector(5 downto 0) := o"36";
   
   constant op_nop	:	std_logic_vector(5 downto 0) := o"40";
   
   constant op_cmpjmp	:	std_logic_vector(5 downto 0) := o"61";
   constant op_cmpjmp	:	std_logic_vector(5 downto 0) := o"60";
   constant op_cmpijmp	:	std_logic_vector(5 downto 0) := o"64";
   constant op_cmpijmp	:	std_logic_vector(5 downto 0) := o"65";
   constant op_cmpfjmp	:	std_logic_vector(5 downto 0) := o"70";
   constant op_cmpfjmp	:	std_logic_vector(5 downto 0) := o"71";
   
   constant op_jal	:	std_logic_vector(5 downto 0) := o"74";
   constant op_jr	:	std_logic_vector(5 downto 0) := o"76"; 	
end package instruction;  
 







