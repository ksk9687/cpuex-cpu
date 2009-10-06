

-- @module : decoder
-- @author : ksk
-- @date   : 2009/10/06


library ieee;
use ieee.std_logic_1164.all;

entity decoder is 
port (
    --clk			: in	  std_logic;
    inst : in std_logic_vector(5 downto 0)
    
    ;alu : out std_logic_vector(5 downto 0)
	;fpu : out std_logic_vector(5 downto 0)
    
    ;regd : out std_logic_vector(4 downto 0)
    ;regs1 : out std_logic_vector(4 downto 0)
    ;regs2 : out std_logic_vector(4 downto 0)
    
	;loadstore : out std_logic_vector(1 downto 0)
	;io : out std_logic_vector(1 downto 0)
	;pc : out std_logic_vector(0 downto 0)
    );
     
end decoder;     
        

architecture synth of decoder is
	signal op:std_logic_vector(5 downto 0):= "000000";
begin
	--演算回路　そのままわたす
	alu <= op;
	fpu <= op;
	
	--オペコード
	op <= inst(31 downto 26);

	
	lsdec : with op select
	 loadstore <= expression_1 when "00",
	 expression_2 when choise_2,
	 expression_n when choise_n;
	 
	--LoadStore
	lsdec : with op select
	 loadstore <= "10" when "001001", -- Load
	 "11" when "001011",-- 	store
	 "00" when others;

	--ReadWrite
	iodec : with op select
	 loadstore <= "10" when "010000", -- read
	 "11" when "010001",-- 	write
	 "00" when others;
	
	--PC
	pcdec : with op select
	 loadstore <= "1" when "001101" | "001110" | "001111" ,--jmp jal jr
	 "0" when others;--+1
	

	regd <= inst(25 downto 21);
	regd <= inst(25 downto 21);
	regd <= inst(25 downto 21);
			
	
			


end synth;








