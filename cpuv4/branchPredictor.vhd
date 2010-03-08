--•ªŠò—\‘ªŠí

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;
entity branchPredictor is
	generic (
		ghistlength : integer := 8--@1-11
	);
	port  (
		clk,flush,stall :in std_logic;
		pc : in std_logic_vector(13 downto 0);
		j1,j2 : in std_logic;
		jmp_commit : in std_logic;
		jmp_commit_counter : in std_logic_vector(1 downto 0);
		jmp_commit_pc : in std_logic_vector(12 downto 0);
		jmp_commit_hist : in std_logic_vector(ghistlength - 1 downto 0);
		c1,c2 : out std_logic_vector(1 downto 0);
		h1,h2 : out std_logic_vector(ghistlength - 1 downto 0)
	);
end branchPredictor;


architecture arch of branchPredictor is
	signal rst :std_logic := '0';
	type counter_table_t is array (0 to 8191) of std_logic_vector (1 downto 0);
	signal counter_table	:	counter_table_t := (others => "10");
	
	signal pc_buf1,pc_buf2 : std_logic_vector(12 downto 0) := (others => '0');
	signal branch_hist_buf,bht1,bht2 : std_logic_vector(ghistlength - 1 downto 0) := (others => '0');
	signal t1,t2: std_logic_vector(1 downto 0) := (others => '0');
begin
  	ROC0 : ROC port map (O => rst);
	c1 <= t1;
	c2 <= t2;

	t1 <= counter_table(conv_integer(pc_buf1));
	t2 <= counter_table(conv_integer(pc_buf2));--1‚ª•s¬—§‚Ìê‡‚Ì—\‘ª
	h1 <= branch_hist_buf;
	h2 <= branch_hist_buf(ghistlength - 2 downto 0)&'0';
	--h1 <= branch_hist_buf(ghistlength - 2 downto 0)&(not t1(1));
	--h2 <= branch_hist_buf(ghistlength - 3 downto 0)&'0'&(not t2(1));
	bht1 <= branch_hist_buf(ghistlength - 2 downto 0)&t2(1)when (j2 = '1') and (j1 = '0') else
	branch_hist_buf(ghistlength - 3 downto 0)&'0'&t2(1) when (j2 = '1') and (j1 = '1') and (t1(1) = '0') else
	branch_hist_buf(ghistlength - 2 downto 0)&t1(1) when (j1 = '1') else
	branch_hist_buf;
	
	process(clk,rst)
	begin
		if rst = '1' then
			branch_hist_buf <= (others => '0');
		elsif rising_edge(clk) then
			if jmp_commit = '1' then
				counter_table(conv_integer(jmp_commit_pc)) <= jmp_commit_counter;
			end if;
				
			if (flush = '1') and (jmp_commit = '1') then
				branch_hist_buf <= jmp_commit_hist;
			elsif (flush ='0') and (stall = '0') then
				branch_hist_buf <= bht1;
			end if;
			
			pc_buf1 <= (pc(12 downto 13 - ghistlength) xor bht1(ghistlength - 1 downto 0))& pc(12 - ghistlength downto 0);
			pc_buf2 <= (pc(12 downto 13 - ghistlength) xor bht1(ghistlength - 2 downto 0)&'0')& pc(12 - ghistlength downto 1)&'1';
		end if;
	end process;

end arch;

