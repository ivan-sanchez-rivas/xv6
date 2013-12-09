#include "types.h"
#include "stat.h"
#include "user.h"
#include "syscall.h"
#include "traps.h"
int contador=0;
void periodico(void);
int getestado(void)
{
int estado;
asm volatile("int %1":"=a"(estado):"i"(T_SYSCALL), "a"(SYS_estado));
return estado;
}

int getsize(void)
{
int size;
asm volatile("int %1":"=a"(size):"i"(T_SYSCALL), "a"(SYS_size));
return size;
}
int PIDPadre(void)
{
int childpid = fork();
if(childpid<0)
	printf(1,"Fork fallo %d\n",childpid);
else if(childpid>0){
printf(1,"Estadisticas del proceso Padre\n");
if(getestado()==0)
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Unused\nSize del Padre: %d\n",getpid(),childpid,getsize());

}
else if(getestado()==1)
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Embryo\nSize del Padre: %d\n",getpid(),childpid,getsize());
}	
else if(getestado()==2)
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Sleep\nSize del Padre: %d\n",getpid(),childpid,getsize());
}
else if(getestado()==3)
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Runnable\nSize del Padre: %d\n",getpid(),childpid,getsize());
}
else if(getestado()==4)
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Running\nSize del Padre: %d\n",getpid(),childpid,getsize());
}
else
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Zombie\nSize del Padre: %d\n",getpid(),childpid,getsize());
}
wait();
}
exit();
}
int main(int argc, char *argv[])
{
int i;
printf(1,"Empezando alarma\n");
alarma(20,periodico);
for(i=0; i<50*200000;i++){
	if((i++%200000)==0)
		write(2,".",1);
}
PIDPadre();
return 0;
}

void periodico(void)
{
printf(1,"alarma!\n");
}
