--SRAM�̃R���g���[��

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity sram_controller is
    Port (
		CLK : in STD_LOGIC
		;SRAMCLK : in STD_LOGIC
		
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
end sram_controller;

architecture Behavioral of sram_controller is

  signal data_buf0 : std_logic_vector(31 downto 0);
  signal data_buf1 : std_logic_vector(31 downto 0);
  signal rw_buf0 :  std_logic := '0';
  signal rw_buf1 :  std_logic := '0';
  
  signal data_out : std_logic_vector(31 downto 0);
  
  --xor�v�Z�@�p���e�B�p
  function br_xor(a: std_logic_vector) return std_logic is
    variable tmp:std_logic := '0';
  begin
    for i in a'range loop
      tmp := tmp xor a(i);
    end loop;
    return (tmp);
  end br_xor;
begin
  
	--�Œ肷��M������
  SRAMLBOA   <= '1';
  SRAMXOEA   <= '0';
  SRAMADVLDA <= '0';
  SRAMZZA    <= '0';
  SRAMCEA    <= '0';
  SRAMCLKMA0 <= sramclk;
  SRAMCLKMA1 <= sramclk;
  SRAMCEHA1X <= '0';
  SRAMCELA1X <= '0';
  SRAMCEA2   <= '1';
  SRAMCEA2X  <= '0';
  SRAMBWA    <= "0000";

  process (clk)
  begin
    if clk'event and clk = '1' then
      if rw_buf1 = '0' then
        --Write
		--2clock��Ƀf�[�^��n��
        SRAMIOA  <= data_buf1;
        SRAMIOPA <=br_xor(data_buf1(31 downto 24))&
		br_xor(data_buf1(23 downto 16))&
		br_xor(data_buf1(15 downto 8))&
		br_xor(data_buf1(7 downto 0));
      else
        -- Read
        SRAMIOA  <= (others => 'Z');
        SRAMIOPA <= (others => 'Z');
      end if;

      SRAMAA  <= ADDR;
      SRAMRWA <= RW;

	  --�o�b�t�@
      rw_buf0    <= RW;
      rw_buf1    <= rw_buf0;
	  
      data_buf0    <= DATAIN;
      data_buf1    <= data_buf0;
	  
	   DATAOUT <= data_out;
    end if;
  end process;
  
  --sram�ɗ^����N���b�N�ɍ��킹��sram�̏o�͂�ۑ�
  process (sramclk)
  begin
    if sramclk'event and sramclk = '1' then
		data_out <= SRAMIOA;
	end if;
  end process;

end Behavioral;

