#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
/*
rec_bytes,rec_packets,rec_errs,rec_drop,rec_fifo,rec_frame,rec_compressed,rec_multicast 
sen_bytes,sen_packets,sen_errs,sen_drop,sen_fifo,sen_frame,sen_compressed,sen_multicast 
 */

typedef struct d{
	int recv;
	int sent;
	int total;
	struct tm datetime;
	int done;     /*validates consistency*/
}data ;
  
    
int main(){

data d;

int index,i,tokens[20];
char string[300];
char *tok;

fgets(string,300,stdin);

tok=strtok(string," ,.");
tokens[0]=atoi(tok);

index=1;
while(1) {
	tok= strtok(NULL, " .,");
	if( tok==NULL) break ;
	tokens[index++] = atoi(tok) ;
	}

d.recv=tokens[0]/(1024*1024);
d.sent=tokens[8]/(1024*1024);
d.total=d.recv+d.sent ;
printf("Received: %d mb",d.recv);
printf("\t\tSent: %d mb",d.sent);
printf("\t\tTotal: %d mb\n",d.total);

return 0;
}
