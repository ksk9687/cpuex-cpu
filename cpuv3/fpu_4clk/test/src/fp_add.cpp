#include <algorithm>
#include <cmath>
using namespace std;

#include "common.hpp"


bool fadd(float src1, float src2, float &dst) {
  myfloat a, b, r;
  a.f = src1;
  b.f = src2;

  
  int be_minus_ae = (int)b.e - (int)a.e;
  int ae_minus_be = (int)a.e - (int)b.e;

  bool agtb = fabs(src1) > fabs(src2) ? 1 : 0;

  int am1 = a.e ? ((1 << 23) | a.m) : 0;
  int bm1 = b.e ? ((1 << 23) | b.m) : 0;

  int we_minus_le, we, wm, lm, os;
  if (agtb) {
    we_minus_le = ae_minus_be;
    we = a.e;
    wm = am1;
    lm = bm1;
    os = a.s;
  }
  else {
    we_minus_le = be_minus_ae;
    we = b.e;
    wm = bm1;
    lm = am1;
    os = b.s;
  }


  int lm2;
  
  if (we_minus_le >= 30) lm2 = 0;
  else lm2 = lm >> we_minus_le;
  
  int oe1 = we;
  int pm = wm;
  int os1 = os;
  int qm = lm2;
  int op = a.s ^ b.s;


  int om1;
  if (op) om1 = pm - qm;
  else om1 = pm + qm;

  int oe2 = oe1;
  int os2 = os1;


  myfloat o;
  o.s = os2;
  for (int i = 24; i >= 0; i--) {
    if (om1 & (1 << i)) {
      // fprintf(stderr, "i=%d\n", i);
      o.e = oe2 + i - 23;
      if (i == 24) o.m = (om1 >> 1) & ((1 << 23) - 1);
      else o.m = (om1 << (23 - i)) & ((1 << 23) - 1);

      dst = o.f;
      return is_normalized(dst);
    }
  }

  dst = 0;
  return true;
}

  



/*
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
*/
