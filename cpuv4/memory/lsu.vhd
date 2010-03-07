
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.util.all; 
use work.instruction.all;
use work.SuperScalarComponents.all; 

entity lsu is
	port  (
		clk,flush,write : in std_logic;
    	load_end,store_ok,io_ok,io_end,lsu_full : out std_logic;
		storeexec,ioexec : in std_logic;
		op : in std_logic_vector(5 downto 0);
		im : in std_logic_vector(13 downto 0);
    	
    	a,b : in std_logic_vector(31 downto 0);
    	o,iou_out : out std_logic_vector(31 downto 0);
    	
    	tagin : in std_logic_vector(3 downto 0);
    	tagout : out std_logic_vector(3 downto 0);
    	
    	ls_flg : out std_logic_vector(2 downto 0);
		load_hit : in std_logic;
    	load_data : in std_logic_vector(31 downto 0);
    	ls_addr_out : out std_logic_vector(19 downto 0);
    	store_data : out std_logic_vector(31 downto 0);
    	
    	RS_RX : in STD_LOGIC;
	    RS_TX : out STD_LOGIC;
	    outdata0 : out std_logic_vector(7 downto 0);
	    outdata1 : out std_logic_vector(7 downto 0);
	    outdata2 : out std_logic_vector(7 downto 0);
	    outdata3 : out std_logic_vector(7 downto 0);
	    outdata4 : out std_logic_vector(7 downto 0);
	    outdata5 : out std_logic_vector(7 downto 0);
	    outdata6 : out std_logic_vector(7 downto 0);
	    outdata7 : out std_logic_vector(7 downto 0)
	);
end lsu;


architecture arch of lsu is
	--io
   signal leddata : std_logic_vector(31 downto 0):= (others => '0');
   signal leddotdata : std_logic_vector(7 downto 0):= (others => '0');
	signal iou_enable :std_logic:='0';
	signal io_read_buf_overrun :std_logic;
	signal io : std_logic_vector(38 downto 0) := (others => '0');
	
	
begin
	lsu_full <= io(38);
	io_ok <= io(38);
	tagout <= io(37 downto 34);
  leddotdata <= "1111111" & (not io_read_buf_overrun);
  led_inst : ledextd2 port map (
      leddata,
      leddotdata,
      outdata0,
      outdata1,
      outdata2,
      outdata3,
      outdata4,
      outdata5,
      outdata6,
      outdata7
    );
    IOU0 : IOU port map (
		clk,iou_enable,
		io(33 downto 32),io(31 downto 0),
		iou_out,RS_RX,RS_TX,
		io_read_buf_overrun
	);
	iou_enable <= (not io(33)) and ioexec and io(38);
	IOPROC:process(clk)
	begin
		if rising_edge(clk) then
			io_end <= iou_enable;
			if flush = '1' then
				io(38) <= '0';
			elsif (write = '1') and (op(5 downto 3) = "111") then--ledi
				io <= '1'&tagin&op(4 downto 3)&x"000000"&im(7 downto 0);
			elsif (write = '1') and (op(5 downto 3) = "110") then
				io <= '1'&tagin&op(4 downto 3)&a;
			elsif ioexec = '1' then
				io(38) <= '0';
  				leddata <= io(31 downto 0);
			end if;
		end if;
	end process;
		

end arch;

