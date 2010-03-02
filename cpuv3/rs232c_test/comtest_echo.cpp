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


#define READLEN 17

int main(int argc, char* argv[])
{
	com_settings cs;

	cs.comport_id = 1;
	//cs.baud = 460800;
	cs.baud = 9600;
	cs.stopbit_len = ONESTOPBIT;
	cs.parity_type = NOPARITY;
	cs.n_databits = 8;
	cs.do_cts_control = FALSE;

	//c = com_getc();
	//com_write((char*)sld_words, sld_n_words*sizeof(sld_words[0]));
	
	setup_comm(&cs);
	
	long long count=0;
	unsigned char readbuf[READLEN+1];
	readbuf[READLEN]='0';
	srand(time(NULL));
	while(1){
		int i;
		for(i=0;i<READLEN;i++){
			readbuf[i]=(char)((rand()>>2)&0xFF);
		}
		com_write((char*)readbuf,READLEN);
		for(i=0;i<READLEN;i++){
			unsigned char c=com_getc();
			if(readbuf[i]!=c){
				printf("ERROR:at %Ld 's %d:%02x -> %02x\n",count,i,readbuf[i],c);
				return 0;//not match
			}
		}
		count++;
		if(count%1000==0){
			printf("OK:%Ld\n",count);
		}
	}
	
	return 0;
}
