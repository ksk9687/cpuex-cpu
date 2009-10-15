#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <stack>
#include <queue>
#include <set>
#include <map>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <cmath>
using namespace std;
 
#define all(c) ((c).begin()), ((c).end()) 
#define iter(c) __typeof((c).begin())
#define present(c, e) ((c).find((e)) != (c).end()) 
#define cpresent(c, e) (find(all(c), (e)) != (c).end())
#define rep(i, n) for (int i = 0; i < (int)(n); i++)
#define tr(c, i) for (iter(c) i = (c).begin(); i != (c).end(); ++i)
#define pb push_back
#define mp make_pair

typedef long long ll;
typedef unsigned long long ull;

// 上位 (M - 1) ビットからの表引き
const int M = 12;

typedef union {
  double d;
  struct {
    ull m : 52;
    ull e : 11;
    ull s : 1; 
  };
} mydouble;


void print_bits(char *p, int b) {
  p += b - 1;
  for (int i = 0; i < b; i++) {
    for (int j = 7; j >= 0; j--) {
      printf("%d", ((*p) >> j) & 1);
    }
    p--;
  }
}

void print_double(double d) {
  print_bits((char*)&d, 8);
  printf(" : %e", d);
  mydouble md;
  md.d = d;
  printf(" (%llu %llu %llu)\n", md.s, md.e, md.m);
}

int main() {
  /*
    // 実験
  ll a = (1LL << M) | 1;
  ll b = (1LL << (M * 3)) / a;
  print_bits((char*)&b, 8); puts("");
  ll c = b >> (2 * M - 1);
  print_bits((char*)&c, 8); puts("");
  c = b >> (2 * M);
  print_bits((char*)&c, 8); puts("");
  */
  
  for (int i = 0; i < (1 << (M - 1)); i++) {
    ull a = (1 << M) | (i << 1) | 1;

    mydouble b;
    b.d = a;
    b.e = 1023;

    mydouble c;
    c.d = 1.0 / b.d / b.d;

    ull tmp = c.m;

    ull d = (1ULL << 52) | c.m;
    //print_bits((char*)&d, 8); puts("");
    d >>= (1023 + 28) - c.e;
    
    //print_bits((char*)&d, 4); puts("");
    /* VHDLを吐く場合 */
    //*
    printf("\"");
    rep (j, 24) printf("%llu", (d >> (23 - j)) & 1);
    if (i + 1 < (1 << (M - 1))) puts("\",");
    else puts("\"");
    /*/
    printf("%llu,\n", d);
    //*/
  }

  return 0;
}

/*
1000000000001
*/
