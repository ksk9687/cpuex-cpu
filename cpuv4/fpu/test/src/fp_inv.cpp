#include <cmath>
#include "common.hpp"

typedef unsigned long long ull;

extern int finv_table[];

bool finv(float src, float &dst) {
  myfloat a;
  a.f = src;
  
  ull am = (1 << 23) | a.m;
  ull x1 = am >> 12;
  ull x2 = am & ((1 << 12) - 1);

  ull c = finv_table[x1 - (1 << 11)];        // 24 bit
  ull x = (x1 << 12) | (x2 ^ ((1 << 12) - 1)); // 24 bit

  /*
  ull om1 = (c * x);
  ull om2 = (om1 & (1ULL << 46)) ? om1 >> 23 : om1 >> 22;
  ull oe = 254 - a.e - ((om1 & (1ULL << 46)) ? 1 : 2);
  /*/
  ull ch = c >> 12, cl = c & ((1 << 12) - 1);
  ull xh = x >> 12, xl = x & ((1 << 12) - 1);
  
  ull oh = ch * xh;
  ull omm1 = (ch * xl) >> 11;
  ull omm2 = (cl * xh) >> 11;

  ull om1 = (oh << 1) + omm1 + omm2 + 2;
  ull om2 = (om1 & (1ULL << 24)) ? (om1 >> 1) : om1;
  ull oe = 254 - a.e - ((om1 & (1ULL << 24)) ? 0 : 1);
  //*/
  if (oe <= 0 || 255 <= oe) return false;
  
  myfloat o;
  o.m = om2 & ((1 << 23) - 1);
  o.e = oe;
  o.s = a.s;
  dst = o.f;
  return true;
}
