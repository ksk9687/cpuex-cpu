
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.instruction.all;
use work.SuperScalarComponents.all; 

entity lsu is
	port  (
		clk,write,load_ok : in std_logic;
		op : in std_logic_vector(2 downto 0);
    	lsu_ok,lsu_full : out std_logic;--
    	
    	ls_addr_in : in std_logic_vector(19 downto 0);--
    	ls_addr_out : out std_logic_vector(19 downto 0);--
    	
    	ls_flg : out std_logic_vector(2 downto 0);--
    	reg_d : out std_logic_vector(5 downto 0);
    	
    	lsu_in : in std_logic_vector(31 downto 0);--
    	lsu_out : out std_logic_vector(31 downto 0);--
    	load_data : in std_logic_vector(31 downto 0);--
    	store_data : out std_logic_vector(31 downto 0)--
	);
end lsu;


architecture arch of lsu is
	type lsu_lstate_t is (
		normal,revert,miss,buf0,buf1,buf2,buf3,buf4
	);
	signal lsu_state : lsu_lstate_t := normal;
	
	
	 signal writeok_in,empty,readok_in,load_end,load_end_p,lsu_ok_in :std_logic := '0';
	 signal writedata,readdata1,readdata2 : std_logic_vector(54 downto 0) := (others => '0');
	 signal readdata1_buf,readdata2_buf : std_logic_vector(54 downto 0) := (others => '0');
	signal load_wait,lsu_may_full,m :std_logic := '0';
begin
	lsu_full <= not lsu_ok_in when (lsu_state = normal) else '1';
	lsu_ok <= readdata1(53) and load_ok when (lsu_state =  miss) else '0';
	
	lsu_ok_in <= (not readdata1(53)) or load_ok;
	-- <= load_ok when readdata1(53) = "1" else '1';
	
	reg_d <= readdata1(25 downto 20);
	lsu_out <= load_data;
	
	ls_flg(2) <= readdata2(54);
	ls_flg(1) <= readdata2(53);
	ls_flg(0) <= readdata2(52);
	store_data <= readdata2(51 downto 20);
	ls_addr_out <= readdata2(19 downto 0);
	
	writedata(19 downto 0) <= ls_addr_in;
	writedata(51 downto 20) <= lsu_in;
	writedata(54) <= write when op = op_store_inst(2 downto 0) else '0'; 
	writedata(53) <= write when (op = op_load(2 downto 0)) or (op = op_loadr(2 downto 0)) else '0'; 
	writedata(52) <= write when (op = op_store(2 downto 0)) or (op = op_store_inst(2 downto 0)) else '0'; 

	process(clk)
	begin
		if rising_edge(clk) then
			case lsu_state is
				when normal =>
					if lsu_ok_in = '0' then
						readdata1_buf <= readdata2;
						readdata2_buf <= writedata;
						readdata1 <= readdata1;
						readdata2 <= readdata1;
						
						lsu_state <= buf0;
					else
						readdata1 <= readdata2;
						readdata2 <= writedata;
					end if;
				when buf0 => lsu_state <= buf1;
				when buf1 => lsu_state <= buf2;
				when buf2 => lsu_state <= buf4;
				when buf3 => lsu_state <= buf4;
				when buf4 => lsu_state <= miss;
				when miss =>
					if lsu_ok_in = '1' then --hit
						if readdata1_buf(53 downto 52) /= "00" then
							lsu_state <= buf4;
							readdata1 <= readdata1_buf;
							readdata2 <= readdata1_buf;
							readdata1_buf <= readdata2_buf;
						elsif readdata2_buf(53 downto 52) /= "00" then
							lsu_state <= buf4;
							readdata1 <= readdata2_buf;
							readdata2 <= readdata2_buf;
							readdata1_buf <= (others => '0');
						else
							lsu_state <= normal;
							readdata1 <= (others => '0');
							readdata2 <= (others => '0');
							readdata1_buf <= (others => '0');
						end if;
							readdata2_buf <= (others => '0');
					else
						readdata1 <= readdata1;
						readdata2 <= readdata1;
					end if;
				when others  => lsu_state <= normal;
			end case;
		end if;
	end process;
end arch;

