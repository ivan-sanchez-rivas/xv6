
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 72 02 00 00       	call   280 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 fa 02 00 00       	call   318 <sleep>
  exit();
  1e:	e8 65 02 00 00       	call   288 <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 0c             	mov    0xc(%ebp),%eax
  59:	0f b6 10             	movzbl (%eax),%edx
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	88 10                	mov    %dl,(%eax)
  61:	8b 45 08             	mov    0x8(%ebp),%eax
  64:	0f b6 00             	movzbl (%eax),%eax
  67:	84 c0                	test   %al,%al
  69:	0f 95 c0             	setne  %al
  6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  74:	84 c0                	test   %al,%al
  76:	75 de                	jne    56 <strcpy+0xd>
    ;
  return os;
  78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  7b:	c9                   	leave  
  7c:	c3                   	ret    

0000007d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  80:	eb 08                	jmp    8a <strcmp+0xd>
    p++, q++;
  82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	0f b6 00             	movzbl (%eax),%eax
  90:	84 c0                	test   %al,%al
  92:	74 10                	je     a4 <strcmp+0x27>
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	0f b6 10             	movzbl (%eax),%edx
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	0f b6 00             	movzbl (%eax),%eax
  a0:	38 c2                	cmp    %al,%dl
  a2:	74 de                	je     82 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  a4:	8b 45 08             	mov    0x8(%ebp),%eax
  a7:	0f b6 00             	movzbl (%eax),%eax
  aa:	0f b6 d0             	movzbl %al,%edx
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	0f b6 c0             	movzbl %al,%eax
  b6:	89 d1                	mov    %edx,%ecx
  b8:	29 c1                	sub    %eax,%ecx
  ba:	89 c8                	mov    %ecx,%eax
}
  bc:	5d                   	pop    %ebp
  bd:	c3                   	ret    

000000be <strlen>:

uint
strlen(char *s)
{
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  cb:	eb 04                	jmp    d1 <strlen+0x13>
  cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  d4:	03 45 08             	add    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	84 c0                	test   %al,%al
  dc:	75 ef                	jne    cd <strlen+0xf>
    ;
  return n;
  de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  e9:	8b 45 10             	mov    0x10(%ebp),%eax
  ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
  fa:	89 04 24             	mov    %eax,(%esp)
  fd:	e8 22 ff ff ff       	call   24 <stosb>
  return dst;
 102:	8b 45 08             	mov    0x8(%ebp),%eax
}
 105:	c9                   	leave  
 106:	c3                   	ret    

00000107 <strchr>:

char*
strchr(const char *s, char c)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 04             	sub    $0x4,%esp
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 113:	eb 14                	jmp    129 <strchr+0x22>
    if(*s == c)
 115:	8b 45 08             	mov    0x8(%ebp),%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 11e:	75 05                	jne    125 <strchr+0x1e>
      return (char*)s;
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	eb 13                	jmp    138 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 125:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 129:	8b 45 08             	mov    0x8(%ebp),%eax
 12c:	0f b6 00             	movzbl (%eax),%eax
 12f:	84 c0                	test   %al,%al
 131:	75 e2                	jne    115 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 133:	b8 00 00 00 00       	mov    $0x0,%eax
}
 138:	c9                   	leave  
 139:	c3                   	ret    

0000013a <gets>:

char*
gets(char *buf, int max)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 140:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 147:	eb 44                	jmp    18d <gets+0x53>
    cc = read(0, &c, 1);
 149:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 150:	00 
 151:	8d 45 ef             	lea    -0x11(%ebp),%eax
 154:	89 44 24 04          	mov    %eax,0x4(%esp)
 158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 15f:	e8 3c 01 00 00       	call   2a0 <read>
 164:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 167:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 16b:	7e 2d                	jle    19a <gets+0x60>
      break;
    buf[i++] = c;
 16d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 170:	03 45 08             	add    0x8(%ebp),%eax
 173:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 177:	88 10                	mov    %dl,(%eax)
 179:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 17d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 181:	3c 0a                	cmp    $0xa,%al
 183:	74 16                	je     19b <gets+0x61>
 185:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 189:	3c 0d                	cmp    $0xd,%al
 18b:	74 0e                	je     19b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 190:	83 c0 01             	add    $0x1,%eax
 193:	3b 45 0c             	cmp    0xc(%ebp),%eax
 196:	7c b1                	jl     149 <gets+0xf>
 198:	eb 01                	jmp    19b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 19a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 19b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19e:	03 45 08             	add    0x8(%ebp),%eax
 1a1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a7:	c9                   	leave  
 1a8:	c3                   	ret    

