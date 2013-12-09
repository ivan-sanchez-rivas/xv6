
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <getppid>:
#include "user.h"
#include "syscall.h"
#include "traps.h"

int getppid(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
int ppid;
asm volatile("int %1":"=a"(ppid):"i"(T_SYSCALL), "a"(SYS_info));
   7:	c7 45 e8 17 00 00 00 	movl   $0x17,-0x18(%ebp)
   e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  11:	cd 40                	int    $0x40
  13:	89 c3                	mov    %eax,%ebx
  15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
return ppid;
  18:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1b:	83 c4 14             	add    $0x14,%esp
  1e:	5b                   	pop    %ebx
  1f:	5d                   	pop    %ebp
  20:	c3                   	ret    

00000021 <getestado>:
int getestado(void)
{
  21:	55                   	push   %ebp
  22:	89 e5                	mov    %esp,%ebp
  24:	53                   	push   %ebx
  25:	83 ec 14             	sub    $0x14,%esp
int estado;
asm volatile("int %1":"=a"(estado):"i"(T_SYSCALL), "a"(SYS_estado));
  28:	c7 45 e8 18 00 00 00 	movl   $0x18,-0x18(%ebp)
  2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  32:	cd 40                	int    $0x40
  34:	89 c3                	mov    %eax,%ebx
  36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
return estado;
  39:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  3c:	83 c4 14             	add    $0x14,%esp
  3f:	5b                   	pop    %ebx
  40:	5d                   	pop    %ebp
  41:	c3                   	ret    

00000042 <getsize>:
int getsize(void)
{
  42:	55                   	push   %ebp
  43:	89 e5                	mov    %esp,%ebp
  45:	53                   	push   %ebx
  46:	83 ec 14             	sub    $0x14,%esp
int size;
asm volatile("int %1":"=a"(size):"i"(T_SYSCALL), "a"(SYS_size));
  49:	c7 45 e8 19 00 00 00 	movl   $0x19,-0x18(%ebp)
  50:	8b 45 e8             	mov    -0x18(%ebp),%eax
  53:	cd 40                	int    $0x40
  55:	89 c3                	mov    %eax,%ebx
  57:	89 5d f8             	mov    %ebx,-0x8(%ebp)
return size;
  5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  5d:	83 c4 14             	add    $0x14,%esp
  60:	5b                   	pop    %ebx
  61:	5d                   	pop    %ebp
  62:	c3                   	ret    

00000063 <main>:
int main(int argc, char **argv)
{
  63:	55                   	push   %ebp
  64:	89 e5                	mov    %esp,%ebp
  66:	53                   	push   %ebx
  67:	83 e4 f0             	and    $0xfffffff0,%esp
  6a:	83 ec 30             	sub    $0x30,%esp
int childpid = fork();
  6d:	e8 16 04 00 00       	call   488 <fork>
  72:	89 44 24 2c          	mov    %eax,0x2c(%esp)
if(childpid<0)
  76:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
  7b:	79 21                	jns    9e <main+0x3b>
	printf(1,"Fork fallo %d\n",childpid);
  7d:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  81:	89 44 24 08          	mov    %eax,0x8(%esp)
  85:	c7 44 24 04 fc 09 00 	movl   $0x9fc,0x4(%esp)
  8c:	00 
  8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  94:	e8 9e 05 00 00       	call   637 <printf>
  99:	e9 83 01 00 00       	jmp    221 <main+0x1be>
else if(childpid>0){
  9e:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
  a3:	0f 8e 78 01 00 00    	jle    221 <main+0x1be>
printf(1,"Estadisticas del proceso Padre\n");
  a9:	c7 44 24 04 0c 0a 00 	movl   $0xa0c,0x4(%esp)
  b0:	00 
  b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b8:	e8 7a 05 00 00       	call   637 <printf>
if(getestado()==0)
  bd:	e8 5f ff ff ff       	call   21 <getestado>
  c2:	85 c0                	test   %eax,%eax
  c4:	75 35                	jne    fb <main+0x98>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Unused\nSize del Padre: %d\n",getpid(),childpid,getsize());
  c6:	e8 77 ff ff ff       	call   42 <getsize>
  cb:	89 c3                	mov    %eax,%ebx
  cd:	e8 3e 04 00 00       	call   510 <getpid>
  d2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  d6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  da:	89 54 24 0c          	mov    %edx,0xc(%esp)
  de:	89 44 24 08          	mov    %eax,0x8(%esp)
  e2:	c7 44 24 04 2c 0a 00 	movl   $0xa2c,0x4(%esp)
  e9:	00 
  ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f1:	e8 41 05 00 00       	call   637 <printf>
  f6:	e9 26 01 00 00       	jmp    221 <main+0x1be>

}
else if(getestado()==1)
  fb:	e8 21 ff ff ff       	call   21 <getestado>
 100:	83 f8 01             	cmp    $0x1,%eax
 103:	75 35                	jne    13a <main+0xd7>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Embryo\nSize del Padre: %d\n",getpid(),childpid,getsize());
 105:	e8 38 ff ff ff       	call   42 <getsize>
 10a:	89 c3                	mov    %eax,%ebx
 10c:	e8 ff 03 00 00       	call   510 <getpid>
 111:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 115:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 119:	89 54 24 0c          	mov    %edx,0xc(%esp)
 11d:	89 44 24 08          	mov    %eax,0x8(%esp)
 121:	c7 44 24 04 80 0a 00 	movl   $0xa80,0x4(%esp)
 128:	00 
 129:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 130:	e8 02 05 00 00       	call   637 <printf>
 135:	e9 e7 00 00 00       	jmp    221 <main+0x1be>
}	
else if(getestado()==2)
 13a:	e8 e2 fe ff ff       	call   21 <getestado>
 13f:	83 f8 02             	cmp    $0x2,%eax
 142:	75 35                	jne    179 <main+0x116>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Sleep\nSize del Padre: %d\n",getpid(),childpid,getsize());
 144:	e8 f9 fe ff ff       	call   42 <getsize>
 149:	89 c3                	mov    %eax,%ebx
 14b:	e8 c0 03 00 00       	call   510 <getpid>
 150:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 154:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 158:	89 54 24 0c          	mov    %edx,0xc(%esp)
 15c:	89 44 24 08          	mov    %eax,0x8(%esp)
 160:	c7 44 24 04 d4 0a 00 	movl   $0xad4,0x4(%esp)
 167:	00 
 168:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 16f:	e8 c3 04 00 00       	call   637 <printf>
 174:	e9 a8 00 00 00       	jmp    221 <main+0x1be>
}
else if(getestado()==3)
 179:	e8 a3 fe ff ff       	call   21 <getestado>
 17e:	83 f8 03             	cmp    $0x3,%eax
 181:	75 32                	jne    1b5 <main+0x152>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Runnable\nSize del Padre: %d\n",getpid(),childpid,getsize());
 183:	e8 ba fe ff ff       	call   42 <getsize>
 188:	89 c3                	mov    %eax,%ebx
 18a:	e8 81 03 00 00       	call   510 <getpid>
 18f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 193:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 197:	89 54 24 0c          	mov    %edx,0xc(%esp)
 19b:	89 44 24 08          	mov    %eax,0x8(%esp)
 19f:	c7 44 24 04 28 0b 00 	movl   $0xb28,0x4(%esp)
 1a6:	00 
 1a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ae:	e8 84 04 00 00       	call   637 <printf>
 1b3:	eb 6c                	jmp    221 <main+0x1be>
}
else if(getestado()==4)
 1b5:	e8 67 fe ff ff       	call   21 <getestado>
 1ba:	83 f8 04             	cmp    $0x4,%eax
 1bd:	75 32                	jne    1f1 <main+0x18e>
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Running\nSize del Padre: %d\n",getpid(),childpid,getsize());
 1bf:	e8 7e fe ff ff       	call   42 <getsize>
 1c4:	89 c3                	mov    %eax,%ebx
 1c6:	e8 45 03 00 00       	call   510 <getpid>
 1cb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 1cf:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 1d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
 1d7:	89 44 24 08          	mov    %eax,0x8(%esp)
 1db:	c7 44 24 04 7c 0b 00 	movl   $0xb7c,0x4(%esp)
 1e2:	00 
 1e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ea:	e8 48 04 00 00       	call   637 <printf>
 1ef:	eb 30                	jmp    221 <main+0x1be>
}
else
{
	printf(1,"PID del padre es: %d\nPID del hijo es: %d\nEstado Padre: Zombie\nSize del Padre: %d\n",getpid(),childpid,getsize());
 1f1:	e8 4c fe ff ff       	call   42 <getsize>
 1f6:	89 c3                	mov    %eax,%ebx
 1f8:	e8 13 03 00 00       	call   510 <getpid>
 1fd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
 201:	8b 54 24 2c          	mov    0x2c(%esp),%edx
 205:	89 54 24 0c          	mov    %edx,0xc(%esp)
 209:	89 44 24 08          	mov    %eax,0x8(%esp)
 20d:	c7 44 24 04 d0 0b 00 	movl   $0xbd0,0x4(%esp)
 214:	00 
 215:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 21c:	e8 16 04 00 00       	call   637 <printf>
}
}
wait();
 221:	e8 72 02 00 00       	call   498 <wait>
