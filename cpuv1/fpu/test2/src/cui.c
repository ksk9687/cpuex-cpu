#include <stdio.h>
#include <math.h>
#include "common.h"

int main() {
  float a, b;
  scanf("%f", &a);
  scanf("%f", &b);

  printf("a:    "); print_float(a);
  printf("b:    "); print_float(b);
  puts("");
  printf("a+b:  "); print_float(a + b);
  printf("mine: "); print_float(fadd(a, b));

  return 0;
}
