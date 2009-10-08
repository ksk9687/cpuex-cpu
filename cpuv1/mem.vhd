

-- @module : mem
-- @author : ksk
-- @date   : 2009/10/06

---SRAMを実装した場合の予定
-- 二倍速
-- 一回目は 命令フェッチ
-- 二回目は ロードストア

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.instruction.all;

entity mem is 
port (
    clk,fastclk,sramclk	: in	  std_logic;
    
    pc : in std_logic_vector(31 downto 0);
    ls_address : in std_logic_vector(31 downto 0);
    load_store : in std_logic;
    write_data : in std_logic_vector(31 downto 0);
    read_inst,read_data : out std_logic_vector(31 downto 0)
    ); 
     
end mem;
        

architecture synth of mem is
    type ram_type is array (0 to 15) of std_logic_vector (31 downto 0); 
	signal RAM : ram_type :=
	(--fib10
	op_li & "00000" & "00000" & x"0000",
	op_li & "00000" & "00001" & x"0000",
	op_li & "00000" & "00010" & x"0001",
	op_li & "00000" & "00011" & x"000A",--10をR3に入れる
	
	op_li & "00000" & "00100" & x"0001",
	op_add & "00001" & "00010" & "00000" & "00000000000",
	op_addi & "00010" & "00001" & x"0000",
	op_addi & "00000" & "00010" & x"0000",
	
	op_addi & "00011" & "00011" & x"FFFF",
	op_cmp & "00011" & "00100" & "00101" & "00000000000",
	op_jmp & "00101" & "00100" & x"FFFB",-- -5
	op_write & "00000" & "00000" & x"0000",
	
	op_halt & "00000" & "00000" & x"0000",
	op_halt & "00000" & "00000" & x"0000",
	op_halt & "00000" & "00000" & x"0000",
	op_halt & "00000" & "00000" & x"0000"
	)
	
	;
begin

	--とりあえず分散RAMをメモリとして利用する
	  
	--データ
	process (clk)
	begin
	    if rising_edge(clk) then
	        if load_store = '1' then
	            RAM(conv_integer(ls_address(3 downto 0))) <= write_data;
	        end if;
	    end if;
	end process;
	read_data <= RAM(conv_integer(ls_address(3 downto 0)));
	
	-- 命令
	read_inst <= RAM(conv_integer(pc(3 downto 0)));


end synth;