000001a9 <stat>:

int
stat(char *n, struct stat *st)
{
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1b6:	00 
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 06 01 00 00       	call   2c8 <open>
 1c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c9:	79 07                	jns    1d2 <stat+0x29>
    return -1;
 1cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1d0:	eb 23                	jmp    1f5 <stat+0x4c>
  r = fstat(fd, st);
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	89 04 24             	mov    %eax,(%esp)
 1df:	e8 fc 00 00 00       	call   2e0 <fstat>
 1e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ea:	89 04 24             	mov    %eax,(%esp)
 1ed:	e8 be 00 00 00       	call   2b0 <close>
  return r;
 1f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1f5:	c9                   	leave  
 1f6:	c3                   	ret    

000001f7 <atoi>:

int
atoi(const char *s)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 204:	eb 23                	jmp    229 <atoi+0x32>
    n = n*10 + *s++ - '0';
 206:	8b 55 fc             	mov    -0x4(%ebp),%edx
 209:	89 d0                	mov    %edx,%eax
 20b:	c1 e0 02             	shl    $0x2,%eax
 20e:	01 d0                	add    %edx,%eax
 210:	01 c0                	add    %eax,%eax
 212:	89 c2                	mov    %eax,%edx
 214:	8b 45 08             	mov    0x8(%ebp),%eax
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	0f be c0             	movsbl %al,%eax
 21d:	01 d0                	add    %edx,%eax
 21f:	83 e8 30             	sub    $0x30,%eax
 222:	89 45 fc             	mov    %eax,-0x4(%ebp)
 225:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	3c 2f                	cmp    $0x2f,%al
 231:	7e 0a                	jle    23d <atoi+0x46>
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	3c 39                	cmp    $0x39,%al
 23b:	7e c9                	jle    206 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 23d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 240:	c9                   	leave  
 241:	c3                   	ret    

00000242 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 242:	55                   	push   %ebp
 243:	89 e5                	mov    %esp,%ebp
 245:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 254:	eb 13                	jmp    269 <memmove+0x27>
    *dst++ = *src++;
 256:	8b 45 f8             	mov    -0x8(%ebp),%eax
 259:	0f b6 10             	movzbl (%eax),%edx
 25c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 25f:	88 10                	mov    %dl,(%eax)
 261:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 265:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 269:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 26d:	0f 9f c0             	setg   %al
 270:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 274:	84 c0                	test   %al,%al
 276:	75 de                	jne    256 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 278:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27b:	c9                   	leave  
 27c:	c3                   	ret    
 27d:	90                   	nop
 27e:	90                   	nop
 27f:	90                   	nop

00000280 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 280:	b8 01 00 00 00       	mov    $0x1,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <exit>:
SYSCALL(exit)
 288:	b8 02 00 00 00       	mov    $0x2,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <wait>:
SYSCALL(wait)
 290:	b8 03 00 00 00       	mov    $0x3,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <pipe>:
SYSCALL(pipe)
 298:	b8 04 00 00 00       	mov    $0x4,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <read>:
SYSCALL(read)
 2a0:	b8 05 00 00 00       	mov    $0x5,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <write>:
SYSCALL(write)
 2a8:	b8 10 00 00 00       	mov    $0x10,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <close>:
SYSCALL(close)
 2b0:	b8 15 00 00 00       	mov    $0x15,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <kill>:
SYSCALL(kill)
 2b8:	b8 06 00 00 00       	mov    $0x6,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <exec>:
SYSCALL(exec)
 2c0:	b8 07 00 00 00       	mov    $0x7,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <open>:
SYSCALL(open)
 2c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <mknod>:
SYSCALL(mknod)
 2d0:	b8 11 00 00 00       	mov    $0x11,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <unlink>:
SYSCALL(unlink)
 2d8:	b8 12 00 00 00       	mov    $0x12,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <fstat>:
SYSCALL(fstat)
 2e0:	b8 08 00 00 00       	mov    $0x8,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <link>:
SYSCALL(link)
 2e8:	b8 13 00 00 00       	mov    $0x13,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <mkdir>:
SYSCALL(mkdir)
 2f0:	b8 14 00 00 00       	mov    $0x14,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <chdir>:
SYSCALL(chdir)
 2f8:	b8 09 00 00 00       	mov    $0x9,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <dup>:
SYSCALL(dup)
 300:	b8 0a 00 00 00       	mov    $0xa,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <getpid>:
SYSCALL(getpid)
 308:	b8 0b 00 00 00       	mov    $0xb,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <sbrk>:
SYSCALL(sbrk)
 310:	b8 0c 00 00 00       	mov    $0xc,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <sleep>:
SYSCALL(sleep)
 318:	b8 0d 00 00 00       	mov    $0xd,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <uptime>:
SYSCALL(uptime)
 320:	b8 0e 00 00 00       	mov    $0xe,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <alarma>:
SYSCALL(alarma)
 328:	b8 16 00 00 00       	mov    $0x16,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <info>:
SYSCALL(info)
 330:	b8 17 00 00 00       	mov    $0x17,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <estado>:
SYSCALL(estado)
 338:	b8 18 00 00 00       	mov    $0x18,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <size>:
SYSCALL(size)
 340:	b8 19 00 00 00       	mov    $0x19,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <estadohijo>:
SYSCALL(estadohijo)
 348:	b8 1a 00 00 00       	mov    $0x1a,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <doge>:
SYSCALL(doge)
 350:	b8 1b 00 00 00       	mov    $0x1b,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 28             	sub    $0x28,%esp
 35e:	8b 45 0c             	mov    0xc(%ebp),%eax
 361:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 364:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 36b:	00 
 36c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 36f:	89 44 24 04          	mov    %eax,0x4(%esp)
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	89 04 24             	mov    %eax,(%esp)
 379:	e8 2a ff ff ff       	call   2a8 <write>
}
 37e:	c9                   	leave  
 37f:	c3                   	ret    

