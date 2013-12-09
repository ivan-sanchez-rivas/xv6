
_doge:     file format elf32-i386


Disassembly of section .text:

00000000 <suchPrint>:

char buf[512];
void concatenate_string(char *original,char *add);

void suchPrint(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
	int n;
	int counter =0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while((n=read(fd,buf,sizeof(buf)))>0){
   d:	e9 f0 00 00 00       	jmp    102 <suchPrint+0x102>
		if(counter==0){
  12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  16:	75 38                	jne    50 <suchPrint+0x50>
		printf(1,"such");
  18:	c7 44 24 04 bf 09 00 	movl   $0x9bf,0x4(%esp)
  1f:	00 
  20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  27:	e8 cf 05 00 00       	call   5fb <printf>
		write(1,buf,n);
  2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  33:	c7 44 24 04 a0 0c 00 	movl   $0xca0,0x4(%esp)
  3a:	00 
  3b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  42:	e8 2d 04 00 00       	call   474 <write>
		counter++;
  47:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  4b:	e9 b2 00 00 00       	jmp    102 <suchPrint+0x102>
		}else if(counter==1){
  50:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  54:	75 35                	jne    8b <suchPrint+0x8b>
			printf(1,"wow");
  56:	c7 44 24 04 c4 09 00 	movl   $0x9c4,0x4(%esp)
  5d:	00 
  5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  65:	e8 91 05 00 00       	call   5fb <printf>
			write(1,buf,n);
  6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  71:	c7 44 24 04 a0 0c 00 	movl   $0xca0,0x4(%esp)
  78:	00 
  79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80:	e8 ef 03 00 00       	call   474 <write>
			counter++;
  85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  89:	eb 77                	jmp    102 <suchPrint+0x102>
		} else if(counter==2){
  8b:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  8f:	75 35                	jne    c6 <suchPrint+0xc6>
		  printf(1,"much");
  91:	c7 44 24 04 c8 09 00 	movl   $0x9c8,0x4(%esp)
  98:	00 
  99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a0:	e8 56 05 00 00       	call   5fb <printf>
		  write(1,buf,n);
  a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  ac:	c7 44 24 04 a0 0c 00 	movl   $0xca0,0x4(%esp)
  b3:	00 
  b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  bb:	e8 b4 03 00 00       	call   474 <write>
		  counter++;
  c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  c4:	eb 3c                	jmp    102 <suchPrint+0x102>
		} else if(counter ==3){
  c6:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  ca:	75 36                	jne    102 <suchPrint+0x102>
		  printf(1,"so");
  cc:	c7 44 24 04 cd 09 00 	movl   $0x9cd,0x4(%esp)
  d3:	00 
  d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  db:	e8 1b 05 00 00       	call   5fb <printf>
		  write(1,buf,n);
  e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  e7:	c7 44 24 04 a0 0c 00 	movl   $0xca0,0x4(%esp)
  ee:	00 
  ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f6:	e8 79 03 00 00       	call   474 <write>
		  counter=0;
  fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

void suchPrint(int fd)
{
	int n;
	int counter =0;
	while((n=read(fd,buf,sizeof(buf)))>0){
 102:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 109:	00 
 10a:	c7 44 24 04 a0 0c 00 	movl   $0xca0,0x4(%esp)
 111:	00 
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	89 04 24             	mov    %eax,(%esp)
 118:	e8 4f 03 00 00       	call   46c <read>
 11d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 120:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 124:	0f 8f e8 fe ff ff    	jg     12 <suchPrint+0x12>
		  printf(1,"so");
		  write(1,buf,n);
		  counter=0;
		}
	}
	if(n<0){
 12a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 12e:	79 19                	jns    149 <suchPrint+0x149>
	   printf(1,"doge: such error\n");
 130:	c7 44 24 04 d0 09 00 	movl   $0x9d0,0x4(%esp)
 137:	00 
 138:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13f:	e8 b7 04 00 00       	call   5fb <printf>
	   exit();
 144:	e8 0b 03 00 00       	call   454 <exit>
	}
}
 149:	c9                   	leave  
 14a:	c3                   	ret    

0000014b <main>:

int main(int argc, char *argv[])
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 e4 f0             	and    $0xfffffff0,%esp
 151:	83 ec 20             	sub    $0x20,%esp
	int fd, i;
	if(argc <=1){
 154:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 158:	7f 11                	jg     16b <main+0x20>
	  suchPrint(0);
 15a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 161:	e8 9a fe ff ff       	call   0 <suchPrint>
	  exit();
 166:	e8 e9 02 00 00       	call   454 <exit>
	}
	for(i=1;i<argc;i++){
 16b:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 172:	00 
 173:	eb 6d                	jmp    1e2 <main+0x97>
		if((fd=open(argv[i],0))<0){
 175:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 179:	c1 e0 02             	shl    $0x2,%eax
 17c:	03 45 0c             	add    0xc(%ebp),%eax
 17f:	8b 00                	mov    (%eax),%eax
 181:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 188:	00 
 189:	89 04 24             	mov    %eax,(%esp)
 18c:	e8 03 03 00 00       	call   494 <open>
 191:	89 44 24 18          	mov    %eax,0x18(%esp)
 195:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 19a:	79 29                	jns    1c5 <main+0x7a>
		   printf(1,"doge: much closed", argv[i]);
 19c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1a0:	c1 e0 02             	shl    $0x2,%eax
 1a3:	03 45 0c             	add    0xc(%ebp),%eax
 1a6:	8b 00                	mov    (%eax),%eax
 1a8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ac:	c7 44 24 04 e2 09 00 	movl   $0x9e2,0x4(%esp)
 1b3:	00 
 1b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bb:	e8 3b 04 00 00       	call   5fb <printf>
		   exit();
 1c0:	e8 8f 02 00 00       	call   454 <exit>
		}
		suchPrint(fd);
 1c5:	8b 44 24 18          	mov    0x18(%esp),%eax
 1c9:	89 04 24             	mov    %eax,(%esp)
 1cc:	e8 2f fe ff ff       	call   0 <suchPrint>
		close(fd);
 1d1:	8b 44 24 18          	mov    0x18(%esp),%eax
 1d5:	89 04 24             	mov    %eax,(%esp)
 1d8:	e8 9f 02 00 00       	call   47c <close>
	int fd, i;
	if(argc <=1){
	  suchPrint(0);
	  exit();
	}
	for(i=1;i<argc;i++){
 1dd:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1e2:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1e6:	3b 45 08             	cmp    0x8(%ebp),%eax
 1e9:	7c 8a                	jl     175 <main+0x2a>
		   exit();
		}
		suchPrint(fd);
		close(fd);
	}
	exit();
 1eb:	e8 64 02 00 00       	call   454 <exit>

000001f0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	57                   	push   %edi
 1f4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1f8:	8b 55 10             	mov    0x10(%ebp),%edx
 1fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 1fe:	89 cb                	mov    %ecx,%ebx
 200:	89 df                	mov    %ebx,%edi
 202:	89 d1                	mov    %edx,%ecx
 204:	fc                   	cld    
 205:	f3 aa                	rep stos %al,%es:(%edi)
 207:	89 ca                	mov    %ecx,%edx
 209:	89 fb                	mov    %edi,%ebx
 20b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 20e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 211:	5b                   	pop    %ebx
 212:	5f                   	pop    %edi
 213:	5d                   	pop    %ebp
 214:	c3                   	ret    

00000215 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 215:	55                   	push   %ebp
 216:	89 e5                	mov    %esp,%ebp
 218:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 21b:	8b 45 08             	mov    0x8(%ebp),%eax
 21e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 221:	90                   	nop
 222:	8b 45 0c             	mov    0xc(%ebp),%eax
 225:	0f b6 10             	movzbl (%eax),%edx
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	88 10                	mov    %dl,(%eax)
 22d:	8b 45 08             	mov    0x8(%ebp),%eax
 230:	0f b6 00             	movzbl (%eax),%eax
 233:	84 c0                	test   %al,%al
 235:	0f 95 c0             	setne  %al
 238:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 240:	84 c0                	test   %al,%al
 242:	75 de                	jne    222 <strcpy+0xd>
    ;
  return os;
 244:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 247:	c9                   	leave  
 248:	c3                   	ret    

00000249 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 249:	55                   	push   %ebp
 24a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 24c:	eb 08                	jmp    256 <strcmp+0xd>
    p++, q++;
 24e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 252:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	74 10                	je     270 <strcmp+0x27>
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	0f b6 10             	movzbl (%eax),%edx
 266:	8b 45 0c             	mov    0xc(%ebp),%eax
 269:	0f b6 00             	movzbl (%eax),%eax
 26c:	38 c2                	cmp    %al,%dl
 26e:	74 de                	je     24e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 270:	8b 45 08             	mov    0x8(%ebp),%eax
 273:	0f b6 00             	movzbl (%eax),%eax
 276:	0f b6 d0             	movzbl %al,%edx
 279:	8b 45 0c             	mov    0xc(%ebp),%eax
 27c:	0f b6 00             	movzbl (%eax),%eax
 27f:	0f b6 c0             	movzbl %al,%eax
 282:	89 d1                	mov    %edx,%ecx
 284:	29 c1                	sub    %eax,%ecx
 286:	89 c8                	mov    %ecx,%eax
}
 288:	5d                   	pop    %ebp
 289:	c3                   	ret    

0000028a <strlen>:

uint
strlen(char *s)
{
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 290:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 297:	eb 04                	jmp    29d <strlen+0x13>
 299:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 29d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a0:	03 45 08             	add    0x8(%ebp),%eax
 2a3:	0f b6 00             	movzbl (%eax),%eax
 2a6:	84 c0                	test   %al,%al
 2a8:	75 ef                	jne    299 <strlen+0xf>
    ;
  return n;
 2aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ad:	c9                   	leave  
 2ae:	c3                   	ret    

000002af <memset>:

void*
memset(void *dst, int c, uint n)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
 2b2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2b5:	8b 45 10             	mov    0x10(%ebp),%eax
 2b8:	89 44 24 08          	mov    %eax,0x8(%esp)
 2bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
 2c6:	89 04 24             	mov    %eax,(%esp)
 2c9:	e8 22 ff ff ff       	call   1f0 <stosb>
  return dst;
 2ce:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d1:	c9                   	leave  
 2d2:	c3                   	ret    

000002d3 <strchr>:

char*
strchr(const char *s, char c)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	83 ec 04             	sub    $0x4,%esp
 2d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dc:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2df:	eb 14                	jmp    2f5 <strchr+0x22>
    if(*s == c)
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	0f b6 00             	movzbl (%eax),%eax
 2e7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2ea:	75 05                	jne    2f1 <strchr+0x1e>
      return (char*)s;
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	eb 13                	jmp    304 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	0f b6 00             	movzbl (%eax),%eax
 2fb:	84 c0                	test   %al,%al
 2fd:	75 e2                	jne    2e1 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
 304:	c9                   	leave  
 305:	c3                   	ret    

00000306 <gets>:

char*
gets(char *buf, int max)
{
 306:	55                   	push   %ebp
 307:	89 e5                	mov    %esp,%ebp
 309:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 30c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 313:	eb 44                	jmp    359 <gets+0x53>
    cc = read(0, &c, 1);
 315:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 31c:	00 
 31d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 320:	89 44 24 04          	mov    %eax,0x4(%esp)
 324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 32b:	e8 3c 01 00 00       	call   46c <read>
 330:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 333:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 337:	7e 2d                	jle    366 <gets+0x60>
      break;
    buf[i++] = c;
 339:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33c:	03 45 08             	add    0x8(%ebp),%eax
 33f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 343:	88 10                	mov    %dl,(%eax)
 345:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 349:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 34d:	3c 0a                	cmp    $0xa,%al
 34f:	74 16                	je     367 <gets+0x61>
 351:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 355:	3c 0d                	cmp    $0xd,%al
 357:	74 0e                	je     367 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 359:	8b 45 f4             	mov    -0xc(%ebp),%eax
 35c:	83 c0 01             	add    $0x1,%eax
 35f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 362:	7c b1                	jl     315 <gets+0xf>
 364:	eb 01                	jmp    367 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 366:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 367:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36a:	03 45 08             	add    0x8(%ebp),%eax
 36d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 370:	8b 45 08             	mov    0x8(%ebp),%eax
}
 373:	c9                   	leave  
 374:	c3                   	ret    

00000375 <stat>:

int
stat(char *n, struct stat *st)
{
 375:	55                   	push   %ebp
 376:	89 e5                	mov    %esp,%ebp
 378:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 37b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 382:	00 
 383:	8b 45 08             	mov    0x8(%ebp),%eax
 386:	89 04 24             	mov    %eax,(%esp)
 389:	e8 06 01 00 00       	call   494 <open>
 38e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 395:	79 07                	jns    39e <stat+0x29>
    return -1;
 397:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 39c:	eb 23                	jmp    3c1 <stat+0x4c>
  r = fstat(fd, st);
 39e:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 3a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a8:	89 04 24             	mov    %eax,(%esp)
 3ab:	e8 fc 00 00 00       	call   4ac <fstat>
 3b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b6:	89 04 24             	mov    %eax,(%esp)
 3b9:	e8 be 00 00 00       	call   47c <close>
  return r;
 3be:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3c1:	c9                   	leave  
 3c2:	c3                   	ret    

000003c3 <atoi>:

int
atoi(const char *s)
{
 3c3:	55                   	push   %ebp
 3c4:	89 e5                	mov    %esp,%ebp
 3c6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3d0:	eb 23                	jmp    3f5 <atoi+0x32>
    n = n*10 + *s++ - '0';
 3d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d5:	89 d0                	mov    %edx,%eax
 3d7:	c1 e0 02             	shl    $0x2,%eax
 3da:	01 d0                	add    %edx,%eax
 3dc:	01 c0                	add    %eax,%eax
 3de:	89 c2                	mov    %eax,%edx
 3e0:	8b 45 08             	mov    0x8(%ebp),%eax
 3e3:	0f b6 00             	movzbl (%eax),%eax
 3e6:	0f be c0             	movsbl %al,%eax
 3e9:	01 d0                	add    %edx,%eax
 3eb:	83 e8 30             	sub    $0x30,%eax
 3ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
 3f8:	0f b6 00             	movzbl (%eax),%eax
 3fb:	3c 2f                	cmp    $0x2f,%al
 3fd:	7e 0a                	jle    409 <atoi+0x46>
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
 402:	0f b6 00             	movzbl (%eax),%eax
 405:	3c 39                	cmp    $0x39,%al
 407:	7e c9                	jle    3d2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 409:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 40c:	c9                   	leave  
 40d:	c3                   	ret    

0000040e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 40e:	55                   	push   %ebp
 40f:	89 e5                	mov    %esp,%ebp
 411:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 414:	8b 45 08             	mov    0x8(%ebp),%eax
 417:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 41a:	8b 45 0c             	mov    0xc(%ebp),%eax
 41d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 420:	eb 13                	jmp    435 <memmove+0x27>
    *dst++ = *src++;
 422:	8b 45 f8             	mov    -0x8(%ebp),%eax
 425:	0f b6 10             	movzbl (%eax),%edx
 428:	8b 45 fc             	mov    -0x4(%ebp),%eax
 42b:	88 10                	mov    %dl,(%eax)
 42d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 431:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 435:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 439:	0f 9f c0             	setg   %al
 43c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 440:	84 c0                	test   %al,%al
 442:	75 de                	jne    422 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 444:	8b 45 08             	mov    0x8(%ebp),%eax
}
 447:	c9                   	leave  
 448:	c3                   	ret    
 449:	90                   	nop
 44a:	90                   	nop
 44b:	90                   	nop

0000044c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 44c:	b8 01 00 00 00       	mov    $0x1,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <exit>:
SYSCALL(exit)
 454:	b8 02 00 00 00       	mov    $0x2,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <wait>:
SYSCALL(wait)
 45c:	b8 03 00 00 00       	mov    $0x3,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <pipe>:
SYSCALL(pipe)
 464:	b8 04 00 00 00       	mov    $0x4,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <read>:
SYSCALL(read)
 46c:	b8 05 00 00 00       	mov    $0x5,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <write>:
SYSCALL(write)
 474:	b8 10 00 00 00       	mov    $0x10,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <close>:
SYSCALL(close)
 47c:	b8 15 00 00 00       	mov    $0x15,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <kill>:
SYSCALL(kill)
 484:	b8 06 00 00 00       	mov    $0x6,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <exec>:
SYSCALL(exec)
 48c:	b8 07 00 00 00       	mov    $0x7,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <open>:
SYSCALL(open)
 494:	b8 0f 00 00 00       	mov    $0xf,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <mknod>:
SYSCALL(mknod)
 49c:	b8 11 00 00 00       	mov    $0x11,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <unlink>:
SYSCALL(unlink)
 4a4:	b8 12 00 00 00       	mov    $0x12,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <fstat>:
SYSCALL(fstat)
 4ac:	b8 08 00 00 00       	mov    $0x8,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <link>:
SYSCALL(link)
 4b4:	b8 13 00 00 00       	mov    $0x13,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <mkdir>:
SYSCALL(mkdir)
 4bc:	b8 14 00 00 00       	mov    $0x14,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <chdir>:
SYSCALL(chdir)
 4c4:	b8 09 00 00 00       	mov    $0x9,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <dup>:
SYSCALL(dup)
 4cc:	b8 0a 00 00 00       	mov    $0xa,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <getpid>:
SYSCALL(getpid)
 4d4:	b8 0b 00 00 00       	mov    $0xb,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <sbrk>:
SYSCALL(sbrk)
 4dc:	b8 0c 00 00 00       	mov    $0xc,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <sleep>:
SYSCALL(sleep)
 4e4:	b8 0d 00 00 00       	mov    $0xd,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <uptime>:
SYSCALL(uptime)
 4ec:	b8 0e 00 00 00       	mov    $0xe,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <alarma>:
SYSCALL(alarma)
 4f4:	b8 16 00 00 00       	mov    $0x16,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <info>:
SYSCALL(info)
 4fc:	b8 17 00 00 00       	mov    $0x17,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <estado>:
SYSCALL(estado)
 504:	b8 18 00 00 00       	mov    $0x18,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <size>:
SYSCALL(size)
 50c:	b8 19 00 00 00       	mov    $0x19,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret    

00000514 <estadohijo>:
SYSCALL(estadohijo)
 514:	b8 1a 00 00 00       	mov    $0x1a,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret    

0000051c <doge>:
SYSCALL(doge)
 51c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret    

00000524 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 524:	55                   	push   %ebp
 525:	89 e5                	mov    %esp,%ebp
 527:	83 ec 28             	sub    $0x28,%esp
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 530:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 537:	00 
 538:	8d 45 f4             	lea    -0xc(%ebp),%eax
 53b:	89 44 24 04          	mov    %eax,0x4(%esp)
 53f:	8b 45 08             	mov    0x8(%ebp),%eax
 542:	89 04 24             	mov    %eax,(%esp)
 545:	e8 2a ff ff ff       	call   474 <write>
}
 54a:	c9                   	leave  
 54b:	c3                   	ret    

0000054c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 552:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 559:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 55d:	74 17                	je     576 <printint+0x2a>
 55f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 563:	79 11                	jns    576 <printint+0x2a>
    neg = 1;
 565:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 56c:	8b 45 0c             	mov    0xc(%ebp),%eax
 56f:	f7 d8                	neg    %eax
 571:	89 45 ec             	mov    %eax,-0x14(%ebp)
 574:	eb 06                	jmp    57c <printint+0x30>
  } else {
    x = xx;
 576:	8b 45 0c             	mov    0xc(%ebp),%eax
 579:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 57c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 583:	8b 4d 10             	mov    0x10(%ebp),%ecx
 586:	8b 45 ec             	mov    -0x14(%ebp),%eax
 589:	ba 00 00 00 00       	mov    $0x0,%edx
 58e:	f7 f1                	div    %ecx
 590:	89 d0                	mov    %edx,%eax
 592:	0f b6 90 58 0c 00 00 	movzbl 0xc58(%eax),%edx
 599:	8d 45 dc             	lea    -0x24(%ebp),%eax
 59c:	03 45 f4             	add    -0xc(%ebp),%eax
 59f:	88 10                	mov    %dl,(%eax)
 5a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 5a5:	8b 55 10             	mov    0x10(%ebp),%edx
 5a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 5ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ae:	ba 00 00 00 00       	mov    $0x0,%edx
 5b3:	f7 75 d4             	divl   -0x2c(%ebp)
 5b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5bd:	75 c4                	jne    583 <printint+0x37>
  if(neg)
 5bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c3:	74 2a                	je     5ef <printint+0xa3>
    buf[i++] = '-';
 5c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5c8:	03 45 f4             	add    -0xc(%ebp),%eax
 5cb:	c6 00 2d             	movb   $0x2d,(%eax)
 5ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5d2:	eb 1b                	jmp    5ef <printint+0xa3>
    putc(fd, buf[i]);
 5d4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5d7:	03 45 f4             	add    -0xc(%ebp),%eax
 5da:	0f b6 00             	movzbl (%eax),%eax
 5dd:	0f be c0             	movsbl %al,%eax
 5e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e4:	8b 45 08             	mov    0x8(%ebp),%eax
 5e7:	89 04 24             	mov    %eax,(%esp)
 5ea:	e8 35 ff ff ff       	call   524 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5ef:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f7:	79 db                	jns    5d4 <printint+0x88>
    putc(fd, buf[i]);
}
 5f9:	c9                   	leave  
 5fa:	c3                   	ret    

000005fb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5fb:	55                   	push   %ebp
 5fc:	89 e5                	mov    %esp,%ebp
 5fe:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 601:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 608:	8d 45 0c             	lea    0xc(%ebp),%eax
 60b:	83 c0 04             	add    $0x4,%eax
 60e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 611:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 618:	e9 7d 01 00 00       	jmp    79a <printf+0x19f>
    c = fmt[i] & 0xff;
 61d:	8b 55 0c             	mov    0xc(%ebp),%edx
 620:	8b 45 f0             	mov    -0x10(%ebp),%eax
 623:	01 d0                	add    %edx,%eax
 625:	0f b6 00             	movzbl (%eax),%eax
 628:	0f be c0             	movsbl %al,%eax
 62b:	25 ff 00 00 00       	and    $0xff,%eax
 630:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 633:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 637:	75 2c                	jne    665 <printf+0x6a>
      if(c == '%'){
 639:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 63d:	75 0c                	jne    64b <printf+0x50>
        state = '%';
 63f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 646:	e9 4b 01 00 00       	jmp    796 <printf+0x19b>
      } else {
        putc(fd, c);
 64b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64e:	0f be c0             	movsbl %al,%eax
 651:	89 44 24 04          	mov    %eax,0x4(%esp)
 655:	8b 45 08             	mov    0x8(%ebp),%eax
 658:	89 04 24             	mov    %eax,(%esp)
 65b:	e8 c4 fe ff ff       	call   524 <putc>
 660:	e9 31 01 00 00       	jmp    796 <printf+0x19b>
      }
    } else if(state == '%'){
 665:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 669:	0f 85 27 01 00 00    	jne    796 <printf+0x19b>
      if(c == 'd'){
 66f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 673:	75 2d                	jne    6a2 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 675:	8b 45 e8             	mov    -0x18(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 681:	00 
 682:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 689:	00 
 68a:	89 44 24 04          	mov    %eax,0x4(%esp)
 68e:	8b 45 08             	mov    0x8(%ebp),%eax
 691:	89 04 24             	mov    %eax,(%esp)
 694:	e8 b3 fe ff ff       	call   54c <printint>
        ap++;
 699:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69d:	e9 ed 00 00 00       	jmp    78f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 6a2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6a6:	74 06                	je     6ae <printf+0xb3>
 6a8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6ac:	75 2d                	jne    6db <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b1:	8b 00                	mov    (%eax),%eax
 6b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6ba:	00 
 6bb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6c2:	00 
 6c3:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	89 04 24             	mov    %eax,(%esp)
 6cd:	e8 7a fe ff ff       	call   54c <printint>
        ap++;
 6d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6d6:	e9 b4 00 00 00       	jmp    78f <printf+0x194>
      } else if(c == 's'){
 6db:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6df:	75 46                	jne    727 <printf+0x12c>
        s = (char*)*ap;
 6e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e4:	8b 00                	mov    (%eax),%eax
 6e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6e9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f1:	75 27                	jne    71a <printf+0x11f>
          s = "(null)";
 6f3:	c7 45 f4 f4 09 00 00 	movl   $0x9f4,-0xc(%ebp)
        while(*s != 0){
 6fa:	eb 1e                	jmp    71a <printf+0x11f>
          putc(fd, *s);
 6fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ff:	0f b6 00             	movzbl (%eax),%eax
 702:	0f be c0             	movsbl %al,%eax
 705:	89 44 24 04          	mov    %eax,0x4(%esp)
 709:	8b 45 08             	mov    0x8(%ebp),%eax
 70c:	89 04 24             	mov    %eax,(%esp)
 70f:	e8 10 fe ff ff       	call   524 <putc>
          s++;
 714:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 718:	eb 01                	jmp    71b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 71a:	90                   	nop
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	0f b6 00             	movzbl (%eax),%eax
 721:	84 c0                	test   %al,%al
 723:	75 d7                	jne    6fc <printf+0x101>
 725:	eb 68                	jmp    78f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 727:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 72b:	75 1d                	jne    74a <printf+0x14f>
        putc(fd, *ap);
 72d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	0f be c0             	movsbl %al,%eax
 735:	89 44 24 04          	mov    %eax,0x4(%esp)
 739:	8b 45 08             	mov    0x8(%ebp),%eax
 73c:	89 04 24             	mov    %eax,(%esp)
 73f:	e8 e0 fd ff ff       	call   524 <putc>
        ap++;
 744:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 748:	eb 45                	jmp    78f <printf+0x194>
      } else if(c == '%'){
 74a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 74e:	75 17                	jne    767 <printf+0x16c>
        putc(fd, c);
 750:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 753:	0f be c0             	movsbl %al,%eax
 756:	89 44 24 04          	mov    %eax,0x4(%esp)
 75a:	8b 45 08             	mov    0x8(%ebp),%eax
 75d:	89 04 24             	mov    %eax,(%esp)
 760:	e8 bf fd ff ff       	call   524 <putc>
 765:	eb 28                	jmp    78f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 767:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 76e:	00 
 76f:	8b 45 08             	mov    0x8(%ebp),%eax
 772:	89 04 24             	mov    %eax,(%esp)
 775:	e8 aa fd ff ff       	call   524 <putc>
        putc(fd, c);
 77a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77d:	0f be c0             	movsbl %al,%eax
 780:	89 44 24 04          	mov    %eax,0x4(%esp)
 784:	8b 45 08             	mov    0x8(%ebp),%eax
 787:	89 04 24             	mov    %eax,(%esp)
 78a:	e8 95 fd ff ff       	call   524 <putc>
      }
      state = 0;
 78f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 796:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 79a:	8b 55 0c             	mov    0xc(%ebp),%edx
 79d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a0:	01 d0                	add    %edx,%eax
 7a2:	0f b6 00             	movzbl (%eax),%eax
 7a5:	84 c0                	test   %al,%al
 7a7:	0f 85 70 fe ff ff    	jne    61d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7ad:	c9                   	leave  
 7ae:	c3                   	ret    
 7af:	90                   	nop

000007b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b0:	55                   	push   %ebp
 7b1:	89 e5                	mov    %esp,%ebp
 7b3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b6:	8b 45 08             	mov    0x8(%ebp),%eax
 7b9:	83 e8 08             	sub    $0x8,%eax
 7bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bf:	a1 88 0c 00 00       	mov    0xc88,%eax
 7c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c7:	eb 24                	jmp    7ed <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d1:	77 12                	ja     7e5 <free+0x35>
 7d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d9:	77 24                	ja     7ff <free+0x4f>
 7db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7de:	8b 00                	mov    (%eax),%eax
 7e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e3:	77 1a                	ja     7ff <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	8b 00                	mov    (%eax),%eax
 7ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7f3:	76 d4                	jbe    7c9 <free+0x19>
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7fd:	76 ca                	jbe    7c9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 802:	8b 40 04             	mov    0x4(%eax),%eax
 805:	c1 e0 03             	shl    $0x3,%eax
 808:	89 c2                	mov    %eax,%edx
 80a:	03 55 f8             	add    -0x8(%ebp),%edx
 80d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	39 c2                	cmp    %eax,%edx
 814:	75 24                	jne    83a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 816:	8b 45 f8             	mov    -0x8(%ebp),%eax
 819:	8b 50 04             	mov    0x4(%eax),%edx
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	8b 40 04             	mov    0x4(%eax),%eax
 824:	01 c2                	add    %eax,%edx
 826:	8b 45 f8             	mov    -0x8(%ebp),%eax
 829:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 82c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82f:	8b 00                	mov    (%eax),%eax
 831:	8b 10                	mov    (%eax),%edx
 833:	8b 45 f8             	mov    -0x8(%ebp),%eax
 836:	89 10                	mov    %edx,(%eax)
 838:	eb 0a                	jmp    844 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 83a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83d:	8b 10                	mov    (%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 844:	8b 45 fc             	mov    -0x4(%ebp),%eax
 847:	8b 40 04             	mov    0x4(%eax),%eax
 84a:	c1 e0 03             	shl    $0x3,%eax
 84d:	03 45 fc             	add    -0x4(%ebp),%eax
 850:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 853:	75 20                	jne    875 <free+0xc5>
    p->s.size += bp->s.size;
 855:	8b 45 fc             	mov    -0x4(%ebp),%eax
 858:	8b 50 04             	mov    0x4(%eax),%edx
 85b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85e:	8b 40 04             	mov    0x4(%eax),%eax
 861:	01 c2                	add    %eax,%edx
 863:	8b 45 fc             	mov    -0x4(%ebp),%eax
 866:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 869:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86c:	8b 10                	mov    (%eax),%edx
 86e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 871:	89 10                	mov    %edx,(%eax)
 873:	eb 08                	jmp    87d <free+0xcd>
  } else
    p->s.ptr = bp;
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	8b 55 f8             	mov    -0x8(%ebp),%edx
 87b:	89 10                	mov    %edx,(%eax)
  freep = p;
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	a3 88 0c 00 00       	mov    %eax,0xc88
}
 885:	c9                   	leave  
 886:	c3                   	ret    

00000887 <morecore>:

static Header*
morecore(uint nu)
{
 887:	55                   	push   %ebp
 888:	89 e5                	mov    %esp,%ebp
 88a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 88d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 894:	77 07                	ja     89d <morecore+0x16>
    nu = 4096;
 896:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 89d:	8b 45 08             	mov    0x8(%ebp),%eax
 8a0:	c1 e0 03             	shl    $0x3,%eax
 8a3:	89 04 24             	mov    %eax,(%esp)
 8a6:	e8 31 fc ff ff       	call   4dc <sbrk>
 8ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ae:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8b2:	75 07                	jne    8bb <morecore+0x34>
    return 0;
 8b4:	b8 00 00 00 00       	mov    $0x0,%eax
 8b9:	eb 22                	jmp    8dd <morecore+0x56>
  hp = (Header*)p;
 8bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c4:	8b 55 08             	mov    0x8(%ebp),%edx
 8c7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cd:	83 c0 08             	add    $0x8,%eax
 8d0:	89 04 24             	mov    %eax,(%esp)
 8d3:	e8 d8 fe ff ff       	call   7b0 <free>
  return freep;
 8d8:	a1 88 0c 00 00       	mov    0xc88,%eax
}
 8dd:	c9                   	leave  
 8de:	c3                   	ret    

000008df <malloc>:

void*
malloc(uint nbytes)
{
 8df:	55                   	push   %ebp
 8e0:	89 e5                	mov    %esp,%ebp
 8e2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e5:	8b 45 08             	mov    0x8(%ebp),%eax
 8e8:	83 c0 07             	add    $0x7,%eax
 8eb:	c1 e8 03             	shr    $0x3,%eax
 8ee:	83 c0 01             	add    $0x1,%eax
 8f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8f4:	a1 88 0c 00 00       	mov    0xc88,%eax
 8f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 900:	75 23                	jne    925 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 902:	c7 45 f0 80 0c 00 00 	movl   $0xc80,-0x10(%ebp)
 909:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90c:	a3 88 0c 00 00       	mov    %eax,0xc88
 911:	a1 88 0c 00 00       	mov    0xc88,%eax
 916:	a3 80 0c 00 00       	mov    %eax,0xc80
    base.s.size = 0;
 91b:	c7 05 84 0c 00 00 00 	movl   $0x0,0xc84
 922:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 925:	8b 45 f0             	mov    -0x10(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 92d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 930:	8b 40 04             	mov    0x4(%eax),%eax
 933:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 936:	72 4d                	jb     985 <malloc+0xa6>
      if(p->s.size == nunits)
 938:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93b:	8b 40 04             	mov    0x4(%eax),%eax
 93e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 941:	75 0c                	jne    94f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 943:	8b 45 f4             	mov    -0xc(%ebp),%eax
 946:	8b 10                	mov    (%eax),%edx
 948:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94b:	89 10                	mov    %edx,(%eax)
 94d:	eb 26                	jmp    975 <malloc+0x96>
      else {
        p->s.size -= nunits;
 94f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	89 c2                	mov    %eax,%edx
 957:	2b 55 ec             	sub    -0x14(%ebp),%edx
 95a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 960:	8b 45 f4             	mov    -0xc(%ebp),%eax
 963:	8b 40 04             	mov    0x4(%eax),%eax
 966:	c1 e0 03             	shl    $0x3,%eax
 969:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 96c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 972:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 975:	8b 45 f0             	mov    -0x10(%ebp),%eax
 978:	a3 88 0c 00 00       	mov    %eax,0xc88
      return (void*)(p + 1);
 97d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 980:	83 c0 08             	add    $0x8,%eax
 983:	eb 38                	jmp    9bd <malloc+0xde>
    }
    if(p == freep)
 985:	a1 88 0c 00 00       	mov    0xc88,%eax
 98a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 98d:	75 1b                	jne    9aa <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 98f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 992:	89 04 24             	mov    %eax,(%esp)
 995:	e8 ed fe ff ff       	call   887 <morecore>
 99a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 99d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9a1:	75 07                	jne    9aa <malloc+0xcb>
        return 0;
 9a3:	b8 00 00 00 00       	mov    $0x0,%eax
 9a8:	eb 13                	jmp    9bd <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b3:	8b 00                	mov    (%eax),%eax
 9b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9b8:	e9 70 ff ff ff       	jmp    92d <malloc+0x4e>
}
 9bd:	c9                   	leave  
 9be:	c3                   	ret    
