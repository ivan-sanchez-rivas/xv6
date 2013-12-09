#include "types.h"
#include "stat.h"
#include "user.h"

char buf[512];
void concatenate_string(char *original,char *add);

void suchPrint(int fd)
{
	int n;
	int counter =0;
	while((n=read(fd,buf,sizeof(buf)))>0){
		if(counter==0){
		printf(1,"such");
		write(1,buf,n);
		counter++;
		}else if(counter==1){
			printf(1,"wow");
			write(1,buf,n);
			counter++;
		} else if(counter==2){
		  printf(1,"much");
		  write(1,buf,n);
		  counter++;
		} else if(counter ==3){
		  printf(1,"so");
		  write(1,buf,n);
		  counter=0;
		}
	}
	if(n<0){
	   printf(1,"doge: such error\n");
	   exit();
	}
}

int main(int argc, char *argv[])
{
	int fd, i;
	if(argc <=1){
	  suchPrint(0);
	  exit();
	}
	for(i=1;i<argc;i++){
		if((fd=open(argv[i],0))<0){
		   printf(1,"doge: much closed", argv[i]);
		   exit();
		}
		suchPrint(fd);
		close(fd);
	}
	exit();
}

