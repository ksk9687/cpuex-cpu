#include <algorithm>
#include <cstdio>
#include <cstdlib>
using namespace std;

#include "common.hpp"

extern bool fadd(float, float, float&);

const int MAX_N = 100000;



// テストケースを作る
// TODO 指数部の大きさが近い数字同士をいっぱい
static void make_table(int n, float *a, float *b, float *o) {
  int j = 0;
  
  // 0.0 + 0.0
  a[j] = b[j] = o[j] = 0.0;
  j++;

  // A + 0.0
  rep (i, min(50, n / 33)) {
    a[j] = make_random_float();
    b[j] = 0.0;
    j++;
  }


  // 0.0 + B
  rep (i, min(50, n / 33)) {
    a[j] = 0.0;
    b[j] = make_random_float();
    j++;
  }

  // A + B = 0
  rep (i, n / 10) {
    a[j] = make_random_float();
    b[j] = -b[j];
    j++;
  }

  // 指数部が同じ
  rep (i, n / 2) {
    int e = 1 + rand() % 254;
    a[j] = make_float((rand() >> 20) & 1, e, rand() & ((1 << 23) - 1));
    b[j] = make_float((rand() >> 20) & 1, e, rand() & ((1 << 23) - 1));
    fprintf(stderr, "%.10e\n%.10e\n", a[j], b[j]);
    j++;
  }
  
  // A + B = ???
  while (j < n) {
    do {
      a[j] = make_random_float();
      b[j] = make_random_float();
    } while (!fadd(a[j], b[j], o[j]));
    j++;
  }

  // output
  rep (i, n) {
    //fprintf(stderr, "%d : %f + %f (%d)\n", i, a[i], b[i], fadd(a[i], b[i], o[i]));
    fadd(a[i], b[i], o[i]);

    // print_float(a[i]);
    // print_float(b[i]);
           
    check(a[i] + b[i], o[i]);
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
