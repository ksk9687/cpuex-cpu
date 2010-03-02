library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reservationStation is
	port  (
		clk : in std_logic;
		write : in std_logic;
		writeok: out std_logic;
		read : in std_logic;
		readok : out std_logic;
			
		inop: in std_logic_vector(3 downto 0);
		indtag: in std_logic_vector(4 downto 0);
		ins1: in std_logic_vector(32 downto 0);
		ins2: in std_logic_vector(32 downto 0);
		
		outop: out std_logic_vector(3 downto 0);
		outdtag: out std_logic_vector(4 downto 0);
		outs1: out std_logic_vector(31 downto 0);
		outs2: out std_logic_vector(31 downto 0);
		
		write1,write2 : in std_logic;
		dtag1,dtag2 : in std_logic_vector(4 downto 0);
		value1,value2 : in std_logic_vector(31 downto 0)
	);
end reservationStation;

architecture arch of reservationStation is

	constant op_valid : integer := 9;

	type s_t is array (0 to 3) of std_logic_vector (32 downto 0);
	signal s1,s1_write : s_t := (others => (others => '0'));
	signal s2,s2_write : s_t := (others => (others => '0'));
	
	type op_t is array (0 to 3) of std_logic_vector (9 downto 0);
	signal op,op_write : op_t := (others => (others => '0'));
	
	signal ready : std_logic_vector(3 downto 0) := (others => '0');
	
	signal readyop : std_logic_vector(73 downto 0) := (others => '0');
	signal go : std_logic_vector(3 downto 0) := (others => '0');
	signal newline : std_logic_vector(3 downto 0) := (others => '0');
