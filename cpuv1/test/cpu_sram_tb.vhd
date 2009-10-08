--CPU�̃e�X�g���x���`


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sram_test is
end sram_test;

architecture Behavioral of sram_test is
	signal CLK : STD_LOGIC := '0';
	
	component sram_model is
    Port (
		SRAMAA : in  STD_LOGIC_VECTOR (19 downto 0)	--�A�h���X
		;SRAMIOA : inout  STD_LOGIC_VECTOR (31 downto 0)	--�f�[�^
		;SRAMIOPA : inout  STD_LOGIC_VECTOR (3 downto 0) --�p���e�B�[
		
		;SRAMRWA : in  STD_LOGIC	--read=>1,write=>0
		;SRAMBWA : in  STD_LOGIC_VECTOR (3 downto 0)--�������݃o�C�g�̎w��

		;SRAMCLKMA0 : in  STD_LOGIC	--SRAM�N���b�N
		;SRAMCLKMA1 : in  STD_LOGIC	--SRAM�N���b�N
		
		;SRAMADVLDA : in  STD_LOGIC	--�o�[�X�g�A�N�Z�X
		;SRAMCEA : in  STD_LOGIC --clock enable
		
		;SRAMCELA1X : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEHA1X : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEA2X : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEA2 : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���

		;SRAMLBOA : in  STD_LOGIC	--�o�[�X�g�A�N�Z�X��
		;SRAMXOEA : in  STD_LOGIC	--IO�o�̓C�l�[�u��
		;SRAMZZA : in  STD_LOGIC	--�X���[�v���[�h�ɓ���
	);
	end component;
	
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
begin
	
	process 
	begin
		CLK <= not CLK;
		wait for 10 ns;
	end process;

	SRAMTOP : sram_top port map(
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

	SRAM : sram_model  port map(
		SRAMAA
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


end Behavioral;



