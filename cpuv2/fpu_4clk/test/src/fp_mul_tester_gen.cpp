#include <algorithm>
#include <cstdio>
#include <cstdlib>
using namespace std;

#include "common.hpp"

extern bool fmul(float, float, float&);

const int MAX_N = 100000;



// テストケースを作る
// TODO 指数部の大きさが近い数字同士をいっぱい
static void make_table(int n, float *a, float *b, float *o) {
  int j = 0;
  
  // 0.0 * 0.0

  a[j] = 1.0;
  b[j] = 1.5;
  fmul(a[j], b[j], o[j]);
  j++;

  //a[j] = b[j] = o[j] = 0.0;
  //j++;

  // A * 0.0
  rep (i, min(50, n / 33)) {
    a[j] = make_random_float();
    b[j] = 0.0;
    fmul(a[j], b[j], o[j]);
    j++;
  }


  // 0.0 * B
  rep (i, min(50, n / 33)) {
    a[j] = 0.0;
    b[j] = make_random_float();
    fmul(a[j], b[j], o[j]);
    j++;
  }

  

  // A * B
  while (j < n) {
    do {
      a[j] = make_random_float();
      b[j] = make_random_float();
    } while (!fmul(a[j], b[j], o[j]));
    j++;
  }

  // check
  rep (i, n) {
    //fprintf(stderr, "%f / %f\n", o[i], a[i] * b[i]);
    check(o[i], a[i] * b[i]);
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

  static float A[MAX_N], B[MAX_N], O[MAX_N];
  make_table(N, A, B, O);

  printf("  constant n : integer := %d;\n", N);
  printf("  subtype float is std_logic_vector(31 downto 0);\n");
  printf("  type table is array(0 to n-1) of float;\n");
  puts("");
  print_table("table_a", A, N);
  puts("");
  print_table("table_b", B, N);
  puts("");
  print_table("table_o", O, N);

  exit(EXIT_SUCCESS);
}
