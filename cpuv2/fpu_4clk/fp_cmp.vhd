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
  signal ZERO,tmpZERO : std_logic;
  
  signal abslt, abseq, absgt : std_logic;

begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------
  
  tmpA1(3) <= '1' when ((not B(31))&B(30 downto 23)) < ((not A(31))&A(30 downto 23)) else '0';
  tmpA1(2) <= '1' when B(23 downto 16) < A(23 downto 16) else '0';
  tmpA1(1) <= '1' when B(15 downto  8) < A(15 downto  8) else '0';
  tmpA1(0) <= '1' when B( 7 downto  0) < A( 7 downto  0) else '0';
  
  tmpB1(3) <= '1' when ((not B(31))&B(30 downto 23)) > ((not A(31))&A(30 downto 23)) else '0';
  tmpB1(2) <= '1' when B(23 downto 16) > A(23 downto 16) else '0';
  tmpB1(1) <= '1' when B(15 downto  8) > A(15 downto  8) else '0';
  tmpB1(0) <= '1' when B( 7 downto  0) > A( 7 downto  0) else '0';
  
  tmpZERO <=  '1' when (A(30 downto 23) = "00000000") and (B(30 downto 23) = "00000000") else '0';

  process (clk)
  begin  -- process
    if rising_edge(clk) then
    if (A(31) = '0') and (B(31) = '0') then
      tmpA2 <= tmpA1;
      tmpB2 <= tmpB1;
     else
      tmpA2 <= tmpB1;
      tmpB2 <= tmpA1;
     end if;
      ZERO <= tmpZERO;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- 2nd stage
  -----------------------------------------------------------------------------
  
  abslt <= '1' when tmpA2 < tmpB2 else '0';--<
  abseq <= '1' when tmpA2 = tmpB2 else '0';--=
  absgt <= '1' when tmpA2 > tmpB2 else '0';-->

  O <= "010"  when ZERO = '1' else
       absgt & abseq & abslt;

end STRUCTURE;
