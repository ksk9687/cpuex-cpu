#include <cmath>
#include "common.hpp"

typedef long long ll;



bool fmul(float src1, float src2, float &dst) {
  myfloat a, b, r;
  a.f = src1;
  b.f = src2;

  if (fabs(src1) == 0.0 || fabs(src2) == 0.0) return 0.0;

  ll am = (1 << 23) | a.m;
  ll bm = (1 << 23) | b.m;
  
  ll rm = (am * bm) >> 23;
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
