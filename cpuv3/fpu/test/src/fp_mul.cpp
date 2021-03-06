#include <cmath>
#include "common.hpp"

typedef long long ll;


#include <cstdio>

bool fmul(float src1, float src2, float &dst) {
  myfloat a, b, r;
  a.f = src1;
  b.f = src2;

  if (fabs(src1) == 0.0 || fabs(src2) == 0.0) return false;

  ll am = (1 << 23) | a.m;
  ll bm = (1 << 23) | b.m;

  ll ah = am >> 12, al = am & ((1 << 12) - 1);
  ll bh = bm >> 12, bl = bm & ((1 << 12) - 1);
  
  ll oh = ah * bh;
  ll om1 = (ah * bl) >> 11;
  ll om2 = (al * bh) >> 11;

  ll rm = (oh << 1) + om1 + om2 + 2;
  // print_bits((char*)&rm, sizeof(ll)); puts("");
  // ll rm2 = (am * bm) >> 23;
  // fprintf(stderr, "%lld\n%lld\n\n", rm, rm2);
  ll re = (a.e - 127) + (b.e - 127) + 127;
  
  while ((rm >> 24)) {
    rm >>= 1;
    re++;
  }

  if (re < 0 || re >= 256) return false;

  r.s = a.s ^ b.s;
  r.e = re;
  r.m = rm & ((1 << 23) - 1);
  dst = r.f;
  return true;
}
