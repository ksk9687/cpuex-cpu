#include <cmath>
#include "common.hpp"

typedef long long ll;



bool finv(float src, float &dst) {
  myfloat a, r;
  a.f = src;

  ll am = (1 << 23) | a.m;
  
  ll rm = (1LL << 47) / am;
  ll re = 127 - (a.e - 127) - 1;
  
  while ((rm >> 24)) {
    rm >>= 1;
    re++;
  }

  if (re < 0 || re >= 256) return false;

  r.s = a.s;
  r.e = re;
  r.m = rm & ((1 << 23) - 1);
  dst = r.f;
  return true;
}
