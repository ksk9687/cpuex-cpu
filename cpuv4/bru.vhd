library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bru is
	port  (
		clk : in std_logic;
    	op   : in std_logic_vector(1 downto 0);-- ret,jmp(1:f,0:i)
    	mask   : in std_logic_vector(2 downto 0);
    	histcounter   : in std_logic_vector(1 downto 0);
    	globalhist   : in std_logic_vector(7 downto 0);
    	A, B : in  std_logic_vector(31 downto 0);
    	pc : in  std_logic_vector(13 downto 0);--jmp��
    	instpc : in  std_logic_vector(13 downto 0);--���򖽗߂̃A�h���X
    	
     	jmpflg : out std_logic;--flush�̕K�v�����邩
     	newpc : out std_logic_vector(13 downto 0);--�V����PC
    	newcounter   : out std_logic_vector(1 downto 0);--�V�����J�E���^
    	key   : out std_logic_vector(12 downto 0);--�V�����J�E���^������ꏊ
    	newhist   : out std_logic_vector(7 downto 0)
	);
end bru;

architecture arch of bru is
  signal g,e,l,z,r,jmpflg_in : std_logic := '0';
  signal op_buf : std_logic_vector(1 downto 0) := (others => '0');
  signal cg,ce,cl,cfg,cfe,cfl,ret,hist_buf : std_logic := '0';
  signal ghist_buf : std_logic_vector(7 downto 0) := (others => '0');
  signal pc_buf : std_logic_vector(13 downto 0) := (others => '0');
  signal mask_buf : std_logic_vector(2 downto 0) := (others => '0');
  signal cot,cont,cotb,contb : std_logic_vector(1 downto 0) := (others => '0');
begin
  	

	g <= '1' when ((not A(31))&A(30 downto 0)) > ((not B(31))&B(30 downto 0)) else '0';
	e <= '1' when ((not A(31))&A(30 downto 0)) = ((not B(31))&B(30 downto 0)) else '0';
	l <= '1' when ((not A(31))&A(30 downto 0)) < ((not B(31))&B(30 downto 0)) else '0';
	z <= '1' when (A(30 downto 23) = "00000000") and (B(30 downto 23) = "00000000") else '0';
	r <= '1' when A(13 downto 0) /= pc else '0';--jr miss
	
	with histcounter select
	 cot <= "01" when "00",
	 "10" when "01",
	 "11" when others;
	with histcounter select
	 cont <= "10" when "11",
	 "01" when "10",
	 "00" when others;
	
	
	
	process(clk)
	begin
		if rising_edge(clk) then
			op_buf <= op;
			
			if op = "11" then--ret
				pc_buf <= A(13 downto 0);
			elsif histcounter(1) = '1' then--���򂵂Ă�����miss�����ꍇ���߂̃A�h���X�{�P������s���Ȃ���
				pc_buf <= instpc + '1';
			else
				pc_buf <= pc;
			end if;
			if op = "11" then
				hist_buf <= '0';
			else
				hist_buf <= histcounter(1);
			end if;
			
			ghist_buf <= globalhist;
			mask_buf <= mask;
			ret <= r;
			
			cg <= g;
			ce <= e;
			cl <= l;
			
			--�X�V��̃J�E���^���
			cotb <= cot;
			contb <= cont;
			
			cfe <= e or z;
			
			key <= (instpc(12 downto 5) xor globalhist(7 downto 0))& instpc(4 downto 0);
			
			if (A(31) = '1') and (B(31) = '1') then
				cfg <= l and (not z);
				cfl <= g and (not z);
			else
				cfg <= g and (not z);
				cfl <= l and (not z);
			end if;
		end if;
	end process;
	
	newhist <= ghist_buf;
	newcounter <= cotb when jmpflg_in = '1' else cotb;
	newpc <= pc_buf;
	--���򂵂Ȃ����K�v�����邩
	jmpflg <= hist_buf xor jmpflg_in;
	with op_buf select
	 jmpflg_in <=((not ((mask_buf(2) and cg) or (mask_buf(1) and ce) or (mask_buf(0) and cl)))) when "00"|"01",--cmpi,cmp
	 (not ((mask_buf(2) and cfg) or (mask_buf(1) and cfe) or (mask_buf(0) and cfl))) when "10",--cmpf
	 ret when others;--ret


end arch;