exit();
 226:	e8 65 02 00 00       	call   490 <exit>
 22b:	90                   	nop

0000022c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	57                   	push   %edi
 230:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 231:	8b 4d 08             	mov    0x8(%ebp),%ecx
 234:	8b 55 10             	mov    0x10(%ebp),%edx
 237:	8b 45 0c             	mov    0xc(%ebp),%eax
 23a:	89 cb                	mov    %ecx,%ebx
 23c:	89 df                	mov    %ebx,%edi
 23e:	89 d1                	mov    %edx,%ecx
 240:	fc                   	cld    
 241:	f3 aa                	rep stos %al,%es:(%edi)
 243:	89 ca                	mov    %ecx,%edx
 245:	89 fb                	mov    %edi,%ebx
 247:	89 5d 08             	mov    %ebx,0x8(%ebp)
 24a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 24d:	5b                   	pop    %ebx
 24e:	5f                   	pop    %edi
 24f:	5d                   	pop    %ebp
 250:	c3                   	ret    

00000251 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 257:	8b 45 08             	mov    0x8(%ebp),%eax
 25a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 25d:	90                   	nop
 25e:	8b 45 0c             	mov    0xc(%ebp),%eax
 261:	0f b6 10             	movzbl (%eax),%edx
 264:	8b 45 08             	mov    0x8(%ebp),%eax
 267:	88 10                	mov    %dl,(%eax)
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	0f b6 00             	movzbl (%eax),%eax
 26f:	84 c0                	test   %al,%al
 271:	0f 95 c0             	setne  %al
 274:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 278:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 27c:	84 c0                	test   %al,%al
 27e:	75 de                	jne    25e <strcpy+0xd>
    ;
  return os;
 280:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 283:	c9                   	leave  
 284:	c3                   	ret    

