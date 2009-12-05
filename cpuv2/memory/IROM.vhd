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
    type rom_t is array (0 to 63) of std_logic_vector (31 downto 0); 
    signal ROM : rom_t :=(
    op_nop & o"00" & x"00000",
    op_li  & o"00" & o"00" &"00"&x"000",
    op_li  & o"00" & o"10" &"00"&x"000",
    op_li  & o"00" & o"11" &"00"&x"000",
    
    op_li  & o"00" & o"12" &"00"&x"000",
    op_li  & o"00" & o"13" &"00"&x"0AA",
    op_jal& "00" & x"100020",
    op_addi & o"01" & o"14" &"00"&x"000",--loop

    op_cmpi & o"14" & o"00" &"00"&x"000",    
    op_jmp & "001"&"100" & x"0000F",--if r14 <= 0
    op_jal& "00" & x"100020",
    op_store & o"10" & o"01" &"00"&x"000",
    
    op_addi  & o"10" & o"10" &"00"&x"001",
    op_addi  & o"14" & o"14" &"11"&x"FFF",
    op_jmp & "001"&"000" & x"00008",--if <= 0
    op_led & o"13" & o"13" &"00"&x"000",
    
    op_write & o"13" & o"15" &"00"&x"000", 
    op_write & o"13" & o"15" &"00"&x"000", 
    op_write & o"13" & o"15" &"00"&x"000", 
    op_write & o"13" & o"15" &"00"&x"000", 

    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000", 
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000", 

    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000", 
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000", 
    
    op_nop & o"00" & x"00000",
    op_nop & o"00" & x"00000", 
    op_nop & o"00" & x"00000",
    op_jr& o"00" & o"00" &"00"&x"000",
    
    
    op_read & o"00" & o"02" &"00"&x"000",--
    op_cmpi & o"02" & o"00" &"00"&x"100",--
    op_jmp & "001"&"001" & x"00020",--if (r2 >= 0x100) then goto 
    op_ledi & o"13" & o"13" &"00"&x"001",
    
    op_read & o"00" & o"03" &"00"&x"000",--
    op_cmpi & o"03" & o"00" &"00"&x"100",--
    op_jmp & "001"&"001" & x"00024",--if (r3 >= 0x100) then goto
    op_ledi & o"13" & o"13" &"00"&x"002",
    
    op_read & o"00" & o"04" &"00"&x"000",--
    op_cmpi & o"04" & o"00" &"00"&x"100",--
    op_jmp & "001"&"001" & x"00028",--if (r4 >= 0x100) then goto 
    op_ledi & o"13" & o"13" &"00"&x"003",
    
    op_read & o"00" & o"05" &"00"&x"000",--
    op_cmpi & o"05" & o"00" &"00"&x"100",--
    op_jmp & "001"&"001" & x"0002C",--if (r5 >= 0x100) then goto 
    op_ledi & o"13" & o"13" &"00"&x"004",
    

	op_sll & o"02" & o"02" &"00"&x"018",--
	op_sll & o"03" & o"03" &"00"&x"010",--
    op_sll & o"04" & o"04" &"00"&x"008",--
    op_li  & o"01" & o"01" &"00"&x"000",--
    
    op_add & o"02" & o"01" & o"01" & x"00",
    op_add & o"03" & o"01" & o"01" & x"00",
    op_add & o"04" & o"01" & o"01" & x"00",
    op_add & o"05" & o"01" & o"01" & x"00",
    
    op_jr & o"77" & x"00000",
    op_halt & o"00" & x"00000", 
    op_halt & o"00" & x"00000",
    op_halt & o"00" & x"00000" ,
      
    op_halt & o"00" & x"00000", 
    op_halt & o"00" & x"00000",
    op_halt & o"00" & x"00000", 
    op_halt & o"00" & x"00000"

    );
    signal i : std_logic_vector(31 downto 0) := op_nop&"00"&x"000000";
    
begin
--	inst <= ROM(conv_integer(pc(3 downto 0)));
	 inst <= i;
	process(clk)
	begin
		if rising_edge(clk) then
			i <= ROM(conv_integer(pc(5 downto 0)));
		end if;
	end process;
	
	 
end arch;


--    op_li  & o"00" & o"00" &"00"&x"000",
--    op_li  & o"00" & o"10" &"00"&x"000",
--    op_li  & o"00" & o"11" &"00"&x"000",
--    op_li  & o"00" & o"12" &"00"&x"000",
--    
--    op_li  & o"00" & o"13" &"00"&x"0AA",
--    op_jal& "00" & x"100010",
--    op_addi & o"01" & o"14" &"00"&x"000",--loop
--    op_cmpi & o"14" & o"00" &"00"&x"000",
--    
--    op_jmp & "001"&"100" & x"0000E",--if r14 <= 0
--    op_jal& "00" & x"100010",
--    op_store & o"10" & o"01" &"00"&x"000",
--    op_addi  & o"10" & o"10" &"00"&x"001",
--    
--    op_addi  & o"14" & o"14" &"11"&x"FFF",
--    op_jmp & "001"&"000" & x"00007",--if <= 0
--    op_write & o"13" & o"13" &"00"&x"000",
--    op_jr& o"00" & o"00" &"00"&x"000",
--    
--    
--    op_read & o"00" & o"02" &"00"&x"000",--
--    op_cmpi & o"02" & o"00" &"00"&x"100",--
--    op_jmp & "001"&"001" & x"00010",--if (r2 >= 0x100) then goto 
--    op_read & o"00" & o"03" &"00"&x"000",--
--    
--    op_cmpi & o"03" & o"00" &"00"&x"100",--
--    op_jmp & "001"&"001" & x"00013",--if (r3 >= 0x100) then goto
--    op_read & o"00" & o"04" &"00"&x"000",--
--    op_cmpi & o"04" & o"00" &"00"&x"100",--
--  
--    op_jmp & "001"&"001" & x"00016",--if (r4 >= 0x100) then goto 
--    op_read & o"00" & o"05" &"00"&x"000",--
--    op_cmpi & o"05" & o"00" &"00"&x"100",--
--    op_jmp & "001"&"001" & x"00019",--if (r5 >= 0x100) then goto 
--    
--	  op_sll & o"02" & o"02" &"00"&x"018",--
--	  op_sll & o"03" & o"03" &"00"&x"010",--
--    op_sll & o"04" & o"04" &"00"&x"008",--
--    op_li  & o"01" & o"01" &"00"&x"000",--
--    
--    
--    op_add & o"02" & o"01" & o"01" & x"00",
--    op_add & o"03" & o"01" & o"01" & x"00",
--    op_add & o"04" & o"01" & o"01" & x"00",
--    op_add & o"05" & o"01" & o"01" & x"00",
--    
--    op_jr & o"77" & x"00000",
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000" ,
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000"


    --read word 0x10
