--分岐予測器

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

	--!TODO 分岐予測のロジックを作る。
	--現在は常に分岐しないと予測
	taken <= '0';

end arch;

