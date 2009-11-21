library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.instruction.all; 

entity IROM is
	port  (
		clk : in std_logic;
		pc : in std_logic_vector(19 downto 0);
		
		inst : out std_logic_vector(31 downto 0)
	);
end IROM;

architecture arch of IROM is
    type rom_t is array (0 to 15) of std_logic_vector (31 downto 0); 
    signal ROM : rom_t :=(
    op_li & o"00" & o"00" & "00"&x"000",--0
    op_li & o"01" & o"01" & "00"&x"001",--1
    op_li & o"02" & o"02" & "00"&x"002",--2
    op_li & o"03" & o"03" & "00"&x"00A",--10
    
    op_add & o"00" & o"01" & o"02" & x"00",
    op_addi & o"01" & o"00" & "00"&x"000",
    op_addi & o"02" & o"01" & "00"&x"000",
    op_addi & o"03" & o"03" & "11"&x"FFF",
    
    op_cmpi & o"03" & o"03" & "00"&x"001",
    op_jmp & "001" & "011" & x"00004",
    op_led & o"00" & x"00000", 
    op_halt & o"00" & x"00000", 
    
    op_halt & o"00" & x"00000", 
    op_halt & o"00" & x"00000", 
    op_halt & o"00" & x"00000", 
    op_halt & o"00" & x"00000"
    );
    signal i : std_logic_vector(31 downto 0) := op_sleep&"00"&x"000000";
    
begin
--	inst <= ROM(conv_integer(pc(3 downto 0)));
	 inst <= i;
	process(clk)
	begin
		if rising_edge(clk) then
			i <= ROM(conv_integer(pc(3 downto 0)));
		end if;
	end process;
	
	 
end arch;

