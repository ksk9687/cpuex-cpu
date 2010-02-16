library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity dff is
    Port (CLK,RST : in  STD_LOGIC;
          D : in  STD_LOGIC;
          Q : out  STD_LOGIC);
end dff;

architecture Behavioral of dff is
	signal W :std_logic := '0';
begin
	Q <= W;
	
  process(CLK,RST)
  begin
  	if RST = '1' then
  		W <= '0';
    elsif rising_edge(CLK) then
		W <= D;
    end if;
  end process;
  

end Behavioral;



