-- neg, abs �̓��b�`�Ȃ� (1 clock)
-- cmp �̓��b�` 1 �� (2 clock)
-- add, sub, mul �̓��b�` 2 �� (3 clock)
-- inv, sqrt �̓��b�` 3 �� (4 clock)

-- �����v�Z�����Ȃ��Ƃ��͕ς� op ����������

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--library work;
--use work.instruction.all;

entity FPU is

  port (
    clk  : in  std_logic;
    op   : in  std_logic_vector(3 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0));

end FPU;


architecture STRUCTURE of FPU is

  -- TODO �b�������Č���
  constant fpu_op_fadd :  std_logic_vector := "0000";
  constant fpu_op_fsub :  std_logic_vector := "0001";
  constant fpu_op_fmul :  std_logic_vector := "0010";
  constant fpu_op_finv :  std_logic_vector := "0011";
  constant fpu_op_fsqrt : std_logic_vector := "0100";
  constant fpu_op_fcmp :  std_logic_vector := "0101";
  constant fpu_op_fabs :  std_logic_vector := "0110";
  constant fpu_op_fneg :  std_logic_vector := "0111";
  -- constant fpu_op_halt :  std_logic_vector := "1111";  -- TODO

  
  component FP_ADD
    port (
      clk  : in  std_logic;
      A, B : in  std_logic_vector(31 downto 0);
      O    : out std_logic_vector(31 downto 0));
  end component;

  component FP_MUL
    port (
      clk  : in  std_logic;
      A, B : in  std_logic_vector(31 downto 0);
      O    : out std_logic_vector(31 downto 0));
  end component;
  
  component FP_INV
    port (
      clk  : in  std_logic;
      A : in  std_logic_vector(31 downto 0);
      O : out std_logic_vector(31 downto 0));
  end component;
  
  component FP_SQRT
    port (
      clk  : in  std_logic;
      A : in  std_logic_vector(31 downto 0);
      O : out std_logic_vector(31 downto 0));
  end component;
  
  component FP_CMP
    port (
      clk  : in  std_logic;
      A, B : in  std_logic_vector(31 downto 0);
      O : out std_logic_vector(31 downto 0));
  end component;

  component FP_NEG
    port (
      A : in  std_logic_vector(31 downto 0);
      O : out std_logic_vector(31 downto 0));
  end component;
  
  component FP_ABS
    port (
      A : in  std_logic_vector(31 downto 0);
      O : out std_logic_vector(31 downto 0));
  end component;

  
  signal O_ADD, O_MUL, O_INV, O_SQRT, O_CMP, O_ABS, O_NEG : std_logic_vector(31 downto 0);
  signal B_ADD, O1 : std_logic_vector(31 downto 0);

  -- op ��ۑ�
  subtype vec4 is std_logic_vector(3 downto 0);
  type queue_t is array (0 to 2) of vec4;
  signal op_queue : queue_t;

begin  -- STRUCTURE

  fp_add_inst  : FP_ADD  port map (clk => clk, O => O_ADD, A => A, B => B_ADD);
  fp_mul_inst  : FP_MUL  port map (clk => clk, O => O_MUL, A => A, B => B);
  fp_inv_inst  : FP_INV  port map (clk => clk, O => O_INV, A => A);
  fp_sqrt_inst : FP_SQRT port map (clk => clk, O => O_SQRT, A => A);
  fp_cmp_inst  : FP_CMP  port map (clk => clk, O => O_CMP, A => A, B => B);
  fp_abs_inst  : FP_ABS  port map (O => O_ABS, A => A);
  fp_neg_inst  : FP_NEG  port map (O => O_NEG, A => A);

  -- B �̕����𔽓]����ꍇ������
  B_ADD(30 downto 0) <= B(30 downto 0);
  B_ADD(31) <= B(31) when op = fpu_op_fadd else       -- add
           (not B(31));  -- sub -> negate


  -- O �ɒ�������K�v��������̂�����
  with op select O <=
    O_ABS when fpu_op_fabs,             -- ����
    O_NEG when fpu_op_fneg,             -- ����
    O1 when others;                     -- �L���[����o�Ă���

  -- �}���`�T�C�N���̂��́A�����łĂ��邩�ȁ[�I�H
  with op_queue(0) select O1 <= 
    O_ADD when fpu_op_fadd,
    O_ADD when fpu_op_fsub,
    O_MUL when fpu_op_fmul,
    O_INV when fpu_op_finv,
    O_SQRT when fpu_op_fsqrt,
    O_CMP when fpu_op_fcmp,
    "11111111111111111111111111111111" when others;  -- BAD OP
  

  -- op ���o���Ȃ���
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      if op = fpu_op_fcmp then
        -- 2 clock (1 ���b�`������j�̉��Z
        op_queue(0) <= op;
        op_queue(1) <= op_queue(2);
        -- op_queue(2) <= op_queue(3);
      elsif op = fpu_op_fadd or op = fpu_op_fsub or op = fpu_op_fmul then
        -- 3 clock (2 ���b�`������) �̉��Z
        op_queue(0) <= op_queue(1);
        op_queue(1) <= op;
        -- op_queue(2) <= op_queue(3);
      elsif op = fpu_op_finv or op = fpu_op_fsqrt then
        -- 4 clock (3 ���b�`������) �̉��Z
        op_queue(0) <= op_queue(1);
        op_queue(1) <= op_queue(2);
        op_queue(2) <= op;
      else
        -- ���Z�������Ă��Ȃ�����
        op_queue(0) <= op_queue(1);
        op_queue(1) <= op_queue(2);
      end if;
    end if;
  end process;
  
end STRUCTURE;
