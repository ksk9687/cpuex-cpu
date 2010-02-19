#include<stdio.h>
int main(){
	int i;
	for(i=0;i<50000;i++){
		fprintf(stderr,"\r%d byte sent.",i);
	}
	return 0;
}