00000285 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 285:	55                   	push   %ebp
 286:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 288:	eb 08                	jmp    292 <strcmp+0xd>
    p++, q++;
 28a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 28e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	0f b6 00             	movzbl (%eax),%eax
 298:	84 c0                	test   %al,%al
 29a:	74 10                	je     2ac <strcmp+0x27>
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	0f b6 10             	movzbl (%eax),%edx
 2a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a5:	0f b6 00             	movzbl (%eax),%eax
 2a8:	38 c2                	cmp    %al,%dl
 2aa:	74 de                	je     28a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	0f b6 00             	movzbl (%eax),%eax
 2b2:	0f b6 d0             	movzbl %al,%edx
 2b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	0f b6 c0             	movzbl %al,%eax
 2be:	89 d1                	mov    %edx,%ecx
 2c0:	29 c1                	sub    %eax,%ecx
 2c2:	89 c8                	mov    %ecx,%eax
}
 2c4:	5d                   	pop    %ebp
 2c5:	c3                   	ret    

000002c6 <strlen>:

uint
strlen(char *s)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2d3:	eb 04                	jmp    2d9 <strlen+0x13>
 2d5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2dc:	03 45 08             	add    0x8(%ebp),%eax
 2df:	0f b6 00             	movzbl (%eax),%eax
 2e2:	84 c0                	test   %al,%al
 2e4:	75 ef                	jne    2d5 <strlen+0xf>
    ;
  return n;
 2e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2e9:	c9                   	leave  
 2ea:	c3                   	ret    

000002eb <memset>:

