#pragma once

#define rep(i, n) for (int i = 0; i < (int)(n); i++)
#define iter(c) __typeof((c).begin())
#define tr(c, i) for (iter(c) i = (c).begin(); i != (c).end(); ++i)

typedef unsigned int uint;



// 浮動小数点数
int is_normalized(float);                 // 正規化数であるか？
float make_float(uint s, uint e, uint m); // 正規化数を作成
float make_random_float();                // ランダムな正規化数を作成


// 表示
void print_bits(char*, int); // 2進数で表示
void print_float(float);     // デバッグ用表示


// 誤差チェック -> 落ちたら即終了
const double cap_err = 1E-6;
void check(float a, float b, double err = cap_err);


// 浮動小数点をいじるための共用体（リトルエンディアン専用）
typedef union {
  float f;
  struct {
    uint m : 23;
    uint e : 8;
    uint s : 1; 
  };
} myfloat;
