-- デコーダ の

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
    r1,r2,d : out std_logic_vector(2 downto 0)
    );
end decoder;     
        

architecture synth of decoder is
	--OPCODE
	alias op : std_logic_vector(5 downto 0) is inst(35 downto 30);
	
begin
  	ROC0 : ROC port map (O => rst);
	write_op <= op;
	
	with op select
	 reg_write <=  '0' when  op_cmp | op_cmpi | op_fcmp | 
	 op_store |op_store_inst | op_hswrite | op_jmp | op_jr | op_jal | op_nop | op_halt |op_sleep| op_ledi | op_led,--書きこまない
	 '1' when others;
	 

	 
	 
			

end synth;








