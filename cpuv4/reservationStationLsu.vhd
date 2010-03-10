library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;
entity reservationStationLsu is
	generic (
		opbits : integer := 20
	);
	port  (
		clk,flush : in std_logic;
		write : in std_logic;
		writeok: out std_logic;
		read : in std_logic;
		readok : out std_logic;
			
		inop: in std_logic_vector(opbits - 1 downto 0);
		indtag: in std_logic_vector(3 downto 0);
		ins1: in std_logic_vector(32 downto 0);
		ins2: in std_logic_vector(32 downto 0);

		outop: out std_logic_vector(opbits - 1 downto 0);
		outdtag: out std_logic_vector(3 downto 0);
		outs1: out std_logic_vector(31 downto 0);
		outs2: out std_logic_vector(31 downto 0);
		
		write1,write2,write3 : in std_logic;
		dtag1,dtag2,dtag3 : in std_logic_vector(3 downto 0);
		value1,value2,value3 : in std_logic_vector(31 downto 0)
	);
end reservationStationLsu;

architecture arch of reservationStationLsu is
	signal rst :std_logic := '0';
	
	constant op_valid : integer := 0;

	constant op_cant_bypass : integer := 5;

	type s_t is array (0 to 3) of std_logic_vector (32 downto 0);
	signal s1,s1_write : s_t := (others => (others => '0'));
	signal s2,s2_write : s_t := (others => (others => '0'));
	
	type op_t is array (0 to 3) of std_logic_vector (opbits + 4 downto 0);
	signal op,op_write : op_t := (others => (others => '0'));
	
	signal ready : std_logic_vector(3 downto 0) := (others => '0');
	
	signal readyop : std_logic_vector((63 + 1 + 4 + opbits) downto 0) := (others => '0');
	signal go : std_logic_vector(3 downto 0) := (others => '0');
	signal newline : std_logic_vector(3 downto 0) := (others => '0');
	signal insert : std_logic_vector(3 downto 0) := (others => '0');
