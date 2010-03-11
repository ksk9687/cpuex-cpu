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
	
	  type ram_type is array (0 to 255) of std_logic_vector (7 downto 0); 
    signal RAM : ram_type := 
    (
x"00", x"00", x"00", x"2D", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"04", x"C0", x"00", x"00", x"00",
x"00", x"00", x"00", x"00", x"03", x"F2", x"00", x"01", x"4F", x"FF", x"FC", x"00", x"00", x"00", x"00", x"14",
x"FF", x"EF", x"C0", x"01", x"4F", x"BE", x"F8", x"00", x"00", x"00", x"00", x"14", x"FB", x"EF", x"80", x"00",
x"C0", x"3C", x"01", x"09", x"00", x"00", x"00", x"C8", x"00", x"00", x"10", x"85", x"00", x"01", x"00", x"00",

x"00", x"00", x"00", x"50", x"00", x"20", x"00", x"10", x"C0", x"3C", x"01", x"0F", x"00", x"00", x"00", x"5C",
x"00", x"10", x"40", x"07", x"10", x"7D", x"00", x"00", x"00", x"00", x"00", x"C8", x"00", x"00", x"10", x"ED",
x"40", x"40", x"09", x"1D", x"00", x"00", x"00", x"08", x"FB", x"E0", x"00", x"34", x"9F", x"80", x"F0", x"00",
x"00", x"00", x"00", x"84", x"04", x"10", x"80", x"05", x"9F", x"80", x"04", x"01", x"00", x"00", x"00", x"0C",

x"03", x"C0", x"10", x"F5", x"9F", x"80", x"04", x"02", x"00", x"00", x"00", x"50", x"F8", x"10", x"00", x"18",
x"40", x"41", x"08", x"00", x"00", x"00", x"00", x"0C", x"03", x"C0", x"10", x"F5", x"0F", x"83", x"00", x"02",
x"00", x"00", x"00", x"80", x"04", x"10", x"C0", x"04", x"0F", x"BC", x"00", x"00", x"00", x"00", x"00", x"04",
x"FB", x"E0", x"00", x"3D", x"8F", x"00", x"00", x"00", x"00", x"00", x"00", x"02", x"41", x"20", x"00", x"00",

x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", 
x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", 
x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", 
x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00", x"3F", x"80", x"00", x"00"
);
    signal readdata_p : std_logic_vector(31 downto 0) := (others => '0');
    signal pointer : std_logic_vector(7 downto 0) := (others => '0');
    signal counter : std_logic_vector(2 downto 0) := (others => '0');
begin
  	RSTXD <= '0';
  	io_read_buf_overrun <= '0';
  	
	readdata_p <= x"00000"&"000"&'0'&RAM(conv_integer(pointer));

	process(clk)
	begin
		if rising_edge(clk) then
			if (iou_op = iou_op_read) and (enable = '1') then
				counter <= counter + '1';
				readdata <= readdata_p;
			elsif (iou_op = iou_op_write) and (enable = '1') then
				counter <= counter + '1';
				readdata <= x"0000000"&"0000";
			else
				readdata <= readdata_p;
			end if;
			if (iou_op = iou_op_read) and (enable = '1') then
				pointer <= pointer + '1';
			end if;
		end if;
	end process;
	 	 
	

end arch;

