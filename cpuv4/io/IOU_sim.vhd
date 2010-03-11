--IOƒ†ƒjƒbƒg‚Ì

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 
library UNISIM;
use UNISIM.VComponents.all;


entity IOU is
	port  (
		clk,enable : in std_logic;
		iou_op : in std_logic_vector(1 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		readdata : out std_logic_vector(31 downto 0)
		
		;RSRXD : in STD_LOGIC
		;RSTXD : out STD_LOGIC
		
		;io_read_buf_overrun : out STD_LOGIC
	);
end IOU;

architecture arch of IOU is
	constant iou_op_read : std_logic_vector := "00";
	constant iou_op_write : std_logic_vector := "01";
	
	  type ram_type is array (0 to 127) of std_logic_vector (7 downto 0); 
    signal RAM : ram_type := 
    (
x"00", x"00", x"00", x"1E",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"04",
 x"C0", x"00", x"00", x"00",
x"00", x"00", x"00", x"00", x"03", x"F2", x"00", x"01", x"4F", x"FF", x"FC", x"00", x"00", x"00", x"00", x"14",
x"FF", x"EF", x"C0", x"01", x"4F", x"BE", x"F8", x"00", x"00", x"00", x"00", x"14", x"FB", x"EF", x"80", x"00",
x"C0", x"3C", x"01", x"09", x"00", x"00", x"00", x"C8", x"00", x"00", x"10", x"80", x"00", x"01", x"00", x"00",

x"00", x"00", x"00", x"00", x"00", x"20", x"00", x"00", x"00", x"03", x"00", x"01", x"00", x"00", x"00", x"C9",
x"04", x"02", x"91", x"21", x"40", x"BD", x"0C", x"00", x"00", x"00", x"00", x"10", x"0C", x"20", x"00", x"01",
x"0F", x"43", x"00", x"00", x"00", x"00", x"00", x"04", x"04", x"10", x"00", x"1C", x"80", x"00", x"01", x"0C",
x"00", x"00", x"00", x"71", x"0B", x"D0", x"00", x"0C", x"80", x"00", x"01", x"13", x"00", x"00", x"00", x"00"
);
    signal readdata_p : std_logic_vector(31 downto 0) := (others => '0');
    signal pointer : std_logic_vector(6 downto 0) := (others => '0');
    signal counter : std_logic_vector(2 downto 0) := (others => '0');
begin
  	RSTXD <= '0';
  	io_read_buf_overrun <= '0';
  	
	readdata_p <= x"00000"&"000"&'1'&RAM(conv_integer(pointer));

	process(clk)
	begin
		if rising_edge(clk) then
			if (iou_op = iou_op_read) and (enable = '1') then
				counter <= counter + '1';
				readdata <= readdata_p;
			elsif (iou_op = iou_op_write) and (enable = '1') then
				counter <= counter + '1';
				readdata <= x"0000000"&"0001";
			else
				readdata <= readdata_p;
			end if;
			if (iou_op = iou_op_read) and (enable = '1') then
				pointer <= pointer + '1';
			end if;
		end if;
	end process;
	 	 
	

end arch;

