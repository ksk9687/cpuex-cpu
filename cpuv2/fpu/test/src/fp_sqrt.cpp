#include <cmath>
#include <cstdio>
#include "common.hpp"

typedef unsigned long long ull;

extern int fsqrt_table[];

#define DEBUG(x) do { puts(#x); print_bits((char*)&x, sizeof(x)); puts(""); } while (0)

bool fsqrt(float src, float &dst) {
  if (src < 0) return false;

  myfloat a;
  a.f = src;

  ull am = (1 << 23) | a.m;  
  ull oe = 63 + (a.e >> 1);
  
  int idx = (((a.e & 1) ^ 1) << 10) | ((am >> 13) ^ (1 << 10));
  ull c = fsqrt_table[idx];

  ull x1 = am >> 13;
  ull x2 = am & ((1 << 13) - 1);

  ull x = 0;
  x |= x1 << 13;
  x |= (1 + ((x2 >> 12) & 1)) << 11;
  x |= (x2 & ((1 << 12) - 1)) >> 1;

  if (src == 0) {
    x = c = 0;
    oe = 0;
  }

  ull ch = c >> 12, cl = c & ((1 << 12) - 1);
  ull xh = x >> 12, xl = x & ((1 << 12) - 1);
  
  ull oh = ch * xh;
  ull omm1 = (ch * xl) >> 11;
  ull omm2 = (cl * xh) >> 11;
  

  ull om1 = (oh << 1) + omm1 + omm2 + 2;
  ull om2 = (om1 & (1ULL << 24)) ? (om1 >> 1) : om1;
  ull oe2 = oe + ((om1 & (1ULL << 24)) ? 1 : 0);

  myfloat o;
  o.m = om2 & ((1 << 23) - 1);
  o.e = oe2;
  o.s = a.s; // •„†IH

  dst = o.f;
  return true;
}
