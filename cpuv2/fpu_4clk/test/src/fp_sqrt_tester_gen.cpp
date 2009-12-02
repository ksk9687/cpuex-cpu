#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cmath>
using namespace std;

#include "common.hpp"

extern bool fsqrt(float, float&);

const int MAX_N = 100000;



// �e�X�g�P�[�X�����
// TODO �w�����̑傫�����߂��������m�������ς�
static void make_table(int n, float *a, float *o) {
  a[0] = 0.0;
  a[1] = 1.0;
  a[2] = 2.0;
  a[3] = 1.5;

  for (int j = 4; j < n; j++) {
    a[j] = fabs(make_random_float());
  }

  // �`�F�b�N
  rep (i, n) {
    fsqrt(a[i], o[i]);
    check(o[i], sqrt((double)a[i]));
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

  static float A[MAX_N], O[MAX_N];
  make_table(N, A, O);
  
  printf("  constant n : integer := %d;\n", N);
  printf("  subtype float is std_logic_vector(31 downto 0);\n");
  printf("  type table is array(0 to n-1) of float;\n");
  puts("");
  print_table("table_a", A, N);
  puts("");
  print_table("table_o", O, N);

  exit(EXIT_SUCCESS);
}
