--•ªŠò—\‘ªŠí

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity branchPredictor is
	port  (
		clk,rst,flush :in std_logic;
		bp_ok :out std_logic;
		pc : in std_logic_vector(13 downto 0);
		jmp,b_taken,b_not_taken : in std_logic;
		taken,taken_hist : out std_logic
	);
end branchPredictor;


architecture arch of branchPredictor is
	type counter_table_t is array (0 to 8191) of std_logic_vector (1 downto 0);
	signal counter_table	:	counter_table_t := (others => "01");
	
	type counter_hist_table_t is array (0 to 15) of std_logic_vector (15 downto 0);
	signal counter_hist_table	:	counter_hist_table_t := (others => (others => '0'));
	
	signal read_pointer :std_logic_vector(3 downto 0) := (others => '0');
	signal write_pointer :std_logic_vector(3 downto 0) := (others => '0');
	
	signal stop,taken_in,hist : std_logic;
	signal counter,counter_buf,newcounter : std_logic_vector(1 downto 0);
	signal pc_buf,pc_buf2 : std_logic_vector(12 downto 0);
	signal hist_buf : std_logic_vector(7 downto 0);
begin
	--taken <= '0';
	--taken_hist <= '0';
	

--	bp_ok <= not stop;
--	taken <= taken_in;
--	taken_hist <= hist;

	taken <= taken_in;
	taken_in <= counter(1);
	counter <= counter_table(conv_integer(pc_buf));
	
	taken_hist <= counter_hist_table(conv_integer(read_pointer))(0);
	counter_buf <= counter_hist_table(conv_integer(read_pointer))(2 downto 1);
	pc_buf2 <= counter_hist_table(conv_integer(read_pointer))(15 downto 3);
	
	
	newcounter <= counter_buf + '1' when b_taken = '1' and counter_buf /= "11" else
	counter_buf - '1' when b_not_taken = '1' and counter_buf /= "00" else
	counter_buf;
	
	process(clk)
	begin
		if rst = '1' then
				read_pointer <= "0000";
				write_pointer <= "0000";
				hist_buf <= (others => '0');
		elsif rising_edge(clk) then
			if flush = '1' then
				read_pointer <= "0000";
				write_pointer <= "0000";
			else
				if jmp = '1' then
					counter_hist_table(conv_integer(write_pointer)) <= pc_buf&counter&taken_in;
					write_pointer <= write_pointer + '1';
				end if;
				if b_taken = '1' or b_not_taken = '1' then
					read_pointer <= read_pointer + '1';
				end if;
			end if;
			
			if b_taken = '1' or b_not_taken = '1' then
				hist_buf <= hist_buf(6 downto 0) & b_taken;
				counter_table(conv_integer(pc_buf2)) <= newcounter;
			end if;
			
			pc_buf <= (pc(12 downto 5) xor hist_buf(7 downto 0))& pc(4 downto 0);
		end if;
	end process;
	
	

end arch;

