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
    type rom_t is array (0 to 31) of std_logic_vector (31 downto 0); 
    signal ROM : rom_t :=(
    op_li & o"00" & o"00" & "00"&x"000",--0
    op_li & o"00" & o"01" & o"00" & x"0A",
    op_li & o"00" & o"02" & o"00" & x"00",
    op_li & o"00" & o"76" & o"00" & x"00",
    
    op_jal & "00000"&"1"&x"00008",--r1 = fib(r1);0100
    op_led & o"01" & x"00000",--ledout(r1);0101
    op_halt & o"00" & x"00000", --0110
    op_halt & o"00" & x"00000",--0111
    
    op_cmpi & o"01" & o"00" & o"00" & x"01",--1000
    op_jmp & "001"&"100" & x"00018",--if (r1 <= 0) then goto ret
    op_addi & o"76" & o"76" & "00"&x"004",-- r62 += 4;
    op_store & o"76" & o"76" &"11"&x"FFF",--1011

    op_store & o"76" & o"01" &"11"&x"FFE",--
    op_store & o"76" & o"77" &"11"&x"FFD",--
    op_addi & o"01"  & o"01"  &"11"&x"FFF",-- r1 -= 1;
    op_jal & "00000"&"1"&x"00008",--r1 = fib(r1);
    
    
    op_store & o"76" & o"01" &"11"&x"FFC",--
    op_load & o"76" & o"01" &"11"&x"FFE",--
    op_addi & o"01" & o"01" & "11"&x"FFE",-- r1 -= 2;
    op_jal & "00000"&"1"&x"00008",--r1 = fib(r1);
   
    op_load & o"76" & o"02" &"11"&x"FFC",--
    op_load & o"76" & o"77" &"11"&x"FFD",--
    op_add & o"01" & o"02" & o"01" & x"00",
    op_addi & o"76" & o"76" & "11"&x"FFC",--
    
    op_jr & o"77" & o"00" & "00"&x"000",
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000",
    
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000"
    );
    signal i : std_logic_vector(31 downto 0) := op_sleep&"00"&x"000000";
    
begin
--	inst <= ROM(conv_integer(pc(3 downto 0)));
	 inst <= i;
	process(clk)
	begin
		if rising_edge(clk) then
			i <= ROM(conv_integer(pc(4 downto 0)));
		end if;
	end process;
	
	 
end arch;

