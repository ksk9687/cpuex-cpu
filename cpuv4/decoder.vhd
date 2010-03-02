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
    inst : in std_logic_vector(35 downto 0);
    r1,r2 : out std_logic_vector(1 downto 0);
    d : out std_logic_vector(4 downto 0)
    );
end decoder;     
        

architecture synth of decoder is
	alias op : std_logic_vector(5 downto 0) is inst(35 downto 30);
	
begin
	
	
	with op select
	 r1 <=  "00" when op_li|op_call|op_ret|op_nop|op_read|op_ledi,
	 "10" when op_cmpfjmp1|op_cmpfjmp2|op_fadd|op_fsub|op_fmul|op_finv|op_fsqrt|op_fmov|op_ftoi,
	 "01" when others;
	 
	with op select
	 r2 <=  "00" when op_li|op_addi|op_subi|op_mov|op_call|op_ret|op_nop|op_cmpijmp1|op_cmpijmp2|op_read|op_write|op_ledi|op_led|op_finv|op_fsqrt|op_fmov|op_itof|op_ftoi,
	 "10" when op_cmpfjmp1|op_cmpfjmp2|op_fadd|op_fsub|op_fmul|op_fstore,
	 "01" when others;

	with op select
	 d <= "11010" when op_cmpijmp1|op_cmpijmp2|op_cmpjmp1|op_cmpjmp2|op_cmpfjmp1|op_cmpfjmp2,
	 "01100" when op_store|op_fstore,
	 "01111" when op_read|op_write,
	 "01110" when op_led|op_ledi,
	 "10001" when op_fadd|op_fsub|op_fmul|op_finv|op_fsqrt|op_fmov|op_itof,
	 "00000" when op_nop,
	 "01001" when others;
	 
	 
			

end synth;








