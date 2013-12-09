
_alarma:     file format elf32-i386


Disassembly of section .text:

00000000 <getestado>:
#include "syscall.h"
#include "traps.h"
int contador=0;
void periodico(void);
int getestado(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
int estado;
asm volatile("int %1":"=a"(estado):"i"(T_SYSCALL), "a"(SYS_estado));
   7:	c7 45 e8 18 00 00 00 	movl   $0x18,-0x18(%ebp)
   e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  11:	cd 40                	int    $0x40
  13:	89 c3                	mov    %eax,%ebx
  15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
return estado;
  18:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1b:	83 c4 14             	add    $0x14,%esp
  1e:	5b                   	pop    %ebx
  1f:	5d                   	pop    %ebp
  20:	c3                   	ret    

00000021 <getsize>:

int getsize(void)
{
  21:	55                   	push   %ebp
  22:	89 e5                	mov    %esp,%ebp
  24:	53                   	push   %ebx
  25:	83 ec 14             	sub    $0x14,%esp
int size;
asm volatile("int %1":"=a"(size):"i"(T_SYSCALL), "a"(SYS_size));
  28:	c7 45 e8 19 00 00 00 	movl   $0x19,-0x18(%ebp)
  2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  32:	cd 40                	int    $0x40
  34:	89 c3                	mov    %eax,%ebx
  36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
return size;
  39:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  3c:	83 c4 14             	add    $0x14,%esp
  3f:	5b                   	pop    %ebx
  40:	5d                   	pop    %ebp
  41:	c3                   	ret    

00000042 <PIDPadre>:
int PIDPadre(void)
{
  42:	55                   	push   %ebp
  43:	89 e5                	mov    %esp,%ebp
  45:	53                   	push   %ebx
  46:	83 ec 34             	sub    $0x34,%esp
int childpid = fork();
  49:	e8 d2 04 00 00       	call   520 <fork>
  4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
if(childpid<0)
  51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  55:	79 20                	jns    77 <PIDPadre+0x35>
	printf(1,"Fork fallo %d\n",childpid);
  57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  5e:	c7 44 24 04 94 0a 00 	movl   $0xa94,0x4(%esp)
  65:	00 
  66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6d:	e8 5d 06 00 00       	call   6cf <printf>
  72:	e9 81 01 00 00       	jmp    1f8 <PIDPadre+0x1b6>
else if(childpid>0){
  77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  7b:	0f 8e 77 01 00 00    	jle    1f8 <PIDPadre+0x1b6>
printf(1,"Estadisticas del proceso Padre\n");
  81:	c7 44 24 04 a4 0a 00 	movl   $0xaa4,0x4(%esp)
  88:	00 
  89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  90:	e8 3a 06 00 00       	call   6cf <printf>
if(getestado()==0)
  95:	e8 66 ff ff ff       	call   0 <getestado>
  9a:	85 c0                	test   %eax,%eax
  9c:	75 34                	jne    d2 <PIDPadre+0x90>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Unused\nSize del Padre: %d\n",getpid(),childpid,getsize());
  9e:	e8 7e ff ff ff       	call   21 <getsize>
  a3:	89 c3                	mov    %eax,%ebx
  a5:	e8 fe 04 00 00       	call   5a8 <getpid>
  aa:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  b9:	c7 44 24 04 c4 0a 00 	movl   $0xac4,0x4(%esp)
  c0:	00 
  c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c8:	e8 02 06 00 00       	call   6cf <printf>
  cd:	e9 21 01 00 00       	jmp    1f3 <PIDPadre+0x1b1>

}
else if(getestado()==1)
  d2:	e8 29 ff ff ff       	call   0 <getestado>
  d7:	83 f8 01             	cmp    $0x1,%eax
  da:	75 34                	jne    110 <PIDPadre+0xce>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Embryo\nSize del Padre: %d\n",getpid(),childpid,getsize());
  dc:	e8 40 ff ff ff       	call   21 <getsize>
  e1:	89 c3                	mov    %eax,%ebx
  e3:	e8 c0 04 00 00       	call   5a8 <getpid>
  e8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  f7:	c7 44 24 04 18 0b 00 	movl   $0xb18,0x4(%esp)
  fe:	00 
  ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 106:	e8 c4 05 00 00       	call   6cf <printf>
 10b:	e9 e3 00 00 00       	jmp    1f3 <PIDPadre+0x1b1>
}	
else if(getestado()==2)
 110:	e8 eb fe ff ff       	call   0 <getestado>
 115:	83 f8 02             	cmp    $0x2,%eax
 118:	75 34                	jne    14e <PIDPadre+0x10c>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Sleep\nSize del Padre: %d\n",getpid(),childpid,getsize());
 11a:	e8 02 ff ff ff       	call   21 <getsize>
 11f:	89 c3                	mov    %eax,%ebx
 121:	e8 82 04 00 00       	call   5a8 <getpid>
 126:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 12a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 12d:	89 54 24 0c          	mov    %edx,0xc(%esp)
 131:	89 44 24 08          	mov    %eax,0x8(%esp)
 135:	c7 44 24 04 6c 0b 00 	movl   $0xb6c,0x4(%esp)
 13c:	00 
 13d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 144:	e8 86 05 00 00       	call   6cf <printf>
 149:	e9 a5 00 00 00       	jmp    1f3 <PIDPadre+0x1b1>
}
else if(getestado()==3)
 14e:	e8 ad fe ff ff       	call   0 <getestado>
 153:	83 f8 03             	cmp    $0x3,%eax
 156:	75 31                	jne    189 <PIDPadre+0x147>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Runnable\nSize del Padre: %d\n",getpid(),childpid,getsize());
 158:	e8 c4 fe ff ff       	call   21 <getsize>
 15d:	89 c3                	mov    %eax,%ebx
 15f:	e8 44 04 00 00       	call   5a8 <getpid>
 164:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 168:	8b 55 f4             	mov    -0xc(%ebp),%edx
 16b:	89 54 24 0c          	mov    %edx,0xc(%esp)
 16f:	89 44 24 08          	mov    %eax,0x8(%esp)
 173:	c7 44 24 04 c0 0b 00 	movl   $0xbc0,0x4(%esp)
 17a:	00 
 17b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 182:	e8 48 05 00 00       	call   6cf <printf>
 187:	eb 6a                	jmp    1f3 <PIDPadre+0x1b1>
}
else if(getestado()==4)
 189:	e8 72 fe ff ff       	call   0 <getestado>
 18e:	83 f8 04             	cmp    $0x4,%eax
 191:	75 31                	jne    1c4 <PIDPadre+0x182>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Running\nSize del Padre: %d\n",getpid(),childpid,getsize());
 193:	e8 89 fe ff ff       	call   21 <getsize>
 198:	89 c3                	mov    %eax,%ebx
 19a:	e8 09 04 00 00       	call   5a8 <getpid>
 19f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 1a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
 1aa:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ae:	c7 44 24 04 14 0c 00 	movl   $0xc14,0x4(%esp)
 1b5:	00 
 1b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bd:	e8 0d 05 00 00       	call   6cf <printf>
 1c2:	eb 2f                	jmp    1f3 <PIDPadre+0x1b1>
}
else
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Zombie\nSize del Padre: %d\n",getpid(),childpid,getsize());
 1c4:	e8 58 fe ff ff       	call   21 <getsize>
 1c9:	89 c3                	mov    %eax,%ebx
 1cb:	e8 d8 03 00 00       	call   5a8 <getpid>
 1d0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 1d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
 1db:	89 44 24 08          	mov    %eax,0x8(%esp)
 1df:	c7 44 24 04 68 0c 00 	movl   $0xc68,0x4(%esp)
 1e6:	00 
 1e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ee:	e8 dc 04 00 00       	call   6cf <printf>
}
wait();
 1f3:	e8 38 03 00 00       	call   530 <wait>
}
exit();
 1f8:	e8 2b 03 00 00       	call   528 <exit>

