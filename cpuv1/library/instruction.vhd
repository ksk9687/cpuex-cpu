

-- @module : instruction
-- @author : ksk
-- @date   : 2009/10/07


library ieee;
use ieee.std_logic_1164.all;

library work;

package instruction is
    
   constant op_add	:	std_logic_vector(5 downto 0) := o"00";
   constant op_addi	:	std_logic_vector(5 downto 0) := o"01";
   constant op_sub	:	std_logic_vector(5 downto 0) := o"02";
   constant op_srl	:	std_logic_vector(5 downto 0) := o"03";
   constant op_sll	:	std_logic_vector(5 downto 0) := o"04";
   constant op_fadd :	std_logic_vector(5 downto 0) := o"05";
   constant op_fsub	:	std_logic_vector(5 downto 0) := o"06";
   constant op_fmul :	std_logic_vector(5 downto 0) := o"07";
   constant op_finv :	std_logic_vector(5 downto 0) := o"10";
   constant op_load :	std_logic_vector(5 downto 0) := o"11";
   constant op_li	:	std_logic_vector(5 downto 0) := o"12";
   constant op_store:	std_logic_vector(5 downto 0) := o"13";
   constant op_cmp	:	std_logic_vector(5 downto 0) := o"14";
   constant op_jmp	:	std_logic_vector(5 downto 0) := o"15";
   constant op_jal	:	std_logic_vector(5 downto 0) := o"16";
   constant op_jr	:	std_logic_vector(5 downto 0) := o"17";
   constant op_read	:	std_logic_vector(5 downto 0) := o"20";
   constant op_write:	std_logic_vector(5 downto 0) := o"21";
   constant op_nop	:	std_logic_vector(5 downto 0) := o"22";
   constant op_halt	:	std_logic_vector(5 downto 0) := o"23";
 
   	

end package instruction;  
 







