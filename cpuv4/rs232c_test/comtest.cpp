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

int main(int argc, char* argv[])
{
	int i;
	if(argc<3){
		fprintf(stderr,"usage:%s programfile outputfile\n",argv[0]);
		return 0;
	}
	
	com_settings cs;

	cs.comport_id = 1;
	//cs.baud = 460800;
	cs.baud = 115200;
	cs.stopbit_len = ONESTOPBIT;
	cs.parity_type = NOPARITY;
	cs.n_databits = 8;
	cs.do_cts_control = FALSE;

	setup_comm(&cs);

	//c = com_getc();
	//com_write((char*)sld_words, sld_n_words*sizeof(sld_words[0]));
	
	FILE *fp;
	
	if((fp=fopen(argv[1],"rb"))==NULL){
		fprintf(stderr,"cannot open %s\n",argv[1]);
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
	
	{
		i=0;
		fprintf(stderr,"Start to read from FPGA.\n");
		unsigned char c=com_getc();
		fprintf(stderr,"get:0x%x\n",c);
		i++;
		fprintf(stderr,"\r%d byte read.");
	}

	i=0;
	fprintf(stderr,"Start to write to FPGA.\n");
	while((ci=fgetc(stdin))!=EOF){
		char c=(char)ci;
		com_write(&c,1);
		i++;
		fprintf(stderr,"\r%d byte written.",i);
	}
	fprintf(stderr,"\nWrite complete.\n",i);
	
	if((fp=fopen(argv[2],"wb"))==NULL){
		fprintf(stderr,"cannot open %s\n",argv[1]);
		return 0;
	}
	i=0;
	fprintf(stderr,"Start to read from FPGA.\n");
	while(1){
		unsigned char c=com_getc();
		fprintf(fp,"%c",c);
		i++;
		fprintf(stderr,"\r%d byte read.",i);
	}
	fclose(fp);

	/*
	srand(time(NULL));
	for(i=0;i<2;i++){
		char readbuf=(char)rand();
		com_write(&readbuf,1);
		printf("write:%x\n",(unsigned char)readbuf);
		unsigned char c=com_getc();
		printf("read:%x\n",c);
	}
	*/
	
	return 0;
}
