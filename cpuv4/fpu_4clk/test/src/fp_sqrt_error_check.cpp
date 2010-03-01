#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cmath>
using namespace std;

#include "common.hpp"

extern bool fsqrt(float, float&);


int main(int argc, char **argv) {
  double ma = 0.0;
  for (int s = 0; s <= 1; s++) {
    for (int e = 1; e <= 254; e++) {
    //for (int e = 120; e <= 130; e++) {
    //int e = 126; {
      for (int m = 0; m < (1 << 23); m++) {
        float a = make_float(s, e, m);
        float b;
        fsqrt(a, b);
        double err = fabs(b / sqrt((double)a) - 1.0);
        if (err > ma) {
          print_float(a);
          print_float(b);
          print_float(sqrt(a));
          ma = err;
          printf("%e\n", err);
        }
      }
    }
  }

  exit(EXIT_SUCCESS);
}
