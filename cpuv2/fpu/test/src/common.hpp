#pragma once

#define rep(i, n) for (int i = 0; i < (int)(n); i++)
#define iter(c) __typeof((c).begin())
#define tr(c, i) for (iter(c) i = (c).begin(); i != (c).end(); ++i)

typedef unsigned int uint;



// ���������_��
int is_normalized(float);                 // ���K�����ł��邩�H
float make_float(uint s, uint e, uint m); // ���K�������쐬
float make_random_float();                // �����_���Ȑ��K�������쐬


// �\��
void print_bits(char*, int); // 2�i���ŕ\��
void print_float(float);     // �f�o�b�O�p�\��


// �덷�`�F�b�N -> �������瑦�I��
const double cap_err = 1E-6;
void check(float a, float b, double err = cap_err);


// ���������_�������邽�߂̋��p�́i���g���G���f�B�A����p�j
typedef union {
  float f;
  struct {
    uint m : 23;
    uint e : 8;
    uint s : 1; 
  };
} myfloat;
