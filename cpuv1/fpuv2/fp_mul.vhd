-- ���b�`�F�O�ƌ��� 2 ��

-- ���K��������� 0.0 �ɑΉ�������Z��
-- �ۂ߂͂΂�����؂�̂�

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FP_MUL is
  
  port (
    clk : in std_logic;
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));

end FP_MUL;


architecture STRUCTURE of FP_MUL is

  signal AS, BS : std_logic;
  signal AE, BE : std_logic_vector(7 downto 0);
  signal AM, BM : std_logic_vector(23 downto 0);
  
  signal OM1 : std_logic_vector(47 downto 0);
  signal OM2 : std_logic_vector(22 downto 0);
  signal OE1, OE2 : std_logic_vector(7 downto 0);
  signal OS : std_logic;
  signal O1, O2 : std_logic_vector(31 downto 0);

  signal Adff1, Bdff1, Odff2 : std_logic_vector(31 downto 0);

begin  -- STRUCTURE

  -----------------------------------------------------------------------------
  -- 1st stage
  -----------------------------------------------------------------------------
  -- Adff1 <= A, Bdff1 <= B

  -- 1 �ȏ� 0.0 �̏ꍇ�� 0.0
  O1 <= O2 when (Adff1(30 downto 0) /= 0 and Bdff1(30 downto 0) /= 0)
        else "00000000000000000000000000000000";
  
  -- ����
  AS <= Adff1(31);
  BS <= Bdff1(31);
  AE <= Adff1(30 downto 23); 
  BE <= Bdff1(30 downto 23); 
  AM <= '1' & Adff1(22 downto 0);
  BM <= '1' & Bdff1(22 downto 0);

  -- �������̐ς��v�Z
  OM1 <= AM * BM;

  -- �������͊e�X [1.0, 2.0) ���ς� [1.0, 4.0)
  OM2 <= OM1(46 downto 24) when OM1(47) = '1' else
         OM1(45 downto 23);

  -- �w�����i�I�[�o�[�t���[�E�A���_�[�t���[�͖����j
  OE1 <= AE + BE - 127;
  OE2 <= OE1 + 1 when OM1(47) = '1' else
         OE1;

  -- ����
  OS <= AS xor BS;

  -- ����
  O2 <= OS & OE2 & OM2;

  
  -----------------------------------------------------------------------------
  -- 2nd stage
  -----------------------------------------------------------------------------
  -- Odff2 <= O1

  O <= Odff2;


  -----------------------------------------------------------------------------
  -- process
  -----------------------------------------------------------------------------

  process(clk)
  begin
    if rising_edge(clk) then
      Adff1 <= A;
      Bdff1 <= B;
      
      Odff2 <= O1;
    end if;
  end process;
  
end STRUCTURE;