void*
memset(void *dst, int c, uint n)
{
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2f1:	8b 45 10             	mov    0x10(%ebp),%eax
 2f4:	89 44 24 08          	mov    %eax,0x8(%esp)
 2f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	89 04 24             	mov    %eax,(%esp)
 305:	e8 22 ff ff ff       	call   22c <stosb>
  return dst;
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 30d:	c9                   	leave  
 30e:	c3                   	ret    

0000030f <strchr>:

char*
strchr(const char *s, char c)
{
 30f:	55                   	push   %ebp
 310:	89 e5                	mov    %esp,%ebp
 312:	83 ec 04             	sub    $0x4,%esp
 315:	8b 45 0c             	mov    0xc(%ebp),%eax
 318:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 31b:	eb 14                	jmp    331 <strchr+0x22>
    if(*s == c)
 31d:	8b 45 08             	mov    0x8(%ebp),%eax
 320:	0f b6 00             	movzbl (%eax),%eax
 323:	3a 45 fc             	cmp    -0x4(%ebp),%al
 326:	75 05                	jne    32d <strchr+0x1e>
      return (char*)s;
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	eb 13                	jmp    340 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 32d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 331:	8b 45 08             	mov    0x8(%ebp),%eax
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	84 c0                	test   %al,%al
 339:	75 e2                	jne    31d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 33b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 340:	c9                   	leave  
 341:	c3                   	ret    

00000342 <gets>:

char*
gets(char *buf, int max)
{
 342:	55                   	push   %ebp
 343:	89 e5                	mov    %esp,%ebp
 345:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 34f:	eb 44                	jmp    395 <gets+0x53>
    cc = read(0, &c, 1);
 351:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 358:	00 
 359:	8d 45 ef             	lea    -0x11(%ebp),%eax
 35c:	89 44 24 04          	mov    %eax,0x4(%esp)
 360:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 367:	e8 3c 01 00 00       	call   4a8 <read>
 36c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 36f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 373:	7e 2d                	jle    3a2 <gets+0x60>
      break;
    buf[i++] = c;
 375:	8b 45 f4             	mov    -0xc(%ebp),%eax
 378:	03 45 08             	add    0x8(%ebp),%eax
 37b:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 37f:	88 10                	mov    %dl,(%eax)
 381:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 385:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 389:	3c 0a                	cmp    $0xa,%al
 38b:	74 16                	je     3a3 <gets+0x61>
 38d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 391:	3c 0d                	cmp    $0xd,%al
 393:	74 0e                	je     3a3 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 395:	8b 45 f4             	mov    -0xc(%ebp),%eax
 398:	83 c0 01             	add    $0x1,%eax
 39b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 39e:	7c b1                	jl     351 <gets+0xf>
 3a0:	eb 01                	jmp    3a3 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3a2:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a6:	03 45 08             	add    0x8(%ebp),%eax
 3a9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3af:	c9                   	leave  
 3b0:	c3                   	ret    

000003b1 <stat>:

int
stat(char *n, struct stat *st)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 3be:	00 
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	89 04 24             	mov    %eax,(%esp)
 3c5:	e8 06 01 00 00       	call   4d0 <open>
 3ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3d1:	79 07                	jns    3da <stat+0x29>
    return -1;
 3d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3d8:	eb 23                	jmp    3fd <stat+0x4c>
  r = fstat(fd, st);
 3da:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e4:	89 04 24             	mov    %eax,(%esp)
 3e7:	e8 fc 00 00 00       	call   4e8 <fstat>
 3ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f2:	89 04 24             	mov    %eax,(%esp)
 3f5:	e8 be 00 00 00       	call   4b8 <close>
  return r;
 3fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3fd:	c9                   	leave  
 3fe:	c3                   	ret    

000003ff <atoi>:

int
atoi(const char *s)
{
 3ff:	55                   	push   %ebp
 400:	89 e5                	mov    %esp,%ebp
 402:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 405:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 40c:	eb 23                	jmp    431 <atoi+0x32>
    n = n*10 + *s++ - '0';
 40e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 411:	89 d0                	mov    %edx,%eax
 413:	c1 e0 02             	shl    $0x2,%eax
 416:	01 d0                	add    %edx,%eax
 418:	01 c0                	add    %eax,%eax
 41a:	89 c2                	mov    %eax,%edx
 41c:	8b 45 08             	mov    0x8(%ebp),%eax
 41f:	0f b6 00             	movzbl (%eax),%eax
 422:	0f be c0             	movsbl %al,%eax
 425:	01 d0                	add    %edx,%eax
 427:	83 e8 30             	sub    $0x30,%eax
 42a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 42d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	0f b6 00             	movzbl (%eax),%eax
 437:	3c 2f                	cmp    $0x2f,%al
 439:	7e 0a                	jle    445 <atoi+0x46>
 43b:	8b 45 08             	mov    0x8(%ebp),%eax
 43e:	0f b6 00             	movzbl (%eax),%eax
 441:	3c 39                	cmp    $0x39,%al
 443:	7e c9                	jle    40e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 445:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 448:	c9                   	leave  
 449:	c3                   	ret    

0000044a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 44a:	55                   	push   %ebp
 44b:	89 e5                	mov    %esp,%ebp
 44d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 456:	8b 45 0c             	mov    0xc(%ebp),%eax
 459:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 45c:	eb 13                	jmp    471 <memmove+0x27>
    *dst++ = *src++;
 45e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 461:	0f b6 10             	movzbl (%eax),%edx
 464:	8b 45 fc             	mov    -0x4(%ebp),%eax
 467:	88 10                	mov    %dl,(%eax)
 469:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 46d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 471:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 475:	0f 9f c0             	setg   %al
 478:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 47c:	84 c0                	test   %al,%al
 47e:	75 de                	jne    45e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 480:	8b 45 08             	mov    0x8(%ebp),%eax
}
 483:	c9                   	leave  
 484:	c3                   	ret    
 485:	90                   	nop
 486:	90                   	nop
 487:	90                   	nop

00000488 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 488:	b8 01 00 00 00       	mov    $0x1,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <exit>:
SYSCALL(exit)
 490:	b8 02 00 00 00       	mov    $0x2,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <wait>:
SYSCALL(wait)
 498:	b8 03 00 00 00       	mov    $0x3,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <pipe>:
SYSCALL(pipe)
 4a0:	b8 04 00 00 00       	mov    $0x4,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <read>:
SYSCALL(read)
 4a8:	b8 05 00 00 00       	mov    $0x5,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <write>:
SYSCALL(write)
 4b0:	b8 10 00 00 00       	mov    $0x10,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <close>:
SYSCALL(close)
 4b8:	b8 15 00 00 00       	mov    $0x15,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <kill>:
SYSCALL(kill)
 4c0:	b8 06 00 00 00       	mov    $0x6,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <exec>:
SYSCALL(exec)
 4c8:	b8 07 00 00 00       	mov    $0x7,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <open>:
SYSCALL(open)
 4d0:	b8 0f 00 00 00       	mov    $0xf,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <mknod>:
SYSCALL(mknod)
 4d8:	b8 11 00 00 00       	mov    $0x11,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <unlink>:
SYSCALL(unlink)
 4e0:	b8 12 00 00 00       	mov    $0x12,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <fstat>:
SYSCALL(fstat)
 4e8:	b8 08 00 00 00       	mov    $0x8,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <link>:
SYSCALL(link)
 4f0:	b8 13 00 00 00       	mov    $0x13,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <mkdir>:
SYSCALL(mkdir)
 4f8:	b8 14 00 00 00       	mov    $0x14,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <chdir>:
SYSCALL(chdir)
 500:	b8 09 00 00 00       	mov    $0x9,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <dup>:
SYSCALL(dup)
 508:	b8 0a 00 00 00       	mov    $0xa,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <getpid>:
SYSCALL(getpid)
 510:	b8 0b 00 00 00       	mov    $0xb,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <sbrk>:
SYSCALL(sbrk)
 518:	b8 0c 00 00 00       	mov    $0xc,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <sleep>:
SYSCALL(sleep)
 520:	b8 0d 00 00 00       	mov    $0xd,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <uptime>:
SYSCALL(uptime)
 528:	b8 0e 00 00 00       	mov    $0xe,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <alarma>:
SYSCALL(alarma)
 530:	b8 16 00 00 00       	mov    $0x16,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <info>:
SYSCALL(info)
 538:	b8 17 00 00 00       	mov    $0x17,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <estado>:
SYSCALL(estado)
 540:	b8 18 00 00 00       	mov    $0x18,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <size>:
SYSCALL(size)
 548:	b8 19 00 00 00       	mov    $0x19,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <estadohijo>:
SYSCALL(estadohijo)
 550:	b8 1a 00 00 00       	mov    $0x1a,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <doge>:
SYSCALL(doge)
 558:	b8 1b 00 00 00       	mov    $0x1b,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 560:	55                   	push   %ebp
 561:	89 e5                	mov    %esp,%ebp
 563:	83 ec 28             	sub    $0x28,%esp
 566:	8b 45 0c             	mov    0xc(%ebp),%eax
 569:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 56c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 573:	00 
 574:	8d 45 f4             	lea    -0xc(%ebp),%eax
 577:	89 44 24 04          	mov    %eax,0x4(%esp)
 57b:	8b 45 08             	mov    0x8(%ebp),%eax
 57e:	89 04 24             	mov    %eax,(%esp)
 581:	e8 2a ff ff ff       	call   4b0 <write>
}
 586:	c9                   	leave  
 587:	c3                   	ret    

00000588 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 588:	55                   	push   %ebp
 589:	89 e5                	mov    %esp,%ebp
 58b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 58e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 595:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 599:	74 17                	je     5b2 <printint+0x2a>
 59b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 59f:	79 11                	jns    5b2 <printint+0x2a>
    neg = 1;
 5a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ab:	f7 d8                	neg    %eax
 5ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b0:	eb 06                	jmp    5b8 <printint+0x30>
  } else {
    x = xx;
 5b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c5:	ba 00 00 00 00       	mov    $0x0,%edx
 5ca:	f7 f1                	div    %ecx
 5cc:	89 d0                	mov    %edx,%eax
 5ce:	0f b6 90 d4 0e 00 00 	movzbl 0xed4(%eax),%edx
 5d5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d8:	03 45 f4             	add    -0xc(%ebp),%eax
 5db:	88 10                	mov    %dl,(%eax)
 5dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5e1:	8b 55 10             	mov    0x10(%ebp),%edx
 5e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ea:	ba 00 00 00 00       	mov    $0x0,%edx
 5ef:	f7 75 d4             	divl   -0x2c(%ebp)
 5f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f9:	75 c4                	jne    5bf <printint+0x37>
  if(neg)
 5fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5ff:	74 2a                	je     62b <printint+0xa3>
    buf[i++] = '-';
 601:	8d 45 dc             	lea    -0x24(%ebp),%eax
 604:	03 45 f4             	add    -0xc(%ebp),%eax
 607:	c6 00 2d             	movb   $0x2d,(%eax)
 60a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 60e:	eb 1b                	jmp    62b <printint+0xa3>
    putc(fd, buf[i]);
 610:	8d 45 dc             	lea    -0x24(%ebp),%eax
 613:	03 45 f4             	add    -0xc(%ebp),%eax
 616:	0f b6 00             	movzbl (%eax),%eax
 619:	0f be c0             	movsbl %al,%eax
 61c:	89 44 24 04          	mov    %eax,0x4(%esp)
 620:	8b 45 08             	mov    0x8(%ebp),%eax
 623:	89 04 24             	mov    %eax,(%esp)
 626:	e8 35 ff ff ff       	call   560 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 62b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 62f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 633:	79 db                	jns    610 <printint+0x88>
    putc(fd, buf[i]);
}
 635:	c9                   	leave  
 636:	c3                   	ret    

00000637 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 637:	55                   	push   %ebp
 638:	89 e5                	mov    %esp,%ebp
 63a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 63d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 644:	8d 45 0c             	lea    0xc(%ebp),%eax
 647:	83 c0 04             	add    $0x4,%eax
 64a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 64d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 654:	e9 7d 01 00 00       	jmp    7d6 <printf+0x19f>
    c = fmt[i] & 0xff;
 659:	8b 55 0c             	mov    0xc(%ebp),%edx
 65c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 65f:	01 d0                	add    %edx,%eax
 661:	0f b6 00             	movzbl (%eax),%eax
 664:	0f be c0             	movsbl %al,%eax
 667:	25 ff 00 00 00       	and    $0xff,%eax
 66c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 66f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 673:	75 2c                	jne    6a1 <printf+0x6a>
      if(c == '%'){
 675:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 679:	75 0c                	jne    687 <printf+0x50>
        state = '%';
 67b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 682:	e9 4b 01 00 00       	jmp    7d2 <printf+0x19b>
      } else {
        putc(fd, c);
 687:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68a:	0f be c0             	movsbl %al,%eax
 68d:	89 44 24 04          	mov    %eax,0x4(%esp)
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	89 04 24             	mov    %eax,(%esp)
 697:	e8 c4 fe ff ff       	call   560 <putc>
 69c:	e9 31 01 00 00       	jmp    7d2 <printf+0x19b>
      }
    } else if(state == '%'){
 6a1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6a5:	0f 85 27 01 00 00    	jne    7d2 <printf+0x19b>
      if(c == 'd'){
 6ab:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6af:	75 2d                	jne    6de <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b4:	8b 00                	mov    (%eax),%eax
 6b6:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6bd:	00 
 6be:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6c5:	00 
 6c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ca:	8b 45 08             	mov    0x8(%ebp),%eax
 6cd:	89 04 24             	mov    %eax,(%esp)
 6d0:	e8 b3 fe ff ff       	call   588 <printint>
        ap++;
 6d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d9:	e9 ed 00 00 00       	jmp    7cb <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6de:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6e2:	74 06                	je     6ea <printf+0xb3>
 6e4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6e8:	75 2d                	jne    717 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ed:	8b 00                	mov    (%eax),%eax
 6ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6f6:	00 
 6f7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6fe:	00 
 6ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 703:	8b 45 08             	mov    0x8(%ebp),%eax
 706:	89 04 24             	mov    %eax,(%esp)
 709:	e8 7a fe ff ff       	call   588 <printint>
        ap++;
 70e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 712:	e9 b4 00 00 00       	jmp    7cb <printf+0x194>
      } else if(c == 's'){
 717:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 71b:	75 46                	jne    763 <printf+0x12c>
        s = (char*)*ap;
 71d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 720:	8b 00                	mov    (%eax),%eax
 722:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 725:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 729:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 72d:	75 27                	jne    756 <printf+0x11f>
          s = "(null)";
 72f:	c7 45 f4 22 0c 00 00 	movl   $0xc22,-0xc(%ebp)
        while(*s != 0){
 736:	eb 1e                	jmp    756 <printf+0x11f>
          putc(fd, *s);
 738:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73b:	0f b6 00             	movzbl (%eax),%eax
 73e:	0f be c0             	movsbl %al,%eax
 741:	89 44 24 04          	mov    %eax,0x4(%esp)
 745:	8b 45 08             	mov    0x8(%ebp),%eax
 748:	89 04 24             	mov    %eax,(%esp)
 74b:	e8 10 fe ff ff       	call   560 <putc>
          s++;
 750:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 754:	eb 01                	jmp    757 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 756:	90                   	nop
 757:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75a:	0f b6 00             	movzbl (%eax),%eax
 75d:	84 c0                	test   %al,%al
 75f:	75 d7                	jne    738 <printf+0x101>
 761:	eb 68                	jmp    7cb <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 763:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 767:	75 1d                	jne    786 <printf+0x14f>
        putc(fd, *ap);
 769:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76c:	8b 00                	mov    (%eax),%eax
 76e:	0f be c0             	movsbl %al,%eax
 771:	89 44 24 04          	mov    %eax,0x4(%esp)
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	89 04 24             	mov    %eax,(%esp)
 77b:	e8 e0 fd ff ff       	call   560 <putc>
        ap++;
 780:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 784:	eb 45                	jmp    7cb <printf+0x194>
      } else if(c == '%'){
 786:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78a:	75 17                	jne    7a3 <printf+0x16c>
        putc(fd, c);
 78c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 78f:	0f be c0             	movsbl %al,%eax
 792:	89 44 24 04          	mov    %eax,0x4(%esp)
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	89 04 24             	mov    %eax,(%esp)
 79c:	e8 bf fd ff ff       	call   560 <putc>
 7a1:	eb 28                	jmp    7cb <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7a3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7aa:	00 
 7ab:	8b 45 08             	mov    0x8(%ebp),%eax
 7ae:	89 04 24             	mov    %eax,(%esp)
 7b1:	e8 aa fd ff ff       	call   560 <putc>
        putc(fd, c);
 7b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b9:	0f be c0             	movsbl %al,%eax
 7bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c0:	8b 45 08             	mov    0x8(%ebp),%eax
 7c3:	89 04 24             	mov    %eax,(%esp)
 7c6:	e8 95 fd ff ff       	call   560 <putc>
      }
      state = 0;
 7cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7d2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	01 d0                	add    %edx,%eax
 7de:	0f b6 00             	movzbl (%eax),%eax
 7e1:	84 c0                	test   %al,%al
 7e3:	0f 85 70 fe ff ff    	jne    659 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7e9:	c9                   	leave  
 7ea:	c3                   	ret    
 7eb:	90                   	nop

000007ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ec:	55                   	push   %ebp
 7ed:	89 e5                	mov    %esp,%ebp
 7ef:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f2:	8b 45 08             	mov    0x8(%ebp),%eax
 7f5:	83 e8 08             	sub    $0x8,%eax
 7f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fb:	a1 f0 0e 00 00       	mov    0xef0,%eax
 800:	89 45 fc             	mov    %eax,-0x4(%ebp)
 803:	eb 24                	jmp    829 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	8b 00                	mov    (%eax),%eax
 80a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 80d:	77 12                	ja     821 <free+0x35>
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 815:	77 24                	ja     83b <free+0x4f>
 817:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81a:	8b 00                	mov    (%eax),%eax
 81c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 81f:	77 1a                	ja     83b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	89 45 fc             	mov    %eax,-0x4(%ebp)
 829:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 82f:	76 d4                	jbe    805 <free+0x19>
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 839:	76 ca                	jbe    805 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 83b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83e:	8b 40 04             	mov    0x4(%eax),%eax
 841:	c1 e0 03             	shl    $0x3,%eax
 844:	89 c2                	mov    %eax,%edx
 846:	03 55 f8             	add    -0x8(%ebp),%edx
 849:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84c:	8b 00                	mov    (%eax),%eax
 84e:	39 c2                	cmp    %eax,%edx
 850:	75 24                	jne    876 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 852:	8b 45 f8             	mov    -0x8(%ebp),%eax
 855:	8b 50 04             	mov    0x4(%eax),%edx
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	8b 40 04             	mov    0x4(%eax),%eax
 860:	01 c2                	add    %eax,%edx
 862:	8b 45 f8             	mov    -0x8(%ebp),%eax
 865:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 868:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86b:	8b 00                	mov    (%eax),%eax
 86d:	8b 10                	mov    (%eax),%edx
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	89 10                	mov    %edx,(%eax)
 874:	eb 0a                	jmp    880 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 876:	8b 45 fc             	mov    -0x4(%ebp),%eax
 879:	8b 10                	mov    (%eax),%edx
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 880:	8b 45 fc             	mov    -0x4(%ebp),%eax
 883:	8b 40 04             	mov    0x4(%eax),%eax
 886:	c1 e0 03             	shl    $0x3,%eax
 889:	03 45 fc             	add    -0x4(%ebp),%eax
 88c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 88f:	75 20                	jne    8b1 <free+0xc5>
    p->s.size += bp->s.size;
 891:	8b 45 fc             	mov    -0x4(%ebp),%eax
 894:	8b 50 04             	mov    0x4(%eax),%edx
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	8b 40 04             	mov    0x4(%eax),%eax
 89d:	01 c2                	add    %eax,%edx
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a8:	8b 10                	mov    (%eax),%edx
 8aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ad:	89 10                	mov    %edx,(%eax)
 8af:	eb 08                	jmp    8b9 <free+0xcd>
  } else
    p->s.ptr = bp;
 8b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8b7:	89 10                	mov    %edx,(%eax)
  freep = p;
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	a3 f0 0e 00 00       	mov    %eax,0xef0
}
 8c1:	c9                   	leave  
 8c2:	c3                   	ret    

