library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bru is
	port  (
		clk : in std_logic;
    	op   : in std_logic_vector(2 downto 0);-- call ret jmp(1:f,0:i)
    	mask   : in std_logic_vector(2 downto 0);
    	hist   : in std_logic;
    	A, B : in  std_logic_vector(31 downto 0);
    	pc : in  std_logic_vector(13 downto 0);
     jmpflg : out std_logic;
     newpc : out std_logic_vector(13 downto 0)
	);
end bru;

architecture arch of bru is
  signal g,e,l,z,r : std_logic := '0';
  signal op_buf : std_logic_vector(2 downto 0) := (others => '0');
  signal cg,ce,cl,cfg,cfe,cfl,ret,hist_buf : std_logic := '0';
  signal pc_buf : std_logic_vector(13 downto 0) := (others => '0');
  signal mask_buf : std_logic_vector(2 downto 0) := (others => '0');
begin
  	

	g <= '1' when ((not A(31))&A(30 downto 0)) > ((not B(31))&B(30 downto 0)) else '0';
	e <= '1' when ((not A(31))&A(30 downto 0)) = ((not B(31))&B(30 downto 0)) else '0';
	l <= '1' when ((not A(31))&A(30 downto 0)) < ((not B(31))&B(30 downto 0)) else '0';
	z <= '1' when (A(30 downto 23) = "00000000") and (B(30 downto 23) = "00000000") else '0';
	--r <= '1' when jr_addr /= pc else '0';
	
	process(clk)
	begin
		if rising_edge(clk) then
			op_buf <= op;
			pc_buf <= pc;
			hist_buf <= hist;
			mask_buf <= mask;
			ret <= r;
			
			cg <= g;
			ce <= e;
			cl <= l;
			
			cfe <= e or z;
			
			if (A(31) = '1') and (B(31) = '1') then
				cfg <= l and (not z);
				cfl <= g and (not z);
			else
				cfg <= g and (not z);
				cfl <= l and (not z);
			end if;
		end if;
	end process;
	
	newpc <= pc_buf;
	--•ªŠò‚µ‚È‚¨‚·•K—v‚ª‚ ‚é‚©
	with op_buf select
	 jmpflg <= hist_buf xor ((not ((mask_buf(2) and cg) or (mask_buf(1) and ce) or (mask_buf(0) and cl)))) when "000"|"001",--cmpi,cmp
	 hist_buf xor (not ((mask_buf(2) and cfg) or (mask_buf(1) and cfe) or (mask_buf(0) and cfl))) when "010",--cmpf
	 '0' when others;--call ret


end arch;