00000380 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 386:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 38d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 391:	74 17                	je     3aa <printint+0x2a>
 393:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 397:	79 11                	jns    3aa <printint+0x2a>
    neg = 1;
 399:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a3:	f7 d8                	neg    %eax
 3a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3a8:	eb 06                	jmp    3b0 <printint+0x30>
  } else {
    x = xx;
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3bd:	ba 00 00 00 00       	mov    $0x0,%edx
 3c2:	f7 f1                	div    %ecx
 3c4:	89 d0                	mov    %edx,%eax
 3c6:	0f b6 90 38 0a 00 00 	movzbl 0xa38(%eax),%edx
 3cd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3d0:	03 45 f4             	add    -0xc(%ebp),%eax
 3d3:	88 10                	mov    %dl,(%eax)
 3d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 3d9:	8b 55 10             	mov    0x10(%ebp),%edx
 3dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e2:	ba 00 00 00 00       	mov    $0x0,%edx
 3e7:	f7 75 d4             	divl   -0x2c(%ebp)
 3ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f1:	75 c4                	jne    3b7 <printint+0x37>
  if(neg)
 3f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f7:	74 2a                	je     423 <printint+0xa3>
    buf[i++] = '-';
 3f9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3fc:	03 45 f4             	add    -0xc(%ebp),%eax
 3ff:	c6 00 2d             	movb   $0x2d,(%eax)
 402:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 406:	eb 1b                	jmp    423 <printint+0xa3>
    putc(fd, buf[i]);
 408:	8d 45 dc             	lea    -0x24(%ebp),%eax
 40b:	03 45 f4             	add    -0xc(%ebp),%eax
 40e:	0f b6 00             	movzbl (%eax),%eax
 411:	0f be c0             	movsbl %al,%eax
 414:	89 44 24 04          	mov    %eax,0x4(%esp)
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	89 04 24             	mov    %eax,(%esp)
 41e:	e8 35 ff ff ff       	call   358 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 423:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 427:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 42b:	79 db                	jns    408 <printint+0x88>
    putc(fd, buf[i]);
}
 42d:	c9                   	leave  
 42e:	c3                   	ret    

