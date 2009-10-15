library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dff is
    Port ( D : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           Q : out  STD_LOGIC);
end dff;

architecture Behavioral of dff is
signal W :std_logic := '0';
begin
  process(CLK)
  begin
    if CLK'event and CLK = '1' then
      W <= D;
    end if;
  end process;
  Q <= W;

end Behavioral;

