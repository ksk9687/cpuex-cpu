--��

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sram_sim is
end sram_sim;

architecture Behavioral of sram_sim is
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
	
	component sram_controller is
    Port (
		CLK : in STD_LOGIC
		
		;ADDR    : in  std_logic_vector(19 downto 0)
		;DATAIN  : in  std_logic_vector(31 downto 0)
		;DATAOUT : out std_logic_vector(31 downto 0)
		;RW      : in  std_logic
		
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
	
	signal ADDR    : std_logic_vector(19 downto 0) := (others => '0');
	signal DATAIN  : std_logic_vector(31 downto 0):= (others => '0');
	signal DATAOUT : std_logic_vector(31 downto 0):= (others => '0');
	signal RW      : std_logic := '0';--�������݂���
		
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
	
	
	signal f : STD_LOGIC := '1';
begin

	--�m�F�pCLK��0�̂Ƃ���f��1�Ȃ琳�����B
	f <= '1' when DATAOUT = "101010101010"&(ADDR(9 downto 0) - "10")&(ADDR(9 downto 0) - "10")  else
	'0';

	process 
	begin
		CLK <= not CLK;
		--CLK��������Ƃ��Ɏ��̃A�h���X��e�X�g�f�[�^�̏���������
		if (CLK = '1') then
			--�ꏄ������ǂݍ��݊J�n
			if ADDR(9 downto 0) = "1111111111" then
				ADDR <= "0000000000"&"0000000000";
				if RW = '1' then
					wait;
				end if;
				RW <= not RW;
			else
					ADDR <= ADDR + 1;
			end if;
			
			if RW = '0' then
				--�������ރf�[�^
				DATAIN <= "101010101010"&ADDR(9 downto 0)&ADDR(9 downto 0);
			else
				DATAIN <= (others => '0');
			end if;
				
		end if;
		wait for 10 ns;
	end process;

	SRAMC : sram_controller port map(
		CLK
		
		,ADDR
		,DATAIN
		,DATAOUT
		,RW
	
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