0000042f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 42f:	55                   	push   %ebp
 430:	89 e5                	mov    %esp,%ebp
 432:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 435:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 43c:	8d 45 0c             	lea    0xc(%ebp),%eax
 43f:	83 c0 04             	add    $0x4,%eax
 442:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 445:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 44c:	e9 7d 01 00 00       	jmp    5ce <printf+0x19f>
    c = fmt[i] & 0xff;
 451:	8b 55 0c             	mov    0xc(%ebp),%edx
 454:	8b 45 f0             	mov    -0x10(%ebp),%eax
 457:	01 d0                	add    %edx,%eax
 459:	0f b6 00             	movzbl (%eax),%eax
 45c:	0f be c0             	movsbl %al,%eax
 45f:	25 ff 00 00 00       	and    $0xff,%eax
 464:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 467:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 46b:	75 2c                	jne    499 <printf+0x6a>
      if(c == '%'){
 46d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 471:	75 0c                	jne    47f <printf+0x50>
        state = '%';
 473:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 47a:	e9 4b 01 00 00       	jmp    5ca <printf+0x19b>
      } else {
        putc(fd, c);
 47f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 482:	0f be c0             	movsbl %al,%eax
 485:	89 44 24 04          	mov    %eax,0x4(%esp)
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	89 04 24             	mov    %eax,(%esp)
 48f:	e8 c4 fe ff ff       	call   358 <putc>
 494:	e9 31 01 00 00       	jmp    5ca <printf+0x19b>
      }
    } else if(state == '%'){
 499:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 49d:	0f 85 27 01 00 00    	jne    5ca <printf+0x19b>
      if(c == 'd'){
 4a3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4a7:	75 2d                	jne    4d6 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ac:	8b 00                	mov    (%eax),%eax
 4ae:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4b5:	00 
 4b6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4bd:	00 
 4be:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c2:	8b 45 08             	mov    0x8(%ebp),%eax
 4c5:	89 04 24             	mov    %eax,(%esp)
 4c8:	e8 b3 fe ff ff       	call   380 <printint>
        ap++;
 4cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d1:	e9 ed 00 00 00       	jmp    5c3 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 4d6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4da:	74 06                	je     4e2 <printf+0xb3>
 4dc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e0:	75 2d                	jne    50f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 4e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e5:	8b 00                	mov    (%eax),%eax
 4e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4ee:	00 
 4ef:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4f6:	00 
 4f7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	89 04 24             	mov    %eax,(%esp)
 501:	e8 7a fe ff ff       	call   380 <printint>
        ap++;
 506:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 50a:	e9 b4 00 00 00       	jmp    5c3 <printf+0x194>
      } else if(c == 's'){
 50f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 513:	75 46                	jne    55b <printf+0x12c>
        s = (char*)*ap;
 515:	8b 45 e8             	mov    -0x18(%ebp),%eax
 518:	8b 00                	mov    (%eax),%eax
 51a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 51d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 521:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 525:	75 27                	jne    54e <printf+0x11f>
          s = "(null)";
 527:	c7 45 f4 f3 07 00 00 	movl   $0x7f3,-0xc(%ebp)
        while(*s != 0){
 52e:	eb 1e                	jmp    54e <printf+0x11f>
          putc(fd, *s);
 530:	8b 45 f4             	mov    -0xc(%ebp),%eax
 533:	0f b6 00             	movzbl (%eax),%eax
 536:	0f be c0             	movsbl %al,%eax
 539:	89 44 24 04          	mov    %eax,0x4(%esp)
 53d:	8b 45 08             	mov    0x8(%ebp),%eax
 540:	89 04 24             	mov    %eax,(%esp)
 543:	e8 10 fe ff ff       	call   358 <putc>
          s++;
 548:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 54c:	eb 01                	jmp    54f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 54e:	90                   	nop
 54f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 552:	0f b6 00             	movzbl (%eax),%eax
 555:	84 c0                	test   %al,%al
 557:	75 d7                	jne    530 <printf+0x101>
 559:	eb 68                	jmp    5c3 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 55b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 55f:	75 1d                	jne    57e <printf+0x14f>
        putc(fd, *ap);
 561:	8b 45 e8             	mov    -0x18(%ebp),%eax
 564:	8b 00                	mov    (%eax),%eax
 566:	0f be c0             	movsbl %al,%eax
 569:	89 44 24 04          	mov    %eax,0x4(%esp)
 56d:	8b 45 08             	mov    0x8(%ebp),%eax
 570:	89 04 24             	mov    %eax,(%esp)
 573:	e8 e0 fd ff ff       	call   358 <putc>
        ap++;
 578:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 57c:	eb 45                	jmp    5c3 <printf+0x194>
      } else if(c == '%'){
 57e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 582:	75 17                	jne    59b <printf+0x16c>
        putc(fd, c);
 584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 587:	0f be c0             	movsbl %al,%eax
 58a:	89 44 24 04          	mov    %eax,0x4(%esp)
 58e:	8b 45 08             	mov    0x8(%ebp),%eax
 591:	89 04 24             	mov    %eax,(%esp)
 594:	e8 bf fd ff ff       	call   358 <putc>
 599:	eb 28                	jmp    5c3 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 59b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5a2:	00 
 5a3:	8b 45 08             	mov    0x8(%ebp),%eax
 5a6:	89 04 24             	mov    %eax,(%esp)
 5a9:	e8 aa fd ff ff       	call   358 <putc>
        putc(fd, c);
 5ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b1:	0f be c0             	movsbl %al,%eax
 5b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	89 04 24             	mov    %eax,(%esp)
 5be:	e8 95 fd ff ff       	call   358 <putc>
      }
      state = 0;
 5c3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5ca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ce:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d4:	01 d0                	add    %edx,%eax
 5d6:	0f b6 00             	movzbl (%eax),%eax
 5d9:	84 c0                	test   %al,%al
 5db:	0f 85 70 fe ff ff    	jne    451 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5e1:	c9                   	leave  
 5e2:	c3                   	ret    
 5e3:	90                   	nop

000005e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5e4:	55                   	push   %ebp
 5e5:	89 e5                	mov    %esp,%ebp
 5e7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	83 e8 08             	sub    $0x8,%eax
 5f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f3:	a1 54 0a 00 00       	mov    0xa54,%eax
 5f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5fb:	eb 24                	jmp    621 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 605:	77 12                	ja     619 <free+0x35>
 607:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 60d:	77 24                	ja     633 <free+0x4f>
 60f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 612:	8b 00                	mov    (%eax),%eax
 614:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 617:	77 1a                	ja     633 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 619:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61c:	8b 00                	mov    (%eax),%eax
 61e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 621:	8b 45 f8             	mov    -0x8(%ebp),%eax
 624:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 627:	76 d4                	jbe    5fd <free+0x19>
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 631:	76 ca                	jbe    5fd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 633:	8b 45 f8             	mov    -0x8(%ebp),%eax
 636:	8b 40 04             	mov    0x4(%eax),%eax
 639:	c1 e0 03             	shl    $0x3,%eax
 63c:	89 c2                	mov    %eax,%edx
 63e:	03 55 f8             	add    -0x8(%ebp),%edx
 641:	8b 45 fc             	mov    -0x4(%ebp),%eax
 644:	8b 00                	mov    (%eax),%eax
 646:	39 c2                	cmp    %eax,%edx
 648:	75 24                	jne    66e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 64a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64d:	8b 50 04             	mov    0x4(%eax),%edx
 650:	8b 45 fc             	mov    -0x4(%ebp),%eax
 653:	8b 00                	mov    (%eax),%eax
 655:	8b 40 04             	mov    0x4(%eax),%eax
 658:	01 c2                	add    %eax,%edx
 65a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 00                	mov    (%eax),%eax
 665:	8b 10                	mov    (%eax),%edx
 667:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66a:	89 10                	mov    %edx,(%eax)
 66c:	eb 0a                	jmp    678 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	8b 10                	mov    (%eax),%edx
 673:	8b 45 f8             	mov    -0x8(%ebp),%eax
 676:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 678:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67b:	8b 40 04             	mov    0x4(%eax),%eax
 67e:	c1 e0 03             	shl    $0x3,%eax
 681:	03 45 fc             	add    -0x4(%ebp),%eax
 684:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 687:	75 20                	jne    6a9 <free+0xc5>
    p->s.size += bp->s.size;
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 50 04             	mov    0x4(%eax),%edx
 68f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	01 c2                	add    %eax,%edx
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 69d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a0:	8b 10                	mov    (%eax),%edx
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	89 10                	mov    %edx,(%eax)
 6a7:	eb 08                	jmp    6b1 <free+0xcd>
  } else
    p->s.ptr = bp;
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6af:	89 10                	mov    %edx,(%eax)
  freep = p;
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	a3 54 0a 00 00       	mov    %eax,0xa54
}
 6b9:	c9                   	leave  
 6ba:	c3                   	ret    

