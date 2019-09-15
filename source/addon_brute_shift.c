#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void rotn(char* ciphertext,int n);
int conv_int(char* string, int pos);
int power(int b, int e);

int main(int argc, char** argv){
	char* ciphertext=*(argv+1);

	printf("\n");

	if(argc>2){
		char* shift_n=*(argv+2);
		int n=conv_int(shift_n, strlen(shift_n));
		rotn(ciphertext, n);
	}
	else{
		for(int i=0; i<26; i++){
			rotn(ciphertext, i);
		}
	}
	return 0;
}

void rotn(char* ciphertext, int n){
	char* tmp=malloc(1024);
	for(int i=0; i<strlen(ciphertext); i++){
		*(tmp+i)=(((*(ciphertext + i)-65)+n)%26)+65;
	}
	*(tmp+strlen(ciphertext))='\0';
	printf("K=%d %s\n\n",n, tmp);
}

int conv_int(char* string, int pos){
	int res=0;
	for(int i=0; i<pos; i++){
		res+=(*(string+pos-i-1)-48)*power(10,i);
	}
	return res;
}

int power(int b, int e){
	if(e==0) return 1;
	int res=1;
	while(e>0){
		e--;
		res*=b;
	}
	return res;
}
