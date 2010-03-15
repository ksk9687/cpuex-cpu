#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
#include <memory.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#include <windows.h>
#include "util.h"
#include "com.h"

#define INPUT_MAXSIZE 65536

/* Application parameters */
typedef struct{
  com_settings cs;
  
  const char* bin_filename;
  const char* input_filename;
  const char* output_filename;
  
  int count_i;
  int count;
} app_settings;

static int parse_options(int argc, char* argv[], app_settings* as){
  int c;
  int tmp;
  opterr = 0;
  while ((c = getopt(argc, argv, "B:c:S:i:p:")) != EOF)
    switch (c) {
    case 'B':
      as->cs.baud = ec_strtol(optarg, 10);
      break;
    case 'c':
      tmp = ec_strtol(optarg, 10);
      if(IS_IN_RANGE(tmp, 1, 9)){
        as->cs.comport_id = tmp;
      } else {
        error("%d : invalid comport ID\n", tmp);
      }
      break;
    case 'S':
      as->bin_filename = optarg;
      break;
    case 'i':
      as->input_filename = optarg;
      break;
    case 'p':
      as->count_i=ec_strtol(optarg, 10);
      break;
    case '?':
      error("%c : unknown option character\n", optopt);
      break;
    }
  return argc;
}

static void parse_arguments(int argc, char* argv[], app_settings* as){
  /*  extern char *optarg;
  extern int optind, opterr, optopt;*/

  as->cs.comport_id = 1;
  as->cs.baud = 115200;
  as->bin_filename = NULL;
  as->input_filename = NULL;
  as->output_filename = NULL;
  as->count_i=1;
  as->count = -1;
  
  argc = parse_options(argc, argv, as);
  
  switch(argc - optind){
  case 0:
    error("missing output bytes\n");
  case 1:
    error("missing output file name\n");
    break;
  case 2:
    int tmp = ec_strtol(argv[optind], 10);
    if(tmp>=0){
      as->count = tmp;
    } else {
      error("%d : invalid output bytes\n", tmp);
    }
    as->output_filename = argv[optind + 1];
    break;
  default:
    error("too many arguments\n");
    break;
  }
  
  if(is_error()){
    fprintf(stderr,
            "usage: %s \n"
            "          [-B <baud>]           ; BAUD, default 115200\n"
            "          [-c <port id>]        ; COMport ID, 1-9, default 1\n"
            "          [-S <source bin>]     ; program file name\n"
            "          [-i <input file>]     ; input file name(binary), size must <%d\n"
            "          [-p <print interval>] ; print received bytes for this interval,default 1(int)\n"
            "                                  if <print interval> <= 0 then it will not print\n"
            "          <outputbytes>         ; how many bytes receive(int)\n"
            "          <output file>         ; output file name\n"
            "e.g.: %s -B 460800 -c 9 -S min-rt.bin -i contest.sldb -p 100 49167 output.ppm \n"
            ,argv[0],INPUT_MAXSIZE,argv[0]);
    exit(1);
  }
}

int main(int argc, char* argv[]){
	DWORD startTime,middleTime,endTime;
	app_settings as;
	int i;


	parse_arguments(argc, argv, &as);
	setup_comm(&as.cs);

	FILE *outfp;
	if((outfp=fopen(as.output_filename,"wb"))==NULL){
		fprintf(stderr,"cannot open output file %s\n",as.output_filename);
		return 0;
	}
	char inputdata[INPUT_MAXSIZE];
	int inputsize=0;
	if(as.input_filename!=NULL){
		FILE *infp;
		if((infp=fopen(as.input_filename,"rb"))==NULL){
			fprintf(stderr,"cannot open input file %s\n",as.input_filename);
			return 0;
		}
		for(i=0;i<INPUT_MAXSIZE;i++){
			int ci;
			if((ci=fgetc(infp))==EOF){
				break;
			}
			inputdata[i]=(char)ci;
		}
		inputsize=i;
		if(i==INPUT_MAXSIZE){
			fprintf(stderr,"WARNING:The size of input file %s is larger than %d\n",as.input_filename,INPUT_MAXSIZE);
		}
		fclose(infp);
	}
	//c = com_getc();
	//com_write((char*)sld_words, sld_n_words*sizeof(sld_words[0]));
	if(as.bin_filename!=NULL){
		FILE *fp;
		if((fp=fopen(as.bin_filename,"rb"))==NULL){
			fprintf(stderr,"cannot open program file %s\n",as.bin_filename);
			return 0;
		}
		int ci;
		i=0;
		fprintf(stderr,"Start to send program to FPGA.\n");
		while((ci=fgetc(fp))!=EOF){
			char c=(char)ci;
			com_write(&c,1);
			i++;
			fprintf(stderr,"\r%d byte sent.",i);
		}
		fclose(fp);
		fprintf(stderr,"\nSend program complete.\n",i);
	}
	
	{
		fprintf(stderr,"Start to get 0xaa from FPGA.\n");
		unsigned char c=com_getc();
		fprintf(stderr,"get:0x%2x\n",c);
		if(c!=0xaa){
			fprintf(stderr,"not 0xaa\n");
			return 0;
		}
	}

	fprintf(stderr,"Start to measure time.\n");
	startTime = GetTickCount();

	if(as.input_filename!=NULL){
		fprintf(stderr,"Start to write to FPGA.\n");
		int sendsize=as.count_i>0?as.count_i:inputsize;
		for(i=0;i<inputsize-sendsize;i+=sendsize){
			com_write(inputdata+i,sendsize);
			fprintf(stderr,"\r%d byte written.",i);
		}
		com_write(inputdata+i,inputsize-i);
		fprintf(stderr,"\r%d byte written.",inputsize);
		fprintf(stderr,"\nWrite complete.\n",i);

		middleTime = GetTickCount();
		DWORD middleelapsedTime = middleTime - startTime;
		fprintf(stderr, "elapsed time : %lu.%03lu s\n",middleelapsedTime/1000, middleelapsedTime%1000);
	}
	
	fprintf(stderr,"Start to read from FPGA.\n");
	int j;
	for(i=0,j=0;i<as.count;i++,j++){
		unsigned char c=com_getc();
		fputc(c,outfp);
		if(as.count_i>0){
			if(j==as.count_i){
				fprintf(stderr,"\r%d byte read.",i);
				j=0;
			}
		}
	}
	endTime = GetTickCount();
	printf("\n");
	fprintf(stderr,"total %d byte read.\n",i);
	fclose(outfp);
	DWORD elapsedTime = endTime - startTime;
	fprintf(stderr, "elapsed time : %lu.%03lu s\n",elapsedTime/1000, elapsedTime%1000);
	
	return 0;
}
