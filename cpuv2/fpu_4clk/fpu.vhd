-- cmp はラッチ 1 つ (2 clock)
-- add, sub, mul, inv, sqrt はラッチ 3 つ (4 clock)

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
    O    : out std_logic_vector(31 downto 0);
    cmp  : out std_logic_vector(2 downto 0));

end FPU;


architecture STRUCTURE of FPU is

  constant fpu_op_fadd :  std_logic_vector := "0000";
  constant fpu_op_fsub :  std_logic_vector := "0001";
  constant fpu_op_fmul :  std_logic_vector := "0010";
  constant fpu_op_finv :  std_logic_vector := "0011";
  constant fpu_op_fsqrt : std_logic_vector := "0100";
  constant fpu_op_fcmp :  std_logic_vector := "0101";

  
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
      O : out std_logic_vector(2 downto 0));
  end component;
  
  signal O_ADD, O_MUL, O_INV, O_SQRT : std_logic_vector(31 downto 0);
  signal O_CMP : std_logic_vector(2 downto 0);
  signal B_ADD : std_logic_vector(31 downto 0);

  -- op を保存
  subtype vec4 is std_logic_vector(3 downto 0);
  type queue_t is array (0 to 2) of vec4;
  signal op_queue : queue_t;

begin  -- STRUCTURE

  fp_add_inst  : FP_ADD  port map (clk => clk, O => O_ADD, A => A, B => B_ADD);
  fp_mul_inst  : FP_MUL  port map (clk => clk, O => O_MUL, A => A, B => B);
  fp_inv_inst  : FP_INV  port map (clk => clk, O => O_INV, A => A);
  fp_sqrt_inst : FP_SQRT port map (clk => clk, O => O_SQRT, A => A);
  fp_cmp_inst  : FP_CMP  port map (clk => clk, O => O_CMP, A => A, B => B);

  -- B の符号を反転する場合がある
  B_ADD <= B when op = fpu_op_fadd else   -- add
           (not B(31)) & B(30 downto 0);  -- sub -> negate

  -- cmp 専用出力
  cmp <= O_CMP;

  -- マルチサイクルのもの、何がでてくるかなー！？
  with op_queue(0) select O <= 
    O_ADD when fpu_op_fadd,
    O_ADD when fpu_op_fsub,
    O_MUL when fpu_op_fmul,
    O_INV when fpu_op_finv,
    O_SQRT when fpu_op_fsqrt,
    "11111111111111111111111111111111" when others;

  -- op を覚えなきゃ
  process (clk)
  begin  -- process
    if rising_edge(clk) then
      -- 全ての演算回路の中に常に 3 個ラッチがある
      op_queue(0) <= op_queue(1);
      op_queue(1) <= op_queue(2);
      op_queue(2) <= op;
    end if;
  end process;
  
end STRUCTURE;
