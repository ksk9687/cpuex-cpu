#include <algorithm>
#include <cmath>
using namespace std;

#include "common.hpp"


bool fadd(float src1, float src2, float &dst) {
  myfloat a, b, r;
  int am, bm, m;

  if (fabs(src1) == 0) { dst = src2; return true; }
  if (fabs(src2) == 0) { dst = src1; return true; }

  a.f = src1;
  b.f = src2;

  r.e = max(a.e, b.e);
  am = (a.s ? -1 : 1) * ((a.m | (1 << 23)) >> min(31U, (r.e - a.e)));
  bm = (b.s ? -1 : 1) * ((b.m | (1 << 23)) >> min(31U, (r.e - b.e)));
  m = am + bm;
  
  if (m == 0) {
    // 0 ‚É‚È‚Á‚½ê‡
    r.m = r.s = r.e = 0;
  }
  else {
    if (m > 0) {
      r.s = 0;
    }
    else {
      r.s = 1;
      m = -m;
    }
    while (m >= (1 << 24)) {
      m >>= 1;
      r.e++;
    }
    while (((m >> 23) & 1) == 0) {
      m <<= 1;
      r.e--;
    }
    r.m = m;
  }

  dst = r.f;
  return dst == 0 || is_normalized(dst);
}
