-- neg, abs はラッチなし (1 clock)
-- cmp はラッチ 1 つ (2 clock)
-- add, sub, mul はラッチ 2 つ (3 clock)
-- inv, sqrt はラッチ 3 つ (4 clock)

-- 何も計算させないときは変な op をください

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--library work;
--use work.instruction.all;

entity FPU is

  port (
    clk,flush,write  : in  std_logic;
    op   : in  std_logic_vector(4 downto 0);
    tag   : in  std_logic_vector(3 downto 0);
    A, B : in  std_logic_vector(31 downto 0);
    O    : out std_logic_vector(31 downto 0);
    Otag    : out std_logic_vector(4 downto 0);
    
    go,writeok    : out std_logic
    );

end FPU;


architecture STRUCTURE of FPU is

  -- TODO 話し合って決定
  constant fpu_op_fadd :  std_logic_vector := "000";
  constant fpu_op_fsub :  std_logic_vector := "001";
  constant fpu_op_fmul :  std_logic_vector := "010";
  constant fpu_op_finv :  std_logic_vector := "011";
  constant fpu_op_fsqrt : std_logic_vector := "100";
  constant fpu_op_fmov : std_logic_vector  := "101";

  
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
  

  
  signal O_ADD, O_MUL, O_INV, O_SQRT : std_logic_vector(31 downto 0);
  signal B_ADD, O_u , O_i , O1 : std_logic_vector(31 downto 0);
  
  signal tag1 : std_logic_vector(3 downto 0);

  -- op を保存
  subtype vec4 is std_logic_vector(9 downto 0);
  type queue_t is array (0 to 2) of vec4;
  signal op_queue : queue_t := (others => (others => '0'));
  signal op_queue_write : queue_t := (others => (others => '0'));

  signal write1,write3,write4 : std_logic := '0';
begin  -- STRUCTURE
	
	tag1 <= op_queue(0)(8 downto 5) when op_queue(0)(9) = '1' else tag;
	
	O1(30 downto 0) <= O_u when op_queue(0)(9) = '1' else A(30 downto 0);
	O1(31) <= (op_queue(0)(1) or O_u(31)) xor op_queue(0)(0) when op_queue(0)(9) = '1' else
	(op(1) or  A(31)) xor op(0);
	
	with op_queue(0)(4 downto 2) select
	 O_u <= O_ADD when "000"|"001",
	 O_MUL when "010",
	 O_INV when "011",
	 O_SQRT when others;
	 
	 write1 <= write when op(4 downto 2) = "101" else '0';
	 
	 with op(4 downto 2) select
	  write3 <= write when "000" | "001" | "010",
	  '0' when others;
	  
	 with op(4 downto 2) select
	  write4 <= write when "011" | "100",
	  '0' when others;
	  
	  with op(4 downto 2) select
	  writeok <= (not op_queue(0)(9)) when "101",
	  (not op_queue(2)(9)) when "000" | "001" | "010",
	  '1' when "011","100",
	  '0' when others;
	   
	op_queue_write(0) <= op_queue(1);
	op_queue_write(1) <= op_queue(2) when op_queue(2)(9) = '1' else write3&tag&op;
	op_queue_write(2) <= write4&tag&op;

	process(clk)
	begin
		if rising_edge(clk) then
			O <= O1;
			tag <= tag1;
			if flush = '1' then
				go <= '0';
				op_queue(0)(9) <= '0';
				op_queue(1)(9) <= '0';
				op_queue(2)(9) <= '0';
				op_queue(3)(9) <= '0';
			else
				go <= op_queue(0)(9) or write1;
				op_queue(0) <= op_queue_write(0);
				op_queue(1) <= op_queue_write(1);
				op_queue(2) <= op_queue_write(2);
			end if;
		end if;
	end process;
	

  fp_add_inst  : FP_ADD  port map (clk => clk, O => O_ADD, A => A, B => B_ADD);
  fp_mul_inst  : FP_MUL  port map (clk => clk, O => O_MUL, A => A, B => B);
  fp_inv_inst  : FP_INV  port map (clk => clk, O => O_INV, A => A);
  fp_sqrt_inst : FP_SQRT port map (clk => clk, O => O_SQRT, A => A);

  -- B の符号を反転する場合がある
  B_ADD(30 downto 0) <= B(30 downto 0);
  B_ADD(31) <= B(31) when op = fpu_op_fadd else       -- add
           (not B(31));  -- sub -> negate


  

  
end STRUCTURE;