000006bb <morecore>:

static Header*
morecore(uint nu)
{
 6bb:	55                   	push   %ebp
 6bc:	89 e5                	mov    %esp,%ebp
 6be:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6c8:	77 07                	ja     6d1 <morecore+0x16>
    nu = 4096;
 6ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d1:	8b 45 08             	mov    0x8(%ebp),%eax
 6d4:	c1 e0 03             	shl    $0x3,%eax
 6d7:	89 04 24             	mov    %eax,(%esp)
 6da:	e8 31 fc ff ff       	call   310 <sbrk>
 6df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6e2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6e6:	75 07                	jne    6ef <morecore+0x34>
    return 0;
 6e8:	b8 00 00 00 00       	mov    $0x0,%eax
 6ed:	eb 22                	jmp    711 <morecore+0x56>
  hp = (Header*)p;
 6ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f8:	8b 55 08             	mov    0x8(%ebp),%edx
 6fb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 701:	83 c0 08             	add    $0x8,%eax
 704:	89 04 24             	mov    %eax,(%esp)
 707:	e8 d8 fe ff ff       	call   5e4 <free>
  return freep;
 70c:	a1 54 0a 00 00       	mov    0xa54,%eax
}
 711:	c9                   	leave  
 712:	c3                   	ret    

00000713 <malloc>:

