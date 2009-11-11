# テストケース数の設定
SIM_TESTS = 100000
FPGA_TESTS = 100

# その他設定
CC = g++
CFLAGS = -Wall -Wextra



# いろいろ

.PHONY: all clean

all: obj bin \
	vhdl/fp_add_tester_sim.vhd vhdl/fp_add_tester_fpga.vhd \
	vhdl/fp_mul_tester_sim.vhd vhdl/fp_mul_tester_fpga.vhd \
	vhdl/fp_inv_tester_sim.vhd vhdl/fp_inv_tester_fpga.vhd \
	vhdl/fp_cmp_tester_sim.vhd vhdl/fp_cmp_tester_fpga.vhd \
	vhdl/fp_sqrt_tester_sim.vhd vhdl/fp_sqrt_tester_fpga.vhd

clean:
	rm -f obj/* bin/* vhdl/*_sim.vhd vhdl/*_fpga.vhd


# ディレクトリ
obj:
	mkdir obj

bin:
	mkdir bin


# VHDL を生成

vhdl/fp_add_tester_sim.vhd: bin/fp_add_tester_gen
	cat tmpl/fp_add_tester_head.txt > vhdl/fp_add_tester_sim.vhd
	bin/fp_add_tester_gen $(SIM_TESTS) >> vhdl/fp_add_tester_sim.vhd
	cat tmpl/fp_add_tester_tail.txt >> vhdl/fp_add_tester_sim.vhd

vhdl/fp_add_tester_fpga.vhd: bin/fp_add_tester_gen
	cat tmpl/fp_add_tester_head.txt > vhdl/fp_add_tester_fpga.vhd
	bin/fp_add_tester_gen $(FPGA_TESTS) >> vhdl/fp_add_tester_fpga.vhd
	cat tmpl/fp_add_tester_tail.txt >> vhdl/fp_add_tester_fpga.vhd


vhdl/fp_mul_tester_sim.vhd: bin/fp_mul_tester_gen
	cat tmpl/fp_mul_tester_head.txt > vhdl/fp_mul_tester_sim.vhd
	bin/fp_mul_tester_gen $(SIM_TESTS) >> vhdl/fp_mul_tester_sim.vhd
	cat tmpl/fp_mul_tester_tail.txt >> vhdl/fp_mul_tester_sim.vhd

vhdl/fp_mul_tester_fpga.vhd: bin/fp_mul_tester_gen
	cat tmpl/fp_mul_tester_head.txt > vhdl/fp_mul_tester_fpga.vhd
	bin/fp_mul_tester_gen $(FPGA_TESTS) >> vhdl/fp_mul_tester_fpga.vhd
	cat tmpl/fp_mul_tester_tail.txt >> vhdl/fp_mul_tester_fpga.vhd


vhdl/fp_inv_tester_sim.vhd: bin/fp_inv_tester_gen
	cat tmpl/fp_inv_tester_head.txt > vhdl/fp_inv_tester_sim.vhd
	bin/fp_inv_tester_gen $(SIM_TESTS) >> vhdl/fp_inv_tester_sim.vhd
	cat tmpl/fp_inv_tester_tail.txt >> vhdl/fp_inv_tester_sim.vhd

vhdl/fp_inv_tester_fpga.vhd: bin/fp_inv_tester_gen
	cat tmpl/fp_inv_tester_head.txt > vhdl/fp_inv_tester_fpga.vhd
	bin/fp_inv_tester_gen $(FPGA_TESTS) >> vhdl/fp_inv_tester_fpga.vhd
	cat tmpl/fp_inv_tester_tail.txt >> vhdl/fp_inv_tester_fpga.vhd


vhdl/fp_cmp_tester_sim.vhd: bin/fp_cmp_tester_gen
	cat tmpl/fp_cmp_tester_head.txt > vhdl/fp_cmp_tester_sim.vhd
	bin/fp_cmp_tester_gen $(SIM_TESTS) >> vhdl/fp_cmp_tester_sim.vhd
	cat tmpl/fp_cmp_tester_tail.txt >> vhdl/fp_cmp_tester_sim.vhd

vhdl/fp_cmp_tester_fpga.vhd: bin/fp_cmp_tester_gen
	cat tmpl/fp_cmp_tester_head.txt > vhdl/fp_cmp_tester_fpga.vhd
	bin/fp_cmp_tester_gen $(FPGA_TESTS) >> vhdl/fp_cmp_tester_fpga.vhd
	cat tmpl/fp_cmp_tester_tail.txt >> vhdl/fp_cmp_tester_fpga.vhd


vhdl/fp_sqrt_tester_sim.vhd: bin/fp_sqrt_tester_gen
	cat tmpl/fp_sqrt_tester_head.txt > vhdl/fp_sqrt_tester_sim.vhd
	bin/fp_sqrt_tester_gen $(SIM_TESTS) >> vhdl/fp_sqrt_tester_sim.vhd
	cat tmpl/fp_sqrt_tester_tail.txt >> vhdl/fp_sqrt_tester_sim.vhd

vhdl/fp_sqrt_tester_fpga.vhd: bin/fp_sqrt_tester_gen
	cat tmpl/fp_sqrt_tester_head.txt > vhdl/fp_sqrt_tester_fpga.vhd
	bin/fp_sqrt_tester_gen $(FPGA_TESTS) >> vhdl/fp_sqrt_tester_fpga.vhd
	cat tmpl/fp_sqrt_tester_tail.txt >> vhdl/fp_sqrt_tester_fpga.vhd


vhdl/fpu_tester_sim.vhd: bin/fpu_tester_gen
	cat tmpl/fpu_tester_head.txt > vhdl/fpu_tester_sim.vhd
	bin/fpu_tester_gen $(SIM_TESTS) >> vhdl/fpu_tester_sim.vhd
	cat tmpl/fpu_tester_tail.txt >> vhdl/fpu_tester_sim.vhd

vhdl/fpu_tester_fpga.vhd: bin/fpu_tester_gen
	cat tmpl/fpu_tester_head.txt > vhdl/fpu_tester_fpga.vhd
	bin/fpu_tester_gen $(FPGA_TESTS) >> vhdl/fpu_tester_fpga.vhd
	cat tmpl/fpu_tester_tail.txt >> vhdl/fpu_tester_fpga.vhd



# 実行ファイルを生成

obj/%.o: src/%.cpp
	$(CC) $(CFLAGS) -c -o $@ $^

bin/fp_add_tester_gen: src/fp_add_tester_gen.cpp obj/fp_add.o obj/common.o
	$(CC) $(CFLAGS) -o $@ $^

bin/fp_mul_tester_gen: src/fp_mul_tester_gen.cpp obj/fp_mul.o obj/common.o
	$(CC) $(CFLAGS) -o $@ $^

bin/fp_inv_tester_gen: src/fp_inv_tester_gen.cpp obj/fp_inv_table.o obj/fp_inv.o obj/common.o
	$(CC) $(CFLAGS) -o $@ $^

bin/fp_cmp_tester_gen: src/fp_cmp_tester_gen.cpp obj/common.o
	$(CC) $(CFLAGS) -o $@ $^

bin/fp_sqrt_tester_gen: src/fp_sqrt_tester_gen.cpp obj/fp_sqrt_table.o obj/fp_sqrt.o obj/common.o
	$(CC) $(CFLAGS) -o $@ $^

bin/fpu_tester_gen: src/fpu_tester_gen.cpp obj/common.o \
		obj/fp_add.o obj/fp_mul.o obj/fp_inv.o obj/fp_inv_table.o \
		obj/fp_sqrt.o obj/fp_sqrt_table.o
	$(CC) $(CFLAGS) -o $@ $^