--    op_read & o"00" & o"02" &"00"&x"000",--
--    op_cmpi & o"02" & o"00" &"00"&x"100",--
--    op_jmp & "001"&"001" & x"00010",--if (r2 >= 0x100) then goto 
--    op_read & o"00" & o"03" &"00"&x"000",--
--    
--    op_cmpi & o"03" & o"00" &"00"&x"100",--
--    op_jmp & "001"&"001" & x"00013",--if (r3 >= 0x100) then goto
--    op_read & o"00" & o"04" &"00"&x"000",--
--    op_cmpi & o"04" & o"00" &"00"&x"100",--
--  
--    op_jmp & "001"&"001" & x"00016",--if (r4 >= 0x100) then goto 
--    op_read & o"00" & o"05" &"00"&x"000",--
--    op_cmpi & o"05" & o"00" &"00"&x"100",--
--    op_jmp & "001"&"001" & x"00019",--if (r5 >= 0x100) then goto 
--    
--	op_sll & o"02" & o"02" &"00"&x"018",--
--	op_sll & o"03" & o"03" &"00"&x"010",--
--    op_sll & o"04" & o"04" &"00"&x"008",--
--    op_li  & "01" & o"01" &"00"&x"000",--
--    
--    op_add & o"02" & o"01" & o"01" & x"00",
--    op_add & o"03" & o"01" & o"01" & x"00",
--    op_add & o"04" & o"01" & o"01" & x"00",
--    op_add & o"05" & o"01" & o"01" & x"00",
--    
--    op_jr & o"00" & x"00000",

--rec fib
--    signal ROM : rom_t :=(
--    op_li & o"00" & o"00" & "00"&x"000",--0
--    op_li & o"00" & o"01" & o"00" & x"0A",
--    op_li & o"00" & o"02" & o"00" & x"00",
--    op_li & o"00" & o"76" & o"00" & x"00",
--    
--    op_jal & "00000"&"1"&x"00008",--r1 = fib(r1);0100
--    op_led & o"01" & x"00000",--ledout(r1);0101
--    op_halt & o"00" & x"00000", --0110
--    op_halt & o"00" & x"00000",--0111
--    
--    op_cmpi & o"01" & o"00" & o"00" & x"01",--1000
--    op_jmp & "001"&"100" & x"00018",--if (r1 <= 0) then goto ret
--    op_addi & o"76" & o"76" & "00"&x"004",-- r62 += 4;
--    op_store & o"76" & o"76" &"11"&x"FFF",--1011
--
--    op_store & o"76" & o"01" &"11"&x"FFE",--
--    op_store & o"76" & o"77" &"11"&x"FFD",--
--    op_addi & o"01"  & o"01"  &"11"&x"FFF",-- r1 -= 1;
--    op_jal & "00000"&"1"&x"00008",--r1 = fib(r1);
--    
--    
--    op_store & o"76" & o"01" &"11"&x"FFC",--
--    op_load & o"76" & o"01" &"11"&x"FFE",--
--    op_addi & o"01" & o"01" & "11"&x"FFE",-- r1 -= 2;
--    op_jal & "00000"&"1"&x"00008",--r1 = fib(r1);
--   
--    op_load & o"76" & o"02" &"11"&x"FFC",--
--    op_load & o"76" & o"77" &"11"&x"FFD",--
--    op_add & o"01" & o"02" & o"01" & x"00",
--    op_addi & o"76" & o"76" & "11"&x"FFC",--
--    
--    op_jr & o"77" & o"00" & "00"&x"000",
--    op_nop & o"00" & x"00000",
--    op_nop & o"00" & x"00000",
--    op_nop & o"00" & x"00000",
--    
--    op_nop & o"00" & x"00000",
--    op_nop & o"00" & x"00000",
--    op_nop & o"00" & x"00000",
--    op_nop & o"00" & x"00000"
--    );

--echo back
--    op_read & o"00" & o"02" &"00"&x"000",--
--    op_cmpi & o"02" & o"00" &"00"&x"100",--
--    op_jmp & "001"&"001" & x"00000",--if (r2 >= 0x100) then goto 
--    op_write & o"02" & o"03" &"00"&x"000",--
--    
--    op_cmpi & o"03" & o"00" &"00"&x"001",--
--    op_jmp & "001"&"001" & x"00003",
--    op_led & o"02" & x"00000",
--    op_jmp & "001"&"000" & x"00000",
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000", 
--    
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000", 
--    op_halt & o"00" & x"00000",
--    op_halt & o"00" & x"00000" 