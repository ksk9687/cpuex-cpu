#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cmath>
using namespace std;

#include "common.hpp"

extern bool finv(float, float&);


int main(int argc, char **argv) {
  double ma = 0.0;
  for (int s = 0; s <= 1; s++) {
    for (int e = 1; e <= 254; e++) {
      for (int m = 0; m < (1 << 23); m++) {
        float a = make_float(s, 127, m);
        float b;
        finv(a, b);
        double err = fabs(b / (1.0 / (double)a) - 1.0);
        if (err > ma) {
          ma = err;
          printf("%e\n", err);
        }
      }
    }
  }

  exit(EXIT_SUCCESS);
}