begin
	writeok <= not (op(0)(op_valid) and op(1)(op_valid) and op(2)(op_valid) and op(3)(op_valid));
	readok <= readyop(73);
	outop <= readyop(72 downto 69);
	outdtag <= readyop(68 downto 64);
	outs1 <= readyop(63 downto 32);
	outs2 <= readyop(31 downto 0);


	--–½—ß‚Ì€”õ‚ªo—ˆ‚Ä‚¢‚é‚©
	ready(0) <= '1' when (s1_write(0)(32) = '1') and (s2_write(0)(32) = '1') and (op(0)(op_valid) = '1') else '0';
	ready(1) <= '1' when (s1_write(1)(32) = '1') and (s2_write(1)(32) = '1') and (op(1)(op_valid) = '1') else '0';
	ready(2) <= '1' when (s1_write(2)(32) = '1') and (s2_write(2)(32) = '1') and (op(2)(op_valid) = '1') else '0';
	ready(3) <= '1' when (s1_write(3)(32) = '1') and (s2_write(3)(32) = '1') and (op(3)(op_valid) = '1') else '0';
	--”­s€”õ‚É“ü‚é‚©
	go(0) <= ready(0) and ((not readyop(73)) or read);
	go(1) <= ready(1) and (not ready(0)) and ((not readyop(73)) or read);
	go(2) <= ready(2) and (not ready(1)) and (not ready(0)) and ((not readyop(73)) or read);
	go(3) <= ready(3) and (not ready(2)) and (not ready(1)) and (not ready(0)) and((not readyop(73)) or read);
	--V‚µ‚­“ü‚ê‚é‚È‚ç‚Ç‚±‚©
	newline(0) <= '1' when (op(0)(op_valid) = '0') or ((go(0) = '1') and (op(1)(op_valid) = '0')) else '0';
	newline(1) <= '1' when (newline(0) = '0') and ((op(1)(op_valid) = '0') or ((go(1) = '1') and (op(2)(op_valid) = '0'))) else '0';
	newline(2) <= '1' when (newline(1) = '0') and ((op(2)(op_valid) = '0') or ((go(0) = '1') and (op(1)(op_valid) = '0'))) else '0';
	newline(3) <= '1' when (newline(2) = '0') and ((op(3)(op_valid) = '0') or ((go(0) = '1') and (op(1)(op_valid) = '0'))) else '0';

	s1_write(0) <= '1'&value1 when (s1(0)(32) = '0') and (write1 = '1') and (s1(0)(4 downto 0) = dtag1) else
	'1'&value2 when (s1(0)(32) = '0') and (write2 = '1') and (s1(0)(4 downto 0) = dtag1) else
	s1(0);
	s1_write(1) <= '1'&value1 when (s1(1)(32) = '0') and (write1 = '1') and (s1(1)(4 downto 0) = dtag1) else
	'1'&value2 when (s1(1)(32) = '0') and (write2 = '1') and (s1(1)(4 downto 0) = dtag1) else
	s1(1);
	s1_write(2) <= '1'&value1 when (s1(2)(32) = '0') and (write1 = '1') and (s1(2)(4 downto 0) = dtag1) else
	'1'&value2 when (s1(2)(32) = '0') and (write2 = '1') and (s1(2)(4 downto 0) = dtag1) else
	s1(2);
	s1_write(3) <= '1'&value1 when (s1(3)(32) = '0') and (write1 = '1') and (s1(3)(4 downto 0) = dtag1) else
	'1'&value2 when (s1(3)(32) = '0') and (write2 = '1') and (s1(3)(4 downto 0) = dtag1) else
	s1(3);

	s2_write(0) <= '1'&value1 when (s2(0)(32) = '0') and (write1 = '1') and (s2(0)(4 downto 0) = dtag1) else
	'1'&value2 when (s2(0)(32) = '0') and (write2 = '1') and (s2(0)(4 downto 0) = dtag1) else
	s2(0);
	s2_write(1) <= '1'&value1 when (s2(1)(32) = '0') and (write1 = '1') and (s2(1)(4 downto 0) = dtag1) else
	'1'&value2 when (s2(1)(32) = '0') and (write2 = '1') and (s2(1)(4 downto 0) = dtag1) else
	s2(1);
	s2_write(2) <= '1'&value1 when (s2(2)(32) = '0') and (write1 = '1') and (s2(2)(4 downto 0) = dtag1) else
	'1'&value2 when (s2(2)(32) = '0') and (write2 = '1') and (s2(2)(4 downto 0) = dtag1) else
	s2(2);
	s2_write(3) <= '1'&value1 when (s2(3)(32) = '0') and (write1 = '1') and (s2(3)(4 downto 0) = dtag1) else
	'1'&value2 when (s2(3)(32) = '0') and (write2 = '1') and (s2(3)(4 downto 0) = dtag1) else
	s2(3);
	
	process(clk)
	begin
		if rising_edge(clk) then
			if go(0) = '1' then
				readyop <= op(0)&s1_write(0)(31 downto 0)&s2_write(0)(31 downto 0);
			elsif go(1) = '1' then
				readyop <= op(1)&s1_write(1)(31 downto 0)&s2_write(1)(31 downto 0);
			elsif go(1) = '1' then
				readyop <= op(2)&s1_write(2)(31 downto 0)&s2_write(2)(31 downto 0);
			elsif go(1) = '1' then
				readyop <= op(3)&s1_write(3)(31 downto 0)&s2_write(3)(31 downto 0);
			elsif read = '1' then
				readyop(73) <= '0';
			end if;
		
			if newline(0) = '1' then
				s1(0) <= ins1;
				s2(0) <= ins2;
				op(0) <= write&inop&indtag;
			elsif go(0) = '1' then
				s1(0) <= s1_write(1);
				s2(0) <= s2_write(1);
				op(0) <= op(1);
			else
				s1(0) <= s1_write(0);
				s2(0) <= s2_write(0);
				op(0) <= op(0);
			end if;
		
			if newline(1) = '1' then
				s1(1) <= ins1;
				s2(1) <= ins2;
				op(1) <= write&inop&indtag;
			elsif go(1) = '1' then
				s1(1) <= s1_write(2);
				s2(1) <= s2_write(2);
				op(1) <= op(2);
			else
				s1(1) <= s1_write(1);
				s2(1) <= s2_write(1);
				op(1) <= op(1);
			end if;
			
			if newline(2) = '1' then
				s1(2) <= ins1;
				s2(2) <= ins2;
				op(2) <= write&inop&indtag;
			elsif go(2) = '1' then
				s1(2) <= s1_write(3);
				s2(2) <= s2_write(3);
				op(2) <= op(3);
			else
				s1(2) <= s1_write(2);
				s2(2) <= s2_write(2);
				op(2) <= op(2);
			end if;
			
			if newline(3) = '1' then
				s1(3) <= ins1;
				s2(3) <= ins2;
				op(3) <= write&inop&indtag;
			elsif go(3) = '1' then
				s1(3) <= (others => '0');
				s2(3) <= (others => '0');
				op(3) <= (others => '0');
			else
				s1(3) <= s1_write(3);
				s2(3) <= s2_write(3);
				op(3) <= op(3);
			end if;
			
		end if;
	end process;
	


end arch;

