library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FP_CMP is
  
  port (
    clk : in std_logic;
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(2 downto 0));

end FP_CMP;


architecture STRUCTURE of FP_CMP is
  
  signal tmpA1, tmpB1, tmpA2, tmpB2 : std_logic_vector(5 downto 0);
  signal AS, BS : std_logic;
  signal ZERO : std_logic;
  
  signal abslt, abseq, absgt : std_logic;

begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------
  
  tmpA1(5) <= '1' when A(30 downto 25) > B(30 downto 25) else '0';
  tmpA1(4) <= '1' when A(24 downto 20) > B(24 downto 20) else '0';
  tmpA1(3) <= '1' when A(19 downto 15) > B(19 downto 15) else '0';
  tmpA1(2) <= '1' when A(14 downto 10) > B(14 downto 10) else '0';
  tmpA1(1) <= '1' when A( 9 downto  5) > B( 9 downto  5) else '0';
  tmpA1(0) <= '1' when A( 4 downto  0) > B( 4 downto  0) else '0';
  
  tmpB1(5) <= '1' when B(30 downto 25) > A(30 downto 25) else '0';
  tmpB1(4) <= '1' when B(24 downto 20) > A(24 downto 20) else '0';
  tmpB1(3) <= '1' when B(19 downto 15) > A(19 downto 15) else '0';
  tmpB1(2) <= '1' when B(14 downto 10) > A(14 downto 10) else '0';
  tmpB1(1) <= '1' when B( 9 downto  5) > A( 9 downto  5) else '0';
  tmpB1(0) <= '1' when B( 4 downto  0) > A( 4 downto  0) else '0';
  

  process (clk)
  begin  -- process
    if rising_edge(clk) then
      tmpA2 <= tmpA1;
      tmpB2 <= tmpB1;

      AS <= A(31);
      BS <= B(31);
      if A(30 downto 23) = "00000000" and B(30 downto 23) = "00000000" then
      	ZERO <= '1';
      else
      	ZERO <= '0';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 2nd stage
  -----------------------------------------------------------------------------
  
  abslt <= '1' when tmpA2 < tmpB2 else '0';
  abseq <= '1' when tmpA2 = tmpB2 else '0';
  absgt <= '1' when tmpA2 > tmpB2 else '0';

  O <= "010"  when ZERO = '1' else
       "100"  when AS = '0' and BS = '1' else
       "001"  when AS = '1' and BS = '0' else
       absgt & abseq & abslt when AS = '0' and BS = '0' else
       abslt & abseq & absgt;

end STRUCTURE;