000001fd <main>:
}
int main(int argc, char *argv[])
{
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
 200:	53                   	push   %ebx
 201:	83 e4 f0             	and    $0xfffffff0,%esp
 204:	83 ec 20             	sub    $0x20,%esp
int i;
printf(1,"Empezando alarma\n");
 207:	c7 44 24 04 ba 0c 00 	movl   $0xcba,0x4(%esp)
 20e:	00 
 20f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 216:	e8 b4 04 00 00       	call   6cf <printf>
alarma(20,periodico);
 21b:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
 222:	00 
 223:	c7 04 24 14 00 00 00 	movl   $0x14,(%esp)
 22a:	e8 99 03 00 00       	call   5c8 <alarma>
for(i=0; i<50*200000;i++){
 22f:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
 236:	00 
 237:	eb 56                	jmp    28f <main+0x92>
	if((i++%200000)==0)
 239:	8b 4c 24 1c          	mov    0x1c(%esp),%ecx
 23d:	ba 89 b5 f8 14       	mov    $0x14f8b589,%edx
 242:	89 c8                	mov    %ecx,%eax
 244:	f7 ea                	imul   %edx
 246:	c1 fa 0e             	sar    $0xe,%edx
 249:	89 c8                	mov    %ecx,%eax
 24b:	c1 f8 1f             	sar    $0x1f,%eax
 24e:	89 d3                	mov    %edx,%ebx
 250:	29 c3                	sub    %eax,%ebx
 252:	89 d8                	mov    %ebx,%eax
 254:	69 c0 40 0d 03 00    	imul   $0x30d40,%eax,%eax
 25a:	89 ca                	mov    %ecx,%edx
 25c:	29 c2                	sub    %eax,%edx
 25e:	89 d0                	mov    %edx,%eax
 260:	85 c0                	test   %eax,%eax
 262:	0f 94 c0             	sete   %al
 265:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 26a:	84 c0                	test   %al,%al
 26c:	74 1c                	je     28a <main+0x8d>
		write(2,".",1);
 26e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 275:	00 
 276:	c7 44 24 04 cc 0c 00 	movl   $0xccc,0x4(%esp)
 27d:	00 
 27e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 285:	e8 be 02 00 00       	call   548 <write>
int main(int argc, char *argv[])
{
int i;
printf(1,"Empezando alarma\n");
alarma(20,periodico);
for(i=0; i<50*200000;i++){
 28a:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 28f:	81 7c 24 1c 7f 96 98 	cmpl   $0x98967f,0x1c(%esp)
 296:	00 
 297:	7e a0                	jle    239 <main+0x3c>
	if((i++%200000)==0)
		write(2,".",1);
}
PIDPadre();
 299:	e8 a4 fd ff ff       	call   42 <PIDPadre>
return 0;
 29e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2a6:	c9                   	leave  
 2a7:	c3                   	ret    

000002a8 <periodico>:

void periodico(void)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	83 ec 18             	sub    $0x18,%esp
printf(1,"alarma!\n");
 2ae:	c7 44 24 04 ce 0c 00 	movl   $0xcce,0x4(%esp)
 2b5:	00 
 2b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bd:	e8 0d 04 00 00       	call   6cf <printf>
}
 2c2:	c9                   	leave  
 2c3:	c3                   	ret    

000002c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2c4:	55                   	push   %ebp
 2c5:	89 e5                	mov    %esp,%ebp
 2c7:	57                   	push   %edi
 2c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2cc:	8b 55 10             	mov    0x10(%ebp),%edx
 2cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d2:	89 cb                	mov    %ecx,%ebx
 2d4:	89 df                	mov    %ebx,%edi
 2d6:	89 d1                	mov    %edx,%ecx
 2d8:	fc                   	cld    
 2d9:	f3 aa                	rep stos %al,%es:(%edi)
 2db:	89 ca                	mov    %ecx,%edx
 2dd:	89 fb                	mov    %edi,%ebx
 2df:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2e5:	5b                   	pop    %ebx
 2e6:	5f                   	pop    %edi
 2e7:	5d                   	pop    %ebp
 2e8:	c3                   	ret    

000002e9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2e9:	55                   	push   %ebp
 2ea:	89 e5                	mov    %esp,%ebp
 2ec:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2f5:	90                   	nop
 2f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f9:	0f b6 10             	movzbl (%eax),%edx
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	88 10                	mov    %dl,(%eax)
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	0f b6 00             	movzbl (%eax),%eax
 307:	84 c0                	test   %al,%al
 309:	0f 95 c0             	setne  %al
 30c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 310:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 314:	84 c0                	test   %al,%al
 316:	75 de                	jne    2f6 <strcpy+0xd>
    ;
  return os;
 318:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31b:	c9                   	leave  
 31c:	c3                   	ret    

0000031d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 31d:	55                   	push   %ebp
 31e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 320:	eb 08                	jmp    32a <strcmp+0xd>
    p++, q++;
 322:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 326:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	84 c0                	test   %al,%al
 332:	74 10                	je     344 <strcmp+0x27>
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	0f b6 10             	movzbl (%eax),%edx
 33a:	8b 45 0c             	mov    0xc(%ebp),%eax
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	38 c2                	cmp    %al,%dl
 342:	74 de                	je     322 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
 347:	0f b6 00             	movzbl (%eax),%eax
 34a:	0f b6 d0             	movzbl %al,%edx
 34d:	8b 45 0c             	mov    0xc(%ebp),%eax
 350:	0f b6 00             	movzbl (%eax),%eax
 353:	0f b6 c0             	movzbl %al,%eax
 356:	89 d1                	mov    %edx,%ecx
 358:	29 c1                	sub    %eax,%ecx
 35a:	89 c8                	mov    %ecx,%eax
}
 35c:	5d                   	pop    %ebp
 35d:	c3                   	ret    

0000035e <strlen>:

uint
strlen(char *s)
{
 35e:	55                   	push   %ebp
 35f:	89 e5                	mov    %esp,%ebp
 361:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 364:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 36b:	eb 04                	jmp    371 <strlen+0x13>
 36d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 371:	8b 45 fc             	mov    -0x4(%ebp),%eax
 374:	03 45 08             	add    0x8(%ebp),%eax
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	84 c0                	test   %al,%al
 37c:	75 ef                	jne    36d <strlen+0xf>
    ;
  return n;
 37e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 381:	c9                   	leave  
 382:	c3                   	ret    

00000383 <memset>:

void*
memset(void *dst, int c, uint n)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 389:	8b 45 10             	mov    0x10(%ebp),%eax
 38c:	89 44 24 08          	mov    %eax,0x8(%esp)
 390:	8b 45 0c             	mov    0xc(%ebp),%eax
 393:	89 44 24 04          	mov    %eax,0x4(%esp)
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	89 04 24             	mov    %eax,(%esp)
 39d:	e8 22 ff ff ff       	call   2c4 <stosb>
  return dst;
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <strchr>:

char*
strchr(const char *s, char c)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	83 ec 04             	sub    $0x4,%esp
 3ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3b3:	eb 14                	jmp    3c9 <strchr+0x22>
    if(*s == c)
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3be:	75 05                	jne    3c5 <strchr+0x1e>
      return (char*)s;
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	eb 13                	jmp    3d8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	84 c0                	test   %al,%al
 3d1:	75 e2                	jne    3b5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3d8:	c9                   	leave  
 3d9:	c3                   	ret    

000003da <gets>:

char*
gets(char *buf, int max)
{
 3da:	55                   	push   %ebp
 3db:	89 e5                	mov    %esp,%ebp
 3dd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3e7:	eb 44                	jmp    42d <gets+0x53>
    cc = read(0, &c, 1);
 3e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3f0:	00 
 3f1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 3f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3ff:	e8 3c 01 00 00       	call   540 <read>
 404:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 40b:	7e 2d                	jle    43a <gets+0x60>
      break;
    buf[i++] = c;
 40d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 410:	03 45 08             	add    0x8(%ebp),%eax
 413:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 417:	88 10                	mov    %dl,(%eax)
 419:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 41d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 421:	3c 0a                	cmp    $0xa,%al
 423:	74 16                	je     43b <gets+0x61>
 425:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 429:	3c 0d                	cmp    $0xd,%al
 42b:	74 0e                	je     43b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 42d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 430:	83 c0 01             	add    $0x1,%eax
 433:	3b 45 0c             	cmp    0xc(%ebp),%eax
 436:	7c b1                	jl     3e9 <gets+0xf>
 438:	eb 01                	jmp    43b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 43a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 43b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43e:	03 45 08             	add    0x8(%ebp),%eax
 441:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 444:	8b 45 08             	mov    0x8(%ebp),%eax
}
 447:	c9                   	leave  
 448:	c3                   	ret    

00000449 <stat>:

int
stat(char *n, struct stat *st)
{
 449:	55                   	push   %ebp
 44a:	89 e5                	mov    %esp,%ebp
 44c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 44f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 456:	00 
 457:	8b 45 08             	mov    0x8(%ebp),%eax
 45a:	89 04 24             	mov    %eax,(%esp)
 45d:	e8 06 01 00 00       	call   568 <open>
 462:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 465:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 469:	79 07                	jns    472 <stat+0x29>
    return -1;
 46b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 470:	eb 23                	jmp    495 <stat+0x4c>
  r = fstat(fd, st);
 472:	8b 45 0c             	mov    0xc(%ebp),%eax
 475:	89 44 24 04          	mov    %eax,0x4(%esp)
 479:	8b 45 f4             	mov    -0xc(%ebp),%eax
 47c:	89 04 24             	mov    %eax,(%esp)
 47f:	e8 fc 00 00 00       	call   580 <fstat>
 484:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 487:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48a:	89 04 24             	mov    %eax,(%esp)
 48d:	e8 be 00 00 00       	call   550 <close>
  return r;
 492:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 495:	c9                   	leave  
 496:	c3                   	ret    

00000497 <atoi>:

int
atoi(const char *s)
{
 497:	55                   	push   %ebp
 498:	89 e5                	mov    %esp,%ebp
 49a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 49d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4a4:	eb 23                	jmp    4c9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 4a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4a9:	89 d0                	mov    %edx,%eax
 4ab:	c1 e0 02             	shl    $0x2,%eax
 4ae:	01 d0                	add    %edx,%eax
 4b0:	01 c0                	add    %eax,%eax
 4b2:	89 c2                	mov    %eax,%edx
 4b4:	8b 45 08             	mov    0x8(%ebp),%eax
 4b7:	0f b6 00             	movzbl (%eax),%eax
 4ba:	0f be c0             	movsbl %al,%eax
 4bd:	01 d0                	add    %edx,%eax
 4bf:	83 e8 30             	sub    $0x30,%eax
 4c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 4c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	0f b6 00             	movzbl (%eax),%eax
 4cf:	3c 2f                	cmp    $0x2f,%al
 4d1:	7e 0a                	jle    4dd <atoi+0x46>
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	0f b6 00             	movzbl (%eax),%eax
 4d9:	3c 39                	cmp    $0x39,%al
 4db:	7e c9                	jle    4a6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 4dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4e0:	c9                   	leave  
 4e1:	c3                   	ret    

000004e2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4e2:	55                   	push   %ebp
 4e3:	89 e5                	mov    %esp,%ebp
 4e5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
 4eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4f4:	eb 13                	jmp    509 <memmove+0x27>
    *dst++ = *src++;
 4f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4f9:	0f b6 10             	movzbl (%eax),%edx
 4fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4ff:	88 10                	mov    %dl,(%eax)
 501:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 505:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 509:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 50d:	0f 9f c0             	setg   %al
 510:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 514:	84 c0                	test   %al,%al
 516:	75 de                	jne    4f6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 518:	8b 45 08             	mov    0x8(%ebp),%eax
}
 51b:	c9                   	leave  
 51c:	c3                   	ret    
 51d:	90                   	nop
 51e:	90                   	nop
 51f:	90                   	nop

00000520 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 520:	b8 01 00 00 00       	mov    $0x1,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <exit>:
SYSCALL(exit)
 528:	b8 02 00 00 00       	mov    $0x2,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <wait>:
SYSCALL(wait)
 530:	b8 03 00 00 00       	mov    $0x3,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <pipe>:
SYSCALL(pipe)
 538:	b8 04 00 00 00       	mov    $0x4,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <read>:
SYSCALL(read)
 540:	b8 05 00 00 00       	mov    $0x5,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <write>:
SYSCALL(write)
 548:	b8 10 00 00 00       	mov    $0x10,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <close>:
SYSCALL(close)
 550:	b8 15 00 00 00       	mov    $0x15,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <kill>:
SYSCALL(kill)
 558:	b8 06 00 00 00       	mov    $0x6,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <exec>:
SYSCALL(exec)
 560:	b8 07 00 00 00       	mov    $0x7,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <open>:
SYSCALL(open)
 568:	b8 0f 00 00 00       	mov    $0xf,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <mknod>:
SYSCALL(mknod)
 570:	b8 11 00 00 00       	mov    $0x11,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <unlink>:
SYSCALL(unlink)
 578:	b8 12 00 00 00       	mov    $0x12,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <fstat>:
SYSCALL(fstat)
 580:	b8 08 00 00 00       	mov    $0x8,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <link>:
SYSCALL(link)
 588:	b8 13 00 00 00       	mov    $0x13,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <mkdir>:
SYSCALL(mkdir)
 590:	b8 14 00 00 00       	mov    $0x14,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <chdir>:
SYSCALL(chdir)
 598:	b8 09 00 00 00       	mov    $0x9,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <dup>:
SYSCALL(dup)
 5a0:	b8 0a 00 00 00       	mov    $0xa,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <getpid>:
SYSCALL(getpid)
 5a8:	b8 0b 00 00 00       	mov    $0xb,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <sbrk>:
SYSCALL(sbrk)
 5b0:	b8 0c 00 00 00       	mov    $0xc,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <sleep>:
SYSCALL(sleep)
 5b8:	b8 0d 00 00 00       	mov    $0xd,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <uptime>:
SYSCALL(uptime)
 5c0:	b8 0e 00 00 00       	mov    $0xe,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <alarma>:
SYSCALL(alarma)
 5c8:	b8 16 00 00 00       	mov    $0x16,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <info>:
SYSCALL(info)
 5d0:	b8 17 00 00 00       	mov    $0x17,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <estado>:
SYSCALL(estado)
 5d8:	b8 18 00 00 00       	mov    $0x18,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <size>:
SYSCALL(size)
 5e0:	b8 19 00 00 00       	mov    $0x19,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <estadohijo>:
SYSCALL(estadohijo)
 5e8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <doge>:
SYSCALL(doge)
 5f0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5f8:	55                   	push   %ebp
 5f9:	89 e5                	mov    %esp,%ebp
 5fb:	83 ec 28             	sub    $0x28,%esp
 5fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 601:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 604:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 60b:	00 
 60c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 60f:	89 44 24 04          	mov    %eax,0x4(%esp)
 613:	8b 45 08             	mov    0x8(%ebp),%eax
 616:	89 04 24             	mov    %eax,(%esp)
 619:	e8 2a ff ff ff       	call   548 <write>
}
 61e:	c9                   	leave  
 61f:	c3                   	ret    

00000620 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 620:	55                   	push   %ebp
 621:	89 e5                	mov    %esp,%ebp
 623:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 626:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 62d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 631:	74 17                	je     64a <printint+0x2a>
 633:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 637:	79 11                	jns    64a <printint+0x2a>
    neg = 1;
 639:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 640:	8b 45 0c             	mov    0xc(%ebp),%eax
 643:	f7 d8                	neg    %eax
 645:	89 45 ec             	mov    %eax,-0x14(%ebp)
 648:	eb 06                	jmp    650 <printint+0x30>
  } else {
    x = xx;
 64a:	8b 45 0c             	mov    0xc(%ebp),%eax
 64d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 650:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 657:	8b 4d 10             	mov    0x10(%ebp),%ecx
 65a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 65d:	ba 00 00 00 00       	mov    $0x0,%edx
 662:	f7 f1                	div    %ecx
 664:	89 d0                	mov    %edx,%eax
 666:	0f b6 90 a8 0f 00 00 	movzbl 0xfa8(%eax),%edx
 66d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 670:	03 45 f4             	add    -0xc(%ebp),%eax
 673:	88 10                	mov    %dl,(%eax)
 675:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 679:	8b 55 10             	mov    0x10(%ebp),%edx
 67c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 67f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 682:	ba 00 00 00 00       	mov    $0x0,%edx
 687:	f7 75 d4             	divl   -0x2c(%ebp)
 68a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 68d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 691:	75 c4                	jne    657 <printint+0x37>
  if(neg)
 693:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 697:	74 2a                	je     6c3 <printint+0xa3>
    buf[i++] = '-';
 699:	8d 45 dc             	lea    -0x24(%ebp),%eax
 69c:	03 45 f4             	add    -0xc(%ebp),%eax
 69f:	c6 00 2d             	movb   $0x2d,(%eax)
 6a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6a6:	eb 1b                	jmp    6c3 <printint+0xa3>
    putc(fd, buf[i]);
 6a8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6ab:	03 45 f4             	add    -0xc(%ebp),%eax
 6ae:	0f b6 00             	movzbl (%eax),%eax
 6b1:	0f be c0             	movsbl %al,%eax
 6b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b8:	8b 45 08             	mov    0x8(%ebp),%eax
 6bb:	89 04 24             	mov    %eax,(%esp)
 6be:	e8 35 ff ff ff       	call   5f8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6c3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6cb:	79 db                	jns    6a8 <printint+0x88>
    putc(fd, buf[i]);
}
 6cd:	c9                   	leave  
 6ce:	c3                   	ret    

000006cf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6cf:	55                   	push   %ebp
 6d0:	89 e5                	mov    %esp,%ebp
 6d2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6dc:	8d 45 0c             	lea    0xc(%ebp),%eax
 6df:	83 c0 04             	add    $0x4,%eax
 6e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ec:	e9 7d 01 00 00       	jmp    86e <printf+0x19f>
    c = fmt[i] & 0xff;
 6f1:	8b 55 0c             	mov    0xc(%ebp),%edx
 6f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f7:	01 d0                	add    %edx,%eax
 6f9:	0f b6 00             	movzbl (%eax),%eax
 6fc:	0f be c0             	movsbl %al,%eax
 6ff:	25 ff 00 00 00       	and    $0xff,%eax
 704:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 707:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70b:	75 2c                	jne    739 <printf+0x6a>
      if(c == '%'){
 70d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 711:	75 0c                	jne    71f <printf+0x50>
        state = '%';
 713:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 71a:	e9 4b 01 00 00       	jmp    86a <printf+0x19b>
      } else {
        putc(fd, c);
 71f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 722:	0f be c0             	movsbl %al,%eax
 725:	89 44 24 04          	mov    %eax,0x4(%esp)
 729:	8b 45 08             	mov    0x8(%ebp),%eax
 72c:	89 04 24             	mov    %eax,(%esp)
 72f:	e8 c4 fe ff ff       	call   5f8 <putc>
 734:	e9 31 01 00 00       	jmp    86a <printf+0x19b>
      }
    } else if(state == '%'){
 739:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 73d:	0f 85 27 01 00 00    	jne    86a <printf+0x19b>
      if(c == 'd'){
 743:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 747:	75 2d                	jne    776 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 749:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 755:	00 
 756:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 75d:	00 
 75e:	89 44 24 04          	mov    %eax,0x4(%esp)
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	89 04 24             	mov    %eax,(%esp)
 768:	e8 b3 fe ff ff       	call   620 <printint>
        ap++;
 76d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 771:	e9 ed 00 00 00       	jmp    863 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 776:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 77a:	74 06                	je     782 <printf+0xb3>
 77c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 780:	75 2d                	jne    7af <printf+0xe0>
        printint(fd, *ap, 16, 0);
 782:	8b 45 e8             	mov    -0x18(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 78e:	00 
 78f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 796:	00 
 797:	89 44 24 04          	mov    %eax,0x4(%esp)
 79b:	8b 45 08             	mov    0x8(%ebp),%eax
 79e:	89 04 24             	mov    %eax,(%esp)
 7a1:	e8 7a fe ff ff       	call   620 <printint>
        ap++;
 7a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7aa:	e9 b4 00 00 00       	jmp    863 <printf+0x194>
      } else if(c == 's'){
 7af:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7b3:	75 46                	jne    7fb <printf+0x12c>
        s = (char*)*ap;
 7b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b8:	8b 00                	mov    (%eax),%eax
 7ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7bd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c5:	75 27                	jne    7ee <printf+0x11f>
          s = "(null)";
 7c7:	c7 45 f4 d7 0c 00 00 	movl   $0xcd7,-0xc(%ebp)
        while(*s != 0){
 7ce:	eb 1e                	jmp    7ee <printf+0x11f>
          putc(fd, *s);
 7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d3:	0f b6 00             	movzbl (%eax),%eax
 7d6:	0f be c0             	movsbl %al,%eax
 7d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7dd:	8b 45 08             	mov    0x8(%ebp),%eax
 7e0:	89 04 24             	mov    %eax,(%esp)
 7e3:	e8 10 fe ff ff       	call   5f8 <putc>
          s++;
 7e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 7ec:	eb 01                	jmp    7ef <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7ee:	90                   	nop
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	0f b6 00             	movzbl (%eax),%eax
 7f5:	84 c0                	test   %al,%al
 7f7:	75 d7                	jne    7d0 <printf+0x101>
 7f9:	eb 68                	jmp    863 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7fb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7ff:	75 1d                	jne    81e <printf+0x14f>
        putc(fd, *ap);
 801:	8b 45 e8             	mov    -0x18(%ebp),%eax
 804:	8b 00                	mov    (%eax),%eax
 806:	0f be c0             	movsbl %al,%eax
 809:	89 44 24 04          	mov    %eax,0x4(%esp)
 80d:	8b 45 08             	mov    0x8(%ebp),%eax
 810:	89 04 24             	mov    %eax,(%esp)
 813:	e8 e0 fd ff ff       	call   5f8 <putc>
        ap++;
 818:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 81c:	eb 45                	jmp    863 <printf+0x194>
      } else if(c == '%'){
 81e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 822:	75 17                	jne    83b <printf+0x16c>
        putc(fd, c);
 824:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 827:	0f be c0             	movsbl %al,%eax
 82a:	89 44 24 04          	mov    %eax,0x4(%esp)
 82e:	8b 45 08             	mov    0x8(%ebp),%eax
 831:	89 04 24             	mov    %eax,(%esp)
 834:	e8 bf fd ff ff       	call   5f8 <putc>
 839:	eb 28                	jmp    863 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 83b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 842:	00 
 843:	8b 45 08             	mov    0x8(%ebp),%eax
 846:	89 04 24             	mov    %eax,(%esp)
 849:	e8 aa fd ff ff       	call   5f8 <putc>
        putc(fd, c);
 84e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 851:	0f be c0             	movsbl %al,%eax
 854:	89 44 24 04          	mov    %eax,0x4(%esp)
 858:	8b 45 08             	mov    0x8(%ebp),%eax
 85b:	89 04 24             	mov    %eax,(%esp)
 85e:	e8 95 fd ff ff       	call   5f8 <putc>
      }
      state = 0;
 863:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 86a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 86e:	8b 55 0c             	mov    0xc(%ebp),%edx
 871:	8b 45 f0             	mov    -0x10(%ebp),%eax
 874:	01 d0                	add    %edx,%eax
 876:	0f b6 00             	movzbl (%eax),%eax
 879:	84 c0                	test   %al,%al
 87b:	0f 85 70 fe ff ff    	jne    6f1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 881:	c9                   	leave  
 882:	c3                   	ret    
 883:	90                   	nop

00000884 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 884:	55                   	push   %ebp
 885:	89 e5                	mov    %esp,%ebp
 887:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88a:	8b 45 08             	mov    0x8(%ebp),%eax
 88d:	83 e8 08             	sub    $0x8,%eax
 890:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 893:	a1 c8 0f 00 00       	mov    0xfc8,%eax
 898:	89 45 fc             	mov    %eax,-0x4(%ebp)
 89b:	eb 24                	jmp    8c1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	8b 00                	mov    (%eax),%eax
 8a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a5:	77 12                	ja     8b9 <free+0x35>
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ad:	77 24                	ja     8d3 <free+0x4f>
 8af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b2:	8b 00                	mov    (%eax),%eax
 8b4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8b7:	77 1a                	ja     8d3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	8b 00                	mov    (%eax),%eax
 8be:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c7:	76 d4                	jbe    89d <free+0x19>
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8d1:	76 ca                	jbe    89d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d6:	8b 40 04             	mov    0x4(%eax),%eax
 8d9:	c1 e0 03             	shl    $0x3,%eax
 8dc:	89 c2                	mov    %eax,%edx
 8de:	03 55 f8             	add    -0x8(%ebp),%edx
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	39 c2                	cmp    %eax,%edx
 8e8:	75 24                	jne    90e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 8ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ed:	8b 50 04             	mov    0x4(%eax),%edx
 8f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f3:	8b 00                	mov    (%eax),%eax
 8f5:	8b 40 04             	mov    0x4(%eax),%eax
 8f8:	01 c2                	add    %eax,%edx
 8fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 900:	8b 45 fc             	mov    -0x4(%ebp),%eax
 903:	8b 00                	mov    (%eax),%eax
 905:	8b 10                	mov    (%eax),%edx
 907:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90a:	89 10                	mov    %edx,(%eax)
 90c:	eb 0a                	jmp    918 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 90e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 911:	8b 10                	mov    (%eax),%edx
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 40 04             	mov    0x4(%eax),%eax
 91e:	c1 e0 03             	shl    $0x3,%eax
 921:	03 45 fc             	add    -0x4(%ebp),%eax
 924:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 927:	75 20                	jne    949 <free+0xc5>
    p->s.size += bp->s.size;
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 50 04             	mov    0x4(%eax),%edx
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	8b 40 04             	mov    0x4(%eax),%eax
 935:	01 c2                	add    %eax,%edx
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	8b 10                	mov    (%eax),%edx
 942:	8b 45 fc             	mov    -0x4(%ebp),%eax
 945:	89 10                	mov    %edx,(%eax)
 947:	eb 08                	jmp    951 <free+0xcd>
  } else
    p->s.ptr = bp;
 949:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 94f:	89 10                	mov    %edx,(%eax)
  freep = p;
 951:	8b 45 fc             	mov    -0x4(%ebp),%eax
 954:	a3 c8 0f 00 00       	mov    %eax,0xfc8
}
 959:	c9                   	leave  
 95a:	c3                   	ret    

0000095b <morecore>:

static Header*
morecore(uint nu)
{
 95b:	55                   	push   %ebp
 95c:	89 e5                	mov    %esp,%ebp
 95e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 961:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 968:	77 07                	ja     971 <morecore+0x16>
    nu = 4096;
 96a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 971:	8b 45 08             	mov    0x8(%ebp),%eax
 974:	c1 e0 03             	shl    $0x3,%eax
 977:	89 04 24             	mov    %eax,(%esp)
 97a:	e8 31 fc ff ff       	call   5b0 <sbrk>
 97f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 982:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 986:	75 07                	jne    98f <morecore+0x34>
    return 0;
 988:	b8 00 00 00 00       	mov    $0x0,%eax
 98d:	eb 22                	jmp    9b1 <morecore+0x56>
  hp = (Header*)p;
 98f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 992:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 995:	8b 45 f0             	mov    -0x10(%ebp),%eax
 998:	8b 55 08             	mov    0x8(%ebp),%edx
 99b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 99e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a1:	83 c0 08             	add    $0x8,%eax
 9a4:	89 04 24             	mov    %eax,(%esp)
 9a7:	e8 d8 fe ff ff       	call   884 <free>
  return freep;
 9ac:	a1 c8 0f 00 00       	mov    0xfc8,%eax
}
 9b1:	c9                   	leave  
 9b2:	c3                   	ret    

000009b3 <malloc>:

void*
malloc(uint nbytes)
{
 9b3:	55                   	push   %ebp
 9b4:	89 e5                	mov    %esp,%ebp
 9b6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b9:	8b 45 08             	mov    0x8(%ebp),%eax
 9bc:	83 c0 07             	add    $0x7,%eax
 9bf:	c1 e8 03             	shr    $0x3,%eax
 9c2:	83 c0 01             	add    $0x1,%eax
 9c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9c8:	a1 c8 0f 00 00       	mov    0xfc8,%eax
 9cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9d4:	75 23                	jne    9f9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9d6:	c7 45 f0 c0 0f 00 00 	movl   $0xfc0,-0x10(%ebp)
 9dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e0:	a3 c8 0f 00 00       	mov    %eax,0xfc8
 9e5:	a1 c8 0f 00 00       	mov    0xfc8,%eax
 9ea:	a3 c0 0f 00 00       	mov    %eax,0xfc0
    base.s.size = 0;
 9ef:	c7 05 c4 0f 00 00 00 	movl   $0x0,0xfc4
 9f6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fc:	8b 00                	mov    (%eax),%eax
 9fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a04:	8b 40 04             	mov    0x4(%eax),%eax
 a07:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a0a:	72 4d                	jb     a59 <malloc+0xa6>
      if(p->s.size == nunits)
 a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0f:	8b 40 04             	mov    0x4(%eax),%eax
 a12:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a15:	75 0c                	jne    a23 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1a:	8b 10                	mov    (%eax),%edx
 a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1f:	89 10                	mov    %edx,(%eax)
 a21:	eb 26                	jmp    a49 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	8b 40 04             	mov    0x4(%eax),%eax
 a29:	89 c2                	mov    %eax,%edx
 a2b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a31:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a37:	8b 40 04             	mov    0x4(%eax),%eax
 a3a:	c1 e0 03             	shl    $0x3,%eax
 a3d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a43:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a46:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a4c:	a3 c8 0f 00 00       	mov    %eax,0xfc8
      return (void*)(p + 1);
 a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a54:	83 c0 08             	add    $0x8,%eax
 a57:	eb 38                	jmp    a91 <malloc+0xde>
    }
    if(p == freep)
 a59:	a1 c8 0f 00 00       	mov    0xfc8,%eax
 a5e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a61:	75 1b                	jne    a7e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a63:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a66:	89 04 24             	mov    %eax,(%esp)
 a69:	e8 ed fe ff ff       	call   95b <morecore>
 a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a75:	75 07                	jne    a7e <malloc+0xcb>
        return 0;
 a77:	b8 00 00 00 00       	mov    $0x0,%eax
 a7c:	eb 13                	jmp    a91 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a87:	8b 00                	mov    (%eax),%eax
 a89:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a8c:	e9 70 ff ff ff       	jmp    a01 <malloc+0x4e>
}
 a91:	c9                   	leave  
 a92:	c3                   	ret    
