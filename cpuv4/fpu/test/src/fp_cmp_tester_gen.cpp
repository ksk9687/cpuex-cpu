#include <algorithm>
#include <cstdio>
#include <cstdlib>
using namespace std;

#include "common.hpp"

extern bool fmul(float, float, float&);

const int MAX_N = 100000;



// テストケースを作る
// TODO 指数部の大きさが近い数字同士をいっぱい
static void make_table(int n, float *a, float *b, uint *o) {
  int j = 0;
  
  // 0.0 * 0.0
  a[j] = b[j] = 0.0;
  j++;

  // A vs A
  rep (i, n / 4) {
    a[j] = make_random_float();
    b[j] = a[j];
    j++;
  }

  // A vs -A
  rep (i, n / 4) {
    a[j] = make_random_float();
    b[j] = -a[j];
    j++;
  }

  // A vs B
  while (j < n) {
    a[j] = make_random_float();
    b[j] = make_random_float();
    j++;
  }

  // check
  rep (i, n) {
    o[i] = 0;
    o[i] |= (a[i] <  b[i] ? 1 : 0) << 0;
    o[i] |= (a[i] == b[i] ? 1 : 0) << 1;
    o[i] |= (a[i] >  b[i] ? 1 : 0) << 2;
  }
}



static void print_table(char *name, float *p, int n) {
  printf("  constant %s : table := (\n", name);
  rep (i, n) {
    printf("    \"");
    print_bits((char*)&p[i], 4);
    if (i + 1 < n) puts("\",");
    else puts("\");");
  }
}



int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s num_of_tests\n", argv[0]);
    exit(EXIT_FAILURE);
  }
  
  int N = atoi(argv[1]);
  if (N < 1 || MAX_N < N) {
    fprintf(stderr, "error: bad range of num_of_tests\n");
    exit(EXIT_FAILURE);
  }

  static float A[MAX_N], B[MAX_N];
  static uint O[MAX_N];
  make_table(N, A, B, O);

  printf("  constant n : integer := %d;\n", N);
  printf("  subtype float is std_logic_vector(31 downto 0);\n");
  printf("  type table is array(0 to n-1) of float;\n");
  puts("");
  print_table("table_a", A, N);
  puts("");
  print_table("table_b", B, N);
  puts("");
  print_table("table_o", (float*)O, N); // てら強引！

  exit(EXIT_SUCCESS);
}