000008c3 <morecore>:

static Header*
morecore(uint nu)
{
 8c3:	55                   	push   %ebp
 8c4:	89 e5                	mov    %esp,%ebp
 8c6:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8c9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8d0:	77 07                	ja     8d9 <morecore+0x16>
    nu = 4096;
 8d2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8d9:	8b 45 08             	mov    0x8(%ebp),%eax
 8dc:	c1 e0 03             	shl    $0x3,%eax
 8df:	89 04 24             	mov    %eax,(%esp)
 8e2:	e8 31 fc ff ff       	call   518 <sbrk>
 8e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ea:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8ee:	75 07                	jne    8f7 <morecore+0x34>
    return 0;
 8f0:	b8 00 00 00 00       	mov    $0x0,%eax
 8f5:	eb 22                	jmp    919 <morecore+0x56>
  hp = (Header*)p;
 8f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 900:	8b 55 08             	mov    0x8(%ebp),%edx
 903:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 906:	8b 45 f0             	mov    -0x10(%ebp),%eax
 909:	83 c0 08             	add    $0x8,%eax
 90c:	89 04 24             	mov    %eax,(%esp)
 90f:	e8 d8 fe ff ff       	call   7ec <free>
  return freep;
 914:	a1 f0 0e 00 00       	mov    0xef0,%eax
}
 919:	c9                   	leave  
 91a:	c3                   	ret    

