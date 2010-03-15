#include <cstdio>
#include <cstdlib>
#include <cmath>
#include "common.hpp"


int is_normalized(float f) {
  myfloat mf;
  mf.f = f;
  return 1 <= mf.e && mf.e <= 254;
}


float make_float(uint s, uint e, uint m) {
  uint t = (s << 31) | (e << 23) | m;
  return *(float*)(void*)&t;
}


float make_random_float() {
  return make_float(rand() % 2, 1 + rand() % 254, rand() & ((1 << 23) - 1));
}


// リトルエンディアン専用
void print_bits(char *p, int b) {
  p += b - 1;
  for (int i = 0; i < b; i++) {
    for (int j = 7; j >= 0; j--) {
      printf("%d", ((*p) >> j) & 1);
    }
    p--;
  }
}


void print_float(float f) {
  print_bits((char*)&f, 4);
  fprintf(stderr, " : %.10e", f);
  myfloat mf;
  mf.f = f;
  fprintf(stderr, " (%d %d %d)\n", mf.s, mf.e, mf.m);
}


void check(float a, float b, double err) {
  if (fabs(a - b) > err
      && fabs(a - b) > err * fmax(fabs(a), fabs(b))) {
    fprintf(stderr, "check failed: %.8e %.8e (%.3e / %.3e)\n",
            a, b, fabs(a - b), fabs(a - b) / fmax(fabs(a), fabs(b)));
    exit(EXIT_FAILURE);
  }
}
