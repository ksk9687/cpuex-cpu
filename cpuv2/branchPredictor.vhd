--����\����

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity branchPredictor is
	port  (
		clk,rst :in std_logic;
		pc : in std_logic_vector(19 downto 0);
		im : in std_logic_vector(13 downto 0);
		taken : out std_logic
	);
end branchPredictor;

architecture arch of branchPredictor is

begin

	--!TODO ����\���̃��W�b�N�����B
	--���݂͏�ɕ��򂵂Ȃ��Ɨ\��
	taken <= '0';

end arch;

