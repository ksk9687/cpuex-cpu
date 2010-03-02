--•ªŠò—\‘ªŠí

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity branchPredictor is
	port  (
		clk,rst,flush :in std_logic;
		bp_ok :out std_logic;
		pc : in std_logic_vector(13 downto 0);
		jmp_num : out std_logic_vector(2 downto 0);
		jmp,b_taken,b_not_taken : in std_logic;
		taken,taken_hist : out std_logic
	);
end branchPredictor;


architecture arch of branchPredictor is
	type counter_table_t is array (0 to 8191) of std_logic_vector (1 downto 0);
	signal counter_table	:	counter_table_t := (others => "01");
	
	type counter_hist_table_t is array (0 to 7) of std_logic_vector (15 downto 0);
	signal counter_hist_table	:	counter_hist_table_t := (others => (others => '0'));
	
	signal read_pointer :std_logic_vector(2 downto 0) := (others => '0');
	signal write_pointer :std_logic_vector(2 downto 0) := (others => '0');
	
	signal stop,taken_in,hist : std_logic;
	signal counter,counter_buf,newcounter,newcounter_p,newcounter_m : std_logic_vector(1 downto 0);
	signal pc_buf,pc_buf2 : std_logic_vector(12 downto 0);
	signal branch_hist_buf : std_logic_vector(8 downto 0);
begin

	taken <= taken_in;
	taken_in <= counter(1);
	counter <= counter_table(conv_integer(pc_buf));
	
	taken_hist <= counter_hist_table(conv_integer(read_pointer))(0);
	counter_buf <= counter_hist_table(conv_integer(read_pointer))(2 downto 1);
	pc_buf2 <= counter_hist_table(conv_integer(read_pointer))(15 downto 3);
	
	bp_ok <= '1' when read_pointer = write_pointer else '0';
	jmp_num <= write_pointer - read_pointer;
	
	with counter_buf select
	 newcounter_p <= "01" when "00",
	 "10" when "01",
	 "11" when others;
	with counter_buf select
	 newcounter_m <= "10" when "11",
	 "01" when "10",
	 "00" when others;
	
	newcounter <= newcounter_p when b_taken = '1' else
	newcounter_m;
	
	process(clk,rst)
	begin
		if rst = '1' then
			read_pointer <= (others => '0');
			write_pointer <= (others => '0');
			branch_hist_buf <= (others => '0');
		elsif rising_edge(clk) then
			if flush = '1' then
				read_pointer <= (others => '0');
				write_pointer <= (others => '0');
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
				branch_hist_buf <= branch_hist_buf(7 downto 0) & b_taken;
				counter_table(conv_integer(pc_buf2)) <= newcounter;
			end if;
			pc_buf <= (pc(12 downto 5) xor branch_hist_buf(7 downto 0))& pc(4 downto 0);
		end if;
	end process;

end arch;

