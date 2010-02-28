#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include "common.hpp"


/*******************************************************************************
 * 演算を行う関数たち
 ******************************************************************************/

extern bool fadd(float, float, float&);
extern bool fmul(float, float, float&);
extern bool finv(float, float&);
extern bool fsqrt(float, float&);
bool fsub(float a, float b, float &o) { return fadd(a, -b, o); }
bool fabs(float a, float &o) { o =  a < 0 ? -a : a; return true; }
bool fneg(float a, float &o) { o = -a; return true; }

float b2f(bit32 a) { myfloat t; t.b = a; return t.f; }
bit32 f2b(float a) { myfloat t; t.f = a; return t.b; }

#define GENERATE2(f)                                    \
  bool f ## _bit(bit32 a, bit32 b, bit32 &o) {          \
    float t;                                            \
    bool r = f(b2f(a), b2f(b), t);                      \
    o = f2b(t);                                         \
    return r;                                           \
  }

#define GENERATE1(f)                    \
  bool (f ## _bit)(bit32 a, bit32 &o) { \
    float t;                            \
    bool r = f(b2f(a), t);              \
    o = f2b(t);                         \
    return r;                           \
  }

GENERATE2(fadd);
GENERATE2(fsub);
GENERATE2(fmul);
GENERATE1(finv);
GENERATE1(fsqrt);
GENERATE1(fabs);
GENERATE1(fneg);

bool fcmp_bit(bit32 a, bit32 b, bit32 &o) {
  float x = b2f(a), y = b2f(b);
  o = 0;
  o |= (x <  y ? 1 : 0) << 0;
  o |= (x == y ? 1 : 0) << 1;
  o |= (x >  y ? 1 : 0) << 2;
  return true;
}



/*******************************************************************************
 * 構造体にまとめる
 ******************************************************************************/

typedef uint32_t bit32;
typedef bool (*func1_t)(bit32, bit32&);
typedef bool (*func2_t)(bit32, bit32, bit32&);

struct op_t {
  int code;
  int argn;
  union {
    func1_t func1;
    func2_t func2;
  };
  int delay;
} ops[] = {
  {0, 2, {(func1_t)fadd_bit}, 3},
  {1, 2, {(func1_t)fsub_bit}, 3},
  {2, 2, {(func1_t)fmul_bit}, 3},
  {3, 1, {(func1_t)finv_bit}, 4}, // hazusitemo NG
  {4, 1, {(func1_t)fsqrt_bit}, 4}, // hazusitemo NG
  {5, 2, {(func1_t)fcmp_bit}, 2},
  {6, 1, {(func1_t)fabs_bit}, 1}, // OK
  {7, 1, {(func1_t)fneg_bit}, 1}, // OK
};
int ops_n = sizeof(ops) / sizeof(ops[0]);


char *op_name[] = {
  "fadd",
  "fsub",
  "fmul",
  "finv",
  "fsqrt",
  "fcmp",
  "fabs",
  "fneg",
};


/*******************************************************************************
 * テストを生成
 ******************************************************************************/

int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s T\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  int T = atoi(argv[1]);

  bit32 *A = (bit32*)malloc(sizeof(bit32) * T);
  bit32 *B = (bit32*)malloc(sizeof(bit32) * T);
  bit32 *O = (bit32*)malloc(sizeof(bit32) * T);
  bit32 *op = (bit32*)malloc(sizeof(bit32) * T);
  bool *chk = (bool*)malloc(sizeof(bool) * T);

  if (!(A && B && O && op && chk)) {
    fprintf(stderr, "error: malloc\n");
    exit(EXIT_FAILURE);
  }

  memset(A, 0, sizeof(bit32) * T);
  memset(B, 0, sizeof(bit32) * T);
  memset(O, 0, sizeof(bit32) * T);
  memset(op, 0, sizeof(bit32) * T);
  memset(chk, 0, sizeof(bool) * T);

  srand((unsigned)time(NULL));
  for (int t = 0; t < T; t++) {
    int i = (rand() >> 8) % ops_n;
    int tt = t + ops[i].delay;
    if (tt >= T || chk[tt]) {
      op[t] = 8; // HALT
      continue;
    }
    // fprintf(stderr, "%d->%d: %d\n", t, tt, ops[i].code);

    op[t] = ops[i].code;
    chk[tt] = true;

    fprintf(stderr, "%02x: %s\n", tt + 1, op_name[op[t]]);

    if (ops[i].argn == 1) {
      do {
        A[t] = f2b(make_random_float());
      } while (!ops[i].func1(A[t], O[tt]));
    }
    else {
      do {
        A[t] = f2b(make_random_float());
        B[t] = f2b(make_random_float());
      } while (!ops[i].func2(A[t], B[t], O[tt]));
    }
  }


  printf("  constant n : integer := %d;\n", T);
  printf("  subtype vec4_t is std_logic_vector(3 downto 0);\n");
  printf("  subtype vec32_t is std_logic_vector(31 downto 0);\n");
  printf("  type table4_t is array(0 to n - 1) of vec4_t;\n");
  printf("  type table32_t is array(0 to n - 1) of vec32_t;\n");
  puts("");

  puts("  constant table_op : table4_t := (");
  for (int t = 0; t < T; t++) {
    printf("    \"");
    printf("%lu", (op[t] >> 3) & 1);
    printf("%lu", (op[t] >> 2) & 1);
    printf("%lu", (op[t] >> 1) & 1);
    printf("%lu", (op[t] >> 0) & 1);
    if (t + 1 < T) puts("\",");
    else puts("\");");
  }
  puts("");

  puts("  constant table_a : table32_t := (");
  for (int t = 0; t < T; t++) {
    printf("    \"");
    print_bits((char*)&A[t], 4);
    if (t + 1 < T) puts("\",");
    else puts("\");");    
  }
  puts("");

  puts("  constant table_b : table32_t := (");
  for (int t = 0; t < T; t++) {
    printf("    \"");
    print_bits((char*)&B[t], 4);
    if (t + 1 < T) puts("\",");
    else puts("\");");    
  }
  puts("");

  puts("  constant table_o : table32_t := (");
  for (int t = 0; t < T; t++) {
    printf("    \"");
    print_bits((char*)&O[t], 4);
    if (t + 1 < T) puts("\",");
    else puts("\");");    
  }
  puts("");

  puts("  constant table_chk : std_logic_vector(0 to n - 1) :=");
  printf("    \"");
  for (int t = 0; t < T; t++) {
    printf("%d", (int)chk[t]);
  }
  puts("\";");
  
//   print_table("table_a", A, N);
//   puts("");
//   print_table("table_b", B, N);
//   puts("");
//   print_table("table_o", O, N);
  
  exit(EXIT_SUCCESS);
}
