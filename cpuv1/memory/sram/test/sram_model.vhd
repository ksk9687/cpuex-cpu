--SRAM�̃V�~�����[�V�������f��

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sram_model is
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
end sram_model;

architecture Behavioral of sram_model is
	type data_ram_type is array (0 to 1023) of std_logic_vector (7 downto 0); 
	type p_ram_type is array (0 to 1023) of std_logic; 
	
	--�P�ڂ�SRAM�p
	--����8bit+1bit
	signal RAM00 : data_ram_type :=  (others => "00000000");
	signal RAMP00 : p_ram_type :=  (others => '0');
	--���8bit+1bit
	signal RAM01 : data_ram_type :=  (others => "00000000");
	signal RAMP01 : p_ram_type :=  (others => '0');
	--�o�b�t�@����
	signal ad_buf00 : std_logic_vector(19 downto 0);
	signal ad_buf01 : std_logic_vector(19 downto 0);
	signal rw_buf00 : std_logic;
	signal rw_buf01 : std_logic;
	signal bw_buf00 : std_logic_vector(1 downto 0);
	signal bw_buf01 : std_logic_vector(1 downto 0);
	signal data_buf00 : std_logic_vector(17 downto 0);
	signal data_buf01 : std_logic_vector(17 downto 0);
	
	
	--��ڂ�SRAM�p
	signal RAM10 : data_ram_type :=  (others => "00000000");
	signal RAMP10 : p_ram_type :=  (others => '0');
	signal RAM11 : data_ram_type :=  (others => "00000000");
	signal RAMP11 : p_ram_type :=  (others => '0');
	signal ad_buf10 : std_logic_vector(19 downto 0);
	signal ad_buf11 : std_logic_vector(19 downto 0);
	signal rw_buf10 : std_logic;
	signal rw_buf11 : std_logic;
	signal bw_buf10 : std_logic_vector(1 downto 0);
	signal bw_buf11 : std_logic_vector(1 downto 0);
	signal data_buf10 : std_logic_vector(17 downto 0);
	signal data_buf11 : std_logic_vector(17 downto 0);
begin
	
--			--���ʏo��
--			SRAMIOA(15 downto 0) <= data_buf01(15 downto 0) when rw_buf01 = '1' else
--			(others => 'Z');
--			SRAMIOPA(1 downto 0) <= data_buf01(17 downto 16) when rw_buf01 = '1' else
--			(others => 'Z');
--		
--			--��ʏo��
--			SRAMIOA(31 downto 16) <=  data_buf11(15 downto 0) when rw_buf11 = '1' else 
--			(others => 'Z') ;
--			SRAMIOPA(3 downto 2) <=  data_buf11(17 downto 16) when rw_buf11 = '1' else
--			(others => 'Z') ;



	process (SRAMCLKMA0) begin
		if falling_edge(SRAMCLKMA0) then
			--���ʏo��
			if rw_buf01 = '1' then
				SRAMIOA(15 downto 0) <= data_buf01(15 downto 0);
			else
				SRAMIOA(15 downto 0) <=(others => 'Z');
			end if;
			
			if rw_buf01 = '1' then
				SRAMIOPA(1 downto 0) <= data_buf01(17 downto 16);
			else
				SRAMIOPA(1 downto 0) <=(others => 'Z');
			end if;
			
		
			--��ʏo��

			if rw_buf11 = '1' then
				SRAMIOA(31 downto 16) <= data_buf11(15 downto 0);
			else
				SRAMIOA(31 downto 16) <=(others => 'Z');
			end if;
			
			if rw_buf11 = '1' then
				SRAMIOPA(3 downto 2) <= data_buf11(17 downto 16);
			else
				SRAMIOPA(3 downto 2) <= (others => 'Z');
			end if;
		end if;
	
	end process;
	
	
	--�ЂƂڂ�SRAM�@����16bit��S��
	process (SRAMCLKMA0) begin
		if SRAMCLKMA0'event and SRAMCLKMA0='1' then
			ad_buf00 <= SRAMAA;
			ad_buf01 <= ad_buf00;
			
			rw_buf00 <= SRAMRWA;
			rw_buf01 <= rw_buf00;
			
			bw_buf00 <= SRAMBWA(1 downto 0);
			bw_buf01 <= bw_buf00;
			
			--Read
			data_buf00(7 downto 0) <= RAM00(conv_integer(SRAMAA(9 downto 0)));
			data_buf00(15 downto 8) <= RAM01(conv_integer(SRAMAA(9 downto 0)));
			data_buf00(16) <= RAMP00(conv_integer(SRAMAA(9 downto 0)));
			data_buf00(17) <= RAMP01(conv_integer(SRAMAA(9 downto 0)));
			data_buf01 <= data_buf00;
			
			--Write
			--����8bit
			if rw_buf01 = '0' and bw_buf01(0) = '0' then
				RAM00(conv_integer(ad_buf01(9 downto 0))) <= SRAMIOA(7 downto 0);
				RAMP00(conv_integer(ad_buf01(9 downto 0))) <= SRAMIOPA(0);
			end if;
			--���8bit
			if rw_buf01 = '0' and bw_buf01(1) = '0' then
				RAM01(conv_integer(ad_buf01(9 downto 0))) <= SRAMIOA(15 downto 8);
				RAMP01(conv_integer(ad_buf01(9 downto 0))) <= SRAMIOPA(1);
			end if;
		end if;
	end process;
	
	
	--��ڂ�SRAM�@���16bit��S��
	process (SRAMCLKMA1) begin
		if SRAMCLKMA1'event and SRAMCLKMA1='1' then
			ad_buf10 <= SRAMAA;
			ad_buf11 <= ad_buf10;
			
			rw_buf10 <= SRAMRWA;
			rw_buf11 <= rw_buf10;
			
			bw_buf10 <= SRAMBWA(1 downto 0);
			bw_buf11 <= bw_buf10;
			
			data_buf10(7 downto 0) <= RAM10(conv_integer(SRAMAA(9 downto 0)));
			data_buf10(15 downto 8) <= RAM11(conv_integer(SRAMAA(9 downto 0)));
			data_buf10(16) <= RAMP10(conv_integer(SRAMAA(9 downto 0)));
			data_buf10(17) <= RAMP11(conv_integer(SRAMAA(9 downto 0)));
			data_buf11 <= data_buf10;
			
			if rw_buf11 = '0' and bw_buf11(0) = '0' then
				RAM10(conv_integer(ad_buf11(9 downto 0))) <= SRAMIOA(23 downto 16);
				RAMP10(conv_integer(ad_buf11(9 downto 0))) <= SRAMIOPA(2);
			end if;
			
			if rw_buf11 = '0' and bw_buf11(1) = '0' then
				RAM11(conv_integer(ad_buf11(9 downto 0))) <= SRAMIOA(31 downto 24);
				RAMP11(conv_integer(ad_buf11(9 downto 0))) <= SRAMIOPA(3);
			end if;
		end if;
	end process;
	
end Behavioral;