0000091b <malloc>:

void*
malloc(uint nbytes)
{
 91b:	55                   	push   %ebp
 91c:	89 e5                	mov    %esp,%ebp
 91e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 921:	8b 45 08             	mov    0x8(%ebp),%eax
 924:	83 c0 07             	add    $0x7,%eax
 927:	c1 e8 03             	shr    $0x3,%eax
 92a:	83 c0 01             	add    $0x1,%eax
 92d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 930:	a1 f0 0e 00 00       	mov    0xef0,%eax
 935:	89 45 f0             	mov    %eax,-0x10(%ebp)
 938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 93c:	75 23                	jne    961 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 93e:	c7 45 f0 e8 0e 00 00 	movl   $0xee8,-0x10(%ebp)
 945:	8b 45 f0             	mov    -0x10(%ebp),%eax
 948:	a3 f0 0e 00 00       	mov    %eax,0xef0
 94d:	a1 f0 0e 00 00       	mov    0xef0,%eax
 952:	a3 e8 0e 00 00       	mov    %eax,0xee8
    base.s.size = 0;
 957:	c7 05 ec 0e 00 00 00 	movl   $0x0,0xeec
 95e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 961:	8b 45 f0             	mov    -0x10(%ebp),%eax
 964:	8b 00                	mov    (%eax),%eax
 966:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 969:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96c:	8b 40 04             	mov    0x4(%eax),%eax
 96f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 972:	72 4d                	jb     9c1 <malloc+0xa6>
      if(p->s.size == nunits)
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	8b 40 04             	mov    0x4(%eax),%eax
 97a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 97d:	75 0c                	jne    98b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	8b 10                	mov    (%eax),%edx
 984:	8b 45 f0             	mov    -0x10(%ebp),%eax
 987:	89 10                	mov    %edx,(%eax)
 989:	eb 26                	jmp    9b1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98e:	8b 40 04             	mov    0x4(%eax),%eax
 991:	89 c2                	mov    %eax,%edx
 993:	2b 55 ec             	sub    -0x14(%ebp),%edx
 996:	8b 45 f4             	mov    -0xc(%ebp),%eax
 999:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 99c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99f:	8b 40 04             	mov    0x4(%eax),%eax
 9a2:	c1 e0 03             	shl    $0x3,%eax
 9a5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ae:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b4:	a3 f0 0e 00 00       	mov    %eax,0xef0
      return (void*)(p + 1);
 9b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bc:	83 c0 08             	add    $0x8,%eax
 9bf:	eb 38                	jmp    9f9 <malloc+0xde>
    }
    if(p == freep)
 9c1:	a1 f0 0e 00 00       	mov    0xef0,%eax
 9c6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9c9:	75 1b                	jne    9e6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9ce:	89 04 24             	mov    %eax,(%esp)
 9d1:	e8 ed fe ff ff       	call   8c3 <morecore>
 9d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9dd:	75 07                	jne    9e6 <malloc+0xcb>
        return 0;
 9df:	b8 00 00 00 00       	mov    $0x0,%eax
 9e4:	eb 13                	jmp    9f9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 00                	mov    (%eax),%eax
 9f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9f4:	e9 70 ff ff ff       	jmp    969 <malloc+0x4e>
}
 9f9:	c9                   	leave  
 9fa:	c3                   	ret    