begin
  	ROC0 : ROC port map (O => rst);
  	
	writeok <= not (op(0)(op_valid) and op(1)(op_valid) and op(2)(op_valid) and op(3)(op_valid));
	outop <= readyop(68 + opbits downto 69 + op_valid);
	outdtag <= readyop(68 + op_valid downto 65 + op_valid);
	readok <= readyop(64 + op_valid);
	outs1 <= readyop(63 downto 32);
	outs2 <= readyop(31 downto 0);


	--命令の準備が出来ているか
	ready(0) <= '1' when (s1_write(0)(32) = '1') and (s2_write(0)(32) = '1') and (op(0)(op_valid) = '1') else '0';
	ready(1) <= '1' when (s1_write(1)(32) = '1') and (s2_write(1)(32) = '1') and (op(1)(op_valid) = '1') else '0';
	ready(2) <= '1' when (s1_write(2)(32) = '1') and (s2_write(2)(32) = '1') and (op(2)(op_valid) = '1') else '0';
	ready(3) <= '1' when (s1_write(3)(32) = '1') and (s2_write(3)(32) = '1') and (op(3)(op_valid) = '1') else '0';
	--発行準備に入るか
	go(0) <= ready(0) and ((not readyop(64 + op_valid)) or read);
	go(1) <= ready(1) and (not ready(0)) and ((not readyop(64 + op_valid)) or read) and (not op(0)(op_cant_bypass));
	go(2) <= ready(2) and (not ready(1)) and (not ready(0)) and ((not readyop(64 + op_valid)) or read) and (not op(0)(op_cant_bypass)) and (not op(1)(op_cant_bypass));
	go(3) <= ready(3) and (not ready(2)) and (not ready(1)) and (not ready(0)) and((not readyop(64 + op_valid)) or read)and (not op(0)(op_cant_bypass))and (not op(1)(op_cant_bypass)) and (not op(2)(op_cant_bypass));
	--最小の無効なライン
	newline(0) <= '1' when (op(0)(op_valid) = '0') else '0';
	newline(1) <= '1' when (op(0)(op_valid) = '1') and (op(1)(op_valid) = '0') else '0';
	newline(2) <= '1' when (op(0)(op_valid) = '1') and (op(1)(op_valid) = '1') and (op(2)(op_valid) = '0') else '0';
	newline(3) <= '1' when (op(0)(op_valid) = '1') and (op(1)(op_valid) = '1') and (op(2)(op_valid) = '1')and (op(3)(op_valid) = '0') else '0';
	--新しく入れるならどこか
	insert(0) <= newline(1) when (go(0) = '1') else newline(0);
	insert(1) <= newline(2) when (go(0) = '1') or (go(1) = '1') else newline(1);
	insert(2) <= newline(3) when (go(0) = '1') or (go(1) = '1') or (go(2) = '1') else newline(2);
	insert(3) <= '0' when (go(0) = '1') or (go(1) = '1') or (go(2) = '1') or (go(3) = '1') else newline(3);

	s1_write(0) <= '1'&value1 when (s1(0)(32) = '0') and (write1 = '1') and (s1(0)(3 downto 0) = dtag1) else
	'1'&value2 when (s1(0)(32) = '0') and (write2 = '1') and (s1(0)(3 downto 0) = dtag2) else
	'1'&value3 when (s1(0)(32) = '0') and (write3 = '1') and (s1(0)(3 downto 0) = dtag3) else
	s1(0);
	s1_write(1) <= '1'&value1 when (s1(1)(32) = '0') and (write1 = '1') and (s1(1)(3 downto 0) = dtag1) else
	'1'&value2 when (s1(1)(32) = '0') and (write2 = '1') and (s1(1)(3 downto 0) = dtag2) else
	'1'&value3 when (s1(1)(32) = '0') and (write3 = '1') and (s1(1)(3 downto 0) = dtag3) else
	s1(1);
	s1_write(2) <= '1'&value1 when (s1(2)(32) = '0') and (write1 = '1') and (s1(2)(3 downto 0) = dtag1) else
	'1'&value2 when (s1(2)(32) = '0') and (write2 = '1') and (s1(2)(3 downto 0) = dtag2) else
	'1'&value3 when (s1(2)(32) = '0') and (write3 = '1') and (s1(2)(3 downto 0) = dtag3) else
	s1(2);
	s1_write(3) <= '1'&value1 when (s1(3)(32) = '0') and (write1 = '1') and (s1(3)(3 downto 0) = dtag1) else
	'1'&value2 when (s1(3)(32) = '0') and (write2 = '1') and (s1(3)(3 downto 0) = dtag2) else
	'1'&value3 when (s1(3)(32) = '0') and (write3 = '1') and (s1(3)(3 downto 0) = dtag3) else
	s1(3);

	s2_write(0) <= '1'&value1 when (s2(0)(32) = '0') and (write1 = '1') and (s2(0)(3 downto 0) = dtag1) else
	'1'&value2 when (s2(0)(32) = '0') and (write2 = '1') and (s2(0)(3 downto 0) = dtag2) else
	'1'&value3 when (s2(0)(32) = '0') and (write3 = '1') and (s2(0)(3 downto 0) = dtag3) else
	s2(0);
	s2_write(1) <= '1'&value1 when (s2(1)(32) = '0') and (write1 = '1') and (s2(1)(3 downto 0) = dtag1) else
	'1'&value2 when (s2(1)(32) = '0') and (write2 = '1') and (s2(1)(3 downto 0) = dtag2) else
	'1'&value3 when (s2(1)(32) = '0') and (write3 = '1') and (s2(1)(3 downto 0) = dtag3) else
	s2(1);
	s2_write(2) <= '1'&value1 when (s2(2)(32) = '0') and (write1 = '1') and (s2(2)(3 downto 0) = dtag1) else
	'1'&value2 when (s2(2)(32) = '0') and (write2 = '1') and (s2(2)(3 downto 0) = dtag2) else
	'1'&value3 when (s2(2)(32) = '0') and (write3 = '1') and (s2(2)(3 downto 0) = dtag3) else
	s2(2);
	s2_write(3) <= '1'&value1 when (s2(3)(32) = '0') and (write1 = '1') and (s2(3)(3 downto 0) = dtag1) else
	'1'&value2 when (s2(3)(32) = '0') and (write2 = '1') and (s2(3)(3 downto 0) = dtag2) else
	'1'&value3 when (s2(3)(32) = '0') and (write3 = '1') and (s2(3)(3 downto 0) = dtag3) else
	s2(3);
	
	process(clk,rst)
	begin
		if rst = '1' then
		elsif rising_edge(clk) then
			if flush = '1' then
				op(0)(op_valid) <= '0';
				op(1)(op_valid) <= '0';
				op(2)(op_valid) <= '0';
				op(3)(op_valid) <= '0';
				readyop <= (others => '0');
			else
				if go(0) = '1' then
					readyop <= op(0)&s1_write(0)(31 downto 0)&s2_write(0)(31 downto 0);
				elsif go(1) = '1' then
					readyop <= op(1)&s1_write(1)(31 downto 0)&s2_write(1)(31 downto 0);
				elsif go(2) = '1' then
					readyop <= op(2)&s1_write(2)(31 downto 0)&s2_write(2)(31 downto 0);
				elsif go(3) = '1' then
					readyop <= op(3)&s1_write(3)(31 downto 0)&s2_write(3)(31 downto 0);
				elsif read = '1' then
					readyop(64 + op_valid) <= '0';
				end if;
			
				if insert(0) = '1' then
					s1(0) <= ins1;
					s2(0) <= ins2;
					op(0) <= inop&indtag&write;
				elsif go(0) = '1' then
					s1(0) <= s1_write(1);
					s2(0) <= s2_write(1);
					op(0) <= op(1);
				else
					s1(0) <= s1_write(0);
					s2(0) <= s2_write(0);
					op(0) <= op(0);
				end if;
			
				if insert(1) = '1' then
					s1(1) <= ins1;
					s2(1) <= ins2;
					op(1) <= inop&indtag&write;
				elsif (go(1) = '1') or (go(0) = '1') then
					s1(1) <= s1_write(2);
					s2(1) <= s2_write(2);
					op(1) <= op(2);
				else
					s1(1) <= s1_write(1);
					s2(1) <= s2_write(1);
					op(1) <= op(1);
				end if;
				
				if insert(2) = '1' then
					s1(2) <= ins1;
					s2(2) <= ins2;
					op(2) <= inop&indtag&write;
				elsif (go(2) = '1') or (go(1) = '1') or (go(0) = '1') then
					s1(2) <= s1_write(3);
					s2(2) <= s2_write(3);
					op(2) <= op(3);
				else
					s1(2) <= s1_write(2);
					s2(2) <= s2_write(2);
					op(2) <= op(2);
				end if;
				
				if insert(3) = '1' then
					s1(3) <= ins1;
					s2(3) <= ins2;
					op(3) <= inop&indtag&write;
				elsif (go(3) = '1') or (go(2) = '1') or (go(1) = '1') or (go(0) = '1')  then
					s1(3) <= (others => '0');
					s2(3) <= (others => '0');
					op(3) <= (others => '0');
				else
					s1(3) <= s1_write(3);
					s2(3) <= s2_write(3);
					op(3) <= op(3);
				end if;
			end if;
		end if;
	end process;
	


end arch;