void*
malloc(uint nbytes)
{
 713:	55                   	push   %ebp
 714:	89 e5                	mov    %esp,%ebp
 716:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	83 c0 07             	add    $0x7,%eax
 71f:	c1 e8 03             	shr    $0x3,%eax
 722:	83 c0 01             	add    $0x1,%eax
 725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 728:	a1 54 0a 00 00       	mov    0xa54,%eax
 72d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 730:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 734:	75 23                	jne    759 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 736:	c7 45 f0 4c 0a 00 00 	movl   $0xa4c,-0x10(%ebp)
 73d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 740:	a3 54 0a 00 00       	mov    %eax,0xa54
 745:	a1 54 0a 00 00       	mov    0xa54,%eax
 74a:	a3 4c 0a 00 00       	mov    %eax,0xa4c
    base.s.size = 0;
 74f:	c7 05 50 0a 00 00 00 	movl   $0x0,0xa50
 756:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 759:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75c:	8b 00                	mov    (%eax),%eax
 75e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 761:	8b 45 f4             	mov    -0xc(%ebp),%eax
 764:	8b 40 04             	mov    0x4(%eax),%eax
 767:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 76a:	72 4d                	jb     7b9 <malloc+0xa6>
      if(p->s.size == nunits)
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	8b 40 04             	mov    0x4(%eax),%eax
 772:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 775:	75 0c                	jne    783 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 777:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77a:	8b 10                	mov    (%eax),%edx
 77c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77f:	89 10                	mov    %edx,(%eax)
 781:	eb 26                	jmp    7a9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 783:	8b 45 f4             	mov    -0xc(%ebp),%eax
 786:	8b 40 04             	mov    0x4(%eax),%eax
 789:	89 c2                	mov    %eax,%edx
 78b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 78e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 791:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	8b 40 04             	mov    0x4(%eax),%eax
 79a:	c1 e0 03             	shl    $0x3,%eax
 79d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7a6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	a3 54 0a 00 00       	mov    %eax,0xa54
      return (void*)(p + 1);
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	83 c0 08             	add    $0x8,%eax
 7b7:	eb 38                	jmp    7f1 <malloc+0xde>
    }
    if(p == freep)
 7b9:	a1 54 0a 00 00       	mov    0xa54,%eax
 7be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7c1:	75 1b                	jne    7de <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7c6:	89 04 24             	mov    %eax,(%esp)
 7c9:	e8 ed fe ff ff       	call   6bb <morecore>
 7ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7d5:	75 07                	jne    7de <malloc+0xcb>
        return 0;
 7d7:	b8 00 00 00 00       	mov    $0x0,%eax
 7dc:	eb 13                	jmp    7f1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	8b 00                	mov    (%eax),%eax
 7e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7ec:	e9 70 ff ff ff       	jmp    761 <malloc+0x4e>
}
 7f1:	c9                   	leave  
 7f2:	c3                   	ret    
