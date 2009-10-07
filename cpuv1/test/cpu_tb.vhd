--CPU�̃e�X�g���x���`



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity cpu_tb is
end cpu_tb;

architecture arch of cpu_tb is
component cpu_top is
    Port (
		CLKIN : in STD_LOGIC
		--led
		;LEDOUT		: out  STD_LOGIC_VECTOR (7 downto 0)
		--SRAM
		;SRAMAA : out  STD_LOGIC_VECTOR (19 downto 0)	--�A�h���X
		;SRAMIOA : inout  STD_LOGIC_VECTOR (31 downto 0)	--�f�[�^
		;SRAMIOPA : inout  STD_LOGIC_VECTOR (3 downto 0) --�p���e�B�[
		
		;SRAMRWA : out  STD_LOGIC	--read=>1,write=>0
		;SRAMBWA : out  STD_LOGIC_VECTOR (3 downto 0)--�������݃o�C�g�̎w��

		;SRAMCLKMA0 : out  STD_LOGIC	--SRAM�N���b�N
		;SRAMCLKMA1 : out  STD_LOGIC	--SRAM�N���b�N
		
		;SRAMADVLDA : out  STD_LOGIC	--�o�[�X�g�A�N�Z�X
		;SRAMCEA : out  STD_LOGIC --clock enable
		
		;SRAMCELA1X : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEHA1X : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEA2X : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEA2 : out  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���

		;SRAMLBOA : out  STD_LOGIC	--�o�[�X�g�A�N�Z�X��
		;SRAMXOEA : out  STD_LOGIC	--IO�o�̓C�l�[�u��
		;SRAMZZA : out  STD_LOGIC	--�X���[�v���[�h�ɓ���
	);
	end component;
	
	signal SRAMAA :STD_LOGIC_VECTOR (19 downto 0);	--�A�h���X
	signal SRAMIOA : STD_LOGIC_VECTOR (31 downto 0);	--�f�[�^
	signal SRAMIOPA : STD_LOGIC_VECTOR (3 downto 0); --�p���e�B�[
		
	signal SRAMRWA : STD_LOGIC;	--read=>1,write=>0
	signal SRAMBWA : STD_LOGIC_VECTOR (3 downto 0);--�������݃o�C�g�̎w��

	signal SRAMCLKMA0 : STD_LOGIC;	--SRAM�N���b�N
	signal SRAMCLKMA1 : STD_LOGIC;	--SRAM�N���b�N
		
	signal SRAMADVLDA : STD_LOGIC;	--�o�[�X�g�A�N�Z�X
	signal SRAMCEA : STD_LOGIC; --clock enable
		
	signal SRAMCELA1X : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
	signal SRAMCEHA1X : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
	signal SRAMCEA2X : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
	signal SRAMCEA2 : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
		
	signal SRAMLBOA : STD_LOGIC;	--�o�[�X�g�A�N�Z�X��
	signal SRAMXOEA : STD_LOGIC;	--IO�o�̓C�l�[�u��
	signal SRAMZZA : STD_LOGIC;	--�X���[�v���[�h�ɓ���
	

	signal LEDOUT   : std_logic_vector(7 downto 0) := (others => '0');
	signal CLK : STD_LOGIC := '0';
begin
	process 
	begin
		CLK <= not CLK;
		wait for 20 ns;--25Mhz
	end process;
	
	CPU : cpu_top port map(
		CLK
		,LEDOUT
	
		--SRAM
		,SRAMAA
		,SRAMIOA
		,SRAMIOPA
		
		,SRAMRWA
		,SRAMBWA

		,SRAMCLKMA0
		,SRAMCLKMA1
		
		,SRAMADVLDA
		,SRAMCEA
		
		,SRAMCELA1X
		,SRAMCEHA1X
		,SRAMCEA2X
		,SRAMCEA2
		
		,SRAMLBOA
		,SRAMXOEA
		,SRAMZZA
	);


end arch;

