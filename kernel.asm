
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 ff 33 10 80       	mov    $0x801033ff,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 1c 82 10 	movl   $0x8010821c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100049:	e8 b0 4a 00 00       	call   80104afe <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 b0 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb0
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 b4 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb4
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801000bd:	e8 5d 4a 00 00       	call   80104b1f <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100104:	e8 78 4a 00 00       	call   80104b81 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 c6 10 	movl   $0x8010c680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 15 47 00 00       	call   80104839 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 b0 db 10 80       	mov    0x8010dbb0,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010017c:	e8 00 4a 00 00       	call   80104b81 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 23 82 10 80 	movl   $0x80108223,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 d4 25 00 00       	call   801027ac <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 34 82 10 80 	movl   $0x80108234,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 97 25 00 00       	call   801027ac <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 3b 82 10 80 	movl   $0x8010823b,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010023c:	e8 de 48 00 00       	call   80104b1f <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 73 46 00 00       	call   80104915 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801002a9:	e8 d3 48 00 00       	call   80104b81 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 bb 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801003bc:	e8 5e 47 00 00       	call   80104b1f <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 42 82 10 80 	movl   $0x80108242,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 59 03 00 00       	call   80100750 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec 4b 82 10 80 	movl   $0x8010824b,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 87 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100536:	e8 46 46 00 00       	call   80104b81 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 52 82 10 80 	movl   $0x80108252,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 61 82 10 80 	movl   $0x80108261,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 39 46 00 00       	call   80104bd0 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 63 82 10 80 	movl   $0x80108263,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 32                	jmp    8010068a <cgaputc+0xbd>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 23                	jle    8010068a <cgaputc+0xbd>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 1d                	jmp    8010068a <cgaputc+0xbd>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100672:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100675:	01 d2                	add    %edx,%edx
80100677:	01 c2                	add    %eax,%edx
80100679:	8b 45 08             	mov    0x8(%ebp),%eax
8010067c:	66 25 ff 00          	and    $0xff,%ax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)
80100686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x119>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 8a 47 00 00       	call   80104e41 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	01 c0                	add    %eax,%eax
801006c5:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 ca                	add    %ecx,%edx
801006d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 14 24             	mov    %edx,(%esp)
801006e1:	e8 88 46 00 00       	call   80104d6e <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 e0 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 c7 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 b3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 9d fb ff ff       	call   801002da <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 94 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 f2 60 00 00       	call   8010686d <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 e6 60 00 00       	call   8010686d <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 da 60 00 00       	call   8010686d <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 cd 60 00 00       	call   8010686d <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 22 fe ff ff       	call   801005cd <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
801007ba:	e8 60 43 00 00       	call   80104b1f <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 41 01 00 00       	jmp    80100905 <consoleintr+0x158>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 68                	je     8010083e <consoleintr+0x91>
801007d6:	e9 94 00 00 00       	jmp    8010086f <consoleintr+0xc2>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 59                	je     8010083e <consoleintr+0x91>
801007e5:	e9 85 00 00 00       	jmp    8010086f <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 cc 41 00 00       	call   801049bb <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
80100816:	a1 78 de 10 80       	mov    0x8010de78,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 f4 dd 10 80 	movzbl -0x7fef220c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100835:	3c 0a                	cmp    $0xa,%al
80100837:	75 bb                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100839:	e9 c0 00 00 00       	jmp    801008fe <consoleintr+0x151>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083e:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
80100844:	a1 78 de 10 80       	mov    0x8010de78,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
8010085e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100865:	e8 e6 fe ff ff       	call   80100750 <consputc>
      }
      break;
8010086a:	e9 92 00 00 00       	jmp    80100901 <consoleintr+0x154>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100873:	0f 84 8b 00 00 00    	je     80100904 <consoleintr+0x157>
80100879:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
8010087f:	a1 74 de 10 80       	mov    0x8010de74,%eax
80100884:	89 d1                	mov    %edx,%ecx
80100886:	29 c1                	sub    %eax,%ecx
80100888:	89 c8                	mov    %ecx,%eax
8010088a:	83 f8 7f             	cmp    $0x7f,%eax
8010088d:	77 75                	ja     80100904 <consoleintr+0x157>
        c = (c == '\r') ? '\n' : c;
8010088f:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
80100893:	74 05                	je     8010089a <consoleintr+0xed>
80100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100898:	eb 05                	jmp    8010089f <consoleintr+0xf2>
8010089a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008a2:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 f4 dd 10 80    	mov    %dl,-0x7fef220c(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008d9:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008eb:	a3 78 de 10 80       	mov    %eax,0x8010de78
          wakeup(&input.r);
801008f0:	c7 04 24 74 de 10 80 	movl   $0x8010de74,(%esp)
801008f7:	e8 19 40 00 00       	call   80104915 <wakeup>
        }
      }
      break;
801008fc:	eb 06                	jmp    80100904 <consoleintr+0x157>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008fe:	90                   	nop
801008ff:	eb 04                	jmp    80100905 <consoleintr+0x158>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100901:	90                   	nop
80100902:	eb 01                	jmp    80100905 <consoleintr+0x158>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100904:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100905:	8b 45 08             	mov    0x8(%ebp),%eax
80100908:	ff d0                	call   *%eax
8010090a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010090d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100911:	0f 89 ad fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100917:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
8010091e:	e8 5e 42 00 00       	call   80104b81 <release>
}
80100923:	c9                   	leave  
80100924:	c3                   	ret    

80100925 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100925:	55                   	push   %ebp
80100926:	89 e5                	mov    %esp,%ebp
80100928:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010092b:	8b 45 08             	mov    0x8(%ebp),%eax
8010092e:	89 04 24             	mov    %eax,(%esp)
80100931:	e8 78 10 00 00       	call   801019ae <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100943:	e8 d7 41 00 00       	call   80104b1f <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 24             	mov    0x24(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100961:	e8 1b 42 00 00       	call   80104b81 <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 ef 0e 00 00       	call   80101860 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 c0 dd 10 	movl   $0x8010ddc0,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 74 de 10 80 	movl   $0x8010de74,(%esp)
8010098a:	e8 aa 3e 00 00       	call   80104839 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
80100998:	a1 78 de 10 80       	mov    0x8010de78,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 74 de 10 80       	mov    0x8010de74,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 f4 dd 10 80 	movzbl -0x7fef220c(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 74 de 10 80       	mov    %eax,0x8010de74
    if(c == C('D')){  // EOF
801009c0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009c4:	75 17                	jne    801009dd <consoleread+0xb8>
      if(n < target){
801009c6:	8b 45 10             	mov    0x10(%ebp),%eax
801009c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009cc:	73 2f                	jae    801009fd <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009ce:	a1 74 de 10 80       	mov    0x8010de74,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 74 de 10 80       	mov    %eax,0x8010de74
      }
      break;
801009db:	eb 20                	jmp    801009fd <consoleread+0xd8>
    }
    *dst++ = c;
801009dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009e0:	89 c2                	mov    %eax,%edx
801009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801009e5:	88 10                	mov    %dl,(%eax)
801009e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009ef:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009f3:	74 0b                	je     80100a00 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f9:	7f 96                	jg     80100991 <consoleread+0x6c>
801009fb:	eb 04                	jmp    80100a01 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
801009fd:	90                   	nop
801009fe:	eb 01                	jmp    80100a01 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a00:	90                   	nop
  }
  release(&input.lock);
80100a01:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100a08:	e8 74 41 00 00       	call   80104b81 <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 48 0e 00 00       	call   80101860 <ilock>

  return target - n;
80100a18:	8b 45 10             	mov    0x10(%ebp),%eax
80100a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a1e:	89 d1                	mov    %edx,%ecx
80100a20:	29 c1                	sub    %eax,%ecx
80100a22:	89 c8                	mov    %ecx,%eax
}
80100a24:	c9                   	leave  
80100a25:	c3                   	ret    

80100a26 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a26:	55                   	push   %ebp
80100a27:	89 e5                	mov    %esp,%ebp
80100a29:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2f:	89 04 24             	mov    %eax,(%esp)
80100a32:	e8 77 0f 00 00       	call   801019ae <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a3e:	e8 dc 40 00 00       	call   80104b1f <acquire>
  for(i = 0; i < n; i++)
80100a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a4a:	eb 1d                	jmp    80100a69 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a4f:	03 45 0c             	add    0xc(%ebp),%eax
80100a52:	0f b6 00             	movzbl (%eax),%eax
80100a55:	0f be c0             	movsbl %al,%eax
80100a58:	25 ff 00 00 00       	and    $0xff,%eax
80100a5d:	89 04 24             	mov    %eax,(%esp)
80100a60:	e8 eb fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a6f:	7c db                	jl     80100a4c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a71:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a78:	e8 04 41 00 00       	call   80104b81 <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 d8 0d 00 00       	call   80101860 <ilock>

  return n;
80100a88:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a8b:	c9                   	leave  
80100a8c:	c3                   	ret    

80100a8d <consoleinit>:

void
consoleinit(void)
{
80100a8d:	55                   	push   %ebp
80100a8e:	89 e5                	mov    %esp,%ebp
80100a90:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a93:	c7 44 24 04 67 82 10 	movl   $0x80108267,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100aa2:	e8 57 40 00 00       	call   80104afe <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 6f 82 10 	movl   $0x8010826f,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100ab6:	e8 43 40 00 00       	call   80104afe <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 2c e8 10 80 26 	movl   $0x80100a26,0x8010e82c
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 28 e8 10 80 25 	movl   $0x80100925,0x8010e828
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 c4 2f 00 00       	call   80103aa9 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 75 1e 00 00       	call   8010296e <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100b05:	8b 45 08             	mov    0x8(%ebp),%eax
80100b08:	89 04 24             	mov    %eax,(%esp)
80100b0b:	e8 f2 18 00 00       	call   80102402 <namei>
80100b10:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b17:	75 0a                	jne    80100b23 <exec+0x27>
    return -1;
80100b19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1e:	e9 d3 03 00 00       	jmp    80100ef6 <exec+0x3fa>
  ilock(ip);
80100b23:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b26:	89 04 24             	mov    %eax,(%esp)
80100b29:	e8 32 0d 00 00       	call   80101860 <ilock>
  pgdir = 0;
80100b2e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b35:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b3c:	00 
80100b3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b44:	00 
80100b45:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b52:	89 04 24             	mov    %eax,(%esp)
80100b55:	e8 fc 11 00 00       	call   80101d56 <readi>
80100b5a:	83 f8 33             	cmp    $0x33,%eax
80100b5d:	0f 86 4d 03 00 00    	jbe    80100eb0 <exec+0x3b4>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b63:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b69:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6e:	0f 85 3f 03 00 00    	jne    80100eb3 <exec+0x3b7>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b74:	e8 38 6e 00 00       	call   801079b1 <setupkvm>
80100b79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b7c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b80:	0f 84 30 03 00 00    	je     80100eb6 <exec+0x3ba>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b86:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b94:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b9d:	e9 c5 00 00 00       	jmp    80100c67 <exec+0x16b>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ba5:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bac:	00 
80100bad:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bb1:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bbe:	89 04 24             	mov    %eax,(%esp)
80100bc1:	e8 90 11 00 00       	call   80101d56 <readi>
80100bc6:	83 f8 20             	cmp    $0x20,%eax
80100bc9:	0f 85 ea 02 00 00    	jne    80100eb9 <exec+0x3bd>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bcf:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bd5:	83 f8 01             	cmp    $0x1,%eax
80100bd8:	75 7f                	jne    80100c59 <exec+0x15d>
      continue;
    if(ph.memsz < ph.filesz)
80100bda:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be0:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100be6:	39 c2                	cmp    %eax,%edx
80100be8:	0f 82 ce 02 00 00    	jb     80100ebc <exec+0x3c0>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bee:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bf4:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100bfa:	01 d0                	add    %edx,%eax
80100bfc:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c03:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c0a:	89 04 24             	mov    %eax,(%esp)
80100c0d:	e8 71 71 00 00       	call   80107d83 <allocuvm>
80100c12:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c15:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c19:	0f 84 a0 02 00 00    	je     80100ebf <exec+0x3c3>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c1f:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c25:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c2b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c31:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c35:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c39:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c3c:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c40:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c44:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c47:	89 04 24             	mov    %eax,(%esp)
80100c4a:	e8 45 70 00 00       	call   80107c94 <loaduvm>
80100c4f:	85 c0                	test   %eax,%eax
80100c51:	0f 88 6b 02 00 00    	js     80100ec2 <exec+0x3c6>
80100c57:	eb 01                	jmp    80100c5a <exec+0x15e>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c59:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c5a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c61:	83 c0 20             	add    $0x20,%eax
80100c64:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c67:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c6e:	0f b7 c0             	movzwl %ax,%eax
80100c71:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c74:	0f 8f 28 ff ff ff    	jg     80100ba2 <exec+0xa6>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c7d:	89 04 24             	mov    %eax,(%esp)
80100c80:	e8 5f 0e 00 00       	call   80101ae4 <iunlockput>
  ip = 0;
80100c85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100c99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9f:	05 00 20 00 00       	add    $0x2000,%eax
80100ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ca8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cab:	89 44 24 04          	mov    %eax,0x4(%esp)
80100caf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cb2:	89 04 24             	mov    %eax,(%esp)
80100cb5:	e8 c9 70 00 00       	call   80107d83 <allocuvm>
80100cba:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cbd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc1:	0f 84 fe 01 00 00    	je     80100ec5 <exec+0x3c9>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cca:	2d 00 20 00 00       	sub    $0x2000,%eax
80100ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd6:	89 04 24             	mov    %eax,(%esp)
80100cd9:	e8 c9 72 00 00       	call   80107fa7 <clearpteu>
  sp = sz;
80100cde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ce4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ceb:	e9 81 00 00 00       	jmp    80100d71 <exec+0x275>
    if(argc >= MAXARG)
80100cf0:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100cf4:	0f 87 ce 01 00 00    	ja     80100ec8 <exec+0x3cc>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100cfd:	c1 e0 02             	shl    $0x2,%eax
80100d00:	03 45 0c             	add    0xc(%ebp),%eax
80100d03:	8b 00                	mov    (%eax),%eax
80100d05:	89 04 24             	mov    %eax,(%esp)
80100d08:	e8 df 42 00 00       	call   80104fec <strlen>
80100d0d:	f7 d0                	not    %eax
80100d0f:	03 45 dc             	add    -0x24(%ebp),%eax
80100d12:	83 e0 fc             	and    $0xfffffffc,%eax
80100d15:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d1b:	c1 e0 02             	shl    $0x2,%eax
80100d1e:	03 45 0c             	add    0xc(%ebp),%eax
80100d21:	8b 00                	mov    (%eax),%eax
80100d23:	89 04 24             	mov    %eax,(%esp)
80100d26:	e8 c1 42 00 00       	call   80104fec <strlen>
80100d2b:	83 c0 01             	add    $0x1,%eax
80100d2e:	89 c2                	mov    %eax,%edx
80100d30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d33:	c1 e0 02             	shl    $0x2,%eax
80100d36:	03 45 0c             	add    0xc(%ebp),%eax
80100d39:	8b 00                	mov    (%eax),%eax
80100d3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d3f:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d46:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d4d:	89 04 24             	mov    %eax,(%esp)
80100d50:	e8 17 74 00 00       	call   8010816c <copyout>
80100d55:	85 c0                	test   %eax,%eax
80100d57:	0f 88 6e 01 00 00    	js     80100ecb <exec+0x3cf>
      goto bad;
    ustack[3+argc] = sp;
80100d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d60:	8d 50 03             	lea    0x3(%eax),%edx
80100d63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d66:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d6d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d74:	c1 e0 02             	shl    $0x2,%eax
80100d77:	03 45 0c             	add    0xc(%ebp),%eax
80100d7a:	8b 00                	mov    (%eax),%eax
80100d7c:	85 c0                	test   %eax,%eax
80100d7e:	0f 85 6c ff ff ff    	jne    80100cf0 <exec+0x1f4>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100d84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d87:	83 c0 03             	add    $0x3,%eax
80100d8a:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100d91:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100d95:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100d9c:	ff ff ff 
  ustack[1] = argc;
80100d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da2:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100da8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dab:	83 c0 01             	add    $0x1,%eax
80100dae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100db8:	29 d0                	sub    %edx,%eax
80100dba:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100dc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc3:	83 c0 04             	add    $0x4,%eax
80100dc6:	c1 e0 02             	shl    $0x2,%eax
80100dc9:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcf:	83 c0 04             	add    $0x4,%eax
80100dd2:	c1 e0 02             	shl    $0x2,%eax
80100dd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100dd9:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100ddf:	89 44 24 08          	mov    %eax,0x8(%esp)
80100de3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ded:	89 04 24             	mov    %eax,(%esp)
80100df0:	e8 77 73 00 00       	call   8010816c <copyout>
80100df5:	85 c0                	test   %eax,%eax
80100df7:	0f 88 d1 00 00 00    	js     80100ece <exec+0x3d2>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80100e00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e09:	eb 17                	jmp    80100e22 <exec+0x326>
    if(*s == '/')
80100e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e0e:	0f b6 00             	movzbl (%eax),%eax
80100e11:	3c 2f                	cmp    $0x2f,%al
80100e13:	75 09                	jne    80100e1e <exec+0x322>
      last = s+1;
80100e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e18:	83 c0 01             	add    $0x1,%eax
80100e1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e25:	0f b6 00             	movzbl (%eax),%eax
80100e28:	84 c0                	test   %al,%al
80100e2a:	75 df                	jne    80100e0b <exec+0x30f>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e32:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e35:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e3c:	00 
80100e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e40:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e44:	89 14 24             	mov    %edx,(%esp)
80100e47:	e8 52 41 00 00       	call   80104f9e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e52:	8b 40 04             	mov    0x4(%eax),%eax
80100e55:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e5e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e61:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e6a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e6d:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e75:	8b 40 18             	mov    0x18(%eax),%eax
80100e78:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e7e:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e87:	8b 40 18             	mov    0x18(%eax),%eax
80100e8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e8d:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e96:	89 04 24             	mov    %eax,(%esp)
80100e99:	e8 04 6c 00 00       	call   80107aa2 <switchuvm>
  freevm(oldpgdir);
80100e9e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ea1:	89 04 24             	mov    %eax,(%esp)
80100ea4:	e8 70 70 00 00       	call   80107f19 <freevm>
  return 0;
80100ea9:	b8 00 00 00 00       	mov    $0x0,%eax
80100eae:	eb 46                	jmp    80100ef6 <exec+0x3fa>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100eb0:	90                   	nop
80100eb1:	eb 1c                	jmp    80100ecf <exec+0x3d3>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100eb3:	90                   	nop
80100eb4:	eb 19                	jmp    80100ecf <exec+0x3d3>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100eb6:	90                   	nop
80100eb7:	eb 16                	jmp    80100ecf <exec+0x3d3>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100eb9:	90                   	nop
80100eba:	eb 13                	jmp    80100ecf <exec+0x3d3>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ebc:	90                   	nop
80100ebd:	eb 10                	jmp    80100ecf <exec+0x3d3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ebf:	90                   	nop
80100ec0:	eb 0d                	jmp    80100ecf <exec+0x3d3>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ec2:	90                   	nop
80100ec3:	eb 0a                	jmp    80100ecf <exec+0x3d3>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ec5:	90                   	nop
80100ec6:	eb 07                	jmp    80100ecf <exec+0x3d3>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ec8:	90                   	nop
80100ec9:	eb 04                	jmp    80100ecf <exec+0x3d3>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100ecb:	90                   	nop
80100ecc:	eb 01                	jmp    80100ecf <exec+0x3d3>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100ece:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ecf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ed3:	74 0b                	je     80100ee0 <exec+0x3e4>
    freevm(pgdir);
80100ed5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ed8:	89 04 24             	mov    %eax,(%esp)
80100edb:	e8 39 70 00 00       	call   80107f19 <freevm>
  if(ip)
80100ee0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ee4:	74 0b                	je     80100ef1 <exec+0x3f5>
    iunlockput(ip);
80100ee6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ee9:	89 04 24             	mov    %eax,(%esp)
80100eec:	e8 f3 0b 00 00       	call   80101ae4 <iunlockput>
  return -1;
80100ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100ef6:	c9                   	leave  
80100ef7:	c3                   	ret    

80100ef8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100ef8:	55                   	push   %ebp
80100ef9:	89 e5                	mov    %esp,%ebp
80100efb:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100efe:	c7 44 24 04 75 82 10 	movl   $0x80108275,0x4(%esp)
80100f05:	80 
80100f06:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f0d:	e8 ec 3b 00 00       	call   80104afe <initlock>
}
80100f12:	c9                   	leave  
80100f13:	c3                   	ret    

80100f14 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f14:	55                   	push   %ebp
80100f15:	89 e5                	mov    %esp,%ebp
80100f17:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f1a:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f21:	e8 f9 3b 00 00       	call   80104b1f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f26:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80100f2d:	eb 29                	jmp    80100f58 <filealloc+0x44>
    if(f->ref == 0){
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	8b 40 04             	mov    0x4(%eax),%eax
80100f35:	85 c0                	test   %eax,%eax
80100f37:	75 1b                	jne    80100f54 <filealloc+0x40>
      f->ref = 1;
80100f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f3c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f43:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f4a:	e8 32 3c 00 00       	call   80104b81 <release>
      return f;
80100f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f52:	eb 1e                	jmp    80100f72 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f54:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f58:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
80100f5f:	72 ce                	jb     80100f2f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f61:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f68:	e8 14 3c 00 00       	call   80104b81 <release>
  return 0;
80100f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f72:	c9                   	leave  
80100f73:	c3                   	ret    

80100f74 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f74:	55                   	push   %ebp
80100f75:	89 e5                	mov    %esp,%ebp
80100f77:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f7a:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f81:	e8 99 3b 00 00       	call   80104b1f <acquire>
  if(f->ref < 1)
80100f86:	8b 45 08             	mov    0x8(%ebp),%eax
80100f89:	8b 40 04             	mov    0x4(%eax),%eax
80100f8c:	85 c0                	test   %eax,%eax
80100f8e:	7f 0c                	jg     80100f9c <filedup+0x28>
    panic("filedup");
80100f90:	c7 04 24 7c 82 10 80 	movl   $0x8010827c,(%esp)
80100f97:	e8 a1 f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9f:	8b 40 04             	mov    0x4(%eax),%eax
80100fa2:	8d 50 01             	lea    0x1(%eax),%edx
80100fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fab:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100fb2:	e8 ca 3b 00 00       	call   80104b81 <release>
  return f;
80100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fba:	c9                   	leave  
80100fbb:	c3                   	ret    

80100fbc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fbc:	55                   	push   %ebp
80100fbd:	89 e5                	mov    %esp,%ebp
80100fbf:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fc2:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100fc9:	e8 51 3b 00 00       	call   80104b1f <acquire>
  if(f->ref < 1)
80100fce:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd1:	8b 40 04             	mov    0x4(%eax),%eax
80100fd4:	85 c0                	test   %eax,%eax
80100fd6:	7f 0c                	jg     80100fe4 <fileclose+0x28>
    panic("fileclose");
80100fd8:	c7 04 24 84 82 10 80 	movl   $0x80108284,(%esp)
80100fdf:	e8 59 f5 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe7:	8b 40 04             	mov    0x4(%eax),%eax
80100fea:	8d 50 ff             	lea    -0x1(%eax),%edx
80100fed:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff0:	89 50 04             	mov    %edx,0x4(%eax)
80100ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff6:	8b 40 04             	mov    0x4(%eax),%eax
80100ff9:	85 c0                	test   %eax,%eax
80100ffb:	7e 11                	jle    8010100e <fileclose+0x52>
    release(&ftable.lock);
80100ffd:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101004:	e8 78 3b 00 00       	call   80104b81 <release>
    return;
80101009:	e9 82 00 00 00       	jmp    80101090 <fileclose+0xd4>
  }
  ff = *f;
8010100e:	8b 45 08             	mov    0x8(%ebp),%eax
80101011:	8b 10                	mov    (%eax),%edx
80101013:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101016:	8b 50 04             	mov    0x4(%eax),%edx
80101019:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010101c:	8b 50 08             	mov    0x8(%eax),%edx
8010101f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101022:	8b 50 0c             	mov    0xc(%eax),%edx
80101025:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101028:	8b 50 10             	mov    0x10(%eax),%edx
8010102b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010102e:	8b 40 14             	mov    0x14(%eax),%eax
80101031:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101034:	8b 45 08             	mov    0x8(%ebp),%eax
80101037:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010103e:	8b 45 08             	mov    0x8(%ebp),%eax
80101041:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101047:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010104e:	e8 2e 3b 00 00       	call   80104b81 <release>
  
  if(ff.type == FD_PIPE)
80101053:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101056:	83 f8 01             	cmp    $0x1,%eax
80101059:	75 18                	jne    80101073 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010105b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010105f:	0f be d0             	movsbl %al,%edx
80101062:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101065:	89 54 24 04          	mov    %edx,0x4(%esp)
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 f2 2c 00 00       	call   80103d63 <pipeclose>
80101071:	eb 1d                	jmp    80101090 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101073:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101076:	83 f8 02             	cmp    $0x2,%eax
80101079:	75 15                	jne    80101090 <fileclose+0xd4>
    begin_trans();
8010107b:	e8 95 21 00 00       	call   80103215 <begin_trans>
    iput(ff.ip);
80101080:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101083:	89 04 24             	mov    %eax,(%esp)
80101086:	e8 88 09 00 00       	call   80101a13 <iput>
    commit_trans();
8010108b:	e8 ce 21 00 00       	call   8010325e <commit_trans>
  }
}
80101090:	c9                   	leave  
80101091:	c3                   	ret    

80101092 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101092:	55                   	push   %ebp
80101093:	89 e5                	mov    %esp,%ebp
80101095:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	8b 00                	mov    (%eax),%eax
8010109d:	83 f8 02             	cmp    $0x2,%eax
801010a0:	75 38                	jne    801010da <filestat+0x48>
    ilock(f->ip);
801010a2:	8b 45 08             	mov    0x8(%ebp),%eax
801010a5:	8b 40 10             	mov    0x10(%eax),%eax
801010a8:	89 04 24             	mov    %eax,(%esp)
801010ab:	e8 b0 07 00 00       	call   80101860 <ilock>
    stati(f->ip, st);
801010b0:	8b 45 08             	mov    0x8(%ebp),%eax
801010b3:	8b 40 10             	mov    0x10(%eax),%eax
801010b6:	8b 55 0c             	mov    0xc(%ebp),%edx
801010b9:	89 54 24 04          	mov    %edx,0x4(%esp)
801010bd:	89 04 24             	mov    %eax,(%esp)
801010c0:	e8 4c 0c 00 00       	call   80101d11 <stati>
    iunlock(f->ip);
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 10             	mov    0x10(%eax),%eax
801010cb:	89 04 24             	mov    %eax,(%esp)
801010ce:	e8 db 08 00 00       	call   801019ae <iunlock>
    return 0;
801010d3:	b8 00 00 00 00       	mov    $0x0,%eax
801010d8:	eb 05                	jmp    801010df <filestat+0x4d>
  }
  return -1;
801010da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010df:	c9                   	leave  
801010e0:	c3                   	ret    

801010e1 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010e1:	55                   	push   %ebp
801010e2:	89 e5                	mov    %esp,%ebp
801010e4:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010e7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ea:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801010ee:	84 c0                	test   %al,%al
801010f0:	75 0a                	jne    801010fc <fileread+0x1b>
    return -1;
801010f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010f7:	e9 9f 00 00 00       	jmp    8010119b <fileread+0xba>
  if(f->type == FD_PIPE)
801010fc:	8b 45 08             	mov    0x8(%ebp),%eax
801010ff:	8b 00                	mov    (%eax),%eax
80101101:	83 f8 01             	cmp    $0x1,%eax
80101104:	75 1e                	jne    80101124 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101106:	8b 45 08             	mov    0x8(%ebp),%eax
80101109:	8b 40 0c             	mov    0xc(%eax),%eax
8010110c:	8b 55 10             	mov    0x10(%ebp),%edx
8010110f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101113:	8b 55 0c             	mov    0xc(%ebp),%edx
80101116:	89 54 24 04          	mov    %edx,0x4(%esp)
8010111a:	89 04 24             	mov    %eax,(%esp)
8010111d:	e8 c3 2d 00 00       	call   80103ee5 <piperead>
80101122:	eb 77                	jmp    8010119b <fileread+0xba>
  if(f->type == FD_INODE){
80101124:	8b 45 08             	mov    0x8(%ebp),%eax
80101127:	8b 00                	mov    (%eax),%eax
80101129:	83 f8 02             	cmp    $0x2,%eax
8010112c:	75 61                	jne    8010118f <fileread+0xae>
    ilock(f->ip);
8010112e:	8b 45 08             	mov    0x8(%ebp),%eax
80101131:	8b 40 10             	mov    0x10(%eax),%eax
80101134:	89 04 24             	mov    %eax,(%esp)
80101137:	e8 24 07 00 00       	call   80101860 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010113c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
80101142:	8b 50 14             	mov    0x14(%eax),%edx
80101145:	8b 45 08             	mov    0x8(%ebp),%eax
80101148:	8b 40 10             	mov    0x10(%eax),%eax
8010114b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010114f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101153:	8b 55 0c             	mov    0xc(%ebp),%edx
80101156:	89 54 24 04          	mov    %edx,0x4(%esp)
8010115a:	89 04 24             	mov    %eax,(%esp)
8010115d:	e8 f4 0b 00 00       	call   80101d56 <readi>
80101162:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101165:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101169:	7e 11                	jle    8010117c <fileread+0x9b>
      f->off += r;
8010116b:	8b 45 08             	mov    0x8(%ebp),%eax
8010116e:	8b 50 14             	mov    0x14(%eax),%edx
80101171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101174:	01 c2                	add    %eax,%edx
80101176:	8b 45 08             	mov    0x8(%ebp),%eax
80101179:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010117c:	8b 45 08             	mov    0x8(%ebp),%eax
8010117f:	8b 40 10             	mov    0x10(%eax),%eax
80101182:	89 04 24             	mov    %eax,(%esp)
80101185:	e8 24 08 00 00       	call   801019ae <iunlock>
    return r;
8010118a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010118d:	eb 0c                	jmp    8010119b <fileread+0xba>
  }
  panic("fileread");
8010118f:	c7 04 24 8e 82 10 80 	movl   $0x8010828e,(%esp)
80101196:	e8 a2 f3 ff ff       	call   8010053d <panic>
}
8010119b:	c9                   	leave  
8010119c:	c3                   	ret    

8010119d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010119d:	55                   	push   %ebp
8010119e:	89 e5                	mov    %esp,%ebp
801011a0:	53                   	push   %ebx
801011a1:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011a4:	8b 45 08             	mov    0x8(%ebp),%eax
801011a7:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011ab:	84 c0                	test   %al,%al
801011ad:	75 0a                	jne    801011b9 <filewrite+0x1c>
    return -1;
801011af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011b4:	e9 23 01 00 00       	jmp    801012dc <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011b9:	8b 45 08             	mov    0x8(%ebp),%eax
801011bc:	8b 00                	mov    (%eax),%eax
801011be:	83 f8 01             	cmp    $0x1,%eax
801011c1:	75 21                	jne    801011e4 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	8b 40 0c             	mov    0xc(%eax),%eax
801011c9:	8b 55 10             	mov    0x10(%ebp),%edx
801011cc:	89 54 24 08          	mov    %edx,0x8(%esp)
801011d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801011d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801011d7:	89 04 24             	mov    %eax,(%esp)
801011da:	e8 16 2c 00 00       	call   80103df5 <pipewrite>
801011df:	e9 f8 00 00 00       	jmp    801012dc <filewrite+0x13f>
  if(f->type == FD_INODE){
801011e4:	8b 45 08             	mov    0x8(%ebp),%eax
801011e7:	8b 00                	mov    (%eax),%eax
801011e9:	83 f8 02             	cmp    $0x2,%eax
801011ec:	0f 85 de 00 00 00    	jne    801012d0 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801011f2:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801011f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101200:	e9 a8 00 00 00       	jmp    801012ad <filewrite+0x110>
      int n1 = n - i;
80101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101208:	8b 55 10             	mov    0x10(%ebp),%edx
8010120b:	89 d1                	mov    %edx,%ecx
8010120d:	29 c1                	sub    %eax,%ecx
8010120f:	89 c8                	mov    %ecx,%eax
80101211:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101214:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101217:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010121a:	7e 06                	jle    80101222 <filewrite+0x85>
        n1 = max;
8010121c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010121f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101222:	e8 ee 1f 00 00       	call   80103215 <begin_trans>
      ilock(f->ip);
80101227:	8b 45 08             	mov    0x8(%ebp),%eax
8010122a:	8b 40 10             	mov    0x10(%eax),%eax
8010122d:	89 04 24             	mov    %eax,(%esp)
80101230:	e8 2b 06 00 00       	call   80101860 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101235:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 48 14             	mov    0x14(%eax),%ecx
8010123e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101241:	89 c2                	mov    %eax,%edx
80101243:	03 55 0c             	add    0xc(%ebp),%edx
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	8b 40 10             	mov    0x10(%eax),%eax
8010124c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101250:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101254:	89 54 24 04          	mov    %edx,0x4(%esp)
80101258:	89 04 24             	mov    %eax,(%esp)
8010125b:	e8 61 0c 00 00       	call   80101ec1 <writei>
80101260:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101263:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101267:	7e 11                	jle    8010127a <filewrite+0xdd>
        f->off += r;
80101269:	8b 45 08             	mov    0x8(%ebp),%eax
8010126c:	8b 50 14             	mov    0x14(%eax),%edx
8010126f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101272:	01 c2                	add    %eax,%edx
80101274:	8b 45 08             	mov    0x8(%ebp),%eax
80101277:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010127a:	8b 45 08             	mov    0x8(%ebp),%eax
8010127d:	8b 40 10             	mov    0x10(%eax),%eax
80101280:	89 04 24             	mov    %eax,(%esp)
80101283:	e8 26 07 00 00       	call   801019ae <iunlock>
      commit_trans();
80101288:	e8 d1 1f 00 00       	call   8010325e <commit_trans>

      if(r < 0)
8010128d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101291:	78 28                	js     801012bb <filewrite+0x11e>
        break;
      if(r != n1)
80101293:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101296:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101299:	74 0c                	je     801012a7 <filewrite+0x10a>
        panic("short filewrite");
8010129b:	c7 04 24 97 82 10 80 	movl   $0x80108297,(%esp)
801012a2:	e8 96 f2 ff ff       	call   8010053d <panic>
      i += r;
801012a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012aa:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b0:	3b 45 10             	cmp    0x10(%ebp),%eax
801012b3:	0f 8c 4c ff ff ff    	jl     80101205 <filewrite+0x68>
801012b9:	eb 01                	jmp    801012bc <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801012bb:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012bf:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c2:	75 05                	jne    801012c9 <filewrite+0x12c>
801012c4:	8b 45 10             	mov    0x10(%ebp),%eax
801012c7:	eb 05                	jmp    801012ce <filewrite+0x131>
801012c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012ce:	eb 0c                	jmp    801012dc <filewrite+0x13f>
  }
  panic("filewrite");
801012d0:	c7 04 24 a7 82 10 80 	movl   $0x801082a7,(%esp)
801012d7:	e8 61 f2 ff ff       	call   8010053d <panic>
}
801012dc:	83 c4 24             	add    $0x24,%esp
801012df:	5b                   	pop    %ebx
801012e0:	5d                   	pop    %ebp
801012e1:	c3                   	ret    
	...

801012e4 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012e4:	55                   	push   %ebp
801012e5:	89 e5                	mov    %esp,%ebp
801012e7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012ea:	8b 45 08             	mov    0x8(%ebp),%eax
801012ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801012f4:	00 
801012f5:	89 04 24             	mov    %eax,(%esp)
801012f8:	e8 a9 ee ff ff       	call   801001a6 <bread>
801012fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101303:	83 c0 18             	add    $0x18,%eax
80101306:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010130d:	00 
8010130e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101312:	8b 45 0c             	mov    0xc(%ebp),%eax
80101315:	89 04 24             	mov    %eax,(%esp)
80101318:	e8 24 3b 00 00       	call   80104e41 <memmove>
  brelse(bp);
8010131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101320:	89 04 24             	mov    %eax,(%esp)
80101323:	e8 ef ee ff ff       	call   80100217 <brelse>
}
80101328:	c9                   	leave  
80101329:	c3                   	ret    

8010132a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010132a:	55                   	push   %ebp
8010132b:	89 e5                	mov    %esp,%ebp
8010132d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101330:	8b 55 0c             	mov    0xc(%ebp),%edx
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	89 54 24 04          	mov    %edx,0x4(%esp)
8010133a:	89 04 24             	mov    %eax,(%esp)
8010133d:	e8 64 ee ff ff       	call   801001a6 <bread>
80101342:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	83 c0 18             	add    $0x18,%eax
8010134b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101352:	00 
80101353:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010135a:	00 
8010135b:	89 04 24             	mov    %eax,(%esp)
8010135e:	e8 0b 3a 00 00       	call   80104d6e <memset>
  log_write(bp);
80101363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101366:	89 04 24             	mov    %eax,(%esp)
80101369:	e8 48 1f 00 00       	call   801032b6 <log_write>
  brelse(bp);
8010136e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101371:	89 04 24             	mov    %eax,(%esp)
80101374:	e8 9e ee ff ff       	call   80100217 <brelse>
}
80101379:	c9                   	leave  
8010137a:	c3                   	ret    

8010137b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010137b:	55                   	push   %ebp
8010137c:	89 e5                	mov    %esp,%ebp
8010137e:	53                   	push   %ebx
8010137f:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101382:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010138f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101393:	89 04 24             	mov    %eax,(%esp)
80101396:	e8 49 ff ff ff       	call   801012e4 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010139b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013a2:	e9 11 01 00 00       	jmp    801014b8 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013aa:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013b0:	85 c0                	test   %eax,%eax
801013b2:	0f 48 c2             	cmovs  %edx,%eax
801013b5:	c1 f8 0c             	sar    $0xc,%eax
801013b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013bb:	c1 ea 03             	shr    $0x3,%edx
801013be:	01 d0                	add    %edx,%eax
801013c0:	83 c0 03             	add    $0x3,%eax
801013c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801013c7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ca:	89 04 24             	mov    %eax,(%esp)
801013cd:	e8 d4 ed ff ff       	call   801001a6 <bread>
801013d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013d5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013dc:	e9 a7 00 00 00       	jmp    80101488 <balloc+0x10d>
      m = 1 << (bi % 8);
801013e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013e4:	89 c2                	mov    %eax,%edx
801013e6:	c1 fa 1f             	sar    $0x1f,%edx
801013e9:	c1 ea 1d             	shr    $0x1d,%edx
801013ec:	01 d0                	add    %edx,%eax
801013ee:	83 e0 07             	and    $0x7,%eax
801013f1:	29 d0                	sub    %edx,%eax
801013f3:	ba 01 00 00 00       	mov    $0x1,%edx
801013f8:	89 d3                	mov    %edx,%ebx
801013fa:	89 c1                	mov    %eax,%ecx
801013fc:	d3 e3                	shl    %cl,%ebx
801013fe:	89 d8                	mov    %ebx,%eax
80101400:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101403:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101406:	8d 50 07             	lea    0x7(%eax),%edx
80101409:	85 c0                	test   %eax,%eax
8010140b:	0f 48 c2             	cmovs  %edx,%eax
8010140e:	c1 f8 03             	sar    $0x3,%eax
80101411:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101414:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101419:	0f b6 c0             	movzbl %al,%eax
8010141c:	23 45 e8             	and    -0x18(%ebp),%eax
8010141f:	85 c0                	test   %eax,%eax
80101421:	75 61                	jne    80101484 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101423:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101426:	8d 50 07             	lea    0x7(%eax),%edx
80101429:	85 c0                	test   %eax,%eax
8010142b:	0f 48 c2             	cmovs  %edx,%eax
8010142e:	c1 f8 03             	sar    $0x3,%eax
80101431:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101434:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101439:	89 d1                	mov    %edx,%ecx
8010143b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010143e:	09 ca                	or     %ecx,%edx
80101440:	89 d1                	mov    %edx,%ecx
80101442:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101445:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101449:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010144c:	89 04 24             	mov    %eax,(%esp)
8010144f:	e8 62 1e 00 00       	call   801032b6 <log_write>
        brelse(bp);
80101454:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101457:	89 04 24             	mov    %eax,(%esp)
8010145a:	e8 b8 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010145f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101462:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101465:	01 c2                	add    %eax,%edx
80101467:	8b 45 08             	mov    0x8(%ebp),%eax
8010146a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010146e:	89 04 24             	mov    %eax,(%esp)
80101471:	e8 b4 fe ff ff       	call   8010132a <bzero>
        return b + bi;
80101476:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101479:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010147c:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
8010147e:	83 c4 34             	add    $0x34,%esp
80101481:	5b                   	pop    %ebx
80101482:	5d                   	pop    %ebp
80101483:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101484:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101488:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010148f:	7f 15                	jg     801014a6 <balloc+0x12b>
80101491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101494:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101497:	01 d0                	add    %edx,%eax
80101499:	89 c2                	mov    %eax,%edx
8010149b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010149e:	39 c2                	cmp    %eax,%edx
801014a0:	0f 82 3b ff ff ff    	jb     801013e1 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014a9:	89 04 24             	mov    %eax,(%esp)
801014ac:	e8 66 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014b1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014be:	39 c2                	cmp    %eax,%edx
801014c0:	0f 82 e1 fe ff ff    	jb     801013a7 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014c6:	c7 04 24 b1 82 10 80 	movl   $0x801082b1,(%esp)
801014cd:	e8 6b f0 ff ff       	call   8010053d <panic>

801014d2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014d2:	55                   	push   %ebp
801014d3:	89 e5                	mov    %esp,%ebp
801014d5:	53                   	push   %ebx
801014d6:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014d9:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801014e0:	8b 45 08             	mov    0x8(%ebp),%eax
801014e3:	89 04 24             	mov    %eax,(%esp)
801014e6:	e8 f9 fd ff ff       	call   801012e4 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801014ee:	89 c2                	mov    %eax,%edx
801014f0:	c1 ea 0c             	shr    $0xc,%edx
801014f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014f6:	c1 e8 03             	shr    $0x3,%eax
801014f9:	01 d0                	add    %edx,%eax
801014fb:	8d 50 03             	lea    0x3(%eax),%edx
801014fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101501:	89 54 24 04          	mov    %edx,0x4(%esp)
80101505:	89 04 24             	mov    %eax,(%esp)
80101508:	e8 99 ec ff ff       	call   801001a6 <bread>
8010150d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101510:	8b 45 0c             	mov    0xc(%ebp),%eax
80101513:	25 ff 0f 00 00       	and    $0xfff,%eax
80101518:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151e:	89 c2                	mov    %eax,%edx
80101520:	c1 fa 1f             	sar    $0x1f,%edx
80101523:	c1 ea 1d             	shr    $0x1d,%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	83 e0 07             	and    $0x7,%eax
8010152b:	29 d0                	sub    %edx,%eax
8010152d:	ba 01 00 00 00       	mov    $0x1,%edx
80101532:	89 d3                	mov    %edx,%ebx
80101534:	89 c1                	mov    %eax,%ecx
80101536:	d3 e3                	shl    %cl,%ebx
80101538:	89 d8                	mov    %ebx,%eax
8010153a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101540:	8d 50 07             	lea    0x7(%eax),%edx
80101543:	85 c0                	test   %eax,%eax
80101545:	0f 48 c2             	cmovs  %edx,%eax
80101548:	c1 f8 03             	sar    $0x3,%eax
8010154b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010154e:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101553:	0f b6 c0             	movzbl %al,%eax
80101556:	23 45 ec             	and    -0x14(%ebp),%eax
80101559:	85 c0                	test   %eax,%eax
8010155b:	75 0c                	jne    80101569 <bfree+0x97>
    panic("freeing free block");
8010155d:	c7 04 24 c7 82 10 80 	movl   $0x801082c7,(%esp)
80101564:	e8 d4 ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	8d 50 07             	lea    0x7(%eax),%edx
8010156f:	85 c0                	test   %eax,%eax
80101571:	0f 48 c2             	cmovs  %edx,%eax
80101574:	c1 f8 03             	sar    $0x3,%eax
80101577:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157a:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010157f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101582:	f7 d1                	not    %ecx
80101584:	21 ca                	and    %ecx,%edx
80101586:	89 d1                	mov    %edx,%ecx
80101588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010158f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101592:	89 04 24             	mov    %eax,(%esp)
80101595:	e8 1c 1d 00 00       	call   801032b6 <log_write>
  brelse(bp);
8010159a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159d:	89 04 24             	mov    %eax,(%esp)
801015a0:	e8 72 ec ff ff       	call   80100217 <brelse>
}
801015a5:	83 c4 34             	add    $0x34,%esp
801015a8:	5b                   	pop    %ebx
801015a9:	5d                   	pop    %ebp
801015aa:	c3                   	ret    

801015ab <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015ab:	55                   	push   %ebp
801015ac:	89 e5                	mov    %esp,%ebp
801015ae:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015b1:	c7 44 24 04 da 82 10 	movl   $0x801082da,0x4(%esp)
801015b8:	80 
801015b9:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801015c0:	e8 39 35 00 00       	call   80104afe <initlock>
}
801015c5:	c9                   	leave  
801015c6:	c3                   	ret    

801015c7 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015c7:	55                   	push   %ebp
801015c8:	89 e5                	mov    %esp,%ebp
801015ca:	83 ec 48             	sub    $0x48,%esp
801015cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d0:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015d4:	8b 45 08             	mov    0x8(%ebp),%eax
801015d7:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015da:	89 54 24 04          	mov    %edx,0x4(%esp)
801015de:	89 04 24             	mov    %eax,(%esp)
801015e1:	e8 fe fc ff ff       	call   801012e4 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015e6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015ed:	e9 98 00 00 00       	jmp    8010168a <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f5:	c1 e8 03             	shr    $0x3,%eax
801015f8:	83 c0 02             	add    $0x2,%eax
801015fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801015ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101602:	89 04 24             	mov    %eax,(%esp)
80101605:	e8 9c eb ff ff       	call   801001a6 <bread>
8010160a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101610:	8d 50 18             	lea    0x18(%eax),%edx
80101613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101616:	83 e0 07             	and    $0x7,%eax
80101619:	c1 e0 06             	shl    $0x6,%eax
8010161c:	01 d0                	add    %edx,%eax
8010161e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101621:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101624:	0f b7 00             	movzwl (%eax),%eax
80101627:	66 85 c0             	test   %ax,%ax
8010162a:	75 4f                	jne    8010167b <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010162c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101633:	00 
80101634:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010163b:	00 
8010163c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010163f:	89 04 24             	mov    %eax,(%esp)
80101642:	e8 27 37 00 00       	call   80104d6e <memset>
      dip->type = type;
80101647:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010164a:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010164e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101654:	89 04 24             	mov    %eax,(%esp)
80101657:	e8 5a 1c 00 00       	call   801032b6 <log_write>
      brelse(bp);
8010165c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165f:	89 04 24             	mov    %eax,(%esp)
80101662:	e8 b0 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010166a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010166e:	8b 45 08             	mov    0x8(%ebp),%eax
80101671:	89 04 24             	mov    %eax,(%esp)
80101674:	e8 e3 00 00 00       	call   8010175c <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101679:	c9                   	leave  
8010167a:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167e:	89 04 24             	mov    %eax,(%esp)
80101681:	e8 91 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010168d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101690:	39 c2                	cmp    %eax,%edx
80101692:	0f 82 5a ff ff ff    	jb     801015f2 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101698:	c7 04 24 e1 82 10 80 	movl   $0x801082e1,(%esp)
8010169f:	e8 99 ee ff ff       	call   8010053d <panic>

801016a4 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016a4:	55                   	push   %ebp
801016a5:	89 e5                	mov    %esp,%ebp
801016a7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016aa:	8b 45 08             	mov    0x8(%ebp),%eax
801016ad:	8b 40 04             	mov    0x4(%eax),%eax
801016b0:	c1 e8 03             	shr    $0x3,%eax
801016b3:	8d 50 02             	lea    0x2(%eax),%edx
801016b6:	8b 45 08             	mov    0x8(%ebp),%eax
801016b9:	8b 00                	mov    (%eax),%eax
801016bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801016bf:	89 04 24             	mov    %eax,(%esp)
801016c2:	e8 df ea ff ff       	call   801001a6 <bread>
801016c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cd:	8d 50 18             	lea    0x18(%eax),%edx
801016d0:	8b 45 08             	mov    0x8(%ebp),%eax
801016d3:	8b 40 04             	mov    0x4(%eax),%eax
801016d6:	83 e0 07             	and    $0x7,%eax
801016d9:	c1 e0 06             	shl    $0x6,%eax
801016dc:	01 d0                	add    %edx,%eax
801016de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016e1:	8b 45 08             	mov    0x8(%ebp),%eax
801016e4:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016eb:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016ee:	8b 45 08             	mov    0x8(%ebp),%eax
801016f1:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f8:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016fc:	8b 45 08             	mov    0x8(%ebp),%eax
801016ff:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101703:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101706:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010170a:	8b 45 08             	mov    0x8(%ebp),%eax
8010170d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101711:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101714:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101718:	8b 45 08             	mov    0x8(%ebp),%eax
8010171b:	8b 50 18             	mov    0x18(%eax),%edx
8010171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101721:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101724:	8b 45 08             	mov    0x8(%ebp),%eax
80101727:	8d 50 1c             	lea    0x1c(%eax),%edx
8010172a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010172d:	83 c0 0c             	add    $0xc,%eax
80101730:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101737:	00 
80101738:	89 54 24 04          	mov    %edx,0x4(%esp)
8010173c:	89 04 24             	mov    %eax,(%esp)
8010173f:	e8 fd 36 00 00       	call   80104e41 <memmove>
  log_write(bp);
80101744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101747:	89 04 24             	mov    %eax,(%esp)
8010174a:	e8 67 1b 00 00       	call   801032b6 <log_write>
  brelse(bp);
8010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101752:	89 04 24             	mov    %eax,(%esp)
80101755:	e8 bd ea ff ff       	call   80100217 <brelse>
}
8010175a:	c9                   	leave  
8010175b:	c3                   	ret    

8010175c <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010175c:	55                   	push   %ebp
8010175d:	89 e5                	mov    %esp,%ebp
8010175f:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101762:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101769:	e8 b1 33 00 00       	call   80104b1f <acquire>

  // Is the inode already cached?
  empty = 0;
8010176e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101775:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
8010177c:	eb 59                	jmp    801017d7 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010177e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101781:	8b 40 08             	mov    0x8(%eax),%eax
80101784:	85 c0                	test   %eax,%eax
80101786:	7e 35                	jle    801017bd <iget+0x61>
80101788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010178b:	8b 00                	mov    (%eax),%eax
8010178d:	3b 45 08             	cmp    0x8(%ebp),%eax
80101790:	75 2b                	jne    801017bd <iget+0x61>
80101792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101795:	8b 40 04             	mov    0x4(%eax),%eax
80101798:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010179b:	75 20                	jne    801017bd <iget+0x61>
      ip->ref++;
8010179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a0:	8b 40 08             	mov    0x8(%eax),%eax
801017a3:	8d 50 01             	lea    0x1(%eax),%edx
801017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a9:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017ac:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801017b3:	e8 c9 33 00 00       	call   80104b81 <release>
      return ip;
801017b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bb:	eb 6f                	jmp    8010182c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017c1:	75 10                	jne    801017d3 <iget+0x77>
801017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c6:	8b 40 08             	mov    0x8(%eax),%eax
801017c9:	85 c0                	test   %eax,%eax
801017cb:	75 06                	jne    801017d3 <iget+0x77>
      empty = ip;
801017cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017d3:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017d7:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
801017de:	72 9e                	jb     8010177e <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017e4:	75 0c                	jne    801017f2 <iget+0x96>
    panic("iget: no inodes");
801017e6:	c7 04 24 f3 82 10 80 	movl   $0x801082f3,(%esp)
801017ed:	e8 4b ed ff ff       	call   8010053d <panic>

  ip = empty;
801017f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fb:	8b 55 08             	mov    0x8(%ebp),%edx
801017fe:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101803:	8b 55 0c             	mov    0xc(%ebp),%edx
80101806:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101816:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010181d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101824:	e8 58 33 00 00       	call   80104b81 <release>

  return ip;
80101829:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010182c:	c9                   	leave  
8010182d:	c3                   	ret    

8010182e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010182e:	55                   	push   %ebp
8010182f:	89 e5                	mov    %esp,%ebp
80101831:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101834:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010183b:	e8 df 32 00 00       	call   80104b1f <acquire>
  ip->ref++;
80101840:	8b 45 08             	mov    0x8(%ebp),%eax
80101843:	8b 40 08             	mov    0x8(%eax),%eax
80101846:	8d 50 01             	lea    0x1(%eax),%edx
80101849:	8b 45 08             	mov    0x8(%ebp),%eax
8010184c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010184f:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101856:	e8 26 33 00 00       	call   80104b81 <release>
  return ip;
8010185b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010185e:	c9                   	leave  
8010185f:	c3                   	ret    

80101860 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101860:	55                   	push   %ebp
80101861:	89 e5                	mov    %esp,%ebp
80101863:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101866:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010186a:	74 0a                	je     80101876 <ilock+0x16>
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	8b 40 08             	mov    0x8(%eax),%eax
80101872:	85 c0                	test   %eax,%eax
80101874:	7f 0c                	jg     80101882 <ilock+0x22>
    panic("ilock");
80101876:	c7 04 24 03 83 10 80 	movl   $0x80108303,(%esp)
8010187d:	e8 bb ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101882:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101889:	e8 91 32 00 00       	call   80104b1f <acquire>
  while(ip->flags & I_BUSY)
8010188e:	eb 13                	jmp    801018a3 <ilock+0x43>
    sleep(ip, &icache.lock);
80101890:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101897:	80 
80101898:	8b 45 08             	mov    0x8(%ebp),%eax
8010189b:	89 04 24             	mov    %eax,(%esp)
8010189e:	e8 96 2f 00 00       	call   80104839 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018a3:	8b 45 08             	mov    0x8(%ebp),%eax
801018a6:	8b 40 0c             	mov    0xc(%eax),%eax
801018a9:	83 e0 01             	and    $0x1,%eax
801018ac:	84 c0                	test   %al,%al
801018ae:	75 e0                	jne    80101890 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018b0:	8b 45 08             	mov    0x8(%ebp),%eax
801018b3:	8b 40 0c             	mov    0xc(%eax),%eax
801018b6:	89 c2                	mov    %eax,%edx
801018b8:	83 ca 01             	or     $0x1,%edx
801018bb:	8b 45 08             	mov    0x8(%ebp),%eax
801018be:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018c1:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801018c8:	e8 b4 32 00 00       	call   80104b81 <release>

  if(!(ip->flags & I_VALID)){
801018cd:	8b 45 08             	mov    0x8(%ebp),%eax
801018d0:	8b 40 0c             	mov    0xc(%eax),%eax
801018d3:	83 e0 02             	and    $0x2,%eax
801018d6:	85 c0                	test   %eax,%eax
801018d8:	0f 85 ce 00 00 00    	jne    801019ac <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018de:	8b 45 08             	mov    0x8(%ebp),%eax
801018e1:	8b 40 04             	mov    0x4(%eax),%eax
801018e4:	c1 e8 03             	shr    $0x3,%eax
801018e7:	8d 50 02             	lea    0x2(%eax),%edx
801018ea:	8b 45 08             	mov    0x8(%ebp),%eax
801018ed:	8b 00                	mov    (%eax),%eax
801018ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801018f3:	89 04 24             	mov    %eax,(%esp)
801018f6:	e8 ab e8 ff ff       	call   801001a6 <bread>
801018fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8d 50 18             	lea    0x18(%eax),%edx
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	8b 40 04             	mov    0x4(%eax),%eax
8010190a:	83 e0 07             	and    $0x7,%eax
8010190d:	c1 e0 06             	shl    $0x6,%eax
80101910:	01 d0                	add    %edx,%eax
80101912:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101918:	0f b7 10             	movzwl (%eax),%edx
8010191b:	8b 45 08             	mov    0x8(%ebp),%eax
8010191e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101922:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101925:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101929:	8b 45 08             	mov    0x8(%ebp),%eax
8010192c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101933:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101937:	8b 45 08             	mov    0x8(%ebp),%eax
8010193a:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
8010193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101941:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
8010194c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194f:	8b 50 08             	mov    0x8(%eax),%edx
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195b:	8d 50 0c             	lea    0xc(%eax),%edx
8010195e:	8b 45 08             	mov    0x8(%ebp),%eax
80101961:	83 c0 1c             	add    $0x1c,%eax
80101964:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010196b:	00 
8010196c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101970:	89 04 24             	mov    %eax,(%esp)
80101973:	e8 c9 34 00 00       	call   80104e41 <memmove>
    brelse(bp);
80101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197b:	89 04 24             	mov    %eax,(%esp)
8010197e:	e8 94 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101983:	8b 45 08             	mov    0x8(%ebp),%eax
80101986:	8b 40 0c             	mov    0xc(%eax),%eax
80101989:	89 c2                	mov    %eax,%edx
8010198b:	83 ca 02             	or     $0x2,%edx
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101994:	8b 45 08             	mov    0x8(%ebp),%eax
80101997:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010199b:	66 85 c0             	test   %ax,%ax
8010199e:	75 0c                	jne    801019ac <ilock+0x14c>
      panic("ilock: no type");
801019a0:	c7 04 24 09 83 10 80 	movl   $0x80108309,(%esp)
801019a7:	e8 91 eb ff ff       	call   8010053d <panic>
  }
}
801019ac:	c9                   	leave  
801019ad:	c3                   	ret    

801019ae <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019ae:	55                   	push   %ebp
801019af:	89 e5                	mov    %esp,%ebp
801019b1:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019b8:	74 17                	je     801019d1 <iunlock+0x23>
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	8b 40 0c             	mov    0xc(%eax),%eax
801019c0:	83 e0 01             	and    $0x1,%eax
801019c3:	85 c0                	test   %eax,%eax
801019c5:	74 0a                	je     801019d1 <iunlock+0x23>
801019c7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ca:	8b 40 08             	mov    0x8(%eax),%eax
801019cd:	85 c0                	test   %eax,%eax
801019cf:	7f 0c                	jg     801019dd <iunlock+0x2f>
    panic("iunlock");
801019d1:	c7 04 24 18 83 10 80 	movl   $0x80108318,(%esp)
801019d8:	e8 60 eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019dd:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801019e4:	e8 36 31 00 00       	call   80104b1f <acquire>
  ip->flags &= ~I_BUSY;
801019e9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ec:	8b 40 0c             	mov    0xc(%eax),%eax
801019ef:	89 c2                	mov    %eax,%edx
801019f1:	83 e2 fe             	and    $0xfffffffe,%edx
801019f4:	8b 45 08             	mov    0x8(%ebp),%eax
801019f7:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019fa:	8b 45 08             	mov    0x8(%ebp),%eax
801019fd:	89 04 24             	mov    %eax,(%esp)
80101a00:	e8 10 2f 00 00       	call   80104915 <wakeup>
  release(&icache.lock);
80101a05:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a0c:	e8 70 31 00 00       	call   80104b81 <release>
}
80101a11:	c9                   	leave  
80101a12:	c3                   	ret    

80101a13 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101a13:	55                   	push   %ebp
80101a14:	89 e5                	mov    %esp,%ebp
80101a16:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a19:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a20:	e8 fa 30 00 00       	call   80104b1f <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a25:	8b 45 08             	mov    0x8(%ebp),%eax
80101a28:	8b 40 08             	mov    0x8(%eax),%eax
80101a2b:	83 f8 01             	cmp    $0x1,%eax
80101a2e:	0f 85 93 00 00 00    	jne    80101ac7 <iput+0xb4>
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3a:	83 e0 02             	and    $0x2,%eax
80101a3d:	85 c0                	test   %eax,%eax
80101a3f:	0f 84 82 00 00 00    	je     80101ac7 <iput+0xb4>
80101a45:	8b 45 08             	mov    0x8(%ebp),%eax
80101a48:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a4c:	66 85 c0             	test   %ax,%ax
80101a4f:	75 76                	jne    80101ac7 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	8b 40 0c             	mov    0xc(%eax),%eax
80101a57:	83 e0 01             	and    $0x1,%eax
80101a5a:	84 c0                	test   %al,%al
80101a5c:	74 0c                	je     80101a6a <iput+0x57>
      panic("iput busy");
80101a5e:	c7 04 24 20 83 10 80 	movl   $0x80108320,(%esp)
80101a65:	e8 d3 ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6d:	8b 40 0c             	mov    0xc(%eax),%eax
80101a70:	89 c2                	mov    %eax,%edx
80101a72:	83 ca 01             	or     $0x1,%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a7b:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a82:	e8 fa 30 00 00       	call   80104b81 <release>
    itrunc(ip);
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	89 04 24             	mov    %eax,(%esp)
80101a8d:	e8 72 01 00 00       	call   80101c04 <itrunc>
    ip->type = 0;
80101a92:	8b 45 08             	mov    0x8(%ebp),%eax
80101a95:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	89 04 24             	mov    %eax,(%esp)
80101aa1:	e8 fe fb ff ff       	call   801016a4 <iupdate>
    acquire(&icache.lock);
80101aa6:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101aad:	e8 6d 30 00 00       	call   80104b1f <acquire>
    ip->flags = 0;
80101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	89 04 24             	mov    %eax,(%esp)
80101ac2:	e8 4e 2e 00 00       	call   80104915 <wakeup>
  }
  ip->ref--;
80101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aca:	8b 40 08             	mov    0x8(%eax),%eax
80101acd:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ad6:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101add:	e8 9f 30 00 00       	call   80104b81 <release>
}
80101ae2:	c9                   	leave  
80101ae3:	c3                   	ret    

80101ae4 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101ae4:	55                   	push   %ebp
80101ae5:	89 e5                	mov    %esp,%ebp
80101ae7:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101aea:	8b 45 08             	mov    0x8(%ebp),%eax
80101aed:	89 04 24             	mov    %eax,(%esp)
80101af0:	e8 b9 fe ff ff       	call   801019ae <iunlock>
  iput(ip);
80101af5:	8b 45 08             	mov    0x8(%ebp),%eax
80101af8:	89 04 24             	mov    %eax,(%esp)
80101afb:	e8 13 ff ff ff       	call   80101a13 <iput>
}
80101b00:	c9                   	leave  
80101b01:	c3                   	ret    

80101b02 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b02:	55                   	push   %ebp
80101b03:	89 e5                	mov    %esp,%ebp
80101b05:	53                   	push   %ebx
80101b06:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b09:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b0d:	77 3e                	ja     80101b4d <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b12:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b15:	83 c2 04             	add    $0x4,%edx
80101b18:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b23:	75 20                	jne    80101b45 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b25:	8b 45 08             	mov    0x8(%ebp),%eax
80101b28:	8b 00                	mov    (%eax),%eax
80101b2a:	89 04 24             	mov    %eax,(%esp)
80101b2d:	e8 49 f8 ff ff       	call   8010137b <balloc>
80101b32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b3b:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b41:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b48:	e9 b1 00 00 00       	jmp    80101bfe <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b4d:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b51:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b55:	0f 87 97 00 00 00    	ja     80101bf2 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b68:	75 19                	jne    80101b83 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6d:	8b 00                	mov    (%eax),%eax
80101b6f:	89 04 24             	mov    %eax,(%esp)
80101b72:	e8 04 f8 ff ff       	call   8010137b <balloc>
80101b77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b80:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b83:	8b 45 08             	mov    0x8(%ebp),%eax
80101b86:	8b 00                	mov    (%eax),%eax
80101b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b8b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b8f:	89 04 24             	mov    %eax,(%esp)
80101b92:	e8 0f e6 ff ff       	call   801001a6 <bread>
80101b97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9d:	83 c0 18             	add    $0x18,%eax
80101ba0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ba6:	c1 e0 02             	shl    $0x2,%eax
80101ba9:	03 45 ec             	add    -0x14(%ebp),%eax
80101bac:	8b 00                	mov    (%eax),%eax
80101bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bb5:	75 2b                	jne    80101be2 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bba:	c1 e0 02             	shl    $0x2,%eax
80101bbd:	89 c3                	mov    %eax,%ebx
80101bbf:	03 5d ec             	add    -0x14(%ebp),%ebx
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	8b 00                	mov    (%eax),%eax
80101bc7:	89 04 24             	mov    %eax,(%esp)
80101bca:	e8 ac f7 ff ff       	call   8010137b <balloc>
80101bcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bd5:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bda:	89 04 24             	mov    %eax,(%esp)
80101bdd:	e8 d4 16 00 00       	call   801032b6 <log_write>
    }
    brelse(bp);
80101be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be5:	89 04 24             	mov    %eax,(%esp)
80101be8:	e8 2a e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf0:	eb 0c                	jmp    80101bfe <bmap+0xfc>
  }

  panic("bmap: out of range");
80101bf2:	c7 04 24 2a 83 10 80 	movl   $0x8010832a,(%esp)
80101bf9:	e8 3f e9 ff ff       	call   8010053d <panic>
}
80101bfe:	83 c4 24             	add    $0x24,%esp
80101c01:	5b                   	pop    %ebx
80101c02:	5d                   	pop    %ebp
80101c03:	c3                   	ret    

80101c04 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c04:	55                   	push   %ebp
80101c05:	89 e5                	mov    %esp,%ebp
80101c07:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c11:	eb 44                	jmp    80101c57 <itrunc+0x53>
    if(ip->addrs[i]){
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c19:	83 c2 04             	add    $0x4,%edx
80101c1c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c20:	85 c0                	test   %eax,%eax
80101c22:	74 2f                	je     80101c53 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c24:	8b 45 08             	mov    0x8(%ebp),%eax
80101c27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c2a:	83 c2 04             	add    $0x4,%edx
80101c2d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c31:	8b 45 08             	mov    0x8(%ebp),%eax
80101c34:	8b 00                	mov    (%eax),%eax
80101c36:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c3a:	89 04 24             	mov    %eax,(%esp)
80101c3d:	e8 90 f8 ff ff       	call   801014d2 <bfree>
      ip->addrs[i] = 0;
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c48:	83 c2 04             	add    $0x4,%edx
80101c4b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c52:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c53:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c57:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c5b:	7e b6                	jle    80101c13 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c63:	85 c0                	test   %eax,%eax
80101c65:	0f 84 8f 00 00 00    	je     80101cfa <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 00                	mov    (%eax),%eax
80101c76:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c7a:	89 04 24             	mov    %eax,(%esp)
80101c7d:	e8 24 e5 ff ff       	call   801001a6 <bread>
80101c82:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c88:	83 c0 18             	add    $0x18,%eax
80101c8b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c95:	eb 2f                	jmp    80101cc6 <itrunc+0xc2>
      if(a[j])
80101c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c9a:	c1 e0 02             	shl    $0x2,%eax
80101c9d:	03 45 e8             	add    -0x18(%ebp),%eax
80101ca0:	8b 00                	mov    (%eax),%eax
80101ca2:	85 c0                	test   %eax,%eax
80101ca4:	74 1c                	je     80101cc2 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca9:	c1 e0 02             	shl    $0x2,%eax
80101cac:	03 45 e8             	add    -0x18(%ebp),%eax
80101caf:	8b 10                	mov    (%eax),%edx
80101cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb4:	8b 00                	mov    (%eax),%eax
80101cb6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cba:	89 04 24             	mov    %eax,(%esp)
80101cbd:	e8 10 f8 ff ff       	call   801014d2 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cc2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc9:	83 f8 7f             	cmp    $0x7f,%eax
80101ccc:	76 c9                	jbe    80101c97 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101cce:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cd1:	89 04 24             	mov    %eax,(%esp)
80101cd4:	e8 3e e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdc:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce2:	8b 00                	mov    (%eax),%eax
80101ce4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce8:	89 04 24             	mov    %eax,(%esp)
80101ceb:	e8 e2 f7 ff ff       	call   801014d2 <bfree>
    ip->addrs[NDIRECT] = 0;
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	89 04 24             	mov    %eax,(%esp)
80101d0a:	e8 95 f9 ff ff       	call   801016a4 <iupdate>
}
80101d0f:	c9                   	leave  
80101d10:	c3                   	ret    

80101d11 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d11:	55                   	push   %ebp
80101d12:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d14:	8b 45 08             	mov    0x8(%ebp),%eax
80101d17:	8b 00                	mov    (%eax),%eax
80101d19:	89 c2                	mov    %eax,%edx
80101d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d1e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d21:	8b 45 08             	mov    0x8(%ebp),%eax
80101d24:	8b 50 04             	mov    0x4(%eax),%edx
80101d27:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d2a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d30:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d37:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d44:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d48:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4b:	8b 50 18             	mov    0x18(%eax),%edx
80101d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d51:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d54:	5d                   	pop    %ebp
80101d55:	c3                   	ret    

80101d56 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d56:	55                   	push   %ebp
80101d57:	89 e5                	mov    %esp,%ebp
80101d59:	53                   	push   %ebx
80101d5a:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d60:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d64:	66 83 f8 03          	cmp    $0x3,%ax
80101d68:	75 60                	jne    80101dca <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d71:	66 85 c0             	test   %ax,%ax
80101d74:	78 20                	js     80101d96 <readi+0x40>
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d7d:	66 83 f8 09          	cmp    $0x9,%ax
80101d81:	7f 13                	jg     80101d96 <readi+0x40>
80101d83:	8b 45 08             	mov    0x8(%ebp),%eax
80101d86:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d8a:	98                   	cwtl   
80101d8b:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80101d92:	85 c0                	test   %eax,%eax
80101d94:	75 0a                	jne    80101da0 <readi+0x4a>
      return -1;
80101d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101d9b:	e9 1b 01 00 00       	jmp    80101ebb <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101da7:	98                   	cwtl   
80101da8:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
80101daf:	8b 45 14             	mov    0x14(%ebp),%eax
80101db2:	89 44 24 08          	mov    %eax,0x8(%esp)
80101db6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db9:	89 44 24 04          	mov    %eax,0x4(%esp)
80101dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc0:	89 04 24             	mov    %eax,(%esp)
80101dc3:	ff d2                	call   *%edx
80101dc5:	e9 f1 00 00 00       	jmp    80101ebb <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80101dca:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcd:	8b 40 18             	mov    0x18(%eax),%eax
80101dd0:	3b 45 10             	cmp    0x10(%ebp),%eax
80101dd3:	72 0d                	jb     80101de2 <readi+0x8c>
80101dd5:	8b 45 14             	mov    0x14(%ebp),%eax
80101dd8:	8b 55 10             	mov    0x10(%ebp),%edx
80101ddb:	01 d0                	add    %edx,%eax
80101ddd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de0:	73 0a                	jae    80101dec <readi+0x96>
    return -1;
80101de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101de7:	e9 cf 00 00 00       	jmp    80101ebb <readi+0x165>
  if(off + n > ip->size)
80101dec:	8b 45 14             	mov    0x14(%ebp),%eax
80101def:	8b 55 10             	mov    0x10(%ebp),%edx
80101df2:	01 c2                	add    %eax,%edx
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	8b 40 18             	mov    0x18(%eax),%eax
80101dfa:	39 c2                	cmp    %eax,%edx
80101dfc:	76 0c                	jbe    80101e0a <readi+0xb4>
    n = ip->size - off;
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	8b 40 18             	mov    0x18(%eax),%eax
80101e04:	2b 45 10             	sub    0x10(%ebp),%eax
80101e07:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e11:	e9 96 00 00 00       	jmp    80101eac <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e16:	8b 45 10             	mov    0x10(%ebp),%eax
80101e19:	c1 e8 09             	shr    $0x9,%eax
80101e1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e20:	8b 45 08             	mov    0x8(%ebp),%eax
80101e23:	89 04 24             	mov    %eax,(%esp)
80101e26:	e8 d7 fc ff ff       	call   80101b02 <bmap>
80101e2b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2e:	8b 12                	mov    (%edx),%edx
80101e30:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e34:	89 14 24             	mov    %edx,(%esp)
80101e37:	e8 6a e3 ff ff       	call   801001a6 <bread>
80101e3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e3f:	8b 45 10             	mov    0x10(%ebp),%eax
80101e42:	89 c2                	mov    %eax,%edx
80101e44:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e4a:	b8 00 02 00 00       	mov    $0x200,%eax
80101e4f:	89 c1                	mov    %eax,%ecx
80101e51:	29 d1                	sub    %edx,%ecx
80101e53:	89 ca                	mov    %ecx,%edx
80101e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e58:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e5b:	89 cb                	mov    %ecx,%ebx
80101e5d:	29 c3                	sub    %eax,%ebx
80101e5f:	89 d8                	mov    %ebx,%eax
80101e61:	39 c2                	cmp    %eax,%edx
80101e63:	0f 46 c2             	cmovbe %edx,%eax
80101e66:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6c:	8d 50 18             	lea    0x18(%eax),%edx
80101e6f:	8b 45 10             	mov    0x10(%ebp),%eax
80101e72:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e77:	01 c2                	add    %eax,%edx
80101e79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e80:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e84:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e87:	89 04 24             	mov    %eax,(%esp)
80101e8a:	e8 b2 2f 00 00       	call   80104e41 <memmove>
    brelse(bp);
80101e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e92:	89 04 24             	mov    %eax,(%esp)
80101e95:	e8 7d e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e9d:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ea0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea3:	01 45 10             	add    %eax,0x10(%ebp)
80101ea6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea9:	01 45 0c             	add    %eax,0xc(%ebp)
80101eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eaf:	3b 45 14             	cmp    0x14(%ebp),%eax
80101eb2:	0f 82 5e ff ff ff    	jb     80101e16 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101eb8:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ebb:	83 c4 24             	add    $0x24,%esp
80101ebe:	5b                   	pop    %ebx
80101ebf:	5d                   	pop    %ebp
80101ec0:	c3                   	ret    

80101ec1 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ec1:	55                   	push   %ebp
80101ec2:	89 e5                	mov    %esp,%ebp
80101ec4:	53                   	push   %ebx
80101ec5:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ecf:	66 83 f8 03          	cmp    $0x3,%ax
80101ed3:	75 60                	jne    80101f35 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101edc:	66 85 c0             	test   %ax,%ax
80101edf:	78 20                	js     80101f01 <writei+0x40>
80101ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee8:	66 83 f8 09          	cmp    $0x9,%ax
80101eec:	7f 13                	jg     80101f01 <writei+0x40>
80101eee:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef1:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef5:	98                   	cwtl   
80101ef6:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80101efd:	85 c0                	test   %eax,%eax
80101eff:	75 0a                	jne    80101f0b <writei+0x4a>
      return -1;
80101f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f06:	e9 46 01 00 00       	jmp    80102051 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f12:	98                   	cwtl   
80101f13:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
80101f1a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f1d:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f24:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f28:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2b:	89 04 24             	mov    %eax,(%esp)
80101f2e:	ff d2                	call   *%edx
80101f30:	e9 1c 01 00 00       	jmp    80102051 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101f35:	8b 45 08             	mov    0x8(%ebp),%eax
80101f38:	8b 40 18             	mov    0x18(%eax),%eax
80101f3b:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f3e:	72 0d                	jb     80101f4d <writei+0x8c>
80101f40:	8b 45 14             	mov    0x14(%ebp),%eax
80101f43:	8b 55 10             	mov    0x10(%ebp),%edx
80101f46:	01 d0                	add    %edx,%eax
80101f48:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f4b:	73 0a                	jae    80101f57 <writei+0x96>
    return -1;
80101f4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f52:	e9 fa 00 00 00       	jmp    80102051 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101f57:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5a:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5d:	01 d0                	add    %edx,%eax
80101f5f:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f64:	76 0a                	jbe    80101f70 <writei+0xaf>
    return -1;
80101f66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6b:	e9 e1 00 00 00       	jmp    80102051 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f77:	e9 a1 00 00 00       	jmp    8010201d <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f7c:	8b 45 10             	mov    0x10(%ebp),%eax
80101f7f:	c1 e8 09             	shr    $0x9,%eax
80101f82:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f86:	8b 45 08             	mov    0x8(%ebp),%eax
80101f89:	89 04 24             	mov    %eax,(%esp)
80101f8c:	e8 71 fb ff ff       	call   80101b02 <bmap>
80101f91:	8b 55 08             	mov    0x8(%ebp),%edx
80101f94:	8b 12                	mov    (%edx),%edx
80101f96:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f9a:	89 14 24             	mov    %edx,(%esp)
80101f9d:	e8 04 e2 ff ff       	call   801001a6 <bread>
80101fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fa5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa8:	89 c2                	mov    %eax,%edx
80101faa:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101fb0:	b8 00 02 00 00       	mov    $0x200,%eax
80101fb5:	89 c1                	mov    %eax,%ecx
80101fb7:	29 d1                	sub    %edx,%ecx
80101fb9:	89 ca                	mov    %ecx,%edx
80101fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fbe:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc1:	89 cb                	mov    %ecx,%ebx
80101fc3:	29 c3                	sub    %eax,%ebx
80101fc5:	89 d8                	mov    %ebx,%eax
80101fc7:	39 c2                	cmp    %eax,%edx
80101fc9:	0f 46 c2             	cmovbe %edx,%eax
80101fcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd2:	8d 50 18             	lea    0x18(%eax),%edx
80101fd5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd8:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdd:	01 c2                	add    %eax,%edx
80101fdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe2:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fed:	89 14 24             	mov    %edx,(%esp)
80101ff0:	e8 4c 2e 00 00       	call   80104e41 <memmove>
    log_write(bp);
80101ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff8:	89 04 24             	mov    %eax,(%esp)
80101ffb:	e8 b6 12 00 00       	call   801032b6 <log_write>
    brelse(bp);
80102000:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102003:	89 04 24             	mov    %eax,(%esp)
80102006:	e8 0c e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010200b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102011:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102014:	01 45 10             	add    %eax,0x10(%ebp)
80102017:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201a:	01 45 0c             	add    %eax,0xc(%ebp)
8010201d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102020:	3b 45 14             	cmp    0x14(%ebp),%eax
80102023:	0f 82 53 ff ff ff    	jb     80101f7c <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102029:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010202d:	74 1f                	je     8010204e <writei+0x18d>
8010202f:	8b 45 08             	mov    0x8(%ebp),%eax
80102032:	8b 40 18             	mov    0x18(%eax),%eax
80102035:	3b 45 10             	cmp    0x10(%ebp),%eax
80102038:	73 14                	jae    8010204e <writei+0x18d>
    ip->size = off;
8010203a:	8b 45 08             	mov    0x8(%ebp),%eax
8010203d:	8b 55 10             	mov    0x10(%ebp),%edx
80102040:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102043:	8b 45 08             	mov    0x8(%ebp),%eax
80102046:	89 04 24             	mov    %eax,(%esp)
80102049:	e8 56 f6 ff ff       	call   801016a4 <iupdate>
  }
  return n;
8010204e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102051:	83 c4 24             	add    $0x24,%esp
80102054:	5b                   	pop    %ebx
80102055:	5d                   	pop    %ebp
80102056:	c3                   	ret    

80102057 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102057:	55                   	push   %ebp
80102058:	89 e5                	mov    %esp,%ebp
8010205a:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010205d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102064:	00 
80102065:	8b 45 0c             	mov    0xc(%ebp),%eax
80102068:	89 44 24 04          	mov    %eax,0x4(%esp)
8010206c:	8b 45 08             	mov    0x8(%ebp),%eax
8010206f:	89 04 24             	mov    %eax,(%esp)
80102072:	e8 6e 2e 00 00       	call   80104ee5 <strncmp>
}
80102077:	c9                   	leave  
80102078:	c3                   	ret    

80102079 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102079:	55                   	push   %ebp
8010207a:	89 e5                	mov    %esp,%ebp
8010207c:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010207f:	8b 45 08             	mov    0x8(%ebp),%eax
80102082:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102086:	66 83 f8 01          	cmp    $0x1,%ax
8010208a:	74 0c                	je     80102098 <dirlookup+0x1f>
    panic("dirlookup not DIR");
8010208c:	c7 04 24 3d 83 10 80 	movl   $0x8010833d,(%esp)
80102093:	e8 a5 e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102098:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010209f:	e9 87 00 00 00       	jmp    8010212b <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020a4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020ab:	00 
801020ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020af:	89 44 24 08          	mov    %eax,0x8(%esp)
801020b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ba:	8b 45 08             	mov    0x8(%ebp),%eax
801020bd:	89 04 24             	mov    %eax,(%esp)
801020c0:	e8 91 fc ff ff       	call   80101d56 <readi>
801020c5:	83 f8 10             	cmp    $0x10,%eax
801020c8:	74 0c                	je     801020d6 <dirlookup+0x5d>
      panic("dirlink read");
801020ca:	c7 04 24 4f 83 10 80 	movl   $0x8010834f,(%esp)
801020d1:	e8 67 e4 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801020d6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020da:	66 85 c0             	test   %ax,%ax
801020dd:	74 47                	je     80102126 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801020df:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020e2:	83 c0 02             	add    $0x2,%eax
801020e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801020e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ec:	89 04 24             	mov    %eax,(%esp)
801020ef:	e8 63 ff ff ff       	call   80102057 <namecmp>
801020f4:	85 c0                	test   %eax,%eax
801020f6:	75 2f                	jne    80102127 <dirlookup+0xae>
      // entry matches path element
      if(poff)
801020f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801020fc:	74 08                	je     80102106 <dirlookup+0x8d>
        *poff = off;
801020fe:	8b 45 10             	mov    0x10(%ebp),%eax
80102101:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102104:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102106:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010210a:	0f b7 c0             	movzwl %ax,%eax
8010210d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102110:	8b 45 08             	mov    0x8(%ebp),%eax
80102113:	8b 00                	mov    (%eax),%eax
80102115:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102118:	89 54 24 04          	mov    %edx,0x4(%esp)
8010211c:	89 04 24             	mov    %eax,(%esp)
8010211f:	e8 38 f6 ff ff       	call   8010175c <iget>
80102124:	eb 19                	jmp    8010213f <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102126:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102127:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010212b:	8b 45 08             	mov    0x8(%ebp),%eax
8010212e:	8b 40 18             	mov    0x18(%eax),%eax
80102131:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102134:	0f 87 6a ff ff ff    	ja     801020a4 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010213a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010213f:	c9                   	leave  
80102140:	c3                   	ret    

80102141 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102141:	55                   	push   %ebp
80102142:	89 e5                	mov    %esp,%ebp
80102144:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102147:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010214e:	00 
8010214f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102152:	89 44 24 04          	mov    %eax,0x4(%esp)
80102156:	8b 45 08             	mov    0x8(%ebp),%eax
80102159:	89 04 24             	mov    %eax,(%esp)
8010215c:	e8 18 ff ff ff       	call   80102079 <dirlookup>
80102161:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102164:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102168:	74 15                	je     8010217f <dirlink+0x3e>
    iput(ip);
8010216a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010216d:	89 04 24             	mov    %eax,(%esp)
80102170:	e8 9e f8 ff ff       	call   80101a13 <iput>
    return -1;
80102175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217a:	e9 b8 00 00 00       	jmp    80102237 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010217f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102186:	eb 44                	jmp    801021cc <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010218b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102192:	00 
80102193:	89 44 24 08          	mov    %eax,0x8(%esp)
80102197:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010219a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010219e:	8b 45 08             	mov    0x8(%ebp),%eax
801021a1:	89 04 24             	mov    %eax,(%esp)
801021a4:	e8 ad fb ff ff       	call   80101d56 <readi>
801021a9:	83 f8 10             	cmp    $0x10,%eax
801021ac:	74 0c                	je     801021ba <dirlink+0x79>
      panic("dirlink read");
801021ae:	c7 04 24 4f 83 10 80 	movl   $0x8010834f,(%esp)
801021b5:	e8 83 e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801021ba:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021be:	66 85 c0             	test   %ax,%ax
801021c1:	74 18                	je     801021db <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c6:	83 c0 10             	add    $0x10,%eax
801021c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021cf:	8b 45 08             	mov    0x8(%ebp),%eax
801021d2:	8b 40 18             	mov    0x18(%eax),%eax
801021d5:	39 c2                	cmp    %eax,%edx
801021d7:	72 af                	jb     80102188 <dirlink+0x47>
801021d9:	eb 01                	jmp    801021dc <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801021db:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801021dc:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021e3:	00 
801021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801021eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ee:	83 c0 02             	add    $0x2,%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 44 2d 00 00       	call   80104f3d <strncpy>
  de.inum = inum;
801021f9:	8b 45 10             	mov    0x10(%ebp),%eax
801021fc:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102203:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220a:	00 
8010220b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010220f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102212:	89 44 24 04          	mov    %eax,0x4(%esp)
80102216:	8b 45 08             	mov    0x8(%ebp),%eax
80102219:	89 04 24             	mov    %eax,(%esp)
8010221c:	e8 a0 fc ff ff       	call   80101ec1 <writei>
80102221:	83 f8 10             	cmp    $0x10,%eax
80102224:	74 0c                	je     80102232 <dirlink+0xf1>
    panic("dirlink");
80102226:	c7 04 24 5c 83 10 80 	movl   $0x8010835c,(%esp)
8010222d:	e8 0b e3 ff ff       	call   8010053d <panic>
  
  return 0;
80102232:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102237:	c9                   	leave  
80102238:	c3                   	ret    

80102239 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102239:	55                   	push   %ebp
8010223a:	89 e5                	mov    %esp,%ebp
8010223c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010223f:	eb 04                	jmp    80102245 <skipelem+0xc>
    path++;
80102241:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102245:	8b 45 08             	mov    0x8(%ebp),%eax
80102248:	0f b6 00             	movzbl (%eax),%eax
8010224b:	3c 2f                	cmp    $0x2f,%al
8010224d:	74 f2                	je     80102241 <skipelem+0x8>
    path++;
  if(*path == 0)
8010224f:	8b 45 08             	mov    0x8(%ebp),%eax
80102252:	0f b6 00             	movzbl (%eax),%eax
80102255:	84 c0                	test   %al,%al
80102257:	75 0a                	jne    80102263 <skipelem+0x2a>
    return 0;
80102259:	b8 00 00 00 00       	mov    $0x0,%eax
8010225e:	e9 86 00 00 00       	jmp    801022e9 <skipelem+0xb0>
  s = path;
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102269:	eb 04                	jmp    8010226f <skipelem+0x36>
    path++;
8010226b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010226f:	8b 45 08             	mov    0x8(%ebp),%eax
80102272:	0f b6 00             	movzbl (%eax),%eax
80102275:	3c 2f                	cmp    $0x2f,%al
80102277:	74 0a                	je     80102283 <skipelem+0x4a>
80102279:	8b 45 08             	mov    0x8(%ebp),%eax
8010227c:	0f b6 00             	movzbl (%eax),%eax
8010227f:	84 c0                	test   %al,%al
80102281:	75 e8                	jne    8010226b <skipelem+0x32>
    path++;
  len = path - s;
80102283:	8b 55 08             	mov    0x8(%ebp),%edx
80102286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102289:	89 d1                	mov    %edx,%ecx
8010228b:	29 c1                	sub    %eax,%ecx
8010228d:	89 c8                	mov    %ecx,%eax
8010228f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102292:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102296:	7e 1c                	jle    801022b4 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
80102298:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010229f:	00 
801022a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801022a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801022aa:	89 04 24             	mov    %eax,(%esp)
801022ad:	e8 8f 2b 00 00       	call   80104e41 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022b2:	eb 28                	jmp    801022dc <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801022bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022be:	89 44 24 04          	mov    %eax,0x4(%esp)
801022c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022c5:	89 04 24             	mov    %eax,(%esp)
801022c8:	e8 74 2b 00 00       	call   80104e41 <memmove>
    name[len] = 0;
801022cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d0:	03 45 0c             	add    0xc(%ebp),%eax
801022d3:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022d6:	eb 04                	jmp    801022dc <skipelem+0xa3>
    path++;
801022d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022dc:	8b 45 08             	mov    0x8(%ebp),%eax
801022df:	0f b6 00             	movzbl (%eax),%eax
801022e2:	3c 2f                	cmp    $0x2f,%al
801022e4:	74 f2                	je     801022d8 <skipelem+0x9f>
    path++;
  return path;
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022e9:	c9                   	leave  
801022ea:	c3                   	ret    

801022eb <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022eb:	55                   	push   %ebp
801022ec:	89 e5                	mov    %esp,%ebp
801022ee:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022f1:	8b 45 08             	mov    0x8(%ebp),%eax
801022f4:	0f b6 00             	movzbl (%eax),%eax
801022f7:	3c 2f                	cmp    $0x2f,%al
801022f9:	75 1c                	jne    80102317 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801022fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102302:	00 
80102303:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010230a:	e8 4d f4 ff ff       	call   8010175c <iget>
8010230f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102312:	e9 af 00 00 00       	jmp    801023c6 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102317:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010231d:	8b 40 68             	mov    0x68(%eax),%eax
80102320:	89 04 24             	mov    %eax,(%esp)
80102323:	e8 06 f5 ff ff       	call   8010182e <idup>
80102328:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010232b:	e9 96 00 00 00       	jmp    801023c6 <namex+0xdb>
    ilock(ip);
80102330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102333:	89 04 24             	mov    %eax,(%esp)
80102336:	e8 25 f5 ff ff       	call   80101860 <ilock>
    if(ip->type != T_DIR){
8010233b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102342:	66 83 f8 01          	cmp    $0x1,%ax
80102346:	74 15                	je     8010235d <namex+0x72>
      iunlockput(ip);
80102348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234b:	89 04 24             	mov    %eax,(%esp)
8010234e:	e8 91 f7 ff ff       	call   80101ae4 <iunlockput>
      return 0;
80102353:	b8 00 00 00 00       	mov    $0x0,%eax
80102358:	e9 a3 00 00 00       	jmp    80102400 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
8010235d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102361:	74 1d                	je     80102380 <namex+0x95>
80102363:	8b 45 08             	mov    0x8(%ebp),%eax
80102366:	0f b6 00             	movzbl (%eax),%eax
80102369:	84 c0                	test   %al,%al
8010236b:	75 13                	jne    80102380 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
8010236d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102370:	89 04 24             	mov    %eax,(%esp)
80102373:	e8 36 f6 ff ff       	call   801019ae <iunlock>
      return ip;
80102378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237b:	e9 80 00 00 00       	jmp    80102400 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102380:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102387:	00 
80102388:	8b 45 10             	mov    0x10(%ebp),%eax
8010238b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010238f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102392:	89 04 24             	mov    %eax,(%esp)
80102395:	e8 df fc ff ff       	call   80102079 <dirlookup>
8010239a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010239d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a1:	75 12                	jne    801023b5 <namex+0xca>
      iunlockput(ip);
801023a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a6:	89 04 24             	mov    %eax,(%esp)
801023a9:	e8 36 f7 ff ff       	call   80101ae4 <iunlockput>
      return 0;
801023ae:	b8 00 00 00 00       	mov    $0x0,%eax
801023b3:	eb 4b                	jmp    80102400 <namex+0x115>
    }
    iunlockput(ip);
801023b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b8:	89 04 24             	mov    %eax,(%esp)
801023bb:	e8 24 f7 ff ff       	call   80101ae4 <iunlockput>
    ip = next;
801023c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023c6:	8b 45 10             	mov    0x10(%ebp),%eax
801023c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801023cd:	8b 45 08             	mov    0x8(%ebp),%eax
801023d0:	89 04 24             	mov    %eax,(%esp)
801023d3:	e8 61 fe ff ff       	call   80102239 <skipelem>
801023d8:	89 45 08             	mov    %eax,0x8(%ebp)
801023db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023df:	0f 85 4b ff ff ff    	jne    80102330 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023e9:	74 12                	je     801023fd <namex+0x112>
    iput(ip);
801023eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ee:	89 04 24             	mov    %eax,(%esp)
801023f1:	e8 1d f6 ff ff       	call   80101a13 <iput>
    return 0;
801023f6:	b8 00 00 00 00       	mov    $0x0,%eax
801023fb:	eb 03                	jmp    80102400 <namex+0x115>
  }
  return ip;
801023fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102400:	c9                   	leave  
80102401:	c3                   	ret    

80102402 <namei>:

struct inode*
namei(char *path)
{
80102402:	55                   	push   %ebp
80102403:	89 e5                	mov    %esp,%ebp
80102405:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102408:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010240b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010240f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102416:	00 
80102417:	8b 45 08             	mov    0x8(%ebp),%eax
8010241a:	89 04 24             	mov    %eax,(%esp)
8010241d:	e8 c9 fe ff ff       	call   801022eb <namex>
}
80102422:	c9                   	leave  
80102423:	c3                   	ret    

80102424 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102424:	55                   	push   %ebp
80102425:	89 e5                	mov    %esp,%ebp
80102427:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010242a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010242d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102431:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102438:	00 
80102439:	8b 45 08             	mov    0x8(%ebp),%eax
8010243c:	89 04 24             	mov    %eax,(%esp)
8010243f:	e8 a7 fe ff ff       	call   801022eb <namex>
}
80102444:	c9                   	leave  
80102445:	c3                   	ret    
	...

80102448 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102448:	55                   	push   %ebp
80102449:	89 e5                	mov    %esp,%ebp
8010244b:	53                   	push   %ebx
8010244c:	83 ec 14             	sub    $0x14,%esp
8010244f:	8b 45 08             	mov    0x8(%ebp),%eax
80102452:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102456:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010245a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010245e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102462:	ec                   	in     (%dx),%al
80102463:	89 c3                	mov    %eax,%ebx
80102465:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102468:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010246c:	83 c4 14             	add    $0x14,%esp
8010246f:	5b                   	pop    %ebx
80102470:	5d                   	pop    %ebp
80102471:	c3                   	ret    

80102472 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102472:	55                   	push   %ebp
80102473:	89 e5                	mov    %esp,%ebp
80102475:	57                   	push   %edi
80102476:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102477:	8b 55 08             	mov    0x8(%ebp),%edx
8010247a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010247d:	8b 45 10             	mov    0x10(%ebp),%eax
80102480:	89 cb                	mov    %ecx,%ebx
80102482:	89 df                	mov    %ebx,%edi
80102484:	89 c1                	mov    %eax,%ecx
80102486:	fc                   	cld    
80102487:	f3 6d                	rep insl (%dx),%es:(%edi)
80102489:	89 c8                	mov    %ecx,%eax
8010248b:	89 fb                	mov    %edi,%ebx
8010248d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102490:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102493:	5b                   	pop    %ebx
80102494:	5f                   	pop    %edi
80102495:	5d                   	pop    %ebp
80102496:	c3                   	ret    

80102497 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102497:	55                   	push   %ebp
80102498:	89 e5                	mov    %esp,%ebp
8010249a:	83 ec 08             	sub    $0x8,%esp
8010249d:	8b 55 08             	mov    0x8(%ebp),%edx
801024a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024a7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024aa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024ae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024b2:	ee                   	out    %al,(%dx)
}
801024b3:	c9                   	leave  
801024b4:	c3                   	ret    

801024b5 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024b5:	55                   	push   %ebp
801024b6:	89 e5                	mov    %esp,%ebp
801024b8:	56                   	push   %esi
801024b9:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024ba:	8b 55 08             	mov    0x8(%ebp),%edx
801024bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024c0:	8b 45 10             	mov    0x10(%ebp),%eax
801024c3:	89 cb                	mov    %ecx,%ebx
801024c5:	89 de                	mov    %ebx,%esi
801024c7:	89 c1                	mov    %eax,%ecx
801024c9:	fc                   	cld    
801024ca:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024cc:	89 c8                	mov    %ecx,%eax
801024ce:	89 f3                	mov    %esi,%ebx
801024d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024d3:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024d6:	5b                   	pop    %ebx
801024d7:	5e                   	pop    %esi
801024d8:	5d                   	pop    %ebp
801024d9:	c3                   	ret    

801024da <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024da:	55                   	push   %ebp
801024db:	89 e5                	mov    %esp,%ebp
801024dd:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024e0:	90                   	nop
801024e1:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024e8:	e8 5b ff ff ff       	call   80102448 <inb>
801024ed:	0f b6 c0             	movzbl %al,%eax
801024f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024f6:	25 c0 00 00 00       	and    $0xc0,%eax
801024fb:	83 f8 40             	cmp    $0x40,%eax
801024fe:	75 e1                	jne    801024e1 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102500:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102504:	74 11                	je     80102517 <idewait+0x3d>
80102506:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102509:	83 e0 21             	and    $0x21,%eax
8010250c:	85 c0                	test   %eax,%eax
8010250e:	74 07                	je     80102517 <idewait+0x3d>
    return -1;
80102510:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102515:	eb 05                	jmp    8010251c <idewait+0x42>
  return 0;
80102517:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010251c:	c9                   	leave  
8010251d:	c3                   	ret    

8010251e <ideinit>:

void
ideinit(void)
{
8010251e:	55                   	push   %ebp
8010251f:	89 e5                	mov    %esp,%ebp
80102521:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102524:	c7 44 24 04 64 83 10 	movl   $0x80108364,0x4(%esp)
8010252b:	80 
8010252c:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102533:	e8 c6 25 00 00       	call   80104afe <initlock>
  picenable(IRQ_IDE);
80102538:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010253f:	e8 65 15 00 00       	call   80103aa9 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102544:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80102549:	83 e8 01             	sub    $0x1,%eax
8010254c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102550:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102557:	e8 12 04 00 00       	call   8010296e <ioapicenable>
  idewait(0);
8010255c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102563:	e8 72 ff ff ff       	call   801024da <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102568:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010256f:	00 
80102570:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102577:	e8 1b ff ff ff       	call   80102497 <outb>
  for(i=0; i<1000; i++){
8010257c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102583:	eb 20                	jmp    801025a5 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102585:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010258c:	e8 b7 fe ff ff       	call   80102448 <inb>
80102591:	84 c0                	test   %al,%al
80102593:	74 0c                	je     801025a1 <ideinit+0x83>
      havedisk1 = 1;
80102595:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
8010259c:	00 00 00 
      break;
8010259f:	eb 0d                	jmp    801025ae <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025a5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025ac:	7e d7                	jle    80102585 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025ae:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025b5:	00 
801025b6:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025bd:	e8 d5 fe ff ff       	call   80102497 <outb>
}
801025c2:	c9                   	leave  
801025c3:	c3                   	ret    

801025c4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025c4:	55                   	push   %ebp
801025c5:	89 e5                	mov    %esp,%ebp
801025c7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ce:	75 0c                	jne    801025dc <idestart+0x18>
    panic("idestart");
801025d0:	c7 04 24 68 83 10 80 	movl   $0x80108368,(%esp)
801025d7:	e8 61 df ff ff       	call   8010053d <panic>

  idewait(0);
801025dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025e3:	e8 f2 fe ff ff       	call   801024da <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025ef:	00 
801025f0:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025f7:	e8 9b fe ff ff       	call   80102497 <outb>
  outb(0x1f2, 1);  // number of sectors
801025fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102603:	00 
80102604:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010260b:	e8 87 fe ff ff       	call   80102497 <outb>
  outb(0x1f3, b->sector & 0xff);
80102610:	8b 45 08             	mov    0x8(%ebp),%eax
80102613:	8b 40 08             	mov    0x8(%eax),%eax
80102616:	0f b6 c0             	movzbl %al,%eax
80102619:	89 44 24 04          	mov    %eax,0x4(%esp)
8010261d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102624:	e8 6e fe ff ff       	call   80102497 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102629:	8b 45 08             	mov    0x8(%ebp),%eax
8010262c:	8b 40 08             	mov    0x8(%eax),%eax
8010262f:	c1 e8 08             	shr    $0x8,%eax
80102632:	0f b6 c0             	movzbl %al,%eax
80102635:	89 44 24 04          	mov    %eax,0x4(%esp)
80102639:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102640:	e8 52 fe ff ff       	call   80102497 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102645:	8b 45 08             	mov    0x8(%ebp),%eax
80102648:	8b 40 08             	mov    0x8(%eax),%eax
8010264b:	c1 e8 10             	shr    $0x10,%eax
8010264e:	0f b6 c0             	movzbl %al,%eax
80102651:	89 44 24 04          	mov    %eax,0x4(%esp)
80102655:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010265c:	e8 36 fe ff ff       	call   80102497 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102661:	8b 45 08             	mov    0x8(%ebp),%eax
80102664:	8b 40 04             	mov    0x4(%eax),%eax
80102667:	83 e0 01             	and    $0x1,%eax
8010266a:	89 c2                	mov    %eax,%edx
8010266c:	c1 e2 04             	shl    $0x4,%edx
8010266f:	8b 45 08             	mov    0x8(%ebp),%eax
80102672:	8b 40 08             	mov    0x8(%eax),%eax
80102675:	c1 e8 18             	shr    $0x18,%eax
80102678:	83 e0 0f             	and    $0xf,%eax
8010267b:	09 d0                	or     %edx,%eax
8010267d:	83 c8 e0             	or     $0xffffffe0,%eax
80102680:	0f b6 c0             	movzbl %al,%eax
80102683:	89 44 24 04          	mov    %eax,0x4(%esp)
80102687:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010268e:	e8 04 fe ff ff       	call   80102497 <outb>
  if(b->flags & B_DIRTY){
80102693:	8b 45 08             	mov    0x8(%ebp),%eax
80102696:	8b 00                	mov    (%eax),%eax
80102698:	83 e0 04             	and    $0x4,%eax
8010269b:	85 c0                	test   %eax,%eax
8010269d:	74 34                	je     801026d3 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
8010269f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026a6:	00 
801026a7:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026ae:	e8 e4 fd ff ff       	call   80102497 <outb>
    outsl(0x1f0, b->data, 512/4);
801026b3:	8b 45 08             	mov    0x8(%ebp),%eax
801026b6:	83 c0 18             	add    $0x18,%eax
801026b9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026c0:	00 
801026c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026c5:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026cc:	e8 e4 fd ff ff       	call   801024b5 <outsl>
801026d1:	eb 14                	jmp    801026e7 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026d3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026da:	00 
801026db:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026e2:	e8 b0 fd ff ff       	call   80102497 <outb>
  }
}
801026e7:	c9                   	leave  
801026e8:	c3                   	ret    

801026e9 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026e9:	55                   	push   %ebp
801026ea:	89 e5                	mov    %esp,%ebp
801026ec:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026ef:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801026f6:	e8 24 24 00 00       	call   80104b1f <acquire>
  if((b = idequeue) == 0){
801026fb:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102700:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102703:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102707:	75 11                	jne    8010271a <ideintr+0x31>
    release(&idelock);
80102709:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102710:	e8 6c 24 00 00       	call   80104b81 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102715:	e9 90 00 00 00       	jmp    801027aa <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	8b 40 14             	mov    0x14(%eax),%eax
80102720:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102728:	8b 00                	mov    (%eax),%eax
8010272a:	83 e0 04             	and    $0x4,%eax
8010272d:	85 c0                	test   %eax,%eax
8010272f:	75 2e                	jne    8010275f <ideintr+0x76>
80102731:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102738:	e8 9d fd ff ff       	call   801024da <idewait>
8010273d:	85 c0                	test   %eax,%eax
8010273f:	78 1e                	js     8010275f <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102744:	83 c0 18             	add    $0x18,%eax
80102747:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010274e:	00 
8010274f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102753:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010275a:	e8 13 fd ff ff       	call   80102472 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010275f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102762:	8b 00                	mov    (%eax),%eax
80102764:	89 c2                	mov    %eax,%edx
80102766:	83 ca 02             	or     $0x2,%edx
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010276e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102771:	8b 00                	mov    (%eax),%eax
80102773:	89 c2                	mov    %eax,%edx
80102775:	83 e2 fb             	and    $0xfffffffb,%edx
80102778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277b:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	89 04 24             	mov    %eax,(%esp)
80102783:	e8 8d 21 00 00       	call   80104915 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102788:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010278d:	85 c0                	test   %eax,%eax
8010278f:	74 0d                	je     8010279e <ideintr+0xb5>
    idestart(idequeue);
80102791:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102796:	89 04 24             	mov    %eax,(%esp)
80102799:	e8 26 fe ff ff       	call   801025c4 <idestart>

  release(&idelock);
8010279e:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027a5:	e8 d7 23 00 00       	call   80104b81 <release>
}
801027aa:	c9                   	leave  
801027ab:	c3                   	ret    

801027ac <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027ac:	55                   	push   %ebp
801027ad:	89 e5                	mov    %esp,%ebp
801027af:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027b2:	8b 45 08             	mov    0x8(%ebp),%eax
801027b5:	8b 00                	mov    (%eax),%eax
801027b7:	83 e0 01             	and    $0x1,%eax
801027ba:	85 c0                	test   %eax,%eax
801027bc:	75 0c                	jne    801027ca <iderw+0x1e>
    panic("iderw: buf not busy");
801027be:	c7 04 24 71 83 10 80 	movl   $0x80108371,(%esp)
801027c5:	e8 73 dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027ca:	8b 45 08             	mov    0x8(%ebp),%eax
801027cd:	8b 00                	mov    (%eax),%eax
801027cf:	83 e0 06             	and    $0x6,%eax
801027d2:	83 f8 02             	cmp    $0x2,%eax
801027d5:	75 0c                	jne    801027e3 <iderw+0x37>
    panic("iderw: nothing to do");
801027d7:	c7 04 24 85 83 10 80 	movl   $0x80108385,(%esp)
801027de:	e8 5a dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801027e3:	8b 45 08             	mov    0x8(%ebp),%eax
801027e6:	8b 40 04             	mov    0x4(%eax),%eax
801027e9:	85 c0                	test   %eax,%eax
801027eb:	74 15                	je     80102802 <iderw+0x56>
801027ed:	a1 58 b6 10 80       	mov    0x8010b658,%eax
801027f2:	85 c0                	test   %eax,%eax
801027f4:	75 0c                	jne    80102802 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027f6:	c7 04 24 9a 83 10 80 	movl   $0x8010839a,(%esp)
801027fd:	e8 3b dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102802:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102809:	e8 11 23 00 00       	call   80104b1f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
8010280e:	8b 45 08             	mov    0x8(%ebp),%eax
80102811:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102818:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
8010281f:	eb 0b                	jmp    8010282c <iderw+0x80>
80102821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102824:	8b 00                	mov    (%eax),%eax
80102826:	83 c0 14             	add    $0x14,%eax
80102829:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010282c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282f:	8b 00                	mov    (%eax),%eax
80102831:	85 c0                	test   %eax,%eax
80102833:	75 ec                	jne    80102821 <iderw+0x75>
    ;
  *pp = b;
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	8b 55 08             	mov    0x8(%ebp),%edx
8010283b:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010283d:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102842:	3b 45 08             	cmp    0x8(%ebp),%eax
80102845:	75 22                	jne    80102869 <iderw+0xbd>
    idestart(b);
80102847:	8b 45 08             	mov    0x8(%ebp),%eax
8010284a:	89 04 24             	mov    %eax,(%esp)
8010284d:	e8 72 fd ff ff       	call   801025c4 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102852:	eb 15                	jmp    80102869 <iderw+0xbd>
    sleep(b, &idelock);
80102854:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
8010285b:	80 
8010285c:	8b 45 08             	mov    0x8(%ebp),%eax
8010285f:	89 04 24             	mov    %eax,(%esp)
80102862:	e8 d2 1f 00 00       	call   80104839 <sleep>
80102867:	eb 01                	jmp    8010286a <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102869:	90                   	nop
8010286a:	8b 45 08             	mov    0x8(%ebp),%eax
8010286d:	8b 00                	mov    (%eax),%eax
8010286f:	83 e0 06             	and    $0x6,%eax
80102872:	83 f8 02             	cmp    $0x2,%eax
80102875:	75 dd                	jne    80102854 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102877:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
8010287e:	e8 fe 22 00 00       	call   80104b81 <release>
}
80102883:	c9                   	leave  
80102884:	c3                   	ret    
80102885:	00 00                	add    %al,(%eax)
	...

80102888 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102888:	55                   	push   %ebp
80102889:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010288b:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102890:	8b 55 08             	mov    0x8(%ebp),%edx
80102893:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102895:	a1 54 f8 10 80       	mov    0x8010f854,%eax
8010289a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010289d:	5d                   	pop    %ebp
8010289e:	c3                   	ret    

8010289f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010289f:	55                   	push   %ebp
801028a0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028a2:	a1 54 f8 10 80       	mov    0x8010f854,%eax
801028a7:	8b 55 08             	mov    0x8(%ebp),%edx
801028aa:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028ac:	a1 54 f8 10 80       	mov    0x8010f854,%eax
801028b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801028b4:	89 50 10             	mov    %edx,0x10(%eax)
}
801028b7:	5d                   	pop    %ebp
801028b8:	c3                   	ret    

801028b9 <ioapicinit>:

void
ioapicinit(void)
{
801028b9:	55                   	push   %ebp
801028ba:	89 e5                	mov    %esp,%ebp
801028bc:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028bf:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801028c4:	85 c0                	test   %eax,%eax
801028c6:	0f 84 9f 00 00 00    	je     8010296b <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801028cc:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
801028d3:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028dd:	e8 a6 ff ff ff       	call   80102888 <ioapicread>
801028e2:	c1 e8 10             	shr    $0x10,%eax
801028e5:	25 ff 00 00 00       	and    $0xff,%eax
801028ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028f4:	e8 8f ff ff ff       	call   80102888 <ioapicread>
801028f9:	c1 e8 18             	shr    $0x18,%eax
801028fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028ff:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102906:	0f b6 c0             	movzbl %al,%eax
80102909:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010290c:	74 0c                	je     8010291a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010290e:	c7 04 24 b8 83 10 80 	movl   $0x801083b8,(%esp)
80102915:	e8 87 da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010291a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102921:	eb 3e                	jmp    80102961 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102926:	83 c0 20             	add    $0x20,%eax
80102929:	0d 00 00 01 00       	or     $0x10000,%eax
8010292e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102931:	83 c2 08             	add    $0x8,%edx
80102934:	01 d2                	add    %edx,%edx
80102936:	89 44 24 04          	mov    %eax,0x4(%esp)
8010293a:	89 14 24             	mov    %edx,(%esp)
8010293d:	e8 5d ff ff ff       	call   8010289f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102945:	83 c0 08             	add    $0x8,%eax
80102948:	01 c0                	add    %eax,%eax
8010294a:	83 c0 01             	add    $0x1,%eax
8010294d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102954:	00 
80102955:	89 04 24             	mov    %eax,(%esp)
80102958:	e8 42 ff ff ff       	call   8010289f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010295d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102964:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102967:	7e ba                	jle    80102923 <ioapicinit+0x6a>
80102969:	eb 01                	jmp    8010296c <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
8010296b:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010296c:	c9                   	leave  
8010296d:	c3                   	ret    

8010296e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010296e:	55                   	push   %ebp
8010296f:	89 e5                	mov    %esp,%ebp
80102971:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102974:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102979:	85 c0                	test   %eax,%eax
8010297b:	74 39                	je     801029b6 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010297d:	8b 45 08             	mov    0x8(%ebp),%eax
80102980:	83 c0 20             	add    $0x20,%eax
80102983:	8b 55 08             	mov    0x8(%ebp),%edx
80102986:	83 c2 08             	add    $0x8,%edx
80102989:	01 d2                	add    %edx,%edx
8010298b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298f:	89 14 24             	mov    %edx,(%esp)
80102992:	e8 08 ff ff ff       	call   8010289f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102997:	8b 45 0c             	mov    0xc(%ebp),%eax
8010299a:	c1 e0 18             	shl    $0x18,%eax
8010299d:	8b 55 08             	mov    0x8(%ebp),%edx
801029a0:	83 c2 08             	add    $0x8,%edx
801029a3:	01 d2                	add    %edx,%edx
801029a5:	83 c2 01             	add    $0x1,%edx
801029a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ac:	89 14 24             	mov    %edx,(%esp)
801029af:	e8 eb fe ff ff       	call   8010289f <ioapicwrite>
801029b4:	eb 01                	jmp    801029b7 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801029b6:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801029b7:	c9                   	leave  
801029b8:	c3                   	ret    
801029b9:	00 00                	add    %al,(%eax)
	...

801029bc <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029bc:	55                   	push   %ebp
801029bd:	89 e5                	mov    %esp,%ebp
801029bf:	8b 45 08             	mov    0x8(%ebp),%eax
801029c2:	05 00 00 00 80       	add    $0x80000000,%eax
801029c7:	5d                   	pop    %ebp
801029c8:	c3                   	ret    

801029c9 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029c9:	55                   	push   %ebp
801029ca:	89 e5                	mov    %esp,%ebp
801029cc:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029cf:	c7 44 24 04 ea 83 10 	movl   $0x801083ea,0x4(%esp)
801029d6:	80 
801029d7:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
801029de:	e8 1b 21 00 00       	call   80104afe <initlock>
  kmem.use_lock = 0;
801029e3:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
801029ea:	00 00 00 
  freerange(vstart, vend);
801029ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801029f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f4:	8b 45 08             	mov    0x8(%ebp),%eax
801029f7:	89 04 24             	mov    %eax,(%esp)
801029fa:	e8 26 00 00 00       	call   80102a25 <freerange>
}
801029ff:	c9                   	leave  
80102a00:	c3                   	ret    

80102a01 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a01:	55                   	push   %ebp
80102a02:	89 e5                	mov    %esp,%ebp
80102a04:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a07:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a11:	89 04 24             	mov    %eax,(%esp)
80102a14:	e8 0c 00 00 00       	call   80102a25 <freerange>
  kmem.use_lock = 1;
80102a19:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102a20:	00 00 00 
}
80102a23:	c9                   	leave  
80102a24:	c3                   	ret    

80102a25 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a25:	55                   	push   %ebp
80102a26:	89 e5                	mov    %esp,%ebp
80102a28:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a3b:	eb 12                	jmp    80102a4f <freerange+0x2a>
    kfree(p);
80102a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a40:	89 04 24             	mov    %eax,(%esp)
80102a43:	e8 16 00 00 00       	call   80102a5e <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a48:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a52:	05 00 10 00 00       	add    $0x1000,%eax
80102a57:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a5a:	76 e1                	jbe    80102a3d <freerange+0x18>
    kfree(p);
}
80102a5c:	c9                   	leave  
80102a5d:	c3                   	ret    

80102a5e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a5e:	55                   	push   %ebp
80102a5f:	89 e5                	mov    %esp,%ebp
80102a61:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a6c:	85 c0                	test   %eax,%eax
80102a6e:	75 1b                	jne    80102a8b <kfree+0x2d>
80102a70:	81 7d 08 1c 2a 11 80 	cmpl   $0x80112a1c,0x8(%ebp)
80102a77:	72 12                	jb     80102a8b <kfree+0x2d>
80102a79:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7c:	89 04 24             	mov    %eax,(%esp)
80102a7f:	e8 38 ff ff ff       	call   801029bc <v2p>
80102a84:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a89:	76 0c                	jbe    80102a97 <kfree+0x39>
    panic("kfree");
80102a8b:	c7 04 24 ef 83 10 80 	movl   $0x801083ef,(%esp)
80102a92:	e8 a6 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a97:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a9e:	00 
80102a9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aa6:	00 
80102aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aaa:	89 04 24             	mov    %eax,(%esp)
80102aad:	e8 bc 22 00 00       	call   80104d6e <memset>

  if(kmem.use_lock)
80102ab2:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102ab7:	85 c0                	test   %eax,%eax
80102ab9:	74 0c                	je     80102ac7 <kfree+0x69>
    acquire(&kmem.lock);
80102abb:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102ac2:	e8 58 20 00 00       	call   80104b1f <acquire>
  r = (struct run*)v;
80102ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102acd:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad6:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adb:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102ae0:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102ae5:	85 c0                	test   %eax,%eax
80102ae7:	74 0c                	je     80102af5 <kfree+0x97>
    release(&kmem.lock);
80102ae9:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102af0:	e8 8c 20 00 00       	call   80104b81 <release>
}
80102af5:	c9                   	leave  
80102af6:	c3                   	ret    

80102af7 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102af7:	55                   	push   %ebp
80102af8:	89 e5                	mov    %esp,%ebp
80102afa:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102afd:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102b02:	85 c0                	test   %eax,%eax
80102b04:	74 0c                	je     80102b12 <kalloc+0x1b>
    acquire(&kmem.lock);
80102b06:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102b0d:	e8 0d 20 00 00       	call   80104b1f <acquire>
  r = kmem.freelist;
80102b12:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b1e:	74 0a                	je     80102b2a <kalloc+0x33>
    kmem.freelist = r->next;
80102b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b23:	8b 00                	mov    (%eax),%eax
80102b25:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102b2a:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102b2f:	85 c0                	test   %eax,%eax
80102b31:	74 0c                	je     80102b3f <kalloc+0x48>
    release(&kmem.lock);
80102b33:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102b3a:	e8 42 20 00 00       	call   80104b81 <release>
  return (char*)r;
80102b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b42:	c9                   	leave  
80102b43:	c3                   	ret    

80102b44 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b44:	55                   	push   %ebp
80102b45:	89 e5                	mov    %esp,%ebp
80102b47:	53                   	push   %ebx
80102b48:	83 ec 14             	sub    $0x14,%esp
80102b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b52:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102b56:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b5a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102b5e:	ec                   	in     (%dx),%al
80102b5f:	89 c3                	mov    %eax,%ebx
80102b61:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b64:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b68:	83 c4 14             	add    $0x14,%esp
80102b6b:	5b                   	pop    %ebx
80102b6c:	5d                   	pop    %ebp
80102b6d:	c3                   	ret    

80102b6e <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b6e:	55                   	push   %ebp
80102b6f:	89 e5                	mov    %esp,%ebp
80102b71:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b74:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b7b:	e8 c4 ff ff ff       	call   80102b44 <inb>
80102b80:	0f b6 c0             	movzbl %al,%eax
80102b83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b89:	83 e0 01             	and    $0x1,%eax
80102b8c:	85 c0                	test   %eax,%eax
80102b8e:	75 0a                	jne    80102b9a <kbdgetc+0x2c>
    return -1;
80102b90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b95:	e9 23 01 00 00       	jmp    80102cbd <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102b9a:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102ba1:	e8 9e ff ff ff       	call   80102b44 <inb>
80102ba6:	0f b6 c0             	movzbl %al,%eax
80102ba9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102bac:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bb3:	75 17                	jne    80102bcc <kbdgetc+0x5e>
    shift |= E0ESC;
80102bb5:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102bba:	83 c8 40             	or     $0x40,%eax
80102bbd:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102bc2:	b8 00 00 00 00       	mov    $0x0,%eax
80102bc7:	e9 f1 00 00 00       	jmp    80102cbd <kbdgetc+0x14f>
  } else if(data & 0x80){
80102bcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bcf:	25 80 00 00 00       	and    $0x80,%eax
80102bd4:	85 c0                	test   %eax,%eax
80102bd6:	74 45                	je     80102c1d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bd8:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102bdd:	83 e0 40             	and    $0x40,%eax
80102be0:	85 c0                	test   %eax,%eax
80102be2:	75 08                	jne    80102bec <kbdgetc+0x7e>
80102be4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be7:	83 e0 7f             	and    $0x7f,%eax
80102bea:	eb 03                	jmp    80102bef <kbdgetc+0x81>
80102bec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bf5:	05 20 90 10 80       	add    $0x80109020,%eax
80102bfa:	0f b6 00             	movzbl (%eax),%eax
80102bfd:	83 c8 40             	or     $0x40,%eax
80102c00:	0f b6 c0             	movzbl %al,%eax
80102c03:	f7 d0                	not    %eax
80102c05:	89 c2                	mov    %eax,%edx
80102c07:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c0c:	21 d0                	and    %edx,%eax
80102c0e:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102c13:	b8 00 00 00 00       	mov    $0x0,%eax
80102c18:	e9 a0 00 00 00       	jmp    80102cbd <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c1d:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c22:	83 e0 40             	and    $0x40,%eax
80102c25:	85 c0                	test   %eax,%eax
80102c27:	74 14                	je     80102c3d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c29:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c30:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c35:	83 e0 bf             	and    $0xffffffbf,%eax
80102c38:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102c3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c40:	05 20 90 10 80       	add    $0x80109020,%eax
80102c45:	0f b6 00             	movzbl (%eax),%eax
80102c48:	0f b6 d0             	movzbl %al,%edx
80102c4b:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c50:	09 d0                	or     %edx,%eax
80102c52:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102c57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c5a:	05 20 91 10 80       	add    $0x80109120,%eax
80102c5f:	0f b6 00             	movzbl (%eax),%eax
80102c62:	0f b6 d0             	movzbl %al,%edx
80102c65:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c6a:	31 d0                	xor    %edx,%eax
80102c6c:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c71:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c76:	83 e0 03             	and    $0x3,%eax
80102c79:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102c80:	03 45 fc             	add    -0x4(%ebp),%eax
80102c83:	0f b6 00             	movzbl (%eax),%eax
80102c86:	0f b6 c0             	movzbl %al,%eax
80102c89:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c8c:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c91:	83 e0 08             	and    $0x8,%eax
80102c94:	85 c0                	test   %eax,%eax
80102c96:	74 22                	je     80102cba <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102c98:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c9c:	76 0c                	jbe    80102caa <kbdgetc+0x13c>
80102c9e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ca2:	77 06                	ja     80102caa <kbdgetc+0x13c>
      c += 'A' - 'a';
80102ca4:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ca8:	eb 10                	jmp    80102cba <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102caa:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cae:	76 0a                	jbe    80102cba <kbdgetc+0x14c>
80102cb0:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102cb4:	77 04                	ja     80102cba <kbdgetc+0x14c>
      c += 'a' - 'A';
80102cb6:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102cba:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102cbd:	c9                   	leave  
80102cbe:	c3                   	ret    

80102cbf <kbdintr>:

void
kbdintr(void)
{
80102cbf:	55                   	push   %ebp
80102cc0:	89 e5                	mov    %esp,%ebp
80102cc2:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cc5:	c7 04 24 6e 2b 10 80 	movl   $0x80102b6e,(%esp)
80102ccc:	e8 dc da ff ff       	call   801007ad <consoleintr>
}
80102cd1:	c9                   	leave  
80102cd2:	c3                   	ret    
	...

80102cd4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cd4:	55                   	push   %ebp
80102cd5:	89 e5                	mov    %esp,%ebp
80102cd7:	83 ec 08             	sub    $0x8,%esp
80102cda:	8b 55 08             	mov    0x8(%ebp),%edx
80102cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ce4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ceb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cef:	ee                   	out    %al,(%dx)
}
80102cf0:	c9                   	leave  
80102cf1:	c3                   	ret    

80102cf2 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cf2:	55                   	push   %ebp
80102cf3:	89 e5                	mov    %esp,%ebp
80102cf5:	53                   	push   %ebx
80102cf6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cf9:	9c                   	pushf  
80102cfa:	5b                   	pop    %ebx
80102cfb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d01:	83 c4 10             	add    $0x10,%esp
80102d04:	5b                   	pop    %ebx
80102d05:	5d                   	pop    %ebp
80102d06:	c3                   	ret    

80102d07 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d07:	55                   	push   %ebp
80102d08:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d0a:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102d0f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d12:	c1 e2 02             	shl    $0x2,%edx
80102d15:	01 c2                	add    %eax,%edx
80102d17:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d1a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d1c:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102d21:	83 c0 20             	add    $0x20,%eax
80102d24:	8b 00                	mov    (%eax),%eax
}
80102d26:	5d                   	pop    %ebp
80102d27:	c3                   	ret    

80102d28 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d28:	55                   	push   %ebp
80102d29:	89 e5                	mov    %esp,%ebp
80102d2b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d2e:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102d33:	85 c0                	test   %eax,%eax
80102d35:	0f 84 47 01 00 00    	je     80102e82 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d3b:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d42:	00 
80102d43:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d4a:	e8 b8 ff ff ff       	call   80102d07 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d4f:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d56:	00 
80102d57:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d5e:	e8 a4 ff ff ff       	call   80102d07 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d63:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d6a:	00 
80102d6b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d72:	e8 90 ff ff ff       	call   80102d07 <lapicw>
  lapicw(TICR, 10000000); 
80102d77:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d7e:	00 
80102d7f:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d86:	e8 7c ff ff ff       	call   80102d07 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d8b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d92:	00 
80102d93:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d9a:	e8 68 ff ff ff       	call   80102d07 <lapicw>
  lapicw(LINT1, MASKED);
80102d9f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102da6:	00 
80102da7:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102dae:	e8 54 ff ff ff       	call   80102d07 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102db3:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102db8:	83 c0 30             	add    $0x30,%eax
80102dbb:	8b 00                	mov    (%eax),%eax
80102dbd:	c1 e8 10             	shr    $0x10,%eax
80102dc0:	25 ff 00 00 00       	and    $0xff,%eax
80102dc5:	83 f8 03             	cmp    $0x3,%eax
80102dc8:	76 14                	jbe    80102dde <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102dca:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dd1:	00 
80102dd2:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102dd9:	e8 29 ff ff ff       	call   80102d07 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102dde:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102de5:	00 
80102de6:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102ded:	e8 15 ff ff ff       	call   80102d07 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102df2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102df9:	00 
80102dfa:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e01:	e8 01 ff ff ff       	call   80102d07 <lapicw>
  lapicw(ESR, 0);
80102e06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e0d:	00 
80102e0e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e15:	e8 ed fe ff ff       	call   80102d07 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e21:	00 
80102e22:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e29:	e8 d9 fe ff ff       	call   80102d07 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e35:	00 
80102e36:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e3d:	e8 c5 fe ff ff       	call   80102d07 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e42:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e49:	00 
80102e4a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e51:	e8 b1 fe ff ff       	call   80102d07 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e56:	90                   	nop
80102e57:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e5c:	05 00 03 00 00       	add    $0x300,%eax
80102e61:	8b 00                	mov    (%eax),%eax
80102e63:	25 00 10 00 00       	and    $0x1000,%eax
80102e68:	85 c0                	test   %eax,%eax
80102e6a:	75 eb                	jne    80102e57 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e73:	00 
80102e74:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e7b:	e8 87 fe ff ff       	call   80102d07 <lapicw>
80102e80:	eb 01                	jmp    80102e83 <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102e82:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102e83:	c9                   	leave  
80102e84:	c3                   	ret    

80102e85 <cpunum>:

int
cpunum(void)
{
80102e85:	55                   	push   %ebp
80102e86:	89 e5                	mov    %esp,%ebp
80102e88:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e8b:	e8 62 fe ff ff       	call   80102cf2 <readeflags>
80102e90:	25 00 02 00 00       	and    $0x200,%eax
80102e95:	85 c0                	test   %eax,%eax
80102e97:	74 29                	je     80102ec2 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102e99:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102e9e:	85 c0                	test   %eax,%eax
80102ea0:	0f 94 c2             	sete   %dl
80102ea3:	83 c0 01             	add    $0x1,%eax
80102ea6:	a3 60 b6 10 80       	mov    %eax,0x8010b660
80102eab:	84 d2                	test   %dl,%dl
80102ead:	74 13                	je     80102ec2 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eaf:	8b 45 04             	mov    0x4(%ebp),%eax
80102eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb6:	c7 04 24 f8 83 10 80 	movl   $0x801083f8,(%esp)
80102ebd:	e8 df d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102ec2:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ec7:	85 c0                	test   %eax,%eax
80102ec9:	74 0f                	je     80102eda <cpunum+0x55>
    return lapic[ID]>>24;
80102ecb:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ed0:	83 c0 20             	add    $0x20,%eax
80102ed3:	8b 00                	mov    (%eax),%eax
80102ed5:	c1 e8 18             	shr    $0x18,%eax
80102ed8:	eb 05                	jmp    80102edf <cpunum+0x5a>
  return 0;
80102eda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102edf:	c9                   	leave  
80102ee0:	c3                   	ret    

80102ee1 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ee1:	55                   	push   %ebp
80102ee2:	89 e5                	mov    %esp,%ebp
80102ee4:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ee7:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102eec:	85 c0                	test   %eax,%eax
80102eee:	74 14                	je     80102f04 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102ef0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ef7:	00 
80102ef8:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102eff:	e8 03 fe ff ff       	call   80102d07 <lapicw>
}
80102f04:	c9                   	leave  
80102f05:	c3                   	ret    

80102f06 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f06:	55                   	push   %ebp
80102f07:	89 e5                	mov    %esp,%ebp
}
80102f09:	5d                   	pop    %ebp
80102f0a:	c3                   	ret    

80102f0b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f0b:	55                   	push   %ebp
80102f0c:	89 e5                	mov    %esp,%ebp
80102f0e:	83 ec 1c             	sub    $0x1c,%esp
80102f11:	8b 45 08             	mov    0x8(%ebp),%eax
80102f14:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102f17:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f1e:	00 
80102f1f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f26:	e8 a9 fd ff ff       	call   80102cd4 <outb>
  outb(IO_RTC+1, 0x0A);
80102f2b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f32:	00 
80102f33:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f3a:	e8 95 fd ff ff       	call   80102cd4 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f3f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f46:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f49:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f51:	8d 50 02             	lea    0x2(%eax),%edx
80102f54:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f57:	c1 e8 04             	shr    $0x4,%eax
80102f5a:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f5d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f61:	c1 e0 18             	shl    $0x18,%eax
80102f64:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f68:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f6f:	e8 93 fd ff ff       	call   80102d07 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f74:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f7b:	00 
80102f7c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f83:	e8 7f fd ff ff       	call   80102d07 <lapicw>
  microdelay(200);
80102f88:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f8f:	e8 72 ff ff ff       	call   80102f06 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f94:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f9b:	00 
80102f9c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fa3:	e8 5f fd ff ff       	call   80102d07 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fa8:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102faf:	e8 52 ff ff ff       	call   80102f06 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fb4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102fbb:	eb 40                	jmp    80102ffd <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fbd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fc1:	c1 e0 18             	shl    $0x18,%eax
80102fc4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fc8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fcf:	e8 33 fd ff ff       	call   80102d07 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fd7:	c1 e8 0c             	shr    $0xc,%eax
80102fda:	80 cc 06             	or     $0x6,%ah
80102fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fe1:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fe8:	e8 1a fd ff ff       	call   80102d07 <lapicw>
    microdelay(200);
80102fed:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ff4:	e8 0d ff ff ff       	call   80102f06 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ff9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102ffd:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103001:	7e ba                	jle    80102fbd <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103003:	c9                   	leave  
80103004:	c3                   	ret    
80103005:	00 00                	add    %al,(%eax)
	...

80103008 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103008:	55                   	push   %ebp
80103009:	89 e5                	mov    %esp,%ebp
8010300b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010300e:	c7 44 24 04 24 84 10 	movl   $0x80108424,0x4(%esp)
80103015:	80 
80103016:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010301d:	e8 dc 1a 00 00       	call   80104afe <initlock>
  readsb(ROOTDEV, &sb);
80103022:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103025:	89 44 24 04          	mov    %eax,0x4(%esp)
80103029:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103030:	e8 af e2 ff ff       	call   801012e4 <readsb>
  log.start = sb.size - sb.nlog;
80103035:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010303b:	89 d1                	mov    %edx,%ecx
8010303d:	29 c1                	sub    %eax,%ecx
8010303f:	89 c8                	mov    %ecx,%eax
80103041:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
80103046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103049:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
8010304e:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
80103055:	00 00 00 
  recover_from_log();
80103058:	e8 97 01 00 00       	call   801031f4 <recover_from_log>
}
8010305d:	c9                   	leave  
8010305e:	c3                   	ret    

8010305f <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010305f:	55                   	push   %ebp
80103060:	89 e5                	mov    %esp,%ebp
80103062:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103065:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010306c:	e9 89 00 00 00       	jmp    801030fa <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103071:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103076:	03 45 f4             	add    -0xc(%ebp),%eax
80103079:	83 c0 01             	add    $0x1,%eax
8010307c:	89 c2                	mov    %eax,%edx
8010307e:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103083:	89 54 24 04          	mov    %edx,0x4(%esp)
80103087:	89 04 24             	mov    %eax,(%esp)
8010308a:	e8 17 d1 ff ff       	call   801001a6 <bread>
8010308f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103095:	83 c0 10             	add    $0x10,%eax
80103098:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010309f:	89 c2                	mov    %eax,%edx
801030a1:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801030a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801030aa:	89 04 24             	mov    %eax,(%esp)
801030ad:	e8 f4 d0 ff ff       	call   801001a6 <bread>
801030b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801030b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030b8:	8d 50 18             	lea    0x18(%eax),%edx
801030bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030be:	83 c0 18             	add    $0x18,%eax
801030c1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801030c8:	00 
801030c9:	89 54 24 04          	mov    %edx,0x4(%esp)
801030cd:	89 04 24             	mov    %eax,(%esp)
801030d0:	e8 6c 1d 00 00       	call   80104e41 <memmove>
    bwrite(dbuf);  // write dst to disk
801030d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030d8:	89 04 24             	mov    %eax,(%esp)
801030db:	e8 fd d0 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801030e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030e3:	89 04 24             	mov    %eax,(%esp)
801030e6:	e8 2c d1 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801030eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ee:	89 04 24             	mov    %eax,(%esp)
801030f1:	e8 21 d1 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030fa:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801030ff:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103102:	0f 8f 69 ff ff ff    	jg     80103071 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103108:	c9                   	leave  
80103109:	c3                   	ret    

8010310a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010310a:	55                   	push   %ebp
8010310b:	89 e5                	mov    %esp,%ebp
8010310d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103110:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103115:	89 c2                	mov    %eax,%edx
80103117:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010311c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103120:	89 04 24             	mov    %eax,(%esp)
80103123:	e8 7e d0 ff ff       	call   801001a6 <bread>
80103128:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010312b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010312e:	83 c0 18             	add    $0x18,%eax
80103131:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103134:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103137:	8b 00                	mov    (%eax),%eax
80103139:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
8010313e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103145:	eb 1b                	jmp    80103162 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103147:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010314a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010314d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103151:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103154:	83 c2 10             	add    $0x10,%edx
80103157:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010315e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103162:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103167:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010316a:	7f db                	jg     80103147 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
8010316c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010316f:	89 04 24             	mov    %eax,(%esp)
80103172:	e8 a0 d0 ff ff       	call   80100217 <brelse>
}
80103177:	c9                   	leave  
80103178:	c3                   	ret    

80103179 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103179:	55                   	push   %ebp
8010317a:	89 e5                	mov    %esp,%ebp
8010317c:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010317f:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103184:	89 c2                	mov    %eax,%edx
80103186:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010318b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010318f:	89 04 24             	mov    %eax,(%esp)
80103192:	e8 0f d0 ff ff       	call   801001a6 <bread>
80103197:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010319a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010319d:	83 c0 18             	add    $0x18,%eax
801031a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801031a3:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
801031a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ac:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801031ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031b5:	eb 1b                	jmp    801031d2 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801031b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031ba:	83 c0 10             	add    $0x10,%eax
801031bd:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
801031c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031ca:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801031ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031d2:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801031d7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801031da:	7f db                	jg     801031b7 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801031dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031df:	89 04 24             	mov    %eax,(%esp)
801031e2:	e8 f6 cf ff ff       	call   801001dd <bwrite>
  brelse(buf);
801031e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031ea:	89 04 24             	mov    %eax,(%esp)
801031ed:	e8 25 d0 ff ff       	call   80100217 <brelse>
}
801031f2:	c9                   	leave  
801031f3:	c3                   	ret    

801031f4 <recover_from_log>:

static void
recover_from_log(void)
{
801031f4:	55                   	push   %ebp
801031f5:	89 e5                	mov    %esp,%ebp
801031f7:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801031fa:	e8 0b ff ff ff       	call   8010310a <read_head>
  install_trans(); // if committed, copy from log to disk
801031ff:	e8 5b fe ff ff       	call   8010305f <install_trans>
  log.lh.n = 0;
80103204:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010320b:	00 00 00 
  write_head(); // clear the log
8010320e:	e8 66 ff ff ff       	call   80103179 <write_head>
}
80103213:	c9                   	leave  
80103214:	c3                   	ret    

80103215 <begin_trans>:

void
begin_trans(void)
{
80103215:	55                   	push   %ebp
80103216:	89 e5                	mov    %esp,%ebp
80103218:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010321b:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103222:	e8 f8 18 00 00       	call   80104b1f <acquire>
  while (log.busy) {
80103227:	eb 14                	jmp    8010323d <begin_trans+0x28>
    sleep(&log, &log.lock);
80103229:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103230:	80 
80103231:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103238:	e8 fc 15 00 00       	call   80104839 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
8010323d:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103242:	85 c0                	test   %eax,%eax
80103244:	75 e3                	jne    80103229 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103246:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
8010324d:	00 00 00 
  release(&log.lock);
80103250:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103257:	e8 25 19 00 00       	call   80104b81 <release>
}
8010325c:	c9                   	leave  
8010325d:	c3                   	ret    

8010325e <commit_trans>:

void
commit_trans(void)
{
8010325e:	55                   	push   %ebp
8010325f:	89 e5                	mov    %esp,%ebp
80103261:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103264:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103269:	85 c0                	test   %eax,%eax
8010326b:	7e 19                	jle    80103286 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
8010326d:	e8 07 ff ff ff       	call   80103179 <write_head>
    install_trans(); // Now install writes to home locations
80103272:	e8 e8 fd ff ff       	call   8010305f <install_trans>
    log.lh.n = 0; 
80103277:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010327e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103281:	e8 f3 fe ff ff       	call   80103179 <write_head>
  }
  
  acquire(&log.lock);
80103286:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010328d:	e8 8d 18 00 00       	call   80104b1f <acquire>
  log.busy = 0;
80103292:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
80103299:	00 00 00 
  wakeup(&log);
8010329c:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801032a3:	e8 6d 16 00 00       	call   80104915 <wakeup>
  release(&log.lock);
801032a8:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801032af:	e8 cd 18 00 00       	call   80104b81 <release>
}
801032b4:	c9                   	leave  
801032b5:	c3                   	ret    

801032b6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801032b6:	55                   	push   %ebp
801032b7:	89 e5                	mov    %esp,%ebp
801032b9:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801032bc:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801032c1:	83 f8 09             	cmp    $0x9,%eax
801032c4:	7f 12                	jg     801032d8 <log_write+0x22>
801032c6:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801032cb:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
801032d1:	83 ea 01             	sub    $0x1,%edx
801032d4:	39 d0                	cmp    %edx,%eax
801032d6:	7c 0c                	jl     801032e4 <log_write+0x2e>
    panic("too big a transaction");
801032d8:	c7 04 24 28 84 10 80 	movl   $0x80108428,(%esp)
801032df:	e8 59 d2 ff ff       	call   8010053d <panic>
  if (!log.busy)
801032e4:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801032e9:	85 c0                	test   %eax,%eax
801032eb:	75 0c                	jne    801032f9 <log_write+0x43>
    panic("write outside of trans");
801032ed:	c7 04 24 3e 84 10 80 	movl   $0x8010843e,(%esp)
801032f4:	e8 44 d2 ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
801032f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103300:	eb 1d                	jmp    8010331f <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103302:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103305:	83 c0 10             	add    $0x10,%eax
80103308:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010330f:	89 c2                	mov    %eax,%edx
80103311:	8b 45 08             	mov    0x8(%ebp),%eax
80103314:	8b 40 08             	mov    0x8(%eax),%eax
80103317:	39 c2                	cmp    %eax,%edx
80103319:	74 10                	je     8010332b <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010331b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010331f:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103324:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103327:	7f d9                	jg     80103302 <log_write+0x4c>
80103329:	eb 01                	jmp    8010332c <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010332b:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
8010332c:	8b 45 08             	mov    0x8(%ebp),%eax
8010332f:	8b 40 08             	mov    0x8(%eax),%eax
80103332:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103335:	83 c2 10             	add    $0x10,%edx
80103338:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010333f:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103344:	03 45 f4             	add    -0xc(%ebp),%eax
80103347:	83 c0 01             	add    $0x1,%eax
8010334a:	89 c2                	mov    %eax,%edx
8010334c:	8b 45 08             	mov    0x8(%ebp),%eax
8010334f:	8b 40 04             	mov    0x4(%eax),%eax
80103352:	89 54 24 04          	mov    %edx,0x4(%esp)
80103356:	89 04 24             	mov    %eax,(%esp)
80103359:	e8 48 ce ff ff       	call   801001a6 <bread>
8010335e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103361:	8b 45 08             	mov    0x8(%ebp),%eax
80103364:	8d 50 18             	lea    0x18(%eax),%edx
80103367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336a:	83 c0 18             	add    $0x18,%eax
8010336d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103374:	00 
80103375:	89 54 24 04          	mov    %edx,0x4(%esp)
80103379:	89 04 24             	mov    %eax,(%esp)
8010337c:	e8 c0 1a 00 00       	call   80104e41 <memmove>
  bwrite(lbuf);
80103381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103384:	89 04 24             	mov    %eax,(%esp)
80103387:	e8 51 ce ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
8010338c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338f:	89 04 24             	mov    %eax,(%esp)
80103392:	e8 80 ce ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
80103397:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010339c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010339f:	75 0d                	jne    801033ae <log_write+0xf8>
    log.lh.n++;
801033a1:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801033a6:	83 c0 01             	add    $0x1,%eax
801033a9:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
801033ae:	8b 45 08             	mov    0x8(%ebp),%eax
801033b1:	8b 00                	mov    (%eax),%eax
801033b3:	89 c2                	mov    %eax,%edx
801033b5:	83 ca 04             	or     $0x4,%edx
801033b8:	8b 45 08             	mov    0x8(%ebp),%eax
801033bb:	89 10                	mov    %edx,(%eax)
}
801033bd:	c9                   	leave  
801033be:	c3                   	ret    
	...

801033c0 <v2p>:
801033c0:	55                   	push   %ebp
801033c1:	89 e5                	mov    %esp,%ebp
801033c3:	8b 45 08             	mov    0x8(%ebp),%eax
801033c6:	05 00 00 00 80       	add    $0x80000000,%eax
801033cb:	5d                   	pop    %ebp
801033cc:	c3                   	ret    

801033cd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801033cd:	55                   	push   %ebp
801033ce:	89 e5                	mov    %esp,%ebp
801033d0:	8b 45 08             	mov    0x8(%ebp),%eax
801033d3:	05 00 00 00 80       	add    $0x80000000,%eax
801033d8:	5d                   	pop    %ebp
801033d9:	c3                   	ret    

801033da <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801033da:	55                   	push   %ebp
801033db:	89 e5                	mov    %esp,%ebp
801033dd:	53                   	push   %ebx
801033de:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801033e1:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033e4:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801033e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033ea:	89 c3                	mov    %eax,%ebx
801033ec:	89 d8                	mov    %ebx,%eax
801033ee:	f0 87 02             	lock xchg %eax,(%edx)
801033f1:	89 c3                	mov    %eax,%ebx
801033f3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801033f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801033f9:	83 c4 10             	add    $0x10,%esp
801033fc:	5b                   	pop    %ebx
801033fd:	5d                   	pop    %ebp
801033fe:	c3                   	ret    

801033ff <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801033ff:	55                   	push   %ebp
80103400:	89 e5                	mov    %esp,%ebp
80103402:	83 e4 f0             	and    $0xfffffff0,%esp
80103405:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103408:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010340f:	80 
80103410:	c7 04 24 1c 2a 11 80 	movl   $0x80112a1c,(%esp)
80103417:	e8 ad f5 ff ff       	call   801029c9 <kinit1>
  kvmalloc();      // kernel page table
8010341c:	e8 4d 46 00 00       	call   80107a6e <kvmalloc>
  mpinit();        // collect info about this machine
80103421:	e8 53 04 00 00       	call   80103879 <mpinit>
  lapicinit();
80103426:	e8 fd f8 ff ff       	call   80102d28 <lapicinit>
  seginit();       // set up segments
8010342b:	e8 e1 3f 00 00       	call   80107411 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103430:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103436:	0f b6 00             	movzbl (%eax),%eax
80103439:	0f b6 c0             	movzbl %al,%eax
8010343c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103440:	c7 04 24 55 84 10 80 	movl   $0x80108455,(%esp)
80103447:	e8 55 cf ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
8010344c:	e8 8d 06 00 00       	call   80103ade <picinit>
  ioapicinit();    // another interrupt controller
80103451:	e8 63 f4 ff ff       	call   801028b9 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103456:	e8 32 d6 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
8010345b:	e8 fc 32 00 00       	call   8010675c <uartinit>
  pinit();         // process table
80103460:	e8 8e 0b 00 00       	call   80103ff3 <pinit>
  tvinit();        // trap vectors
80103465:	e8 05 2e 00 00       	call   8010626f <tvinit>
  binit();         // buffer cache
8010346a:	e8 c5 cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010346f:	e8 84 da ff ff       	call   80100ef8 <fileinit>
  iinit();         // inode cache
80103474:	e8 32 e1 ff ff       	call   801015ab <iinit>
  ideinit();       // disk
80103479:	e8 a0 f0 ff ff       	call   8010251e <ideinit>
  if(!ismp)
8010347e:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103483:	85 c0                	test   %eax,%eax
80103485:	75 05                	jne    8010348c <main+0x8d>
    timerinit();   // uniprocessor timer
80103487:	e8 26 2d 00 00       	call   801061b2 <timerinit>
  startothers();   // start other processors
8010348c:	e8 7f 00 00 00       	call   80103510 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103491:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103498:	8e 
80103499:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801034a0:	e8 5c f5 ff ff       	call   80102a01 <kinit2>
  userinit();      // first user process
801034a5:	e8 8e 0c 00 00       	call   80104138 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801034aa:	e8 1a 00 00 00       	call   801034c9 <mpmain>

801034af <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801034af:	55                   	push   %ebp
801034b0:	89 e5                	mov    %esp,%ebp
801034b2:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801034b5:	e8 cb 45 00 00       	call   80107a85 <switchkvm>
  seginit();
801034ba:	e8 52 3f 00 00       	call   80107411 <seginit>
  lapicinit();
801034bf:	e8 64 f8 ff ff       	call   80102d28 <lapicinit>
  mpmain();
801034c4:	e8 00 00 00 00       	call   801034c9 <mpmain>

801034c9 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801034c9:	55                   	push   %ebp
801034ca:	89 e5                	mov    %esp,%ebp
801034cc:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801034cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034d5:	0f b6 00             	movzbl (%eax),%eax
801034d8:	0f b6 c0             	movzbl %al,%eax
801034db:	89 44 24 04          	mov    %eax,0x4(%esp)
801034df:	c7 04 24 6c 84 10 80 	movl   $0x8010846c,(%esp)
801034e6:	e8 b6 ce ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
801034eb:	e8 f3 2e 00 00       	call   801063e3 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801034f0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034f6:	05 a8 00 00 00       	add    $0xa8,%eax
801034fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103502:	00 
80103503:	89 04 24             	mov    %eax,(%esp)
80103506:	e8 cf fe ff ff       	call   801033da <xchg>
  scheduler();     // start running processes
8010350b:	e8 7d 11 00 00       	call   8010468d <scheduler>

80103510 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103510:	55                   	push   %ebp
80103511:	89 e5                	mov    %esp,%ebp
80103513:	53                   	push   %ebx
80103514:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103517:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010351e:	e8 aa fe ff ff       	call   801033cd <p2v>
80103523:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103526:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010352b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010352f:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
80103536:	80 
80103537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010353a:	89 04 24             	mov    %eax,(%esp)
8010353d:	e8 ff 18 00 00       	call   80104e41 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103542:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
80103549:	e9 86 00 00 00       	jmp    801035d4 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
8010354e:	e8 32 f9 ff ff       	call   80102e85 <cpunum>
80103553:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103559:	05 40 f9 10 80       	add    $0x8010f940,%eax
8010355e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103561:	74 69                	je     801035cc <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103563:	e8 8f f5 ff ff       	call   80102af7 <kalloc>
80103568:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010356b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356e:	83 e8 04             	sub    $0x4,%eax
80103571:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103574:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010357a:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010357c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010357f:	83 e8 08             	sub    $0x8,%eax
80103582:	c7 00 af 34 10 80    	movl   $0x801034af,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010358b:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010358e:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103595:	e8 26 fe ff ff       	call   801033c0 <v2p>
8010359a:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010359c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010359f:	89 04 24             	mov    %eax,(%esp)
801035a2:	e8 19 fe ff ff       	call   801033c0 <v2p>
801035a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035aa:	0f b6 12             	movzbl (%edx),%edx
801035ad:	0f b6 d2             	movzbl %dl,%edx
801035b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801035b4:	89 14 24             	mov    %edx,(%esp)
801035b7:	e8 4f f9 ff ff       	call   80102f0b <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801035bc:	90                   	nop
801035bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801035c6:	85 c0                	test   %eax,%eax
801035c8:	74 f3                	je     801035bd <startothers+0xad>
801035ca:	eb 01                	jmp    801035cd <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801035cc:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801035cd:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801035d4:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801035d9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801035df:	05 40 f9 10 80       	add    $0x8010f940,%eax
801035e4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035e7:	0f 87 61 ff ff ff    	ja     8010354e <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801035ed:	83 c4 24             	add    $0x24,%esp
801035f0:	5b                   	pop    %ebx
801035f1:	5d                   	pop    %ebp
801035f2:	c3                   	ret    
	...

801035f4 <p2v>:
801035f4:	55                   	push   %ebp
801035f5:	89 e5                	mov    %esp,%ebp
801035f7:	8b 45 08             	mov    0x8(%ebp),%eax
801035fa:	05 00 00 00 80       	add    $0x80000000,%eax
801035ff:	5d                   	pop    %ebp
80103600:	c3                   	ret    

80103601 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103601:	55                   	push   %ebp
80103602:	89 e5                	mov    %esp,%ebp
80103604:	53                   	push   %ebx
80103605:	83 ec 14             	sub    $0x14,%esp
80103608:	8b 45 08             	mov    0x8(%ebp),%eax
8010360b:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010360f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103613:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103617:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010361b:	ec                   	in     (%dx),%al
8010361c:	89 c3                	mov    %eax,%ebx
8010361e:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103621:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103625:	83 c4 14             	add    $0x14,%esp
80103628:	5b                   	pop    %ebx
80103629:	5d                   	pop    %ebp
8010362a:	c3                   	ret    

8010362b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010362b:	55                   	push   %ebp
8010362c:	89 e5                	mov    %esp,%ebp
8010362e:	83 ec 08             	sub    $0x8,%esp
80103631:	8b 55 08             	mov    0x8(%ebp),%edx
80103634:	8b 45 0c             	mov    0xc(%ebp),%eax
80103637:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010363b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010363e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103642:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103646:	ee                   	out    %al,(%dx)
}
80103647:	c9                   	leave  
80103648:	c3                   	ret    

80103649 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103649:	55                   	push   %ebp
8010364a:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
8010364c:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80103651:	89 c2                	mov    %eax,%edx
80103653:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
80103658:	89 d1                	mov    %edx,%ecx
8010365a:	29 c1                	sub    %eax,%ecx
8010365c:	89 c8                	mov    %ecx,%eax
8010365e:	c1 f8 02             	sar    $0x2,%eax
80103661:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103667:	5d                   	pop    %ebp
80103668:	c3                   	ret    

80103669 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103669:	55                   	push   %ebp
8010366a:	89 e5                	mov    %esp,%ebp
8010366c:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010366f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103676:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010367d:	eb 13                	jmp    80103692 <sum+0x29>
    sum += addr[i];
8010367f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103682:	03 45 08             	add    0x8(%ebp),%eax
80103685:	0f b6 00             	movzbl (%eax),%eax
80103688:	0f b6 c0             	movzbl %al,%eax
8010368b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
8010368e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103692:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103695:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103698:	7c e5                	jl     8010367f <sum+0x16>
    sum += addr[i];
  return sum;
8010369a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010369d:	c9                   	leave  
8010369e:	c3                   	ret    

8010369f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010369f:	55                   	push   %ebp
801036a0:	89 e5                	mov    %esp,%ebp
801036a2:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801036a5:	8b 45 08             	mov    0x8(%ebp),%eax
801036a8:	89 04 24             	mov    %eax,(%esp)
801036ab:	e8 44 ff ff ff       	call   801035f4 <p2v>
801036b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801036b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801036b6:	03 45 f0             	add    -0x10(%ebp),%eax
801036b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801036bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801036c2:	eb 3f                	jmp    80103703 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801036c4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801036cb:	00 
801036cc:	c7 44 24 04 80 84 10 	movl   $0x80108480,0x4(%esp)
801036d3:	80 
801036d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d7:	89 04 24             	mov    %eax,(%esp)
801036da:	e8 06 17 00 00       	call   80104de5 <memcmp>
801036df:	85 c0                	test   %eax,%eax
801036e1:	75 1c                	jne    801036ff <mpsearch1+0x60>
801036e3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801036ea:	00 
801036eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ee:	89 04 24             	mov    %eax,(%esp)
801036f1:	e8 73 ff ff ff       	call   80103669 <sum>
801036f6:	84 c0                	test   %al,%al
801036f8:	75 05                	jne    801036ff <mpsearch1+0x60>
      return (struct mp*)p;
801036fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036fd:	eb 11                	jmp    80103710 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801036ff:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103706:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103709:	72 b9                	jb     801036c4 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
8010370b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103710:	c9                   	leave  
80103711:	c3                   	ret    

80103712 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103712:	55                   	push   %ebp
80103713:	89 e5                	mov    %esp,%ebp
80103715:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103718:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010371f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103722:	83 c0 0f             	add    $0xf,%eax
80103725:	0f b6 00             	movzbl (%eax),%eax
80103728:	0f b6 c0             	movzbl %al,%eax
8010372b:	89 c2                	mov    %eax,%edx
8010372d:	c1 e2 08             	shl    $0x8,%edx
80103730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103733:	83 c0 0e             	add    $0xe,%eax
80103736:	0f b6 00             	movzbl (%eax),%eax
80103739:	0f b6 c0             	movzbl %al,%eax
8010373c:	09 d0                	or     %edx,%eax
8010373e:	c1 e0 04             	shl    $0x4,%eax
80103741:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103744:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103748:	74 21                	je     8010376b <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
8010374a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103751:	00 
80103752:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103755:	89 04 24             	mov    %eax,(%esp)
80103758:	e8 42 ff ff ff       	call   8010369f <mpsearch1>
8010375d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103760:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103764:	74 50                	je     801037b6 <mpsearch+0xa4>
      return mp;
80103766:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103769:	eb 5f                	jmp    801037ca <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
8010376b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010376e:	83 c0 14             	add    $0x14,%eax
80103771:	0f b6 00             	movzbl (%eax),%eax
80103774:	0f b6 c0             	movzbl %al,%eax
80103777:	89 c2                	mov    %eax,%edx
80103779:	c1 e2 08             	shl    $0x8,%edx
8010377c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010377f:	83 c0 13             	add    $0x13,%eax
80103782:	0f b6 00             	movzbl (%eax),%eax
80103785:	0f b6 c0             	movzbl %al,%eax
80103788:	09 d0                	or     %edx,%eax
8010378a:	c1 e0 0a             	shl    $0xa,%eax
8010378d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103790:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103793:	2d 00 04 00 00       	sub    $0x400,%eax
80103798:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010379f:	00 
801037a0:	89 04 24             	mov    %eax,(%esp)
801037a3:	e8 f7 fe ff ff       	call   8010369f <mpsearch1>
801037a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801037ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801037af:	74 05                	je     801037b6 <mpsearch+0xa4>
      return mp;
801037b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037b4:	eb 14                	jmp    801037ca <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801037b6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801037bd:	00 
801037be:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801037c5:	e8 d5 fe ff ff       	call   8010369f <mpsearch1>
}
801037ca:	c9                   	leave  
801037cb:	c3                   	ret    

801037cc <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801037cc:	55                   	push   %ebp
801037cd:	89 e5                	mov    %esp,%ebp
801037cf:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801037d2:	e8 3b ff ff ff       	call   80103712 <mpsearch>
801037d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801037da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037de:	74 0a                	je     801037ea <mpconfig+0x1e>
801037e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e3:	8b 40 04             	mov    0x4(%eax),%eax
801037e6:	85 c0                	test   %eax,%eax
801037e8:	75 0a                	jne    801037f4 <mpconfig+0x28>
    return 0;
801037ea:	b8 00 00 00 00       	mov    $0x0,%eax
801037ef:	e9 83 00 00 00       	jmp    80103877 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801037f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037f7:	8b 40 04             	mov    0x4(%eax),%eax
801037fa:	89 04 24             	mov    %eax,(%esp)
801037fd:	e8 f2 fd ff ff       	call   801035f4 <p2v>
80103802:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103805:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010380c:	00 
8010380d:	c7 44 24 04 85 84 10 	movl   $0x80108485,0x4(%esp)
80103814:	80 
80103815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103818:	89 04 24             	mov    %eax,(%esp)
8010381b:	e8 c5 15 00 00       	call   80104de5 <memcmp>
80103820:	85 c0                	test   %eax,%eax
80103822:	74 07                	je     8010382b <mpconfig+0x5f>
    return 0;
80103824:	b8 00 00 00 00       	mov    $0x0,%eax
80103829:	eb 4c                	jmp    80103877 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
8010382b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010382e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103832:	3c 01                	cmp    $0x1,%al
80103834:	74 12                	je     80103848 <mpconfig+0x7c>
80103836:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103839:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010383d:	3c 04                	cmp    $0x4,%al
8010383f:	74 07                	je     80103848 <mpconfig+0x7c>
    return 0;
80103841:	b8 00 00 00 00       	mov    $0x0,%eax
80103846:	eb 2f                	jmp    80103877 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103848:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010384b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010384f:	0f b7 c0             	movzwl %ax,%eax
80103852:	89 44 24 04          	mov    %eax,0x4(%esp)
80103856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103859:	89 04 24             	mov    %eax,(%esp)
8010385c:	e8 08 fe ff ff       	call   80103669 <sum>
80103861:	84 c0                	test   %al,%al
80103863:	74 07                	je     8010386c <mpconfig+0xa0>
    return 0;
80103865:	b8 00 00 00 00       	mov    $0x0,%eax
8010386a:	eb 0b                	jmp    80103877 <mpconfig+0xab>
  *pmp = mp;
8010386c:	8b 45 08             	mov    0x8(%ebp),%eax
8010386f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103872:	89 10                	mov    %edx,(%eax)
  return conf;
80103874:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103877:	c9                   	leave  
80103878:	c3                   	ret    

80103879 <mpinit>:

void
mpinit(void)
{
80103879:	55                   	push   %ebp
8010387a:	89 e5                	mov    %esp,%ebp
8010387c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
8010387f:	c7 05 64 b6 10 80 40 	movl   $0x8010f940,0x8010b664
80103886:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103889:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010388c:	89 04 24             	mov    %eax,(%esp)
8010388f:	e8 38 ff ff ff       	call   801037cc <mpconfig>
80103894:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103897:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010389b:	0f 84 9c 01 00 00    	je     80103a3d <mpinit+0x1c4>
    return;
  ismp = 1;
801038a1:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
801038a8:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801038ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ae:	8b 40 24             	mov    0x24(%eax),%eax
801038b1:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801038b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b9:	83 c0 2c             	add    $0x2c,%eax
801038bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801038bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801038c6:	0f b7 c0             	movzwl %ax,%eax
801038c9:	03 45 f0             	add    -0x10(%ebp),%eax
801038cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801038cf:	e9 f4 00 00 00       	jmp    801039c8 <mpinit+0x14f>
    switch(*p){
801038d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038d7:	0f b6 00             	movzbl (%eax),%eax
801038da:	0f b6 c0             	movzbl %al,%eax
801038dd:	83 f8 04             	cmp    $0x4,%eax
801038e0:	0f 87 bf 00 00 00    	ja     801039a5 <mpinit+0x12c>
801038e6:	8b 04 85 c8 84 10 80 	mov    -0x7fef7b38(,%eax,4),%eax
801038ed:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801038ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801038f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038f8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801038fc:	0f b6 d0             	movzbl %al,%edx
801038ff:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103904:	39 c2                	cmp    %eax,%edx
80103906:	74 2d                	je     80103935 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103908:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010390b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010390f:	0f b6 d0             	movzbl %al,%edx
80103912:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103917:	89 54 24 08          	mov    %edx,0x8(%esp)
8010391b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010391f:	c7 04 24 8a 84 10 80 	movl   $0x8010848a,(%esp)
80103926:	e8 76 ca ff ff       	call   801003a1 <cprintf>
        ismp = 0;
8010392b:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103932:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103935:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103938:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010393c:	0f b6 c0             	movzbl %al,%eax
8010393f:	83 e0 02             	and    $0x2,%eax
80103942:	85 c0                	test   %eax,%eax
80103944:	74 15                	je     8010395b <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103946:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
8010394b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103951:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103956:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
8010395b:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103961:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103966:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
8010396c:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103972:	88 02                	mov    %al,(%edx)
      ncpu++;
80103974:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103979:	83 c0 01             	add    $0x1,%eax
8010397c:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103981:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103985:	eb 41                	jmp    801039c8 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010398a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010398d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103990:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103994:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103999:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010399d:	eb 29                	jmp    801039c8 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010399f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039a3:	eb 23                	jmp    801039c8 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801039a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a8:	0f b6 00             	movzbl (%eax),%eax
801039ab:	0f b6 c0             	movzbl %al,%eax
801039ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801039b2:	c7 04 24 a8 84 10 80 	movl   $0x801084a8,(%esp)
801039b9:	e8 e3 c9 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801039be:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
801039c5:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801039c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039ce:	0f 82 00 ff ff ff    	jb     801038d4 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801039d4:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801039d9:	85 c0                	test   %eax,%eax
801039db:	75 1d                	jne    801039fa <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801039dd:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
801039e4:	00 00 00 
    lapic = 0;
801039e7:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
801039ee:	00 00 00 
    ioapicid = 0;
801039f1:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
801039f8:	eb 44                	jmp    80103a3e <mpinit+0x1c5>
  }

  if(mp->imcrp){
801039fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039fd:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103a01:	84 c0                	test   %al,%al
80103a03:	74 39                	je     80103a3e <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103a05:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103a0c:	00 
80103a0d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103a14:	e8 12 fc ff ff       	call   8010362b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103a19:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a20:	e8 dc fb ff ff       	call   80103601 <inb>
80103a25:	83 c8 01             	or     $0x1,%eax
80103a28:	0f b6 c0             	movzbl %al,%eax
80103a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a2f:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a36:	e8 f0 fb ff ff       	call   8010362b <outb>
80103a3b:	eb 01                	jmp    80103a3e <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103a3d:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103a3e:	c9                   	leave  
80103a3f:	c3                   	ret    

80103a40 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a40:	55                   	push   %ebp
80103a41:	89 e5                	mov    %esp,%ebp
80103a43:	83 ec 08             	sub    $0x8,%esp
80103a46:	8b 55 08             	mov    0x8(%ebp),%edx
80103a49:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a4c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a50:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a53:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a57:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a5b:	ee                   	out    %al,(%dx)
}
80103a5c:	c9                   	leave  
80103a5d:	c3                   	ret    

80103a5e <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103a5e:	55                   	push   %ebp
80103a5f:	89 e5                	mov    %esp,%ebp
80103a61:	83 ec 0c             	sub    $0xc,%esp
80103a64:	8b 45 08             	mov    0x8(%ebp),%eax
80103a67:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103a6b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a6f:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103a75:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a79:	0f b6 c0             	movzbl %al,%eax
80103a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a80:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103a87:	e8 b4 ff ff ff       	call   80103a40 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103a8c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a90:	66 c1 e8 08          	shr    $0x8,%ax
80103a94:	0f b6 c0             	movzbl %al,%eax
80103a97:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a9b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103aa2:	e8 99 ff ff ff       	call   80103a40 <outb>
}
80103aa7:	c9                   	leave  
80103aa8:	c3                   	ret    

80103aa9 <picenable>:

void
picenable(int irq)
{
80103aa9:	55                   	push   %ebp
80103aaa:	89 e5                	mov    %esp,%ebp
80103aac:	53                   	push   %ebx
80103aad:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab3:	ba 01 00 00 00       	mov    $0x1,%edx
80103ab8:	89 d3                	mov    %edx,%ebx
80103aba:	89 c1                	mov    %eax,%ecx
80103abc:	d3 e3                	shl    %cl,%ebx
80103abe:	89 d8                	mov    %ebx,%eax
80103ac0:	89 c2                	mov    %eax,%edx
80103ac2:	f7 d2                	not    %edx
80103ac4:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103acb:	21 d0                	and    %edx,%eax
80103acd:	0f b7 c0             	movzwl %ax,%eax
80103ad0:	89 04 24             	mov    %eax,(%esp)
80103ad3:	e8 86 ff ff ff       	call   80103a5e <picsetmask>
}
80103ad8:	83 c4 04             	add    $0x4,%esp
80103adb:	5b                   	pop    %ebx
80103adc:	5d                   	pop    %ebp
80103add:	c3                   	ret    

80103ade <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ade:	55                   	push   %ebp
80103adf:	89 e5                	mov    %esp,%ebp
80103ae1:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ae4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103aeb:	00 
80103aec:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103af3:	e8 48 ff ff ff       	call   80103a40 <outb>
  outb(IO_PIC2+1, 0xFF);
80103af8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103aff:	00 
80103b00:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b07:	e8 34 ff ff ff       	call   80103a40 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103b0c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b13:	00 
80103b14:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b1b:	e8 20 ff ff ff       	call   80103a40 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103b20:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103b27:	00 
80103b28:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b2f:	e8 0c ff ff ff       	call   80103a40 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b34:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103b3b:	00 
80103b3c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b43:	e8 f8 fe ff ff       	call   80103a40 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103b48:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b4f:	00 
80103b50:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b57:	e8 e4 fe ff ff       	call   80103a40 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103b5c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b63:	00 
80103b64:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b6b:	e8 d0 fe ff ff       	call   80103a40 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103b70:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103b77:	00 
80103b78:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b7f:	e8 bc fe ff ff       	call   80103a40 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103b84:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103b8b:	00 
80103b8c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b93:	e8 a8 fe ff ff       	call   80103a40 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103b98:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b9f:	00 
80103ba0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ba7:	e8 94 fe ff ff       	call   80103a40 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103bac:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bb3:	00 
80103bb4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103bbb:	e8 80 fe ff ff       	call   80103a40 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103bc0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103bc7:	00 
80103bc8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103bcf:	e8 6c fe ff ff       	call   80103a40 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103bd4:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bdb:	00 
80103bdc:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103be3:	e8 58 fe ff ff       	call   80103a40 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103be8:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103bef:	00 
80103bf0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bf7:	e8 44 fe ff ff       	call   80103a40 <outb>

  if(irqmask != 0xFFFF)
80103bfc:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c03:	66 83 f8 ff          	cmp    $0xffff,%ax
80103c07:	74 12                	je     80103c1b <picinit+0x13d>
    picsetmask(irqmask);
80103c09:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c10:	0f b7 c0             	movzwl %ax,%eax
80103c13:	89 04 24             	mov    %eax,(%esp)
80103c16:	e8 43 fe ff ff       	call   80103a5e <picsetmask>
}
80103c1b:	c9                   	leave  
80103c1c:	c3                   	ret    
80103c1d:	00 00                	add    %al,(%eax)
	...

80103c20 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103c20:	55                   	push   %ebp
80103c21:	89 e5                	mov    %esp,%ebp
80103c23:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103c26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c36:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c39:	8b 10                	mov    (%eax),%edx
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c40:	e8 cf d2 ff ff       	call   80100f14 <filealloc>
80103c45:	8b 55 08             	mov    0x8(%ebp),%edx
80103c48:	89 02                	mov    %eax,(%edx)
80103c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c4d:	8b 00                	mov    (%eax),%eax
80103c4f:	85 c0                	test   %eax,%eax
80103c51:	0f 84 c8 00 00 00    	je     80103d1f <pipealloc+0xff>
80103c57:	e8 b8 d2 ff ff       	call   80100f14 <filealloc>
80103c5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c5f:	89 02                	mov    %eax,(%edx)
80103c61:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c64:	8b 00                	mov    (%eax),%eax
80103c66:	85 c0                	test   %eax,%eax
80103c68:	0f 84 b1 00 00 00    	je     80103d1f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c6e:	e8 84 ee ff ff       	call   80102af7 <kalloc>
80103c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c7a:	0f 84 9e 00 00 00    	je     80103d1e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c83:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c8a:	00 00 00 
  p->writeopen = 1;
80103c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c90:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c97:	00 00 00 
  p->nwrite = 0;
80103c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ca4:	00 00 00 
  p->nread = 0;
80103ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103caa:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103cb1:	00 00 00 
  initlock(&p->lock, "pipe");
80103cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb7:	c7 44 24 04 dc 84 10 	movl   $0x801084dc,0x4(%esp)
80103cbe:	80 
80103cbf:	89 04 24             	mov    %eax,(%esp)
80103cc2:	e8 37 0e 00 00       	call   80104afe <initlock>
  (*f0)->type = FD_PIPE;
80103cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80103cca:	8b 00                	mov    (%eax),%eax
80103ccc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd5:	8b 00                	mov    (%eax),%eax
80103cd7:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80103cde:	8b 00                	mov    (%eax),%eax
80103ce0:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce7:	8b 00                	mov    (%eax),%eax
80103ce9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cec:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103cef:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf2:	8b 00                	mov    (%eax),%eax
80103cf4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cfd:	8b 00                	mov    (%eax),%eax
80103cff:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103d03:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d06:	8b 00                	mov    (%eax),%eax
80103d08:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d0f:	8b 00                	mov    (%eax),%eax
80103d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d14:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103d17:	b8 00 00 00 00       	mov    $0x0,%eax
80103d1c:	eb 43                	jmp    80103d61 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103d1e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103d1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d23:	74 0b                	je     80103d30 <pipealloc+0x110>
    kfree((char*)p);
80103d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d28:	89 04 24             	mov    %eax,(%esp)
80103d2b:	e8 2e ed ff ff       	call   80102a5e <kfree>
  if(*f0)
80103d30:	8b 45 08             	mov    0x8(%ebp),%eax
80103d33:	8b 00                	mov    (%eax),%eax
80103d35:	85 c0                	test   %eax,%eax
80103d37:	74 0d                	je     80103d46 <pipealloc+0x126>
    fileclose(*f0);
80103d39:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3c:	8b 00                	mov    (%eax),%eax
80103d3e:	89 04 24             	mov    %eax,(%esp)
80103d41:	e8 76 d2 ff ff       	call   80100fbc <fileclose>
  if(*f1)
80103d46:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d49:	8b 00                	mov    (%eax),%eax
80103d4b:	85 c0                	test   %eax,%eax
80103d4d:	74 0d                	je     80103d5c <pipealloc+0x13c>
    fileclose(*f1);
80103d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d52:	8b 00                	mov    (%eax),%eax
80103d54:	89 04 24             	mov    %eax,(%esp)
80103d57:	e8 60 d2 ff ff       	call   80100fbc <fileclose>
  return -1;
80103d5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d61:	c9                   	leave  
80103d62:	c3                   	ret    

80103d63 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d63:	55                   	push   %ebp
80103d64:	89 e5                	mov    %esp,%ebp
80103d66:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103d69:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6c:	89 04 24             	mov    %eax,(%esp)
80103d6f:	e8 ab 0d 00 00       	call   80104b1f <acquire>
  if(writable){
80103d74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d78:	74 1f                	je     80103d99 <pipeclose+0x36>
    p->writeopen = 0;
80103d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d84:	00 00 00 
    wakeup(&p->nread);
80103d87:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8a:	05 34 02 00 00       	add    $0x234,%eax
80103d8f:	89 04 24             	mov    %eax,(%esp)
80103d92:	e8 7e 0b 00 00       	call   80104915 <wakeup>
80103d97:	eb 1d                	jmp    80103db6 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103d99:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103da3:	00 00 00 
    wakeup(&p->nwrite);
80103da6:	8b 45 08             	mov    0x8(%ebp),%eax
80103da9:	05 38 02 00 00       	add    $0x238,%eax
80103dae:	89 04 24             	mov    %eax,(%esp)
80103db1:	e8 5f 0b 00 00       	call   80104915 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103db6:	8b 45 08             	mov    0x8(%ebp),%eax
80103db9:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103dbf:	85 c0                	test   %eax,%eax
80103dc1:	75 25                	jne    80103de8 <pipeclose+0x85>
80103dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dcc:	85 c0                	test   %eax,%eax
80103dce:	75 18                	jne    80103de8 <pipeclose+0x85>
    release(&p->lock);
80103dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd3:	89 04 24             	mov    %eax,(%esp)
80103dd6:	e8 a6 0d 00 00       	call   80104b81 <release>
    kfree((char*)p);
80103ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dde:	89 04 24             	mov    %eax,(%esp)
80103de1:	e8 78 ec ff ff       	call   80102a5e <kfree>
80103de6:	eb 0b                	jmp    80103df3 <pipeclose+0x90>
  } else
    release(&p->lock);
80103de8:	8b 45 08             	mov    0x8(%ebp),%eax
80103deb:	89 04 24             	mov    %eax,(%esp)
80103dee:	e8 8e 0d 00 00       	call   80104b81 <release>
}
80103df3:	c9                   	leave  
80103df4:	c3                   	ret    

80103df5 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103df5:	55                   	push   %ebp
80103df6:	89 e5                	mov    %esp,%ebp
80103df8:	53                   	push   %ebx
80103df9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103dff:	89 04 24             	mov    %eax,(%esp)
80103e02:	e8 18 0d 00 00       	call   80104b1f <acquire>
  for(i = 0; i < n; i++){
80103e07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e0e:	e9 a6 00 00 00       	jmp    80103eb9 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103e13:	8b 45 08             	mov    0x8(%ebp),%eax
80103e16:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e1c:	85 c0                	test   %eax,%eax
80103e1e:	74 0d                	je     80103e2d <pipewrite+0x38>
80103e20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e26:	8b 40 24             	mov    0x24(%eax),%eax
80103e29:	85 c0                	test   %eax,%eax
80103e2b:	74 15                	je     80103e42 <pipewrite+0x4d>
        release(&p->lock);
80103e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e30:	89 04 24             	mov    %eax,(%esp)
80103e33:	e8 49 0d 00 00       	call   80104b81 <release>
        return -1;
80103e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e3d:	e9 9d 00 00 00       	jmp    80103edf <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103e42:	8b 45 08             	mov    0x8(%ebp),%eax
80103e45:	05 34 02 00 00       	add    $0x234,%eax
80103e4a:	89 04 24             	mov    %eax,(%esp)
80103e4d:	e8 c3 0a 00 00       	call   80104915 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e52:	8b 45 08             	mov    0x8(%ebp),%eax
80103e55:	8b 55 08             	mov    0x8(%ebp),%edx
80103e58:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e62:	89 14 24             	mov    %edx,(%esp)
80103e65:	e8 cf 09 00 00       	call   80104839 <sleep>
80103e6a:	eb 01                	jmp    80103e6d <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e6c:	90                   	nop
80103e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e70:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e76:	8b 45 08             	mov    0x8(%ebp),%eax
80103e79:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e7f:	05 00 02 00 00       	add    $0x200,%eax
80103e84:	39 c2                	cmp    %eax,%edx
80103e86:	74 8b                	je     80103e13 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e88:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e91:	89 c3                	mov    %eax,%ebx
80103e93:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103e99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e9c:	03 55 0c             	add    0xc(%ebp),%edx
80103e9f:	0f b6 0a             	movzbl (%edx),%ecx
80103ea2:	8b 55 08             	mov    0x8(%ebp),%edx
80103ea5:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80103ea9:	8d 50 01             	lea    0x1(%eax),%edx
80103eac:	8b 45 08             	mov    0x8(%ebp),%eax
80103eaf:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103eb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ebc:	3b 45 10             	cmp    0x10(%ebp),%eax
80103ebf:	7c ab                	jl     80103e6c <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec4:	05 34 02 00 00       	add    $0x234,%eax
80103ec9:	89 04 24             	mov    %eax,(%esp)
80103ecc:	e8 44 0a 00 00       	call   80104915 <wakeup>
  release(&p->lock);
80103ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed4:	89 04 24             	mov    %eax,(%esp)
80103ed7:	e8 a5 0c 00 00       	call   80104b81 <release>
  return n;
80103edc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103edf:	83 c4 24             	add    $0x24,%esp
80103ee2:	5b                   	pop    %ebx
80103ee3:	5d                   	pop    %ebp
80103ee4:	c3                   	ret    

80103ee5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ee5:	55                   	push   %ebp
80103ee6:	89 e5                	mov    %esp,%ebp
80103ee8:	53                   	push   %ebx
80103ee9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103eec:	8b 45 08             	mov    0x8(%ebp),%eax
80103eef:	89 04 24             	mov    %eax,(%esp)
80103ef2:	e8 28 0c 00 00       	call   80104b1f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ef7:	eb 3a                	jmp    80103f33 <piperead+0x4e>
    if(proc->killed){
80103ef9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103eff:	8b 40 24             	mov    0x24(%eax),%eax
80103f02:	85 c0                	test   %eax,%eax
80103f04:	74 15                	je     80103f1b <piperead+0x36>
      release(&p->lock);
80103f06:	8b 45 08             	mov    0x8(%ebp),%eax
80103f09:	89 04 24             	mov    %eax,(%esp)
80103f0c:	e8 70 0c 00 00       	call   80104b81 <release>
      return -1;
80103f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f16:	e9 b6 00 00 00       	jmp    80103fd1 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1e:	8b 55 08             	mov    0x8(%ebp),%edx
80103f21:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f27:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f2b:	89 14 24             	mov    %edx,(%esp)
80103f2e:	e8 06 09 00 00       	call   80104839 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f33:	8b 45 08             	mov    0x8(%ebp),%eax
80103f36:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f45:	39 c2                	cmp    %eax,%edx
80103f47:	75 0d                	jne    80103f56 <piperead+0x71>
80103f49:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f52:	85 c0                	test   %eax,%eax
80103f54:	75 a3                	jne    80103ef9 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f5d:	eb 49                	jmp    80103fa8 <piperead+0xc3>
    if(p->nread == p->nwrite)
80103f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f62:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f68:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f71:	39 c2                	cmp    %eax,%edx
80103f73:	74 3d                	je     80103fb2 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f78:	89 c2                	mov    %eax,%edx
80103f7a:	03 55 0c             	add    0xc(%ebp),%edx
80103f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f80:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f86:	89 c3                	mov    %eax,%ebx
80103f88:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f91:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80103f96:	88 0a                	mov    %cl,(%edx)
80103f98:	8d 50 01             	lea    0x1(%eax),%edx
80103f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9e:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103fa4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fab:	3b 45 10             	cmp    0x10(%ebp),%eax
80103fae:	7c af                	jl     80103f5f <piperead+0x7a>
80103fb0:	eb 01                	jmp    80103fb3 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80103fb2:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb6:	05 38 02 00 00       	add    $0x238,%eax
80103fbb:	89 04 24             	mov    %eax,(%esp)
80103fbe:	e8 52 09 00 00       	call   80104915 <wakeup>
  release(&p->lock);
80103fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc6:	89 04 24             	mov    %eax,(%esp)
80103fc9:	e8 b3 0b 00 00       	call   80104b81 <release>
  return i;
80103fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fd1:	83 c4 24             	add    $0x24,%esp
80103fd4:	5b                   	pop    %ebx
80103fd5:	5d                   	pop    %ebp
80103fd6:	c3                   	ret    
	...

80103fd8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103fd8:	55                   	push   %ebp
80103fd9:	89 e5                	mov    %esp,%ebp
80103fdb:	53                   	push   %ebx
80103fdc:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fdf:	9c                   	pushf  
80103fe0:	5b                   	pop    %ebx
80103fe1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103fe4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103fe7:	83 c4 10             	add    $0x10,%esp
80103fea:	5b                   	pop    %ebx
80103feb:	5d                   	pop    %ebp
80103fec:	c3                   	ret    

80103fed <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80103fed:	55                   	push   %ebp
80103fee:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ff0:	fb                   	sti    
}
80103ff1:	5d                   	pop    %ebp
80103ff2:	c3                   	ret    

80103ff3 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103ff3:	55                   	push   %ebp
80103ff4:	89 e5                	mov    %esp,%ebp
80103ff6:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103ff9:	c7 44 24 04 e1 84 10 	movl   $0x801084e1,0x4(%esp)
80104000:	80 
80104001:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104008:	e8 f1 0a 00 00       	call   80104afe <initlock>
}
8010400d:	c9                   	leave  
8010400e:	c3                   	ret    

8010400f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010400f:	55                   	push   %ebp
80104010:	89 e5                	mov    %esp,%ebp
80104012:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104015:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010401c:	e8 fe 0a 00 00       	call   80104b1f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104021:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104028:	eb 11                	jmp    8010403b <allocproc+0x2c>
    if(p->state == UNUSED)
8010402a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402d:	8b 40 0c             	mov    0xc(%eax),%eax
80104030:	85 c0                	test   %eax,%eax
80104032:	74 26                	je     8010405a <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104034:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010403b:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104042:	72 e6                	jb     8010402a <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104044:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010404b:	e8 31 0b 00 00       	call   80104b81 <release>
  return 0;
80104050:	b8 00 00 00 00       	mov    $0x0,%eax
80104055:	e9 dc 00 00 00       	jmp    80104136 <allocproc+0x127>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010405a:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104065:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010406a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010406d:	89 42 10             	mov    %eax,0x10(%edx)
80104070:	83 c0 01             	add    $0x1,%eax
80104073:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
80104078:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010407f:	e8 fd 0a 00 00       	call   80104b81 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104084:	e8 6e ea ff ff       	call   80102af7 <kalloc>
80104089:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010408c:	89 42 08             	mov    %eax,0x8(%edx)
8010408f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104092:	8b 40 08             	mov    0x8(%eax),%eax
80104095:	85 c0                	test   %eax,%eax
80104097:	75 14                	jne    801040ad <allocproc+0x9e>
    p->state = UNUSED;
80104099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801040a3:	b8 00 00 00 00       	mov    $0x0,%eax
801040a8:	e9 89 00 00 00       	jmp    80104136 <allocproc+0x127>
  }
  sp = p->kstack + KSTACKSIZE;
801040ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b0:	8b 40 08             	mov    0x8(%eax),%eax
801040b3:	05 00 10 00 00       	add    $0x1000,%eax
801040b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801040bb:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801040bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040c5:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801040c8:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801040cc:	ba 24 62 10 80       	mov    $0x80106224,%edx
801040d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040d4:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801040d6:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801040da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040e0:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801040e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e6:	8b 40 1c             	mov    0x1c(%eax),%eax
801040e9:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801040f0:	00 
801040f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801040f8:	00 
801040f9:	89 04 24             	mov    %eax,(%esp)
801040fc:	e8 6d 0c 00 00       	call   80104d6e <memset>
  p->context->eip = (uint)forkret;
80104101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104104:	8b 40 1c             	mov    0x1c(%eax),%eax
80104107:	ba 0d 48 10 80       	mov    $0x8010480d,%edx
8010410c:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticksalarma =0;
8010410f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104112:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->alarmhandler =0;
80104119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411c:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104123:	00 00 00 
  p->ticks=0;
80104126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104129:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104130:	00 00 00 

  return p;
80104133:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104136:	c9                   	leave  
80104137:	c3                   	ret    

80104138 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104138:	55                   	push   %ebp
80104139:	89 e5                	mov    %esp,%ebp
8010413b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010413e:	e8 cc fe ff ff       	call   8010400f <allocproc>
80104143:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
8010414e:	e8 5e 38 00 00       	call   801079b1 <setupkvm>
80104153:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104156:	89 42 04             	mov    %eax,0x4(%edx)
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	8b 40 04             	mov    0x4(%eax),%eax
8010415f:	85 c0                	test   %eax,%eax
80104161:	75 0c                	jne    8010416f <userinit+0x37>
    panic("userinit: out of memory?");
80104163:	c7 04 24 e8 84 10 80 	movl   $0x801084e8,(%esp)
8010416a:	e8 ce c3 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010416f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104177:	8b 40 04             	mov    0x4(%eax),%eax
8010417a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010417e:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
80104185:	80 
80104186:	89 04 24             	mov    %eax,(%esp)
80104189:	e8 7b 3a 00 00       	call   80107c09 <inituvm>
  p->sz = PGSIZE;
8010418e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104191:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419a:	8b 40 18             	mov    0x18(%eax),%eax
8010419d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801041a4:	00 
801041a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801041ac:	00 
801041ad:	89 04 24             	mov    %eax,(%esp)
801041b0:	e8 b9 0b 00 00       	call   80104d6e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801041b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b8:	8b 40 18             	mov    0x18(%eax),%eax
801041bb:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c4:	8b 40 18             	mov    0x18(%eax),%eax
801041c7:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801041cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d0:	8b 40 18             	mov    0x18(%eax),%eax
801041d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041d6:	8b 52 18             	mov    0x18(%edx),%edx
801041d9:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801041dd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801041e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e4:	8b 40 18             	mov    0x18(%eax),%eax
801041e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ea:	8b 52 18             	mov    0x18(%edx),%edx
801041ed:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801041f1:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801041f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f8:	8b 40 18             	mov    0x18(%eax),%eax
801041fb:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	8b 40 18             	mov    0x18(%eax),%eax
80104208:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104212:	8b 40 18             	mov    0x18(%eax),%eax
80104215:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010421c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421f:	83 c0 6c             	add    $0x6c,%eax
80104222:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104229:	00 
8010422a:	c7 44 24 04 01 85 10 	movl   $0x80108501,0x4(%esp)
80104231:	80 
80104232:	89 04 24             	mov    %eax,(%esp)
80104235:	e8 64 0d 00 00       	call   80104f9e <safestrcpy>
  p->cwd = namei("/");
8010423a:	c7 04 24 0a 85 10 80 	movl   $0x8010850a,(%esp)
80104241:	e8 bc e1 ff ff       	call   80102402 <namei>
80104246:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104249:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
8010424c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104256:	c9                   	leave  
80104257:	c3                   	ret    

80104258 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104258:	55                   	push   %ebp
80104259:	89 e5                	mov    %esp,%ebp
8010425b:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010425e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104264:	8b 00                	mov    (%eax),%eax
80104266:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104269:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010426d:	7e 34                	jle    801042a3 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010426f:	8b 45 08             	mov    0x8(%ebp),%eax
80104272:	89 c2                	mov    %eax,%edx
80104274:	03 55 f4             	add    -0xc(%ebp),%edx
80104277:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010427d:	8b 40 04             	mov    0x4(%eax),%eax
80104280:	89 54 24 08          	mov    %edx,0x8(%esp)
80104284:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104287:	89 54 24 04          	mov    %edx,0x4(%esp)
8010428b:	89 04 24             	mov    %eax,(%esp)
8010428e:	e8 f0 3a 00 00       	call   80107d83 <allocuvm>
80104293:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104296:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010429a:	75 41                	jne    801042dd <growproc+0x85>
      return -1;
8010429c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a1:	eb 58                	jmp    801042fb <growproc+0xa3>
  } else if(n < 0){
801042a3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042a7:	79 34                	jns    801042dd <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801042a9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ac:	89 c2                	mov    %eax,%edx
801042ae:	03 55 f4             	add    -0xc(%ebp),%edx
801042b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042b7:	8b 40 04             	mov    0x4(%eax),%eax
801042ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801042be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801042c5:	89 04 24             	mov    %eax,(%esp)
801042c8:	e8 90 3b 00 00       	call   80107e5d <deallocuvm>
801042cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042d4:	75 07                	jne    801042dd <growproc+0x85>
      return -1;
801042d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042db:	eb 1e                	jmp    801042fb <growproc+0xa3>
  }
  proc->sz = sz;
801042dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042e6:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801042e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ee:	89 04 24             	mov    %eax,(%esp)
801042f1:	e8 ac 37 00 00       	call   80107aa2 <switchuvm>
  return 0;
801042f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042fb:	c9                   	leave  
801042fc:	c3                   	ret    

801042fd <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801042fd:	55                   	push   %ebp
801042fe:	89 e5                	mov    %esp,%ebp
80104300:	57                   	push   %edi
80104301:	56                   	push   %esi
80104302:	53                   	push   %ebx
80104303:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104306:	e8 04 fd ff ff       	call   8010400f <allocproc>
8010430b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010430e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104312:	75 0a                	jne    8010431e <fork+0x21>
    return -1;
80104314:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104319:	e9 3a 01 00 00       	jmp    80104458 <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010431e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104324:	8b 10                	mov    (%eax),%edx
80104326:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010432c:	8b 40 04             	mov    0x4(%eax),%eax
8010432f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104333:	89 04 24             	mov    %eax,(%esp)
80104336:	e8 b2 3c 00 00       	call   80107fed <copyuvm>
8010433b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010433e:	89 42 04             	mov    %eax,0x4(%edx)
80104341:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104344:	8b 40 04             	mov    0x4(%eax),%eax
80104347:	85 c0                	test   %eax,%eax
80104349:	75 2c                	jne    80104377 <fork+0x7a>
    kfree(np->kstack);
8010434b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010434e:	8b 40 08             	mov    0x8(%eax),%eax
80104351:	89 04 24             	mov    %eax,(%esp)
80104354:	e8 05 e7 ff ff       	call   80102a5e <kfree>
    np->kstack = 0;
80104359:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010435c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104363:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104366:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010436d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104372:	e9 e1 00 00 00       	jmp    80104458 <fork+0x15b>
  }
  np->sz = proc->sz;
80104377:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010437d:	8b 10                	mov    (%eax),%edx
8010437f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104382:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104384:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010438b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010438e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104391:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104394:	8b 50 18             	mov    0x18(%eax),%edx
80104397:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010439d:	8b 40 18             	mov    0x18(%eax),%eax
801043a0:	89 c3                	mov    %eax,%ebx
801043a2:	b8 13 00 00 00       	mov    $0x13,%eax
801043a7:	89 d7                	mov    %edx,%edi
801043a9:	89 de                	mov    %ebx,%esi
801043ab:	89 c1                	mov    %eax,%ecx
801043ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801043af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043b2:	8b 40 18             	mov    0x18(%eax),%eax
801043b5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801043bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801043c3:	eb 3d                	jmp    80104402 <fork+0x105>
    if(proc->ofile[i])
801043c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043ce:	83 c2 08             	add    $0x8,%edx
801043d1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043d5:	85 c0                	test   %eax,%eax
801043d7:	74 25                	je     801043fe <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801043d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043e2:	83 c2 08             	add    $0x8,%edx
801043e5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043e9:	89 04 24             	mov    %eax,(%esp)
801043ec:	e8 83 cb ff ff       	call   80100f74 <filedup>
801043f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801043f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801043f7:	83 c1 08             	add    $0x8,%ecx
801043fa:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801043fe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104402:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104406:	7e bd                	jle    801043c5 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104408:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010440e:	8b 40 68             	mov    0x68(%eax),%eax
80104411:	89 04 24             	mov    %eax,(%esp)
80104414:	e8 15 d4 ff ff       	call   8010182e <idup>
80104419:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010441c:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010441f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104422:	8b 40 10             	mov    0x10(%eax),%eax
80104425:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104428:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010442b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104432:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104438:	8d 50 6c             	lea    0x6c(%eax),%edx
8010443b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010443e:	83 c0 6c             	add    $0x6c,%eax
80104441:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104448:	00 
80104449:	89 54 24 04          	mov    %edx,0x4(%esp)
8010444d:	89 04 24             	mov    %eax,(%esp)
80104450:	e8 49 0b 00 00       	call   80104f9e <safestrcpy>
  return pid;
80104455:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104458:	83 c4 2c             	add    $0x2c,%esp
8010445b:	5b                   	pop    %ebx
8010445c:	5e                   	pop    %esi
8010445d:	5f                   	pop    %edi
8010445e:	5d                   	pop    %ebp
8010445f:	c3                   	ret    

80104460 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104460:	55                   	push   %ebp
80104461:	89 e5                	mov    %esp,%ebp
80104463:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104466:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010446d:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104472:	39 c2                	cmp    %eax,%edx
80104474:	75 0c                	jne    80104482 <exit+0x22>
    panic("init exiting");
80104476:	c7 04 24 0c 85 10 80 	movl   $0x8010850c,(%esp)
8010447d:	e8 bb c0 ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104482:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104489:	eb 44                	jmp    801044cf <exit+0x6f>
    if(proc->ofile[fd]){
8010448b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104491:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104494:	83 c2 08             	add    $0x8,%edx
80104497:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010449b:	85 c0                	test   %eax,%eax
8010449d:	74 2c                	je     801044cb <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010449f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044a8:	83 c2 08             	add    $0x8,%edx
801044ab:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044af:	89 04 24             	mov    %eax,(%esp)
801044b2:	e8 05 cb ff ff       	call   80100fbc <fileclose>
      proc->ofile[fd] = 0;
801044b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044c0:	83 c2 08             	add    $0x8,%edx
801044c3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801044ca:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801044cb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801044cf:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801044d3:	7e b6                	jle    8010448b <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
801044d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044db:	8b 40 68             	mov    0x68(%eax),%eax
801044de:	89 04 24             	mov    %eax,(%esp)
801044e1:	e8 2d d5 ff ff       	call   80101a13 <iput>
  proc->cwd = 0;
801044e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044ec:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801044f3:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801044fa:	e8 20 06 00 00       	call   80104b1f <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801044ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104505:	8b 40 14             	mov    0x14(%eax),%eax
80104508:	89 04 24             	mov    %eax,(%esp)
8010450b:	e8 c4 03 00 00       	call   801048d4 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104510:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104517:	eb 3b                	jmp    80104554 <exit+0xf4>
    if(p->parent == proc){
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	8b 50 14             	mov    0x14(%eax),%edx
8010451f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104525:	39 c2                	cmp    %eax,%edx
80104527:	75 24                	jne    8010454d <exit+0xed>
      p->parent = initproc;
80104529:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
8010452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104532:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	8b 40 0c             	mov    0xc(%eax),%eax
8010453b:	83 f8 05             	cmp    $0x5,%eax
8010453e:	75 0d                	jne    8010454d <exit+0xed>
        wakeup1(initproc);
80104540:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104545:	89 04 24             	mov    %eax,(%esp)
80104548:	e8 87 03 00 00       	call   801048d4 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010454d:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104554:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
8010455b:	72 bc                	jb     80104519 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010455d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104563:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010456a:	e8 ba 01 00 00       	call   80104729 <sched>
  panic("zombie exit");
8010456f:	c7 04 24 19 85 10 80 	movl   $0x80108519,(%esp)
80104576:	e8 c2 bf ff ff       	call   8010053d <panic>

8010457b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010457b:	55                   	push   %ebp
8010457c:	89 e5                	mov    %esp,%ebp
8010457e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104581:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104588:	e8 92 05 00 00       	call   80104b1f <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010458d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104594:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010459b:	e9 9d 00 00 00       	jmp    8010463d <wait+0xc2>
      if(p->parent != proc)
801045a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a3:	8b 50 14             	mov    0x14(%eax),%edx
801045a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ac:	39 c2                	cmp    %eax,%edx
801045ae:	0f 85 81 00 00 00    	jne    80104635 <wait+0xba>
        continue;
      havekids = 1;
801045b4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045be:	8b 40 0c             	mov    0xc(%eax),%eax
801045c1:	83 f8 05             	cmp    $0x5,%eax
801045c4:	75 70                	jne    80104636 <wait+0xbb>
        // Found one.
        pid = p->pid;
801045c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c9:	8b 40 10             	mov    0x10(%eax),%eax
801045cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d2:	8b 40 08             	mov    0x8(%eax),%eax
801045d5:	89 04 24             	mov    %eax,(%esp)
801045d8:	e8 81 e4 ff ff       	call   80102a5e <kfree>
        p->kstack = 0;
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801045e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ea:	8b 40 04             	mov    0x4(%eax),%eax
801045ed:	89 04 24             	mov    %eax,(%esp)
801045f0:	e8 24 39 00 00       	call   80107f19 <freevm>
        p->state = UNUSED;
801045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010461a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104624:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010462b:	e8 51 05 00 00       	call   80104b81 <release>
        return pid;
80104630:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104633:	eb 56                	jmp    8010468b <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104635:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104636:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010463d:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104644:	0f 82 56 ff ff ff    	jb     801045a0 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010464a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010464e:	74 0d                	je     8010465d <wait+0xe2>
80104650:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104656:	8b 40 24             	mov    0x24(%eax),%eax
80104659:	85 c0                	test   %eax,%eax
8010465b:	74 13                	je     80104670 <wait+0xf5>
      release(&ptable.lock);
8010465d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104664:	e8 18 05 00 00       	call   80104b81 <release>
      return -1;
80104669:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010466e:	eb 1b                	jmp    8010468b <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104670:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104676:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
8010467d:	80 
8010467e:	89 04 24             	mov    %eax,(%esp)
80104681:	e8 b3 01 00 00       	call   80104839 <sleep>
  }
80104686:	e9 02 ff ff ff       	jmp    8010458d <wait+0x12>
}
8010468b:	c9                   	leave  
8010468c:	c3                   	ret    

8010468d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010468d:	55                   	push   %ebp
8010468e:	89 e5                	mov    %esp,%ebp
80104690:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104693:	e8 55 f9 ff ff       	call   80103fed <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104698:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010469f:	e8 7b 04 00 00       	call   80104b1f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046a4:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801046ab:	eb 62                	jmp    8010470f <scheduler+0x82>
      if(p->state != RUNNABLE)
801046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b0:	8b 40 0c             	mov    0xc(%eax),%eax
801046b3:	83 f8 03             	cmp    $0x3,%eax
801046b6:	75 4f                	jne    80104707 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801046b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bb:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801046c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c4:	89 04 24             	mov    %eax,(%esp)
801046c7:	e8 d6 33 00 00       	call   80107aa2 <switchuvm>
      p->state = RUNNING;
801046cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cf:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801046d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046dc:	8b 40 1c             	mov    0x1c(%eax),%eax
801046df:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801046e6:	83 c2 04             	add    $0x4,%edx
801046e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801046ed:	89 14 24             	mov    %edx,(%esp)
801046f0:	e8 1f 09 00 00       	call   80105014 <swtch>
      switchkvm();
801046f5:	e8 8b 33 00 00       	call   80107a85 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801046fa:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104701:	00 00 00 00 
80104705:	eb 01                	jmp    80104708 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104707:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104708:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010470f:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104716:	72 95                	jb     801046ad <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104718:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010471f:	e8 5d 04 00 00       	call   80104b81 <release>

  }
80104724:	e9 6a ff ff ff       	jmp    80104693 <scheduler+0x6>

80104729 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104729:	55                   	push   %ebp
8010472a:	89 e5                	mov    %esp,%ebp
8010472c:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
8010472f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104736:	e8 02 05 00 00       	call   80104c3d <holding>
8010473b:	85 c0                	test   %eax,%eax
8010473d:	75 0c                	jne    8010474b <sched+0x22>
    panic("sched ptable.lock");
8010473f:	c7 04 24 25 85 10 80 	movl   $0x80108525,(%esp)
80104746:	e8 f2 bd ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
8010474b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104751:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104757:	83 f8 01             	cmp    $0x1,%eax
8010475a:	74 0c                	je     80104768 <sched+0x3f>
    panic("sched locks");
8010475c:	c7 04 24 37 85 10 80 	movl   $0x80108537,(%esp)
80104763:	e8 d5 bd ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104768:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476e:	8b 40 0c             	mov    0xc(%eax),%eax
80104771:	83 f8 04             	cmp    $0x4,%eax
80104774:	75 0c                	jne    80104782 <sched+0x59>
    panic("sched running");
80104776:	c7 04 24 43 85 10 80 	movl   $0x80108543,(%esp)
8010477d:	e8 bb bd ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104782:	e8 51 f8 ff ff       	call   80103fd8 <readeflags>
80104787:	25 00 02 00 00       	and    $0x200,%eax
8010478c:	85 c0                	test   %eax,%eax
8010478e:	74 0c                	je     8010479c <sched+0x73>
    panic("sched interruptible");
80104790:	c7 04 24 51 85 10 80 	movl   $0x80108551,(%esp)
80104797:	e8 a1 bd ff ff       	call   8010053d <panic>
  intena = cpu->intena;
8010479c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047a2:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801047a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801047ab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047b1:	8b 40 04             	mov    0x4(%eax),%eax
801047b4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047bb:	83 c2 1c             	add    $0x1c,%edx
801047be:	89 44 24 04          	mov    %eax,0x4(%esp)
801047c2:	89 14 24             	mov    %edx,(%esp)
801047c5:	e8 4a 08 00 00       	call   80105014 <swtch>
  cpu->intena = intena;
801047ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047d3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801047d9:	c9                   	leave  
801047da:	c3                   	ret    

801047db <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801047db:	55                   	push   %ebp
801047dc:	89 e5                	mov    %esp,%ebp
801047de:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801047e1:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801047e8:	e8 32 03 00 00       	call   80104b1f <acquire>
  proc->state = RUNNABLE;
801047ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801047fa:	e8 2a ff ff ff       	call   80104729 <sched>
  release(&ptable.lock);
801047ff:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104806:	e8 76 03 00 00       	call   80104b81 <release>
}
8010480b:	c9                   	leave  
8010480c:	c3                   	ret    

8010480d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010480d:	55                   	push   %ebp
8010480e:	89 e5                	mov    %esp,%ebp
80104810:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104813:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010481a:	e8 62 03 00 00       	call   80104b81 <release>

  if (first) {
8010481f:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104824:	85 c0                	test   %eax,%eax
80104826:	74 0f                	je     80104837 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104828:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
8010482f:	00 00 00 
    initlog();
80104832:	e8 d1 e7 ff ff       	call   80103008 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104837:	c9                   	leave  
80104838:	c3                   	ret    

80104839 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104839:	55                   	push   %ebp
8010483a:	89 e5                	mov    %esp,%ebp
8010483c:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
8010483f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104845:	85 c0                	test   %eax,%eax
80104847:	75 0c                	jne    80104855 <sleep+0x1c>
    panic("sleep");
80104849:	c7 04 24 65 85 10 80 	movl   $0x80108565,(%esp)
80104850:	e8 e8 bc ff ff       	call   8010053d <panic>

  if(lk == 0)
80104855:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104859:	75 0c                	jne    80104867 <sleep+0x2e>
    panic("sleep without lk");
8010485b:	c7 04 24 6b 85 10 80 	movl   $0x8010856b,(%esp)
80104862:	e8 d6 bc ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104867:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
8010486e:	74 17                	je     80104887 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104870:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104877:	e8 a3 02 00 00       	call   80104b1f <acquire>
    release(lk);
8010487c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010487f:	89 04 24             	mov    %eax,(%esp)
80104882:	e8 fa 02 00 00       	call   80104b81 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104887:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488d:	8b 55 08             	mov    0x8(%ebp),%edx
80104890:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104893:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104899:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801048a0:	e8 84 fe ff ff       	call   80104729 <sched>

  // Tidy up.
  proc->chan = 0;
801048a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ab:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801048b2:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
801048b9:	74 17                	je     801048d2 <sleep+0x99>
    release(&ptable.lock);
801048bb:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801048c2:	e8 ba 02 00 00       	call   80104b81 <release>
    acquire(lk);
801048c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801048ca:	89 04 24             	mov    %eax,(%esp)
801048cd:	e8 4d 02 00 00       	call   80104b1f <acquire>
  }
}
801048d2:	c9                   	leave  
801048d3:	c3                   	ret    

801048d4 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801048d4:	55                   	push   %ebp
801048d5:	89 e5                	mov    %esp,%ebp
801048d7:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048da:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
801048e1:	eb 27                	jmp    8010490a <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801048e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048e6:	8b 40 0c             	mov    0xc(%eax),%eax
801048e9:	83 f8 02             	cmp    $0x2,%eax
801048ec:	75 15                	jne    80104903 <wakeup1+0x2f>
801048ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048f1:	8b 40 20             	mov    0x20(%eax),%eax
801048f4:	3b 45 08             	cmp    0x8(%ebp),%eax
801048f7:	75 0a                	jne    80104903 <wakeup1+0x2f>
      p->state = RUNNABLE;
801048f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048fc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104903:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
8010490a:	81 7d fc 74 21 11 80 	cmpl   $0x80112174,-0x4(%ebp)
80104911:	72 d0                	jb     801048e3 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104913:	c9                   	leave  
80104914:	c3                   	ret    

80104915 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104915:	55                   	push   %ebp
80104916:	89 e5                	mov    %esp,%ebp
80104918:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
8010491b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104922:	e8 f8 01 00 00       	call   80104b1f <acquire>
  wakeup1(chan);
80104927:	8b 45 08             	mov    0x8(%ebp),%eax
8010492a:	89 04 24             	mov    %eax,(%esp)
8010492d:	e8 a2 ff ff ff       	call   801048d4 <wakeup1>
  release(&ptable.lock);
80104932:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104939:	e8 43 02 00 00       	call   80104b81 <release>
}
8010493e:	c9                   	leave  
8010493f:	c3                   	ret    

80104940 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104940:	55                   	push   %ebp
80104941:	89 e5                	mov    %esp,%ebp
80104943:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104946:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010494d:	e8 cd 01 00 00       	call   80104b1f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104952:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104959:	eb 44                	jmp    8010499f <kill+0x5f>
    if(p->pid == pid){
8010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495e:	8b 40 10             	mov    0x10(%eax),%eax
80104961:	3b 45 08             	cmp    0x8(%ebp),%eax
80104964:	75 32                	jne    80104998 <kill+0x58>
      p->killed = 1;
80104966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104969:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104973:	8b 40 0c             	mov    0xc(%eax),%eax
80104976:	83 f8 02             	cmp    $0x2,%eax
80104979:	75 0a                	jne    80104985 <kill+0x45>
        p->state = RUNNABLE;
8010497b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104985:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010498c:	e8 f0 01 00 00       	call   80104b81 <release>
      return 0;
80104991:	b8 00 00 00 00       	mov    $0x0,%eax
80104996:	eb 21                	jmp    801049b9 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104998:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010499f:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801049a6:	72 b3                	jb     8010495b <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801049a8:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049af:	e8 cd 01 00 00       	call   80104b81 <release>
  return -1;
801049b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801049b9:	c9                   	leave  
801049ba:	c3                   	ret    

801049bb <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801049bb:	55                   	push   %ebp
801049bc:	89 e5                	mov    %esp,%ebp
801049be:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049c1:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
801049c8:	e9 db 00 00 00       	jmp    80104aa8 <procdump+0xed>
    if(p->state == UNUSED)
801049cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d0:	8b 40 0c             	mov    0xc(%eax),%eax
801049d3:	85 c0                	test   %eax,%eax
801049d5:	0f 84 c5 00 00 00    	je     80104aa0 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801049db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049de:	8b 40 0c             	mov    0xc(%eax),%eax
801049e1:	83 f8 05             	cmp    $0x5,%eax
801049e4:	77 23                	ja     80104a09 <procdump+0x4e>
801049e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e9:	8b 40 0c             	mov    0xc(%eax),%eax
801049ec:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
801049f3:	85 c0                	test   %eax,%eax
801049f5:	74 12                	je     80104a09 <procdump+0x4e>
      state = states[p->state];
801049f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049fa:	8b 40 0c             	mov    0xc(%eax),%eax
801049fd:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104a04:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104a07:	eb 07                	jmp    80104a10 <procdump+0x55>
    else
      state = "???";
80104a09:	c7 45 ec 7c 85 10 80 	movl   $0x8010857c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a13:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a19:	8b 40 10             	mov    0x10(%eax),%eax
80104a1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104a20:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104a23:	89 54 24 08          	mov    %edx,0x8(%esp)
80104a27:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a2b:	c7 04 24 80 85 10 80 	movl   $0x80108580,(%esp)
80104a32:	e8 6a b9 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a3a:	8b 40 0c             	mov    0xc(%eax),%eax
80104a3d:	83 f8 02             	cmp    $0x2,%eax
80104a40:	75 50                	jne    80104a92 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a45:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a48:	8b 40 0c             	mov    0xc(%eax),%eax
80104a4b:	83 c0 08             	add    $0x8,%eax
80104a4e:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104a51:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a55:	89 04 24             	mov    %eax,(%esp)
80104a58:	e8 73 01 00 00       	call   80104bd0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a64:	eb 1b                	jmp    80104a81 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a69:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a71:	c7 04 24 89 85 10 80 	movl   $0x80108589,(%esp)
80104a78:	e8 24 b9 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104a7d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a81:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a85:	7f 0b                	jg     80104a92 <procdump+0xd7>
80104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a8e:	85 c0                	test   %eax,%eax
80104a90:	75 d4                	jne    80104a66 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104a92:	c7 04 24 8d 85 10 80 	movl   $0x8010858d,(%esp)
80104a99:	e8 03 b9 ff ff       	call   801003a1 <cprintf>
80104a9e:	eb 01                	jmp    80104aa1 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104aa0:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa1:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80104aa8:	81 7d f0 74 21 11 80 	cmpl   $0x80112174,-0x10(%ebp)
80104aaf:	0f 82 18 ff ff ff    	jb     801049cd <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104ab5:	c9                   	leave  
80104ab6:	c3                   	ret    
	...

80104ab8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ab8:	55                   	push   %ebp
80104ab9:	89 e5                	mov    %esp,%ebp
80104abb:	53                   	push   %ebx
80104abc:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104abf:	9c                   	pushf  
80104ac0:	5b                   	pop    %ebx
80104ac1:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104ac4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104ac7:	83 c4 10             	add    $0x10,%esp
80104aca:	5b                   	pop    %ebx
80104acb:	5d                   	pop    %ebp
80104acc:	c3                   	ret    

80104acd <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104acd:	55                   	push   %ebp
80104ace:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ad0:	fa                   	cli    
}
80104ad1:	5d                   	pop    %ebp
80104ad2:	c3                   	ret    

80104ad3 <sti>:

static inline void
sti(void)
{
80104ad3:	55                   	push   %ebp
80104ad4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ad6:	fb                   	sti    
}
80104ad7:	5d                   	pop    %ebp
80104ad8:	c3                   	ret    

80104ad9 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104ad9:	55                   	push   %ebp
80104ada:	89 e5                	mov    %esp,%ebp
80104adc:	53                   	push   %ebx
80104add:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104ae0:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104ae9:	89 c3                	mov    %eax,%ebx
80104aeb:	89 d8                	mov    %ebx,%eax
80104aed:	f0 87 02             	lock xchg %eax,(%edx)
80104af0:	89 c3                	mov    %eax,%ebx
80104af2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104af5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104af8:	83 c4 10             	add    $0x10,%esp
80104afb:	5b                   	pop    %ebx
80104afc:	5d                   	pop    %ebp
80104afd:	c3                   	ret    

80104afe <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104afe:	55                   	push   %ebp
80104aff:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b01:	8b 45 08             	mov    0x8(%ebp),%eax
80104b04:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b07:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b13:	8b 45 08             	mov    0x8(%ebp),%eax
80104b16:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b1d:	5d                   	pop    %ebp
80104b1e:	c3                   	ret    

80104b1f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b1f:	55                   	push   %ebp
80104b20:	89 e5                	mov    %esp,%ebp
80104b22:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b25:	e8 3d 01 00 00       	call   80104c67 <pushcli>
  if(holding(lk))
80104b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b2d:	89 04 24             	mov    %eax,(%esp)
80104b30:	e8 08 01 00 00       	call   80104c3d <holding>
80104b35:	85 c0                	test   %eax,%eax
80104b37:	74 0c                	je     80104b45 <acquire+0x26>
    panic("acquire");
80104b39:	c7 04 24 b9 85 10 80 	movl   $0x801085b9,(%esp)
80104b40:	e8 f8 b9 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104b45:	90                   	nop
80104b46:	8b 45 08             	mov    0x8(%ebp),%eax
80104b49:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104b50:	00 
80104b51:	89 04 24             	mov    %eax,(%esp)
80104b54:	e8 80 ff ff ff       	call   80104ad9 <xchg>
80104b59:	85 c0                	test   %eax,%eax
80104b5b:	75 e9                	jne    80104b46 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b60:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b67:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6d:	83 c0 0c             	add    $0xc,%eax
80104b70:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b74:	8d 45 08             	lea    0x8(%ebp),%eax
80104b77:	89 04 24             	mov    %eax,(%esp)
80104b7a:	e8 51 00 00 00       	call   80104bd0 <getcallerpcs>
}
80104b7f:	c9                   	leave  
80104b80:	c3                   	ret    

80104b81 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b81:	55                   	push   %ebp
80104b82:	89 e5                	mov    %esp,%ebp
80104b84:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104b87:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8a:	89 04 24             	mov    %eax,(%esp)
80104b8d:	e8 ab 00 00 00       	call   80104c3d <holding>
80104b92:	85 c0                	test   %eax,%eax
80104b94:	75 0c                	jne    80104ba2 <release+0x21>
    panic("release");
80104b96:	c7 04 24 c1 85 10 80 	movl   $0x801085c1,(%esp)
80104b9d:	e8 9b b9 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80104ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104bac:	8b 45 08             	mov    0x8(%ebp),%eax
80104baf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104bc0:	00 
80104bc1:	89 04 24             	mov    %eax,(%esp)
80104bc4:	e8 10 ff ff ff       	call   80104ad9 <xchg>

  popcli();
80104bc9:	e8 e1 00 00 00       	call   80104caf <popcli>
}
80104bce:	c9                   	leave  
80104bcf:	c3                   	ret    

80104bd0 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104bd0:	55                   	push   %ebp
80104bd1:	89 e5                	mov    %esp,%ebp
80104bd3:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd9:	83 e8 08             	sub    $0x8,%eax
80104bdc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bdf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104be6:	eb 32                	jmp    80104c1a <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104be8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104bec:	74 47                	je     80104c35 <getcallerpcs+0x65>
80104bee:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104bf5:	76 3e                	jbe    80104c35 <getcallerpcs+0x65>
80104bf7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104bfb:	74 38                	je     80104c35 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104bfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c00:	c1 e0 02             	shl    $0x2,%eax
80104c03:	03 45 0c             	add    0xc(%ebp),%eax
80104c06:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c09:	8b 52 04             	mov    0x4(%edx),%edx
80104c0c:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c11:	8b 00                	mov    (%eax),%eax
80104c13:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104c16:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c1a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c1e:	7e c8                	jle    80104be8 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104c20:	eb 13                	jmp    80104c35 <getcallerpcs+0x65>
    pcs[i] = 0;
80104c22:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c25:	c1 e0 02             	shl    $0x2,%eax
80104c28:	03 45 0c             	add    0xc(%ebp),%eax
80104c2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104c31:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c35:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c39:	7e e7                	jle    80104c22 <getcallerpcs+0x52>
    pcs[i] = 0;
}
80104c3b:	c9                   	leave  
80104c3c:	c3                   	ret    

80104c3d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c3d:	55                   	push   %ebp
80104c3e:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	8b 00                	mov    (%eax),%eax
80104c45:	85 c0                	test   %eax,%eax
80104c47:	74 17                	je     80104c60 <holding+0x23>
80104c49:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4c:	8b 50 08             	mov    0x8(%eax),%edx
80104c4f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c55:	39 c2                	cmp    %eax,%edx
80104c57:	75 07                	jne    80104c60 <holding+0x23>
80104c59:	b8 01 00 00 00       	mov    $0x1,%eax
80104c5e:	eb 05                	jmp    80104c65 <holding+0x28>
80104c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c65:	5d                   	pop    %ebp
80104c66:	c3                   	ret    

80104c67 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c67:	55                   	push   %ebp
80104c68:	89 e5                	mov    %esp,%ebp
80104c6a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104c6d:	e8 46 fe ff ff       	call   80104ab8 <readeflags>
80104c72:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104c75:	e8 53 fe ff ff       	call   80104acd <cli>
  if(cpu->ncli++ == 0)
80104c7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c80:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104c86:	85 d2                	test   %edx,%edx
80104c88:	0f 94 c1             	sete   %cl
80104c8b:	83 c2 01             	add    $0x1,%edx
80104c8e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104c94:	84 c9                	test   %cl,%cl
80104c96:	74 15                	je     80104cad <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80104c98:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c9e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ca1:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ca7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cad:	c9                   	leave  
80104cae:	c3                   	ret    

80104caf <popcli>:

void
popcli(void)
{
80104caf:	55                   	push   %ebp
80104cb0:	89 e5                	mov    %esp,%ebp
80104cb2:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104cb5:	e8 fe fd ff ff       	call   80104ab8 <readeflags>
80104cba:	25 00 02 00 00       	and    $0x200,%eax
80104cbf:	85 c0                	test   %eax,%eax
80104cc1:	74 0c                	je     80104ccf <popcli+0x20>
    panic("popcli - interruptible");
80104cc3:	c7 04 24 c9 85 10 80 	movl   $0x801085c9,(%esp)
80104cca:	e8 6e b8 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80104ccf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cd5:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104cdb:	83 ea 01             	sub    $0x1,%edx
80104cde:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104ce4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104cea:	85 c0                	test   %eax,%eax
80104cec:	79 0c                	jns    80104cfa <popcli+0x4b>
    panic("popcli");
80104cee:	c7 04 24 e0 85 10 80 	movl   $0x801085e0,(%esp)
80104cf5:	e8 43 b8 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104cfa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d00:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d06:	85 c0                	test   %eax,%eax
80104d08:	75 15                	jne    80104d1f <popcli+0x70>
80104d0a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d10:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d16:	85 c0                	test   %eax,%eax
80104d18:	74 05                	je     80104d1f <popcli+0x70>
    sti();
80104d1a:	e8 b4 fd ff ff       	call   80104ad3 <sti>
}
80104d1f:	c9                   	leave  
80104d20:	c3                   	ret    
80104d21:	00 00                	add    %al,(%eax)
	...

80104d24 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104d24:	55                   	push   %ebp
80104d25:	89 e5                	mov    %esp,%ebp
80104d27:	57                   	push   %edi
80104d28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d29:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d2c:	8b 55 10             	mov    0x10(%ebp),%edx
80104d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d32:	89 cb                	mov    %ecx,%ebx
80104d34:	89 df                	mov    %ebx,%edi
80104d36:	89 d1                	mov    %edx,%ecx
80104d38:	fc                   	cld    
80104d39:	f3 aa                	rep stos %al,%es:(%edi)
80104d3b:	89 ca                	mov    %ecx,%edx
80104d3d:	89 fb                	mov    %edi,%ebx
80104d3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104d45:	5b                   	pop    %ebx
80104d46:	5f                   	pop    %edi
80104d47:	5d                   	pop    %ebp
80104d48:	c3                   	ret    

80104d49 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104d49:	55                   	push   %ebp
80104d4a:	89 e5                	mov    %esp,%ebp
80104d4c:	57                   	push   %edi
80104d4d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d51:	8b 55 10             	mov    0x10(%ebp),%edx
80104d54:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d57:	89 cb                	mov    %ecx,%ebx
80104d59:	89 df                	mov    %ebx,%edi
80104d5b:	89 d1                	mov    %edx,%ecx
80104d5d:	fc                   	cld    
80104d5e:	f3 ab                	rep stos %eax,%es:(%edi)
80104d60:	89 ca                	mov    %ecx,%edx
80104d62:	89 fb                	mov    %edi,%ebx
80104d64:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d67:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104d6a:	5b                   	pop    %ebx
80104d6b:	5f                   	pop    %edi
80104d6c:	5d                   	pop    %ebp
80104d6d:	c3                   	ret    

80104d6e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d6e:	55                   	push   %ebp
80104d6f:	89 e5                	mov    %esp,%ebp
80104d71:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d74:	8b 45 08             	mov    0x8(%ebp),%eax
80104d77:	83 e0 03             	and    $0x3,%eax
80104d7a:	85 c0                	test   %eax,%eax
80104d7c:	75 49                	jne    80104dc7 <memset+0x59>
80104d7e:	8b 45 10             	mov    0x10(%ebp),%eax
80104d81:	83 e0 03             	and    $0x3,%eax
80104d84:	85 c0                	test   %eax,%eax
80104d86:	75 3f                	jne    80104dc7 <memset+0x59>
    c &= 0xFF;
80104d88:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d8f:	8b 45 10             	mov    0x10(%ebp),%eax
80104d92:	c1 e8 02             	shr    $0x2,%eax
80104d95:	89 c2                	mov    %eax,%edx
80104d97:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d9a:	89 c1                	mov    %eax,%ecx
80104d9c:	c1 e1 18             	shl    $0x18,%ecx
80104d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da2:	c1 e0 10             	shl    $0x10,%eax
80104da5:	09 c1                	or     %eax,%ecx
80104da7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104daa:	c1 e0 08             	shl    $0x8,%eax
80104dad:	09 c8                	or     %ecx,%eax
80104daf:	0b 45 0c             	or     0xc(%ebp),%eax
80104db2:	89 54 24 08          	mov    %edx,0x8(%esp)
80104db6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dba:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbd:	89 04 24             	mov    %eax,(%esp)
80104dc0:	e8 84 ff ff ff       	call   80104d49 <stosl>
80104dc5:	eb 19                	jmp    80104de0 <memset+0x72>
  } else
    stosb(dst, c, n);
80104dc7:	8b 45 10             	mov    0x10(%ebp),%eax
80104dca:	89 44 24 08          	mov    %eax,0x8(%esp)
80104dce:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd8:	89 04 24             	mov    %eax,(%esp)
80104ddb:	e8 44 ff ff ff       	call   80104d24 <stosb>
  return dst;
80104de0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104de3:	c9                   	leave  
80104de4:	c3                   	ret    

80104de5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104de5:	55                   	push   %ebp
80104de6:	89 e5                	mov    %esp,%ebp
80104de8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80104deb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104df1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104df7:	eb 32                	jmp    80104e2b <memcmp+0x46>
    if(*s1 != *s2)
80104df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dfc:	0f b6 10             	movzbl (%eax),%edx
80104dff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e02:	0f b6 00             	movzbl (%eax),%eax
80104e05:	38 c2                	cmp    %al,%dl
80104e07:	74 1a                	je     80104e23 <memcmp+0x3e>
      return *s1 - *s2;
80104e09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e0c:	0f b6 00             	movzbl (%eax),%eax
80104e0f:	0f b6 d0             	movzbl %al,%edx
80104e12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e15:	0f b6 00             	movzbl (%eax),%eax
80104e18:	0f b6 c0             	movzbl %al,%eax
80104e1b:	89 d1                	mov    %edx,%ecx
80104e1d:	29 c1                	sub    %eax,%ecx
80104e1f:	89 c8                	mov    %ecx,%eax
80104e21:	eb 1c                	jmp    80104e3f <memcmp+0x5a>
    s1++, s2++;
80104e23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e27:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104e2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e2f:	0f 95 c0             	setne  %al
80104e32:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e36:	84 c0                	test   %al,%al
80104e38:	75 bf                	jne    80104df9 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80104e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e3f:	c9                   	leave  
80104e40:	c3                   	ret    

80104e41 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e41:	55                   	push   %ebp
80104e42:	89 e5                	mov    %esp,%ebp
80104e44:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e4a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e50:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e56:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e59:	73 54                	jae    80104eaf <memmove+0x6e>
80104e5b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e5e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e61:	01 d0                	add    %edx,%eax
80104e63:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e66:	76 47                	jbe    80104eaf <memmove+0x6e>
    s += n;
80104e68:	8b 45 10             	mov    0x10(%ebp),%eax
80104e6b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e6e:	8b 45 10             	mov    0x10(%ebp),%eax
80104e71:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e74:	eb 13                	jmp    80104e89 <memmove+0x48>
      *--d = *--s;
80104e76:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e7a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e81:	0f b6 10             	movzbl (%eax),%edx
80104e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e87:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104e89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e8d:	0f 95 c0             	setne  %al
80104e90:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e94:	84 c0                	test   %al,%al
80104e96:	75 de                	jne    80104e76 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104e98:	eb 25                	jmp    80104ebf <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9d:	0f b6 10             	movzbl (%eax),%edx
80104ea0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea3:	88 10                	mov    %dl,(%eax)
80104ea5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ea9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ead:	eb 01                	jmp    80104eb0 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104eaf:	90                   	nop
80104eb0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104eb4:	0f 95 c0             	setne  %al
80104eb7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ebb:	84 c0                	test   %al,%al
80104ebd:	75 db                	jne    80104e9a <memmove+0x59>
      *d++ = *s++;

  return dst;
80104ebf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ec2:	c9                   	leave  
80104ec3:	c3                   	ret    

80104ec4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ec4:	55                   	push   %ebp
80104ec5:	89 e5                	mov    %esp,%ebp
80104ec7:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80104eca:	8b 45 10             	mov    0x10(%ebp),%eax
80104ecd:	89 44 24 08          	mov    %eax,0x8(%esp)
80104ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80104edb:	89 04 24             	mov    %eax,(%esp)
80104ede:	e8 5e ff ff ff       	call   80104e41 <memmove>
}
80104ee3:	c9                   	leave  
80104ee4:	c3                   	ret    

80104ee5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ee5:	55                   	push   %ebp
80104ee6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ee8:	eb 0c                	jmp    80104ef6 <strncmp+0x11>
    n--, p++, q++;
80104eea:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104eee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ef2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104ef6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104efa:	74 1a                	je     80104f16 <strncmp+0x31>
80104efc:	8b 45 08             	mov    0x8(%ebp),%eax
80104eff:	0f b6 00             	movzbl (%eax),%eax
80104f02:	84 c0                	test   %al,%al
80104f04:	74 10                	je     80104f16 <strncmp+0x31>
80104f06:	8b 45 08             	mov    0x8(%ebp),%eax
80104f09:	0f b6 10             	movzbl (%eax),%edx
80104f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f0f:	0f b6 00             	movzbl (%eax),%eax
80104f12:	38 c2                	cmp    %al,%dl
80104f14:	74 d4                	je     80104eea <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80104f16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f1a:	75 07                	jne    80104f23 <strncmp+0x3e>
    return 0;
80104f1c:	b8 00 00 00 00       	mov    $0x0,%eax
80104f21:	eb 18                	jmp    80104f3b <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80104f23:	8b 45 08             	mov    0x8(%ebp),%eax
80104f26:	0f b6 00             	movzbl (%eax),%eax
80104f29:	0f b6 d0             	movzbl %al,%edx
80104f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f2f:	0f b6 00             	movzbl (%eax),%eax
80104f32:	0f b6 c0             	movzbl %al,%eax
80104f35:	89 d1                	mov    %edx,%ecx
80104f37:	29 c1                	sub    %eax,%ecx
80104f39:	89 c8                	mov    %ecx,%eax
}
80104f3b:	5d                   	pop    %ebp
80104f3c:	c3                   	ret    

80104f3d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f3d:	55                   	push   %ebp
80104f3e:	89 e5                	mov    %esp,%ebp
80104f40:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104f43:	8b 45 08             	mov    0x8(%ebp),%eax
80104f46:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f49:	90                   	nop
80104f4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f4e:	0f 9f c0             	setg   %al
80104f51:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f55:	84 c0                	test   %al,%al
80104f57:	74 30                	je     80104f89 <strncpy+0x4c>
80104f59:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f5c:	0f b6 10             	movzbl (%eax),%edx
80104f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f62:	88 10                	mov    %dl,(%eax)
80104f64:	8b 45 08             	mov    0x8(%ebp),%eax
80104f67:	0f b6 00             	movzbl (%eax),%eax
80104f6a:	84 c0                	test   %al,%al
80104f6c:	0f 95 c0             	setne  %al
80104f6f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f73:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104f77:	84 c0                	test   %al,%al
80104f79:	75 cf                	jne    80104f4a <strncpy+0xd>
    ;
  while(n-- > 0)
80104f7b:	eb 0c                	jmp    80104f89 <strncpy+0x4c>
    *s++ = 0;
80104f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f80:	c6 00 00             	movb   $0x0,(%eax)
80104f83:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f87:	eb 01                	jmp    80104f8a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80104f89:	90                   	nop
80104f8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f8e:	0f 9f c0             	setg   %al
80104f91:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f95:	84 c0                	test   %al,%al
80104f97:	75 e4                	jne    80104f7d <strncpy+0x40>
    *s++ = 0;
  return os;
80104f99:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f9c:	c9                   	leave  
80104f9d:	c3                   	ret    

80104f9e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f9e:	55                   	push   %ebp
80104f9f:	89 e5                	mov    %esp,%ebp
80104fa1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104faa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fae:	7f 05                	jg     80104fb5 <safestrcpy+0x17>
    return os;
80104fb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fb3:	eb 35                	jmp    80104fea <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104fb5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fbd:	7e 22                	jle    80104fe1 <safestrcpy+0x43>
80104fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc2:	0f b6 10             	movzbl (%eax),%edx
80104fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc8:	88 10                	mov    %dl,(%eax)
80104fca:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcd:	0f b6 00             	movzbl (%eax),%eax
80104fd0:	84 c0                	test   %al,%al
80104fd2:	0f 95 c0             	setne  %al
80104fd5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fd9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104fdd:	84 c0                	test   %al,%al
80104fdf:	75 d4                	jne    80104fb5 <safestrcpy+0x17>
    ;
  *s = 0;
80104fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe4:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fe7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fea:	c9                   	leave  
80104feb:	c3                   	ret    

80104fec <strlen>:

int
strlen(const char *s)
{
80104fec:	55                   	push   %ebp
80104fed:	89 e5                	mov    %esp,%ebp
80104fef:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104ff2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104ff9:	eb 04                	jmp    80104fff <strlen+0x13>
80104ffb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104fff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105002:	03 45 08             	add    0x8(%ebp),%eax
80105005:	0f b6 00             	movzbl (%eax),%eax
80105008:	84 c0                	test   %al,%al
8010500a:	75 ef                	jne    80104ffb <strlen+0xf>
    ;
  return n;
8010500c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010500f:	c9                   	leave  
80105010:	c3                   	ret    
80105011:	00 00                	add    %al,(%eax)
	...

80105014 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105014:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105018:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010501c:	55                   	push   %ebp
  pushl %ebx
8010501d:	53                   	push   %ebx
  pushl %esi
8010501e:	56                   	push   %esi
  pushl %edi
8010501f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105020:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105022:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105024:	5f                   	pop    %edi
  popl %esi
80105025:	5e                   	pop    %esi
  popl %ebx
80105026:	5b                   	pop    %ebx
  popl %ebp
80105027:	5d                   	pop    %ebp
  ret
80105028:	c3                   	ret    
80105029:	00 00                	add    %al,(%eax)
	...

8010502c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010502c:	55                   	push   %ebp
8010502d:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010502f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105035:	8b 00                	mov    (%eax),%eax
80105037:	3b 45 08             	cmp    0x8(%ebp),%eax
8010503a:	76 12                	jbe    8010504e <fetchint+0x22>
8010503c:	8b 45 08             	mov    0x8(%ebp),%eax
8010503f:	8d 50 04             	lea    0x4(%eax),%edx
80105042:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105048:	8b 00                	mov    (%eax),%eax
8010504a:	39 c2                	cmp    %eax,%edx
8010504c:	76 07                	jbe    80105055 <fetchint+0x29>
    return -1;
8010504e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105053:	eb 0f                	jmp    80105064 <fetchint+0x38>
  *ip = *(int*)(addr);
80105055:	8b 45 08             	mov    0x8(%ebp),%eax
80105058:	8b 10                	mov    (%eax),%edx
8010505a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010505d:	89 10                	mov    %edx,(%eax)
  return 0;
8010505f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105064:	5d                   	pop    %ebp
80105065:	c3                   	ret    

80105066 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105066:	55                   	push   %ebp
80105067:	89 e5                	mov    %esp,%ebp
80105069:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
8010506c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105072:	8b 00                	mov    (%eax),%eax
80105074:	3b 45 08             	cmp    0x8(%ebp),%eax
80105077:	77 07                	ja     80105080 <fetchstr+0x1a>
    return -1;
80105079:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010507e:	eb 48                	jmp    801050c8 <fetchstr+0x62>
  *pp = (char*)addr;
80105080:	8b 55 08             	mov    0x8(%ebp),%edx
80105083:	8b 45 0c             	mov    0xc(%ebp),%eax
80105086:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105088:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010508e:	8b 00                	mov    (%eax),%eax
80105090:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105093:	8b 45 0c             	mov    0xc(%ebp),%eax
80105096:	8b 00                	mov    (%eax),%eax
80105098:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010509b:	eb 1e                	jmp    801050bb <fetchstr+0x55>
    if(*s == 0)
8010509d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050a0:	0f b6 00             	movzbl (%eax),%eax
801050a3:	84 c0                	test   %al,%al
801050a5:	75 10                	jne    801050b7 <fetchstr+0x51>
      return s - *pp;
801050a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ad:	8b 00                	mov    (%eax),%eax
801050af:	89 d1                	mov    %edx,%ecx
801050b1:	29 c1                	sub    %eax,%ecx
801050b3:	89 c8                	mov    %ecx,%eax
801050b5:	eb 11                	jmp    801050c8 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801050b7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050c1:	72 da                	jb     8010509d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801050c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050c8:	c9                   	leave  
801050c9:	c3                   	ret    

801050ca <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050ca:	55                   	push   %ebp
801050cb:	89 e5                	mov    %esp,%ebp
801050cd:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801050d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d6:	8b 40 18             	mov    0x18(%eax),%eax
801050d9:	8b 50 44             	mov    0x44(%eax),%edx
801050dc:	8b 45 08             	mov    0x8(%ebp),%eax
801050df:	c1 e0 02             	shl    $0x2,%eax
801050e2:	01 d0                	add    %edx,%eax
801050e4:	8d 50 04             	lea    0x4(%eax),%edx
801050e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801050ee:	89 14 24             	mov    %edx,(%esp)
801050f1:	e8 36 ff ff ff       	call   8010502c <fetchint>
}
801050f6:	c9                   	leave  
801050f7:	c3                   	ret    

801050f8 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050f8:	55                   	push   %ebp
801050f9:	89 e5                	mov    %esp,%ebp
801050fb:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801050fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105101:	89 44 24 04          	mov    %eax,0x4(%esp)
80105105:	8b 45 08             	mov    0x8(%ebp),%eax
80105108:	89 04 24             	mov    %eax,(%esp)
8010510b:	e8 ba ff ff ff       	call   801050ca <argint>
80105110:	85 c0                	test   %eax,%eax
80105112:	79 07                	jns    8010511b <argptr+0x23>
    return -1;
80105114:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105119:	eb 3d                	jmp    80105158 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010511b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010511e:	89 c2                	mov    %eax,%edx
80105120:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105126:	8b 00                	mov    (%eax),%eax
80105128:	39 c2                	cmp    %eax,%edx
8010512a:	73 16                	jae    80105142 <argptr+0x4a>
8010512c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010512f:	89 c2                	mov    %eax,%edx
80105131:	8b 45 10             	mov    0x10(%ebp),%eax
80105134:	01 c2                	add    %eax,%edx
80105136:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513c:	8b 00                	mov    (%eax),%eax
8010513e:	39 c2                	cmp    %eax,%edx
80105140:	76 07                	jbe    80105149 <argptr+0x51>
    return -1;
80105142:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105147:	eb 0f                	jmp    80105158 <argptr+0x60>
  *pp = (char*)i;
80105149:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010514c:	89 c2                	mov    %eax,%edx
8010514e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105151:	89 10                	mov    %edx,(%eax)
  return 0;
80105153:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105158:	c9                   	leave  
80105159:	c3                   	ret    

8010515a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010515a:	55                   	push   %ebp
8010515b:	89 e5                	mov    %esp,%ebp
8010515d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105160:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105163:	89 44 24 04          	mov    %eax,0x4(%esp)
80105167:	8b 45 08             	mov    0x8(%ebp),%eax
8010516a:	89 04 24             	mov    %eax,(%esp)
8010516d:	e8 58 ff ff ff       	call   801050ca <argint>
80105172:	85 c0                	test   %eax,%eax
80105174:	79 07                	jns    8010517d <argstr+0x23>
    return -1;
80105176:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517b:	eb 12                	jmp    8010518f <argstr+0x35>
  return fetchstr(addr, pp);
8010517d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105180:	8b 55 0c             	mov    0xc(%ebp),%edx
80105183:	89 54 24 04          	mov    %edx,0x4(%esp)
80105187:	89 04 24             	mov    %eax,(%esp)
8010518a:	e8 d7 fe ff ff       	call   80105066 <fetchstr>
}
8010518f:	c9                   	leave  
80105190:	c3                   	ret    

80105191 <syscall>:
[SYS_doge]    sys_doge
};

void
syscall(void)
{
80105191:	55                   	push   %ebp
80105192:	89 e5                	mov    %esp,%ebp
80105194:	53                   	push   %ebx
80105195:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105198:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010519e:	8b 40 18             	mov    0x18(%eax),%eax
801051a1:	8b 40 1c             	mov    0x1c(%eax),%eax
801051a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801051a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051ab:	7e 30                	jle    801051dd <syscall+0x4c>
801051ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b0:	83 f8 1b             	cmp    $0x1b,%eax
801051b3:	77 28                	ja     801051dd <syscall+0x4c>
801051b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b8:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801051bf:	85 c0                	test   %eax,%eax
801051c1:	74 1a                	je     801051dd <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801051c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c9:	8b 58 18             	mov    0x18(%eax),%ebx
801051cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cf:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801051d6:	ff d0                	call   *%eax
801051d8:	89 43 1c             	mov    %eax,0x1c(%ebx)
801051db:	eb 3d                	jmp    8010521a <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801051dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051e3:	8d 48 6c             	lea    0x6c(%eax),%ecx
801051e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801051ec:	8b 40 10             	mov    0x10(%eax),%eax
801051ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
801051f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801051fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801051fe:	c7 04 24 e7 85 10 80 	movl   $0x801085e7,(%esp)
80105205:	e8 97 b1 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010520a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105210:	8b 40 18             	mov    0x18(%eax),%eax
80105213:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010521a:	83 c4 24             	add    $0x24,%esp
8010521d:	5b                   	pop    %ebx
8010521e:	5d                   	pop    %ebp
8010521f:	c3                   	ret    

80105220 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105220:	55                   	push   %ebp
80105221:	89 e5                	mov    %esp,%ebp
80105223:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105226:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105229:	89 44 24 04          	mov    %eax,0x4(%esp)
8010522d:	8b 45 08             	mov    0x8(%ebp),%eax
80105230:	89 04 24             	mov    %eax,(%esp)
80105233:	e8 92 fe ff ff       	call   801050ca <argint>
80105238:	85 c0                	test   %eax,%eax
8010523a:	79 07                	jns    80105243 <argfd+0x23>
    return -1;
8010523c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105241:	eb 50                	jmp    80105293 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105246:	85 c0                	test   %eax,%eax
80105248:	78 21                	js     8010526b <argfd+0x4b>
8010524a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524d:	83 f8 0f             	cmp    $0xf,%eax
80105250:	7f 19                	jg     8010526b <argfd+0x4b>
80105252:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105258:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010525b:	83 c2 08             	add    $0x8,%edx
8010525e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105262:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105265:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105269:	75 07                	jne    80105272 <argfd+0x52>
    return -1;
8010526b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105270:	eb 21                	jmp    80105293 <argfd+0x73>
  if(pfd)
80105272:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105276:	74 08                	je     80105280 <argfd+0x60>
    *pfd = fd;
80105278:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010527b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010527e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105280:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105284:	74 08                	je     8010528e <argfd+0x6e>
    *pf = f;
80105286:	8b 45 10             	mov    0x10(%ebp),%eax
80105289:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010528c:	89 10                	mov    %edx,(%eax)
  return 0;
8010528e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105293:	c9                   	leave  
80105294:	c3                   	ret    

80105295 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105295:	55                   	push   %ebp
80105296:	89 e5                	mov    %esp,%ebp
80105298:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010529b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801052a2:	eb 30                	jmp    801052d4 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801052a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052ad:	83 c2 08             	add    $0x8,%edx
801052b0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052b4:	85 c0                	test   %eax,%eax
801052b6:	75 18                	jne    801052d0 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801052b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052be:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052c1:	8d 4a 08             	lea    0x8(%edx),%ecx
801052c4:	8b 55 08             	mov    0x8(%ebp),%edx
801052c7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801052cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052ce:	eb 0f                	jmp    801052df <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801052d0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052d4:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801052d8:	7e ca                	jle    801052a4 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801052da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052df:	c9                   	leave  
801052e0:	c3                   	ret    

801052e1 <sys_dup>:

int
sys_dup(void)
{
801052e1:	55                   	push   %ebp
801052e2:	89 e5                	mov    %esp,%ebp
801052e4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801052e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801052ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801052f5:	00 
801052f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801052fd:	e8 1e ff ff ff       	call   80105220 <argfd>
80105302:	85 c0                	test   %eax,%eax
80105304:	79 07                	jns    8010530d <sys_dup+0x2c>
    return -1;
80105306:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010530b:	eb 29                	jmp    80105336 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010530d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105310:	89 04 24             	mov    %eax,(%esp)
80105313:	e8 7d ff ff ff       	call   80105295 <fdalloc>
80105318:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010531b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010531f:	79 07                	jns    80105328 <sys_dup+0x47>
    return -1;
80105321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105326:	eb 0e                	jmp    80105336 <sys_dup+0x55>
  filedup(f);
80105328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010532b:	89 04 24             	mov    %eax,(%esp)
8010532e:	e8 41 bc ff ff       	call   80100f74 <filedup>
  return fd;
80105333:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105336:	c9                   	leave  
80105337:	c3                   	ret    

80105338 <sys_read>:

int
sys_read(void)
{
80105338:	55                   	push   %ebp
80105339:	89 e5                	mov    %esp,%ebp
8010533b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010533e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105341:	89 44 24 08          	mov    %eax,0x8(%esp)
80105345:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010534c:	00 
8010534d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105354:	e8 c7 fe ff ff       	call   80105220 <argfd>
80105359:	85 c0                	test   %eax,%eax
8010535b:	78 35                	js     80105392 <sys_read+0x5a>
8010535d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105360:	89 44 24 04          	mov    %eax,0x4(%esp)
80105364:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010536b:	e8 5a fd ff ff       	call   801050ca <argint>
80105370:	85 c0                	test   %eax,%eax
80105372:	78 1e                	js     80105392 <sys_read+0x5a>
80105374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105377:	89 44 24 08          	mov    %eax,0x8(%esp)
8010537b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010537e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105382:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105389:	e8 6a fd ff ff       	call   801050f8 <argptr>
8010538e:	85 c0                	test   %eax,%eax
80105390:	79 07                	jns    80105399 <sys_read+0x61>
    return -1;
80105392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105397:	eb 19                	jmp    801053b2 <sys_read+0x7a>
  return fileread(f, p, n);
80105399:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010539c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010539f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801053a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801053aa:	89 04 24             	mov    %eax,(%esp)
801053ad:	e8 2f bd ff ff       	call   801010e1 <fileread>
}
801053b2:	c9                   	leave  
801053b3:	c3                   	ret    

801053b4 <sys_write>:

int
sys_write(void)
{
801053b4:	55                   	push   %ebp
801053b5:	89 e5                	mov    %esp,%ebp
801053b7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053bd:	89 44 24 08          	mov    %eax,0x8(%esp)
801053c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801053c8:	00 
801053c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801053d0:	e8 4b fe ff ff       	call   80105220 <argfd>
801053d5:	85 c0                	test   %eax,%eax
801053d7:	78 35                	js     8010540e <sys_write+0x5a>
801053d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801053e0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801053e7:	e8 de fc ff ff       	call   801050ca <argint>
801053ec:	85 c0                	test   %eax,%eax
801053ee:	78 1e                	js     8010540e <sys_write+0x5a>
801053f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f3:	89 44 24 08          	mov    %eax,0x8(%esp)
801053f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801053fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105405:	e8 ee fc ff ff       	call   801050f8 <argptr>
8010540a:	85 c0                	test   %eax,%eax
8010540c:	79 07                	jns    80105415 <sys_write+0x61>
    return -1;
8010540e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105413:	eb 19                	jmp    8010542e <sys_write+0x7a>
  return filewrite(f, p, n);
80105415:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105418:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010541b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105422:	89 54 24 04          	mov    %edx,0x4(%esp)
80105426:	89 04 24             	mov    %eax,(%esp)
80105429:	e8 6f bd ff ff       	call   8010119d <filewrite>
}
8010542e:	c9                   	leave  
8010542f:	c3                   	ret    

80105430 <sys_close>:

int
sys_close(void)
{
80105430:	55                   	push   %ebp
80105431:	89 e5                	mov    %esp,%ebp
80105433:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105436:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105439:	89 44 24 08          	mov    %eax,0x8(%esp)
8010543d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105440:	89 44 24 04          	mov    %eax,0x4(%esp)
80105444:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010544b:	e8 d0 fd ff ff       	call   80105220 <argfd>
80105450:	85 c0                	test   %eax,%eax
80105452:	79 07                	jns    8010545b <sys_close+0x2b>
    return -1;
80105454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105459:	eb 24                	jmp    8010547f <sys_close+0x4f>
  proc->ofile[fd] = 0;
8010545b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105464:	83 c2 08             	add    $0x8,%edx
80105467:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010546e:	00 
  fileclose(f);
8010546f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105472:	89 04 24             	mov    %eax,(%esp)
80105475:	e8 42 bb ff ff       	call   80100fbc <fileclose>
  return 0;
8010547a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010547f:	c9                   	leave  
80105480:	c3                   	ret    

80105481 <sys_fstat>:

int
sys_fstat(void)
{
80105481:	55                   	push   %ebp
80105482:	89 e5                	mov    %esp,%ebp
80105484:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105487:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010548a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010548e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105495:	00 
80105496:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010549d:	e8 7e fd ff ff       	call   80105220 <argfd>
801054a2:	85 c0                	test   %eax,%eax
801054a4:	78 1f                	js     801054c5 <sys_fstat+0x44>
801054a6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801054ad:	00 
801054ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801054b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801054bc:	e8 37 fc ff ff       	call   801050f8 <argptr>
801054c1:	85 c0                	test   %eax,%eax
801054c3:	79 07                	jns    801054cc <sys_fstat+0x4b>
    return -1;
801054c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ca:	eb 12                	jmp    801054de <sys_fstat+0x5d>
  return filestat(f, st);
801054cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801054d6:	89 04 24             	mov    %eax,(%esp)
801054d9:	e8 b4 bb ff ff       	call   80101092 <filestat>
}
801054de:	c9                   	leave  
801054df:	c3                   	ret    

801054e0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801054e0:	55                   	push   %ebp
801054e1:	89 e5                	mov    %esp,%ebp
801054e3:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801054e6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801054e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801054ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801054f4:	e8 61 fc ff ff       	call   8010515a <argstr>
801054f9:	85 c0                	test   %eax,%eax
801054fb:	78 17                	js     80105514 <sys_link+0x34>
801054fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105500:	89 44 24 04          	mov    %eax,0x4(%esp)
80105504:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010550b:	e8 4a fc ff ff       	call   8010515a <argstr>
80105510:	85 c0                	test   %eax,%eax
80105512:	79 0a                	jns    8010551e <sys_link+0x3e>
    return -1;
80105514:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105519:	e9 3c 01 00 00       	jmp    8010565a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
8010551e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105521:	89 04 24             	mov    %eax,(%esp)
80105524:	e8 d9 ce ff ff       	call   80102402 <namei>
80105529:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010552c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105530:	75 0a                	jne    8010553c <sys_link+0x5c>
    return -1;
80105532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105537:	e9 1e 01 00 00       	jmp    8010565a <sys_link+0x17a>

  begin_trans();
8010553c:	e8 d4 dc ff ff       	call   80103215 <begin_trans>

  ilock(ip);
80105541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105544:	89 04 24             	mov    %eax,(%esp)
80105547:	e8 14 c3 ff ff       	call   80101860 <ilock>
  if(ip->type == T_DIR){
8010554c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105553:	66 83 f8 01          	cmp    $0x1,%ax
80105557:	75 1a                	jne    80105573 <sys_link+0x93>
    iunlockput(ip);
80105559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010555c:	89 04 24             	mov    %eax,(%esp)
8010555f:	e8 80 c5 ff ff       	call   80101ae4 <iunlockput>
    commit_trans();
80105564:	e8 f5 dc ff ff       	call   8010325e <commit_trans>
    return -1;
80105569:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556e:	e9 e7 00 00 00       	jmp    8010565a <sys_link+0x17a>
  }

  ip->nlink++;
80105573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105576:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010557a:	8d 50 01             	lea    0x1(%eax),%edx
8010557d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105580:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105587:	89 04 24             	mov    %eax,(%esp)
8010558a:	e8 15 c1 ff ff       	call   801016a4 <iupdate>
  iunlock(ip);
8010558f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105592:	89 04 24             	mov    %eax,(%esp)
80105595:	e8 14 c4 ff ff       	call   801019ae <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010559a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010559d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801055a4:	89 04 24             	mov    %eax,(%esp)
801055a7:	e8 78 ce ff ff       	call   80102424 <nameiparent>
801055ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055b3:	74 68                	je     8010561d <sys_link+0x13d>
    goto bad;
  ilock(dp);
801055b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b8:	89 04 24             	mov    %eax,(%esp)
801055bb:	e8 a0 c2 ff ff       	call   80101860 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801055c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c3:	8b 10                	mov    (%eax),%edx
801055c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c8:	8b 00                	mov    (%eax),%eax
801055ca:	39 c2                	cmp    %eax,%edx
801055cc:	75 20                	jne    801055ee <sys_link+0x10e>
801055ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d1:	8b 40 04             	mov    0x4(%eax),%eax
801055d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801055d8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801055db:	89 44 24 04          	mov    %eax,0x4(%esp)
801055df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e2:	89 04 24             	mov    %eax,(%esp)
801055e5:	e8 57 cb ff ff       	call   80102141 <dirlink>
801055ea:	85 c0                	test   %eax,%eax
801055ec:	79 0d                	jns    801055fb <sys_link+0x11b>
    iunlockput(dp);
801055ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055f1:	89 04 24             	mov    %eax,(%esp)
801055f4:	e8 eb c4 ff ff       	call   80101ae4 <iunlockput>
    goto bad;
801055f9:	eb 23                	jmp    8010561e <sys_link+0x13e>
  }
  iunlockput(dp);
801055fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055fe:	89 04 24             	mov    %eax,(%esp)
80105601:	e8 de c4 ff ff       	call   80101ae4 <iunlockput>
  iput(ip);
80105606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105609:	89 04 24             	mov    %eax,(%esp)
8010560c:	e8 02 c4 ff ff       	call   80101a13 <iput>

  commit_trans();
80105611:	e8 48 dc ff ff       	call   8010325e <commit_trans>

  return 0;
80105616:	b8 00 00 00 00       	mov    $0x0,%eax
8010561b:	eb 3d                	jmp    8010565a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010561d:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
8010561e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105621:	89 04 24             	mov    %eax,(%esp)
80105624:	e8 37 c2 ff ff       	call   80101860 <ilock>
  ip->nlink--;
80105629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105630:	8d 50 ff             	lea    -0x1(%eax),%edx
80105633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105636:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010563a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563d:	89 04 24             	mov    %eax,(%esp)
80105640:	e8 5f c0 ff ff       	call   801016a4 <iupdate>
  iunlockput(ip);
80105645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105648:	89 04 24             	mov    %eax,(%esp)
8010564b:	e8 94 c4 ff ff       	call   80101ae4 <iunlockput>
  commit_trans();
80105650:	e8 09 dc ff ff       	call   8010325e <commit_trans>
  return -1;
80105655:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010565a:	c9                   	leave  
8010565b:	c3                   	ret    

8010565c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010565c:	55                   	push   %ebp
8010565d:	89 e5                	mov    %esp,%ebp
8010565f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105662:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105669:	eb 4b                	jmp    801056b6 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010566b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105675:	00 
80105676:	89 44 24 08          	mov    %eax,0x8(%esp)
8010567a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010567d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105681:	8b 45 08             	mov    0x8(%ebp),%eax
80105684:	89 04 24             	mov    %eax,(%esp)
80105687:	e8 ca c6 ff ff       	call   80101d56 <readi>
8010568c:	83 f8 10             	cmp    $0x10,%eax
8010568f:	74 0c                	je     8010569d <isdirempty+0x41>
      panic("isdirempty: readi");
80105691:	c7 04 24 03 86 10 80 	movl   $0x80108603,(%esp)
80105698:	e8 a0 ae ff ff       	call   8010053d <panic>
    if(de.inum != 0)
8010569d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056a1:	66 85 c0             	test   %ax,%ax
801056a4:	74 07                	je     801056ad <isdirempty+0x51>
      return 0;
801056a6:	b8 00 00 00 00       	mov    $0x0,%eax
801056ab:	eb 1b                	jmp    801056c8 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b0:	83 c0 10             	add    $0x10,%eax
801056b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056b9:	8b 45 08             	mov    0x8(%ebp),%eax
801056bc:	8b 40 18             	mov    0x18(%eax),%eax
801056bf:	39 c2                	cmp    %eax,%edx
801056c1:	72 a8                	jb     8010566b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801056c3:	b8 01 00 00 00       	mov    $0x1,%eax
}
801056c8:	c9                   	leave  
801056c9:	c3                   	ret    

801056ca <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801056ca:	55                   	push   %ebp
801056cb:	89 e5                	mov    %esp,%ebp
801056cd:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801056d0:	8d 45 cc             	lea    -0x34(%ebp),%eax
801056d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801056d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056de:	e8 77 fa ff ff       	call   8010515a <argstr>
801056e3:	85 c0                	test   %eax,%eax
801056e5:	79 0a                	jns    801056f1 <sys_unlink+0x27>
    return -1;
801056e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ec:	e9 aa 01 00 00       	jmp    8010589b <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
801056f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056f4:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801056fb:	89 04 24             	mov    %eax,(%esp)
801056fe:	e8 21 cd ff ff       	call   80102424 <nameiparent>
80105703:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105706:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010570a:	75 0a                	jne    80105716 <sys_unlink+0x4c>
    return -1;
8010570c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105711:	e9 85 01 00 00       	jmp    8010589b <sys_unlink+0x1d1>

  begin_trans();
80105716:	e8 fa da ff ff       	call   80103215 <begin_trans>

  ilock(dp);
8010571b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010571e:	89 04 24             	mov    %eax,(%esp)
80105721:	e8 3a c1 ff ff       	call   80101860 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105726:	c7 44 24 04 15 86 10 	movl   $0x80108615,0x4(%esp)
8010572d:	80 
8010572e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105731:	89 04 24             	mov    %eax,(%esp)
80105734:	e8 1e c9 ff ff       	call   80102057 <namecmp>
80105739:	85 c0                	test   %eax,%eax
8010573b:	0f 84 45 01 00 00    	je     80105886 <sys_unlink+0x1bc>
80105741:	c7 44 24 04 17 86 10 	movl   $0x80108617,0x4(%esp)
80105748:	80 
80105749:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010574c:	89 04 24             	mov    %eax,(%esp)
8010574f:	e8 03 c9 ff ff       	call   80102057 <namecmp>
80105754:	85 c0                	test   %eax,%eax
80105756:	0f 84 2a 01 00 00    	je     80105886 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010575c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010575f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105763:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105766:	89 44 24 04          	mov    %eax,0x4(%esp)
8010576a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576d:	89 04 24             	mov    %eax,(%esp)
80105770:	e8 04 c9 ff ff       	call   80102079 <dirlookup>
80105775:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105778:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010577c:	0f 84 03 01 00 00    	je     80105885 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105785:	89 04 24             	mov    %eax,(%esp)
80105788:	e8 d3 c0 ff ff       	call   80101860 <ilock>

  if(ip->nlink < 1)
8010578d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105790:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105794:	66 85 c0             	test   %ax,%ax
80105797:	7f 0c                	jg     801057a5 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105799:	c7 04 24 1a 86 10 80 	movl   $0x8010861a,(%esp)
801057a0:	e8 98 ad ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801057a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801057ac:	66 83 f8 01          	cmp    $0x1,%ax
801057b0:	75 1f                	jne    801057d1 <sys_unlink+0x107>
801057b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b5:	89 04 24             	mov    %eax,(%esp)
801057b8:	e8 9f fe ff ff       	call   8010565c <isdirempty>
801057bd:	85 c0                	test   %eax,%eax
801057bf:	75 10                	jne    801057d1 <sys_unlink+0x107>
    iunlockput(ip);
801057c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c4:	89 04 24             	mov    %eax,(%esp)
801057c7:	e8 18 c3 ff ff       	call   80101ae4 <iunlockput>
    goto bad;
801057cc:	e9 b5 00 00 00       	jmp    80105886 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
801057d1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801057d8:	00 
801057d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057e0:	00 
801057e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057e4:	89 04 24             	mov    %eax,(%esp)
801057e7:	e8 82 f5 ff ff       	call   80104d6e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057ec:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057ef:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801057f6:	00 
801057f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801057fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105805:	89 04 24             	mov    %eax,(%esp)
80105808:	e8 b4 c6 ff ff       	call   80101ec1 <writei>
8010580d:	83 f8 10             	cmp    $0x10,%eax
80105810:	74 0c                	je     8010581e <sys_unlink+0x154>
    panic("unlink: writei");
80105812:	c7 04 24 2c 86 10 80 	movl   $0x8010862c,(%esp)
80105819:	e8 1f ad ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
8010581e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105821:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105825:	66 83 f8 01          	cmp    $0x1,%ax
80105829:	75 1c                	jne    80105847 <sys_unlink+0x17d>
    dp->nlink--;
8010582b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105832:	8d 50 ff             	lea    -0x1(%eax),%edx
80105835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105838:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010583c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583f:	89 04 24             	mov    %eax,(%esp)
80105842:	e8 5d be ff ff       	call   801016a4 <iupdate>
  }
  iunlockput(dp);
80105847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584a:	89 04 24             	mov    %eax,(%esp)
8010584d:	e8 92 c2 ff ff       	call   80101ae4 <iunlockput>

  ip->nlink--;
80105852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105855:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105859:	8d 50 ff             	lea    -0x1(%eax),%edx
8010585c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105866:	89 04 24             	mov    %eax,(%esp)
80105869:	e8 36 be ff ff       	call   801016a4 <iupdate>
  iunlockput(ip);
8010586e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105871:	89 04 24             	mov    %eax,(%esp)
80105874:	e8 6b c2 ff ff       	call   80101ae4 <iunlockput>

  commit_trans();
80105879:	e8 e0 d9 ff ff       	call   8010325e <commit_trans>

  return 0;
8010587e:	b8 00 00 00 00       	mov    $0x0,%eax
80105883:	eb 16                	jmp    8010589b <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105885:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105889:	89 04 24             	mov    %eax,(%esp)
8010588c:	e8 53 c2 ff ff       	call   80101ae4 <iunlockput>
  commit_trans();
80105891:	e8 c8 d9 ff ff       	call   8010325e <commit_trans>
  return -1;
80105896:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010589b:	c9                   	leave  
8010589c:	c3                   	ret    

8010589d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010589d:	55                   	push   %ebp
8010589e:	89 e5                	mov    %esp,%ebp
801058a0:	83 ec 48             	sub    $0x48,%esp
801058a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801058a6:	8b 55 10             	mov    0x10(%ebp),%edx
801058a9:	8b 45 14             	mov    0x14(%ebp),%eax
801058ac:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801058b0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801058b4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801058b8:	8d 45 de             	lea    -0x22(%ebp),%eax
801058bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801058bf:	8b 45 08             	mov    0x8(%ebp),%eax
801058c2:	89 04 24             	mov    %eax,(%esp)
801058c5:	e8 5a cb ff ff       	call   80102424 <nameiparent>
801058ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058d1:	75 0a                	jne    801058dd <create+0x40>
    return 0;
801058d3:	b8 00 00 00 00       	mov    $0x0,%eax
801058d8:	e9 7e 01 00 00       	jmp    80105a5b <create+0x1be>
  ilock(dp);
801058dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e0:	89 04 24             	mov    %eax,(%esp)
801058e3:	e8 78 bf ff ff       	call   80101860 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801058e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058eb:	89 44 24 08          	mov    %eax,0x8(%esp)
801058ef:	8d 45 de             	lea    -0x22(%ebp),%eax
801058f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f9:	89 04 24             	mov    %eax,(%esp)
801058fc:	e8 78 c7 ff ff       	call   80102079 <dirlookup>
80105901:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105904:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105908:	74 47                	je     80105951 <create+0xb4>
    iunlockput(dp);
8010590a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590d:	89 04 24             	mov    %eax,(%esp)
80105910:	e8 cf c1 ff ff       	call   80101ae4 <iunlockput>
    ilock(ip);
80105915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105918:	89 04 24             	mov    %eax,(%esp)
8010591b:	e8 40 bf ff ff       	call   80101860 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105920:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105925:	75 15                	jne    8010593c <create+0x9f>
80105927:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010592e:	66 83 f8 02          	cmp    $0x2,%ax
80105932:	75 08                	jne    8010593c <create+0x9f>
      return ip;
80105934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105937:	e9 1f 01 00 00       	jmp    80105a5b <create+0x1be>
    iunlockput(ip);
8010593c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593f:	89 04 24             	mov    %eax,(%esp)
80105942:	e8 9d c1 ff ff       	call   80101ae4 <iunlockput>
    return 0;
80105947:	b8 00 00 00 00       	mov    $0x0,%eax
8010594c:	e9 0a 01 00 00       	jmp    80105a5b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105951:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105958:	8b 00                	mov    (%eax),%eax
8010595a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010595e:	89 04 24             	mov    %eax,(%esp)
80105961:	e8 61 bc ff ff       	call   801015c7 <ialloc>
80105966:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105969:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010596d:	75 0c                	jne    8010597b <create+0xde>
    panic("create: ialloc");
8010596f:	c7 04 24 3b 86 10 80 	movl   $0x8010863b,(%esp)
80105976:	e8 c2 ab ff ff       	call   8010053d <panic>

  ilock(ip);
8010597b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597e:	89 04 24             	mov    %eax,(%esp)
80105981:	e8 da be ff ff       	call   80101860 <ilock>
  ip->major = major;
80105986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105989:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010598d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105994:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105998:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010599c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801059a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a8:	89 04 24             	mov    %eax,(%esp)
801059ab:	e8 f4 bc ff ff       	call   801016a4 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801059b0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059b5:	75 6a                	jne    80105a21 <create+0x184>
    dp->nlink++;  // for ".."
801059b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ba:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059be:	8d 50 01             	lea    0x1(%eax),%edx
801059c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801059c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cb:	89 04 24             	mov    %eax,(%esp)
801059ce:	e8 d1 bc ff ff       	call   801016a4 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d6:	8b 40 04             	mov    0x4(%eax),%eax
801059d9:	89 44 24 08          	mov    %eax,0x8(%esp)
801059dd:	c7 44 24 04 15 86 10 	movl   $0x80108615,0x4(%esp)
801059e4:	80 
801059e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e8:	89 04 24             	mov    %eax,(%esp)
801059eb:	e8 51 c7 ff ff       	call   80102141 <dirlink>
801059f0:	85 c0                	test   %eax,%eax
801059f2:	78 21                	js     80105a15 <create+0x178>
801059f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f7:	8b 40 04             	mov    0x4(%eax),%eax
801059fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801059fe:	c7 44 24 04 17 86 10 	movl   $0x80108617,0x4(%esp)
80105a05:	80 
80105a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a09:	89 04 24             	mov    %eax,(%esp)
80105a0c:	e8 30 c7 ff ff       	call   80102141 <dirlink>
80105a11:	85 c0                	test   %eax,%eax
80105a13:	79 0c                	jns    80105a21 <create+0x184>
      panic("create dots");
80105a15:	c7 04 24 4a 86 10 80 	movl   $0x8010864a,(%esp)
80105a1c:	e8 1c ab ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a24:	8b 40 04             	mov    0x4(%eax),%eax
80105a27:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a2b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a35:	89 04 24             	mov    %eax,(%esp)
80105a38:	e8 04 c7 ff ff       	call   80102141 <dirlink>
80105a3d:	85 c0                	test   %eax,%eax
80105a3f:	79 0c                	jns    80105a4d <create+0x1b0>
    panic("create: dirlink");
80105a41:	c7 04 24 56 86 10 80 	movl   $0x80108656,(%esp)
80105a48:	e8 f0 aa ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a50:	89 04 24             	mov    %eax,(%esp)
80105a53:	e8 8c c0 ff ff       	call   80101ae4 <iunlockput>

  return ip;
80105a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a5b:	c9                   	leave  
80105a5c:	c3                   	ret    

80105a5d <sys_open>:

int
sys_open(void)
{
80105a5d:	55                   	push   %ebp
80105a5e:	89 e5                	mov    %esp,%ebp
80105a60:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a63:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a66:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a71:	e8 e4 f6 ff ff       	call   8010515a <argstr>
80105a76:	85 c0                	test   %eax,%eax
80105a78:	78 17                	js     80105a91 <sys_open+0x34>
80105a7a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a88:	e8 3d f6 ff ff       	call   801050ca <argint>
80105a8d:	85 c0                	test   %eax,%eax
80105a8f:	79 0a                	jns    80105a9b <sys_open+0x3e>
    return -1;
80105a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a96:	e9 46 01 00 00       	jmp    80105be1 <sys_open+0x184>
  if(omode & O_CREATE){
80105a9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a9e:	25 00 02 00 00       	and    $0x200,%eax
80105aa3:	85 c0                	test   %eax,%eax
80105aa5:	74 40                	je     80105ae7 <sys_open+0x8a>
    begin_trans();
80105aa7:	e8 69 d7 ff ff       	call   80103215 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aaf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105ab6:	00 
80105ab7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105abe:	00 
80105abf:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105ac6:	00 
80105ac7:	89 04 24             	mov    %eax,(%esp)
80105aca:	e8 ce fd ff ff       	call   8010589d <create>
80105acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105ad2:	e8 87 d7 ff ff       	call   8010325e <commit_trans>
    if(ip == 0)
80105ad7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105adb:	75 5c                	jne    80105b39 <sys_open+0xdc>
      return -1;
80105add:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae2:	e9 fa 00 00 00       	jmp    80105be1 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
80105ae7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105aea:	89 04 24             	mov    %eax,(%esp)
80105aed:	e8 10 c9 ff ff       	call   80102402 <namei>
80105af2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af9:	75 0a                	jne    80105b05 <sys_open+0xa8>
      return -1;
80105afb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b00:	e9 dc 00 00 00       	jmp    80105be1 <sys_open+0x184>
    ilock(ip);
80105b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b08:	89 04 24             	mov    %eax,(%esp)
80105b0b:	e8 50 bd ff ff       	call   80101860 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b13:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b17:	66 83 f8 01          	cmp    $0x1,%ax
80105b1b:	75 1c                	jne    80105b39 <sys_open+0xdc>
80105b1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b20:	85 c0                	test   %eax,%eax
80105b22:	74 15                	je     80105b39 <sys_open+0xdc>
      iunlockput(ip);
80105b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b27:	89 04 24             	mov    %eax,(%esp)
80105b2a:	e8 b5 bf ff ff       	call   80101ae4 <iunlockput>
      return -1;
80105b2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b34:	e9 a8 00 00 00       	jmp    80105be1 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b39:	e8 d6 b3 ff ff       	call   80100f14 <filealloc>
80105b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b45:	74 14                	je     80105b5b <sys_open+0xfe>
80105b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4a:	89 04 24             	mov    %eax,(%esp)
80105b4d:	e8 43 f7 ff ff       	call   80105295 <fdalloc>
80105b52:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b55:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b59:	79 23                	jns    80105b7e <sys_open+0x121>
    if(f)
80105b5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b5f:	74 0b                	je     80105b6c <sys_open+0x10f>
      fileclose(f);
80105b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b64:	89 04 24             	mov    %eax,(%esp)
80105b67:	e8 50 b4 ff ff       	call   80100fbc <fileclose>
    iunlockput(ip);
80105b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6f:	89 04 24             	mov    %eax,(%esp)
80105b72:	e8 6d bf ff ff       	call   80101ae4 <iunlockput>
    return -1;
80105b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7c:	eb 63                	jmp    80105be1 <sys_open+0x184>
  }
  iunlock(ip);
80105b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b81:	89 04 24             	mov    %eax,(%esp)
80105b84:	e8 25 be ff ff       	call   801019ae <iunlock>

  f->type = FD_INODE;
80105b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b98:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ba5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ba8:	83 e0 01             	and    $0x1,%eax
80105bab:	85 c0                	test   %eax,%eax
80105bad:	0f 94 c2             	sete   %dl
80105bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105bb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bb9:	83 e0 01             	and    $0x1,%eax
80105bbc:	84 c0                	test   %al,%al
80105bbe:	75 0a                	jne    80105bca <sys_open+0x16d>
80105bc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bc3:	83 e0 02             	and    $0x2,%eax
80105bc6:	85 c0                	test   %eax,%eax
80105bc8:	74 07                	je     80105bd1 <sys_open+0x174>
80105bca:	b8 01 00 00 00       	mov    $0x1,%eax
80105bcf:	eb 05                	jmp    80105bd6 <sys_open+0x179>
80105bd1:	b8 00 00 00 00       	mov    $0x0,%eax
80105bd6:	89 c2                	mov    %eax,%edx
80105bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105bde:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105be1:	c9                   	leave  
80105be2:	c3                   	ret    

80105be3 <sys_mkdir>:

int
sys_mkdir(void)
{
80105be3:	55                   	push   %ebp
80105be4:	89 e5                	mov    %esp,%ebp
80105be6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105be9:	e8 27 d6 ff ff       	call   80103215 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bfc:	e8 59 f5 ff ff       	call   8010515a <argstr>
80105c01:	85 c0                	test   %eax,%eax
80105c03:	78 2c                	js     80105c31 <sys_mkdir+0x4e>
80105c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105c0f:	00 
80105c10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105c17:	00 
80105c18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105c1f:	00 
80105c20:	89 04 24             	mov    %eax,(%esp)
80105c23:	e8 75 fc ff ff       	call   8010589d <create>
80105c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c2b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c2f:	75 0c                	jne    80105c3d <sys_mkdir+0x5a>
    commit_trans();
80105c31:	e8 28 d6 ff ff       	call   8010325e <commit_trans>
    return -1;
80105c36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3b:	eb 15                	jmp    80105c52 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c40:	89 04 24             	mov    %eax,(%esp)
80105c43:	e8 9c be ff ff       	call   80101ae4 <iunlockput>
  commit_trans();
80105c48:	e8 11 d6 ff ff       	call   8010325e <commit_trans>
  return 0;
80105c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c52:	c9                   	leave  
80105c53:	c3                   	ret    

80105c54 <sys_mknod>:

int
sys_mknod(void)
{
80105c54:	55                   	push   %ebp
80105c55:	89 e5                	mov    %esp,%ebp
80105c57:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105c5a:	e8 b6 d5 ff ff       	call   80103215 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105c5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c62:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c6d:	e8 e8 f4 ff ff       	call   8010515a <argstr>
80105c72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c79:	78 5e                	js     80105cd9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105c7b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c89:	e8 3c f4 ff ff       	call   801050ca <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105c8e:	85 c0                	test   %eax,%eax
80105c90:	78 47                	js     80105cd9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105c92:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c95:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c99:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105ca0:	e8 25 f4 ff ff       	call   801050ca <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105ca5:	85 c0                	test   %eax,%eax
80105ca7:	78 30                	js     80105cd9 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ca9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cac:	0f bf c8             	movswl %ax,%ecx
80105caf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cb2:	0f bf d0             	movswl %ax,%edx
80105cb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105cb8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105cbc:	89 54 24 08          	mov    %edx,0x8(%esp)
80105cc0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105cc7:	00 
80105cc8:	89 04 24             	mov    %eax,(%esp)
80105ccb:	e8 cd fb ff ff       	call   8010589d <create>
80105cd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cd3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cd7:	75 0c                	jne    80105ce5 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105cd9:	e8 80 d5 ff ff       	call   8010325e <commit_trans>
    return -1;
80105cde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce3:	eb 15                	jmp    80105cfa <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce8:	89 04 24             	mov    %eax,(%esp)
80105ceb:	e8 f4 bd ff ff       	call   80101ae4 <iunlockput>
  commit_trans();
80105cf0:	e8 69 d5 ff ff       	call   8010325e <commit_trans>
  return 0;
80105cf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cfa:	c9                   	leave  
80105cfb:	c3                   	ret    

80105cfc <sys_chdir>:

int
sys_chdir(void)
{
80105cfc:	55                   	push   %ebp
80105cfd:	89 e5                	mov    %esp,%ebp
80105cff:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105d02:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d05:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d10:	e8 45 f4 ff ff       	call   8010515a <argstr>
80105d15:	85 c0                	test   %eax,%eax
80105d17:	78 14                	js     80105d2d <sys_chdir+0x31>
80105d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1c:	89 04 24             	mov    %eax,(%esp)
80105d1f:	e8 de c6 ff ff       	call   80102402 <namei>
80105d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d2b:	75 07                	jne    80105d34 <sys_chdir+0x38>
    return -1;
80105d2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d32:	eb 57                	jmp    80105d8b <sys_chdir+0x8f>
  ilock(ip);
80105d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d37:	89 04 24             	mov    %eax,(%esp)
80105d3a:	e8 21 bb ff ff       	call   80101860 <ilock>
  if(ip->type != T_DIR){
80105d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d42:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d46:	66 83 f8 01          	cmp    $0x1,%ax
80105d4a:	74 12                	je     80105d5e <sys_chdir+0x62>
    iunlockput(ip);
80105d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4f:	89 04 24             	mov    %eax,(%esp)
80105d52:	e8 8d bd ff ff       	call   80101ae4 <iunlockput>
    return -1;
80105d57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d5c:	eb 2d                	jmp    80105d8b <sys_chdir+0x8f>
  }
  iunlock(ip);
80105d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d61:	89 04 24             	mov    %eax,(%esp)
80105d64:	e8 45 bc ff ff       	call   801019ae <iunlock>
  iput(proc->cwd);
80105d69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d6f:	8b 40 68             	mov    0x68(%eax),%eax
80105d72:	89 04 24             	mov    %eax,(%esp)
80105d75:	e8 99 bc ff ff       	call   80101a13 <iput>
  proc->cwd = ip;
80105d7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d83:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d8b:	c9                   	leave  
80105d8c:	c3                   	ret    

80105d8d <sys_exec>:

int
sys_exec(void)
{
80105d8d:	55                   	push   %ebp
80105d8e:	89 e5                	mov    %esp,%ebp
80105d90:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d96:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d99:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105da4:	e8 b1 f3 ff ff       	call   8010515a <argstr>
80105da9:	85 c0                	test   %eax,%eax
80105dab:	78 1a                	js     80105dc7 <sys_exec+0x3a>
80105dad:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105db3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105dbe:	e8 07 f3 ff ff       	call   801050ca <argint>
80105dc3:	85 c0                	test   %eax,%eax
80105dc5:	79 0a                	jns    80105dd1 <sys_exec+0x44>
    return -1;
80105dc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dcc:	e9 cc 00 00 00       	jmp    80105e9d <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
80105dd1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80105dd8:	00 
80105dd9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105de0:	00 
80105de1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105de7:	89 04 24             	mov    %eax,(%esp)
80105dea:	e8 7f ef ff ff       	call   80104d6e <memset>
  for(i=0;; i++){
80105def:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df9:	83 f8 1f             	cmp    $0x1f,%eax
80105dfc:	76 0a                	jbe    80105e08 <sys_exec+0x7b>
      return -1;
80105dfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e03:	e9 95 00 00 00       	jmp    80105e9d <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0b:	c1 e0 02             	shl    $0x2,%eax
80105e0e:	89 c2                	mov    %eax,%edx
80105e10:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e16:	01 c2                	add    %eax,%edx
80105e18:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e22:	89 14 24             	mov    %edx,(%esp)
80105e25:	e8 02 f2 ff ff       	call   8010502c <fetchint>
80105e2a:	85 c0                	test   %eax,%eax
80105e2c:	79 07                	jns    80105e35 <sys_exec+0xa8>
      return -1;
80105e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e33:	eb 68                	jmp    80105e9d <sys_exec+0x110>
    if(uarg == 0){
80105e35:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e3b:	85 c0                	test   %eax,%eax
80105e3d:	75 26                	jne    80105e65 <sys_exec+0xd8>
      argv[i] = 0;
80105e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e42:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e49:	00 00 00 00 
      break;
80105e4d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e51:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e57:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e5b:	89 04 24             	mov    %eax,(%esp)
80105e5e:	e8 99 ac ff ff       	call   80100afc <exec>
80105e63:	eb 38                	jmp    80105e9d <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e68:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105e6f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e75:	01 c2                	add    %eax,%edx
80105e77:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e7d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e81:	89 04 24             	mov    %eax,(%esp)
80105e84:	e8 dd f1 ff ff       	call   80105066 <fetchstr>
80105e89:	85 c0                	test   %eax,%eax
80105e8b:	79 07                	jns    80105e94 <sys_exec+0x107>
      return -1;
80105e8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e92:	eb 09                	jmp    80105e9d <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80105e94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80105e98:	e9 59 ff ff ff       	jmp    80105df6 <sys_exec+0x69>
  return exec(path, argv);
}
80105e9d:	c9                   	leave  
80105e9e:	c3                   	ret    

80105e9f <sys_pipe>:

int
sys_pipe(void)
{
80105e9f:	55                   	push   %ebp
80105ea0:	89 e5                	mov    %esp,%ebp
80105ea2:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ea5:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80105eac:	00 
80105ead:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ebb:	e8 38 f2 ff ff       	call   801050f8 <argptr>
80105ec0:	85 c0                	test   %eax,%eax
80105ec2:	79 0a                	jns    80105ece <sys_pipe+0x2f>
    return -1;
80105ec4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec9:	e9 9b 00 00 00       	jmp    80105f69 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80105ece:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ed5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ed8:	89 04 24             	mov    %eax,(%esp)
80105edb:	e8 40 dd ff ff       	call   80103c20 <pipealloc>
80105ee0:	85 c0                	test   %eax,%eax
80105ee2:	79 07                	jns    80105eeb <sys_pipe+0x4c>
    return -1;
80105ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee9:	eb 7e                	jmp    80105f69 <sys_pipe+0xca>
  fd0 = -1;
80105eeb:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ef2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ef5:	89 04 24             	mov    %eax,(%esp)
80105ef8:	e8 98 f3 ff ff       	call   80105295 <fdalloc>
80105efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f04:	78 14                	js     80105f1a <sys_pipe+0x7b>
80105f06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f09:	89 04 24             	mov    %eax,(%esp)
80105f0c:	e8 84 f3 ff ff       	call   80105295 <fdalloc>
80105f11:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f18:	79 37                	jns    80105f51 <sys_pipe+0xb2>
    if(fd0 >= 0)
80105f1a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f1e:	78 14                	js     80105f34 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80105f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f29:	83 c2 08             	add    $0x8,%edx
80105f2c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f33:	00 
    fileclose(rf);
80105f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f37:	89 04 24             	mov    %eax,(%esp)
80105f3a:	e8 7d b0 ff ff       	call   80100fbc <fileclose>
    fileclose(wf);
80105f3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f42:	89 04 24             	mov    %eax,(%esp)
80105f45:	e8 72 b0 ff ff       	call   80100fbc <fileclose>
    return -1;
80105f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f4f:	eb 18                	jmp    80105f69 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80105f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f57:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f5c:	8d 50 04             	lea    0x4(%eax),%edx
80105f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f62:	89 02                	mov    %eax,(%edx)
  return 0;
80105f64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f69:	c9                   	leave  
80105f6a:	c3                   	ret    
	...

80105f6c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105f6c:	55                   	push   %ebp
80105f6d:	89 e5                	mov    %esp,%ebp
80105f6f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f72:	e8 86 e3 ff ff       	call   801042fd <fork>
}
80105f77:	c9                   	leave  
80105f78:	c3                   	ret    

80105f79 <sys_exit>:

int
sys_exit(void)
{
80105f79:	55                   	push   %ebp
80105f7a:	89 e5                	mov    %esp,%ebp
80105f7c:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f7f:	e8 dc e4 ff ff       	call   80104460 <exit>
  return 0;  // not reached
80105f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f89:	c9                   	leave  
80105f8a:	c3                   	ret    

80105f8b <sys_wait>:

int
sys_wait(void)
{
80105f8b:	55                   	push   %ebp
80105f8c:	89 e5                	mov    %esp,%ebp
80105f8e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105f91:	e8 e5 e5 ff ff       	call   8010457b <wait>
}
80105f96:	c9                   	leave  
80105f97:	c3                   	ret    

80105f98 <sys_kill>:

int
sys_kill(void)
{
80105f98:	55                   	push   %ebp
80105f99:	89 e5                	mov    %esp,%ebp
80105f9b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105f9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fac:	e8 19 f1 ff ff       	call   801050ca <argint>
80105fb1:	85 c0                	test   %eax,%eax
80105fb3:	79 07                	jns    80105fbc <sys_kill+0x24>
    return -1;
80105fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fba:	eb 0b                	jmp    80105fc7 <sys_kill+0x2f>
  return kill(pid);
80105fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbf:	89 04 24             	mov    %eax,(%esp)
80105fc2:	e8 79 e9 ff ff       	call   80104940 <kill>
}
80105fc7:	c9                   	leave  
80105fc8:	c3                   	ret    

80105fc9 <sys_getpid>:

int
sys_getpid(void)
{
80105fc9:	55                   	push   %ebp
80105fca:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80105fcc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fd2:	8b 40 10             	mov    0x10(%eax),%eax
}
80105fd5:	5d                   	pop    %ebp
80105fd6:	c3                   	ret    

80105fd7 <sys_sbrk>:

int
sys_sbrk(void)
{
80105fd7:	55                   	push   %ebp
80105fd8:	89 e5                	mov    %esp,%ebp
80105fda:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105fdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fe4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105feb:	e8 da f0 ff ff       	call   801050ca <argint>
80105ff0:	85 c0                	test   %eax,%eax
80105ff2:	79 07                	jns    80105ffb <sys_sbrk+0x24>
    return -1;
80105ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff9:	eb 24                	jmp    8010601f <sys_sbrk+0x48>
  addr = proc->sz;
80105ffb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106001:	8b 00                	mov    (%eax),%eax
80106003:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106009:	89 04 24             	mov    %eax,(%esp)
8010600c:	e8 47 e2 ff ff       	call   80104258 <growproc>
80106011:	85 c0                	test   %eax,%eax
80106013:	79 07                	jns    8010601c <sys_sbrk+0x45>
    return -1;
80106015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601a:	eb 03                	jmp    8010601f <sys_sbrk+0x48>
  return addr;
8010601c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010601f:	c9                   	leave  
80106020:	c3                   	ret    

80106021 <sys_sleep>:

int
sys_sleep(void)
{
80106021:	55                   	push   %ebp
80106022:	89 e5                	mov    %esp,%ebp
80106024:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106027:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010602a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010602e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106035:	e8 90 f0 ff ff       	call   801050ca <argint>
8010603a:	85 c0                	test   %eax,%eax
8010603c:	79 07                	jns    80106045 <sys_sleep+0x24>
    return -1;
8010603e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106043:	eb 6c                	jmp    801060b1 <sys_sleep+0x90>
  acquire(&tickslock);
80106045:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010604c:	e8 ce ea ff ff       	call   80104b1f <acquire>
  ticks0 = ticks;
80106051:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106056:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106059:	eb 34                	jmp    8010608f <sys_sleep+0x6e>
    if(proc->killed){
8010605b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106061:	8b 40 24             	mov    0x24(%eax),%eax
80106064:	85 c0                	test   %eax,%eax
80106066:	74 13                	je     8010607b <sys_sleep+0x5a>
      release(&tickslock);
80106068:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010606f:	e8 0d eb ff ff       	call   80104b81 <release>
      return -1;
80106074:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106079:	eb 36                	jmp    801060b1 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010607b:	c7 44 24 04 80 21 11 	movl   $0x80112180,0x4(%esp)
80106082:	80 
80106083:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
8010608a:	e8 aa e7 ff ff       	call   80104839 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010608f:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106094:	89 c2                	mov    %eax,%edx
80106096:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609c:	39 c2                	cmp    %eax,%edx
8010609e:	72 bb                	jb     8010605b <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801060a0:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801060a7:	e8 d5 ea ff ff       	call   80104b81 <release>
  return 0;
801060ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060b1:	c9                   	leave  
801060b2:	c3                   	ret    

801060b3 <sys_alarma>:
int
sys_alarma(void)
{
801060b3:	55                   	push   %ebp
801060b4:	89 e5                	mov    %esp,%ebp
801060b6:	83 ec 28             	sub    $0x28,%esp
int ticks;
void(*handler)();
if(argint(0,&ticks)<0)
801060b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801060c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060c7:	e8 fe ef ff ff       	call   801050ca <argint>
801060cc:	85 c0                	test   %eax,%eax
801060ce:	79 07                	jns    801060d7 <sys_alarma+0x24>
	return -1;
801060d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d5:	eb 46                	jmp    8010611d <sys_alarma+0x6a>
if(argptr(1,(char**)&handler,1)<0)
801060d7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801060de:	00 
801060df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801060e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060ed:	e8 06 f0 ff ff       	call   801050f8 <argptr>
801060f2:	85 c0                	test   %eax,%eax
801060f4:	79 07                	jns    801060fd <sys_alarma+0x4a>
	return -1;
801060f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060fb:	eb 20                	jmp    8010611d <sys_alarma+0x6a>
proc-> ticksalarma = ticks;
801060fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106103:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106106:	89 50 7c             	mov    %edx,0x7c(%eax)
proc-> alarmhandler = handler;
80106109:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010610f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106112:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
return 0;
80106118:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010611d:	c9                   	leave  
8010611e:	c3                   	ret    

8010611f <sys_info>:
int
sys_info(void)
{
8010611f:	55                   	push   %ebp
80106120:	89 e5                	mov    %esp,%ebp
//return proc->state;
//return cpu->id;
//return proc->killed;
//return proc->sz;
//return proc->parent->sz;
return proc->parent->pid;
80106122:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106128:	8b 40 14             	mov    0x14(%eax),%eax
8010612b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010612e:	5d                   	pop    %ebp
8010612f:	c3                   	ret    

80106130 <sys_estado>:
int 
sys_estado(void)
{
80106130:	55                   	push   %ebp
80106131:	89 e5                	mov    %esp,%ebp
return proc->parent->state;
80106133:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106139:	8b 40 14             	mov    0x14(%eax),%eax
8010613c:	8b 40 0c             	mov    0xc(%eax),%eax
}
8010613f:	5d                   	pop    %ebp
80106140:	c3                   	ret    

80106141 <sys_estadohijo>:
int
sys_estadohijo(void)
{
80106141:	55                   	push   %ebp
80106142:	89 e5                	mov    %esp,%ebp
return proc->state;
80106144:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010614a:	8b 40 0c             	mov    0xc(%eax),%eax
}
8010614d:	5d                   	pop    %ebp
8010614e:	c3                   	ret    

8010614f <sys_size>:
int
sys_size(void)
{
8010614f:	55                   	push   %ebp
80106150:	89 e5                	mov    %esp,%ebp
return proc->sz;
80106152:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106158:	8b 00                	mov    (%eax),%eax
}
8010615a:	5d                   	pop    %ebp
8010615b:	c3                   	ret    

8010615c <sys_doge>:
int
sys_doge(void)
{
8010615c:	55                   	push   %ebp
8010615d:	89 e5                	mov    %esp,%ebp
return 1;
8010615f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106164:	5d                   	pop    %ebp
80106165:	c3                   	ret    

80106166 <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106166:	55                   	push   %ebp
80106167:	89 e5                	mov    %esp,%ebp
80106169:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010616c:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106173:	e8 a7 e9 ff ff       	call   80104b1f <acquire>
  xticks = ticks;
80106178:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010617d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106180:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106187:	e8 f5 e9 ff ff       	call   80104b81 <release>
  return xticks;
8010618c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010618f:	c9                   	leave  
80106190:	c3                   	ret    
80106191:	00 00                	add    %al,(%eax)
	...

80106194 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106194:	55                   	push   %ebp
80106195:	89 e5                	mov    %esp,%ebp
80106197:	83 ec 08             	sub    $0x8,%esp
8010619a:	8b 55 08             	mov    0x8(%ebp),%edx
8010619d:	8b 45 0c             	mov    0xc(%ebp),%eax
801061a0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801061a4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061a7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801061ab:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801061af:	ee                   	out    %al,(%dx)
}
801061b0:	c9                   	leave  
801061b1:	c3                   	ret    

801061b2 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801061b2:	55                   	push   %ebp
801061b3:	89 e5                	mov    %esp,%ebp
801061b5:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801061b8:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801061bf:	00 
801061c0:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801061c7:	e8 c8 ff ff ff       	call   80106194 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801061cc:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801061d3:	00 
801061d4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801061db:	e8 b4 ff ff ff       	call   80106194 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801061e0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801061e7:	00 
801061e8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801061ef:	e8 a0 ff ff ff       	call   80106194 <outb>
  picenable(IRQ_TIMER);
801061f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061fb:	e8 a9 d8 ff ff       	call   80103aa9 <picenable>
}
80106200:	c9                   	leave  
80106201:	c3                   	ret    
	...

80106204 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106204:	1e                   	push   %ds
  pushl %es
80106205:	06                   	push   %es
  pushl %fs
80106206:	0f a0                	push   %fs
  pushl %gs
80106208:	0f a8                	push   %gs
  pushal
8010620a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010620b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010620f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106211:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106213:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106217:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106219:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010621b:	54                   	push   %esp
  call trap
8010621c:	e8 de 01 00 00       	call   801063ff <trap>
  addl $4, %esp
80106221:	83 c4 04             	add    $0x4,%esp

80106224 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106224:	61                   	popa   
  popl %gs
80106225:	0f a9                	pop    %gs
  popl %fs
80106227:	0f a1                	pop    %fs
  popl %es
80106229:	07                   	pop    %es
  popl %ds
8010622a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010622b:	83 c4 08             	add    $0x8,%esp
  iret
8010622e:	cf                   	iret   
	...

80106230 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106230:	55                   	push   %ebp
80106231:	89 e5                	mov    %esp,%ebp
80106233:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106236:	8b 45 0c             	mov    0xc(%ebp),%eax
80106239:	83 e8 01             	sub    $0x1,%eax
8010623c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106240:	8b 45 08             	mov    0x8(%ebp),%eax
80106243:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106247:	8b 45 08             	mov    0x8(%ebp),%eax
8010624a:	c1 e8 10             	shr    $0x10,%eax
8010624d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106251:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106254:	0f 01 18             	lidtl  (%eax)
}
80106257:	c9                   	leave  
80106258:	c3                   	ret    

80106259 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106259:	55                   	push   %ebp
8010625a:	89 e5                	mov    %esp,%ebp
8010625c:	53                   	push   %ebx
8010625d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106260:	0f 20 d3             	mov    %cr2,%ebx
80106263:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106266:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106269:	83 c4 10             	add    $0x10,%esp
8010626c:	5b                   	pop    %ebx
8010626d:	5d                   	pop    %ebp
8010626e:	c3                   	ret    

8010626f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010626f:	55                   	push   %ebp
80106270:	89 e5                	mov    %esp,%ebp
80106272:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010627c:	e9 c3 00 00 00       	jmp    80106344 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106284:	8b 04 85 b0 b0 10 80 	mov    -0x7fef4f50(,%eax,4),%eax
8010628b:	89 c2                	mov    %eax,%edx
8010628d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106290:	66 89 14 c5 c0 21 11 	mov    %dx,-0x7feede40(,%eax,8)
80106297:	80 
80106298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629b:	66 c7 04 c5 c2 21 11 	movw   $0x8,-0x7feede3e(,%eax,8)
801062a2:	80 08 00 
801062a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a8:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
801062af:	80 
801062b0:	83 e2 e0             	and    $0xffffffe0,%edx
801062b3:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
801062ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bd:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
801062c4:	80 
801062c5:	83 e2 1f             	and    $0x1f,%edx
801062c8:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
801062cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d2:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801062d9:	80 
801062da:	83 e2 f0             	and    $0xfffffff0,%edx
801062dd:	83 ca 0e             	or     $0xe,%edx
801062e0:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801062e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ea:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801062f1:	80 
801062f2:	83 e2 ef             	and    $0xffffffef,%edx
801062f5:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801062fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ff:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106306:	80 
80106307:	83 e2 9f             	and    $0xffffff9f,%edx
8010630a:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106314:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
8010631b:	80 
8010631c:	83 ca 80             	or     $0xffffff80,%edx
8010631f:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106329:	8b 04 85 b0 b0 10 80 	mov    -0x7fef4f50(,%eax,4),%eax
80106330:	c1 e8 10             	shr    $0x10,%eax
80106333:	89 c2                	mov    %eax,%edx
80106335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106338:	66 89 14 c5 c6 21 11 	mov    %dx,-0x7feede3a(,%eax,8)
8010633f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106340:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106344:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010634b:	0f 8e 30 ff ff ff    	jle    80106281 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106351:	a1 b0 b1 10 80       	mov    0x8010b1b0,%eax
80106356:	66 a3 c0 23 11 80    	mov    %ax,0x801123c0
8010635c:	66 c7 05 c2 23 11 80 	movw   $0x8,0x801123c2
80106363:	08 00 
80106365:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010636c:	83 e0 e0             	and    $0xffffffe0,%eax
8010636f:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106374:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010637b:	83 e0 1f             	and    $0x1f,%eax
8010637e:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106383:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
8010638a:	83 c8 0f             	or     $0xf,%eax
8010638d:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106392:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106399:	83 e0 ef             	and    $0xffffffef,%eax
8010639c:	a2 c5 23 11 80       	mov    %al,0x801123c5
801063a1:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801063a8:	83 c8 60             	or     $0x60,%eax
801063ab:	a2 c5 23 11 80       	mov    %al,0x801123c5
801063b0:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801063b7:	83 c8 80             	or     $0xffffff80,%eax
801063ba:	a2 c5 23 11 80       	mov    %al,0x801123c5
801063bf:	a1 b0 b1 10 80       	mov    0x8010b1b0,%eax
801063c4:	c1 e8 10             	shr    $0x10,%eax
801063c7:	66 a3 c6 23 11 80    	mov    %ax,0x801123c6
  
  initlock(&tickslock, "time");
801063cd:	c7 44 24 04 68 86 10 	movl   $0x80108668,0x4(%esp)
801063d4:	80 
801063d5:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801063dc:	e8 1d e7 ff ff       	call   80104afe <initlock>
}
801063e1:	c9                   	leave  
801063e2:	c3                   	ret    

801063e3 <idtinit>:

void
idtinit(void)
{
801063e3:	55                   	push   %ebp
801063e4:	89 e5                	mov    %esp,%ebp
801063e6:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801063e9:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801063f0:	00 
801063f1:	c7 04 24 c0 21 11 80 	movl   $0x801121c0,(%esp)
801063f8:	e8 33 fe ff ff       	call   80106230 <lidt>
}
801063fd:	c9                   	leave  
801063fe:	c3                   	ret    

801063ff <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063ff:	55                   	push   %ebp
80106400:	89 e5                	mov    %esp,%ebp
80106402:	57                   	push   %edi
80106403:	56                   	push   %esi
80106404:	53                   	push   %ebx
80106405:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106408:	8b 45 08             	mov    0x8(%ebp),%eax
8010640b:	8b 40 30             	mov    0x30(%eax),%eax
8010640e:	83 f8 40             	cmp    $0x40,%eax
80106411:	75 3e                	jne    80106451 <trap+0x52>
    if(proc->killed)
80106413:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106419:	8b 40 24             	mov    0x24(%eax),%eax
8010641c:	85 c0                	test   %eax,%eax
8010641e:	74 05                	je     80106425 <trap+0x26>
      exit();
80106420:	e8 3b e0 ff ff       	call   80104460 <exit>
    proc->tf = tf;
80106425:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010642b:	8b 55 08             	mov    0x8(%ebp),%edx
8010642e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106431:	e8 5b ed ff ff       	call   80105191 <syscall>
    if(proc->killed)
80106436:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010643c:	8b 40 24             	mov    0x24(%eax),%eax
8010643f:	85 c0                	test   %eax,%eax
80106441:	0f 84 c3 02 00 00    	je     8010670a <trap+0x30b>
      exit();
80106447:	e8 14 e0 ff ff       	call   80104460 <exit>
    return;
8010644c:	e9 b9 02 00 00       	jmp    8010670a <trap+0x30b>
  }

  switch(tf->trapno){
80106451:	8b 45 08             	mov    0x8(%ebp),%eax
80106454:	8b 40 30             	mov    0x30(%eax),%eax
80106457:	83 e8 20             	sub    $0x20,%eax
8010645a:	83 f8 1f             	cmp    $0x1f,%eax
8010645d:	0f 87 4b 01 00 00    	ja     801065ae <trap+0x1af>
80106463:	8b 04 85 10 87 10 80 	mov    -0x7fef78f0(,%eax,4),%eax
8010646a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010646c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106472:	0f b6 00             	movzbl (%eax),%eax
80106475:	84 c0                	test   %al,%al
80106477:	75 31                	jne    801064aa <trap+0xab>
      acquire(&tickslock);
80106479:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106480:	e8 9a e6 ff ff       	call   80104b1f <acquire>
      ticks++;
80106485:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010648a:	83 c0 01             	add    $0x1,%eax
8010648d:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      wakeup(&ticks);
80106492:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
80106499:	e8 77 e4 ff ff       	call   80104915 <wakeup>
      release(&tickslock);
8010649e:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801064a5:	e8 d7 e6 ff ff       	call   80104b81 <release>
    }
if(proc && (tf->cs & 3)==3){
801064aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064b0:	85 c0                	test   %eax,%eax
801064b2:	0f 84 81 00 00 00    	je     80106539 <trap+0x13a>
801064b8:	8b 45 08             	mov    0x8(%ebp),%eax
801064bb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064bf:	0f b7 c0             	movzwl %ax,%eax
801064c2:	83 e0 03             	and    $0x3,%eax
801064c5:	83 f8 03             	cmp    $0x3,%eax
801064c8:	75 6f                	jne    80106539 <trap+0x13a>
	proc->ticks++;
801064ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064d0:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801064d6:	83 c2 01             	add    $0x1,%edx
801064d9:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	if(proc->ticksalarma==proc->ticks){
801064df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064e5:	8b 50 7c             	mov    0x7c(%eax),%edx
801064e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064ee:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801064f4:	39 c2                	cmp    %eax,%edx
801064f6:	75 41                	jne    80106539 <trap+0x13a>
	proc->ticks=0;
801064f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064fe:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80106505:	00 00 00 
	tf->esp -=4;
80106508:	8b 45 08             	mov    0x8(%ebp),%eax
8010650b:	8b 40 44             	mov    0x44(%eax),%eax
8010650e:	8d 50 fc             	lea    -0x4(%eax),%edx
80106511:	8b 45 08             	mov    0x8(%ebp),%eax
80106514:	89 50 44             	mov    %edx,0x44(%eax)
	*((uint*)(tf->esp))=tf->eip;
80106517:	8b 45 08             	mov    0x8(%ebp),%eax
8010651a:	8b 40 44             	mov    0x44(%eax),%eax
8010651d:	8b 55 08             	mov    0x8(%ebp),%edx
80106520:	8b 52 38             	mov    0x38(%edx),%edx
80106523:	89 10                	mov    %edx,(%eax)
	tf->eip=(uint)proc->alarmhandler;
80106525:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652b:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80106531:	89 c2                	mov    %eax,%edx
80106533:	8b 45 08             	mov    0x8(%ebp),%eax
80106536:	89 50 38             	mov    %edx,0x38(%eax)
}
}
    lapiceoi();
80106539:	e8 a3 c9 ff ff       	call   80102ee1 <lapiceoi>
    break;
8010653e:	e9 41 01 00 00       	jmp    80106684 <trap+0x285>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106543:	e8 a1 c1 ff ff       	call   801026e9 <ideintr>
    lapiceoi();
80106548:	e8 94 c9 ff ff       	call   80102ee1 <lapiceoi>
    break;
8010654d:	e9 32 01 00 00       	jmp    80106684 <trap+0x285>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106552:	e8 68 c7 ff ff       	call   80102cbf <kbdintr>
    lapiceoi();
80106557:	e8 85 c9 ff ff       	call   80102ee1 <lapiceoi>
    break;
8010655c:	e9 23 01 00 00       	jmp    80106684 <trap+0x285>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106561:	e8 aa 03 00 00       	call   80106910 <uartintr>
    lapiceoi();
80106566:	e8 76 c9 ff ff       	call   80102ee1 <lapiceoi>
    break;
8010656b:	e9 14 01 00 00       	jmp    80106684 <trap+0x285>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106570:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106573:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106576:	8b 45 08             	mov    0x8(%ebp),%eax
80106579:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010657d:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106580:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106586:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106589:	0f b6 c0             	movzbl %al,%eax
8010658c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106590:	89 54 24 08          	mov    %edx,0x8(%esp)
80106594:	89 44 24 04          	mov    %eax,0x4(%esp)
80106598:	c7 04 24 70 86 10 80 	movl   $0x80108670,(%esp)
8010659f:	e8 fd 9d ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801065a4:	e8 38 c9 ff ff       	call   80102ee1 <lapiceoi>
    break;
801065a9:	e9 d6 00 00 00       	jmp    80106684 <trap+0x285>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801065ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065b4:	85 c0                	test   %eax,%eax
801065b6:	74 11                	je     801065c9 <trap+0x1ca>
801065b8:	8b 45 08             	mov    0x8(%ebp),%eax
801065bb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065bf:	0f b7 c0             	movzwl %ax,%eax
801065c2:	83 e0 03             	and    $0x3,%eax
801065c5:	85 c0                	test   %eax,%eax
801065c7:	75 46                	jne    8010660f <trap+0x210>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065c9:	e8 8b fc ff ff       	call   80106259 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
801065ce:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065d1:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801065d4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801065db:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065de:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801065e1:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065e4:	8b 52 30             	mov    0x30(%edx),%edx
801065e7:	89 44 24 10          	mov    %eax,0x10(%esp)
801065eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801065ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801065f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801065f7:	c7 04 24 94 86 10 80 	movl   $0x80108694,(%esp)
801065fe:	e8 9e 9d ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106603:	c7 04 24 c6 86 10 80 	movl   $0x801086c6,(%esp)
8010660a:	e8 2e 9f ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010660f:	e8 45 fc ff ff       	call   80106259 <rcr2>
80106614:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106616:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106619:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010661c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106622:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106625:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106628:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010662b:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010662e:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106631:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106634:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010663a:	83 c0 6c             	add    $0x6c,%eax
8010663d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106640:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106646:	8b 40 10             	mov    0x10(%eax),%eax
80106649:	89 54 24 1c          	mov    %edx,0x1c(%esp)
8010664d:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106651:	89 74 24 14          	mov    %esi,0x14(%esp)
80106655:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106659:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010665d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106660:	89 54 24 08          	mov    %edx,0x8(%esp)
80106664:	89 44 24 04          	mov    %eax,0x4(%esp)
80106668:	c7 04 24 cc 86 10 80 	movl   $0x801086cc,(%esp)
8010666f:	e8 2d 9d ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106674:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106681:	eb 01                	jmp    80106684 <trap+0x285>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106683:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010668a:	85 c0                	test   %eax,%eax
8010668c:	74 24                	je     801066b2 <trap+0x2b3>
8010668e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106694:	8b 40 24             	mov    0x24(%eax),%eax
80106697:	85 c0                	test   %eax,%eax
80106699:	74 17                	je     801066b2 <trap+0x2b3>
8010669b:	8b 45 08             	mov    0x8(%ebp),%eax
8010669e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066a2:	0f b7 c0             	movzwl %ax,%eax
801066a5:	83 e0 03             	and    $0x3,%eax
801066a8:	83 f8 03             	cmp    $0x3,%eax
801066ab:	75 05                	jne    801066b2 <trap+0x2b3>
    exit();
801066ad:	e8 ae dd ff ff       	call   80104460 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801066b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066b8:	85 c0                	test   %eax,%eax
801066ba:	74 1e                	je     801066da <trap+0x2db>
801066bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066c2:	8b 40 0c             	mov    0xc(%eax),%eax
801066c5:	83 f8 04             	cmp    $0x4,%eax
801066c8:	75 10                	jne    801066da <trap+0x2db>
801066ca:	8b 45 08             	mov    0x8(%ebp),%eax
801066cd:	8b 40 30             	mov    0x30(%eax),%eax
801066d0:	83 f8 20             	cmp    $0x20,%eax
801066d3:	75 05                	jne    801066da <trap+0x2db>
    yield();
801066d5:	e8 01 e1 ff ff       	call   801047db <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801066da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066e0:	85 c0                	test   %eax,%eax
801066e2:	74 27                	je     8010670b <trap+0x30c>
801066e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ea:	8b 40 24             	mov    0x24(%eax),%eax
801066ed:	85 c0                	test   %eax,%eax
801066ef:	74 1a                	je     8010670b <trap+0x30c>
801066f1:	8b 45 08             	mov    0x8(%ebp),%eax
801066f4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066f8:	0f b7 c0             	movzwl %ax,%eax
801066fb:	83 e0 03             	and    $0x3,%eax
801066fe:	83 f8 03             	cmp    $0x3,%eax
80106701:	75 08                	jne    8010670b <trap+0x30c>
    exit();
80106703:	e8 58 dd ff ff       	call   80104460 <exit>
80106708:	eb 01                	jmp    8010670b <trap+0x30c>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010670a:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010670b:	83 c4 3c             	add    $0x3c,%esp
8010670e:	5b                   	pop    %ebx
8010670f:	5e                   	pop    %esi
80106710:	5f                   	pop    %edi
80106711:	5d                   	pop    %ebp
80106712:	c3                   	ret    
	...

80106714 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106714:	55                   	push   %ebp
80106715:	89 e5                	mov    %esp,%ebp
80106717:	53                   	push   %ebx
80106718:	83 ec 14             	sub    $0x14,%esp
8010671b:	8b 45 08             	mov    0x8(%ebp),%eax
8010671e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106722:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106726:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010672a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010672e:	ec                   	in     (%dx),%al
8010672f:	89 c3                	mov    %eax,%ebx
80106731:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106734:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106738:	83 c4 14             	add    $0x14,%esp
8010673b:	5b                   	pop    %ebx
8010673c:	5d                   	pop    %ebp
8010673d:	c3                   	ret    

8010673e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010673e:	55                   	push   %ebp
8010673f:	89 e5                	mov    %esp,%ebp
80106741:	83 ec 08             	sub    $0x8,%esp
80106744:	8b 55 08             	mov    0x8(%ebp),%edx
80106747:	8b 45 0c             	mov    0xc(%ebp),%eax
8010674a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010674e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106751:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106755:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106759:	ee                   	out    %al,(%dx)
}
8010675a:	c9                   	leave  
8010675b:	c3                   	ret    

8010675c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010675c:	55                   	push   %ebp
8010675d:	89 e5                	mov    %esp,%ebp
8010675f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106762:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106769:	00 
8010676a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106771:	e8 c8 ff ff ff       	call   8010673e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106776:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
8010677d:	00 
8010677e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106785:	e8 b4 ff ff ff       	call   8010673e <outb>
  outb(COM1+0, 115200/9600);
8010678a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106791:	00 
80106792:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106799:	e8 a0 ff ff ff       	call   8010673e <outb>
  outb(COM1+1, 0);
8010679e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801067a5:	00 
801067a6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801067ad:	e8 8c ff ff ff       	call   8010673e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801067b2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801067b9:	00 
801067ba:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801067c1:	e8 78 ff ff ff       	call   8010673e <outb>
  outb(COM1+4, 0);
801067c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801067cd:	00 
801067ce:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801067d5:	e8 64 ff ff ff       	call   8010673e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801067da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801067e1:	00 
801067e2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801067e9:	e8 50 ff ff ff       	call   8010673e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801067ee:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801067f5:	e8 1a ff ff ff       	call   80106714 <inb>
801067fa:	3c ff                	cmp    $0xff,%al
801067fc:	74 6c                	je     8010686a <uartinit+0x10e>
    return;
  uart = 1;
801067fe:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
80106805:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106808:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010680f:	e8 00 ff ff ff       	call   80106714 <inb>
  inb(COM1+0);
80106814:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010681b:	e8 f4 fe ff ff       	call   80106714 <inb>
  picenable(IRQ_COM1);
80106820:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106827:	e8 7d d2 ff ff       	call   80103aa9 <picenable>
  ioapicenable(IRQ_COM1, 0);
8010682c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106833:	00 
80106834:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010683b:	e8 2e c1 ff ff       	call   8010296e <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106840:	c7 45 f4 90 87 10 80 	movl   $0x80108790,-0xc(%ebp)
80106847:	eb 15                	jmp    8010685e <uartinit+0x102>
    uartputc(*p);
80106849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684c:	0f b6 00             	movzbl (%eax),%eax
8010684f:	0f be c0             	movsbl %al,%eax
80106852:	89 04 24             	mov    %eax,(%esp)
80106855:	e8 13 00 00 00       	call   8010686d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010685a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010685e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106861:	0f b6 00             	movzbl (%eax),%eax
80106864:	84 c0                	test   %al,%al
80106866:	75 e1                	jne    80106849 <uartinit+0xed>
80106868:	eb 01                	jmp    8010686b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010686a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010686b:	c9                   	leave  
8010686c:	c3                   	ret    

8010686d <uartputc>:

void
uartputc(int c)
{
8010686d:	55                   	push   %ebp
8010686e:	89 e5                	mov    %esp,%ebp
80106870:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106873:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106878:	85 c0                	test   %eax,%eax
8010687a:	74 4d                	je     801068c9 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010687c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106883:	eb 10                	jmp    80106895 <uartputc+0x28>
    microdelay(10);
80106885:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010688c:	e8 75 c6 ff ff       	call   80102f06 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106891:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106895:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106899:	7f 16                	jg     801068b1 <uartputc+0x44>
8010689b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801068a2:	e8 6d fe ff ff       	call   80106714 <inb>
801068a7:	0f b6 c0             	movzbl %al,%eax
801068aa:	83 e0 20             	and    $0x20,%eax
801068ad:	85 c0                	test   %eax,%eax
801068af:	74 d4                	je     80106885 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801068b1:	8b 45 08             	mov    0x8(%ebp),%eax
801068b4:	0f b6 c0             	movzbl %al,%eax
801068b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801068bb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801068c2:	e8 77 fe ff ff       	call   8010673e <outb>
801068c7:	eb 01                	jmp    801068ca <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801068c9:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801068ca:	c9                   	leave  
801068cb:	c3                   	ret    

801068cc <uartgetc>:

static int
uartgetc(void)
{
801068cc:	55                   	push   %ebp
801068cd:	89 e5                	mov    %esp,%ebp
801068cf:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801068d2:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
801068d7:	85 c0                	test   %eax,%eax
801068d9:	75 07                	jne    801068e2 <uartgetc+0x16>
    return -1;
801068db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e0:	eb 2c                	jmp    8010690e <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801068e2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801068e9:	e8 26 fe ff ff       	call   80106714 <inb>
801068ee:	0f b6 c0             	movzbl %al,%eax
801068f1:	83 e0 01             	and    $0x1,%eax
801068f4:	85 c0                	test   %eax,%eax
801068f6:	75 07                	jne    801068ff <uartgetc+0x33>
    return -1;
801068f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068fd:	eb 0f                	jmp    8010690e <uartgetc+0x42>
  return inb(COM1+0);
801068ff:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106906:	e8 09 fe ff ff       	call   80106714 <inb>
8010690b:	0f b6 c0             	movzbl %al,%eax
}
8010690e:	c9                   	leave  
8010690f:	c3                   	ret    

80106910 <uartintr>:

void
uartintr(void)
{
80106910:	55                   	push   %ebp
80106911:	89 e5                	mov    %esp,%ebp
80106913:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106916:	c7 04 24 cc 68 10 80 	movl   $0x801068cc,(%esp)
8010691d:	e8 8b 9e ff ff       	call   801007ad <consoleintr>
}
80106922:	c9                   	leave  
80106923:	c3                   	ret    

80106924 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106924:	6a 00                	push   $0x0
  pushl $0
80106926:	6a 00                	push   $0x0
  jmp alltraps
80106928:	e9 d7 f8 ff ff       	jmp    80106204 <alltraps>

8010692d <vector1>:
.globl vector1
vector1:
  pushl $0
8010692d:	6a 00                	push   $0x0
  pushl $1
8010692f:	6a 01                	push   $0x1
  jmp alltraps
80106931:	e9 ce f8 ff ff       	jmp    80106204 <alltraps>

80106936 <vector2>:
.globl vector2
vector2:
  pushl $0
80106936:	6a 00                	push   $0x0
  pushl $2
80106938:	6a 02                	push   $0x2
  jmp alltraps
8010693a:	e9 c5 f8 ff ff       	jmp    80106204 <alltraps>

8010693f <vector3>:
.globl vector3
vector3:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $3
80106941:	6a 03                	push   $0x3
  jmp alltraps
80106943:	e9 bc f8 ff ff       	jmp    80106204 <alltraps>

80106948 <vector4>:
.globl vector4
vector4:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $4
8010694a:	6a 04                	push   $0x4
  jmp alltraps
8010694c:	e9 b3 f8 ff ff       	jmp    80106204 <alltraps>

80106951 <vector5>:
.globl vector5
vector5:
  pushl $0
80106951:	6a 00                	push   $0x0
  pushl $5
80106953:	6a 05                	push   $0x5
  jmp alltraps
80106955:	e9 aa f8 ff ff       	jmp    80106204 <alltraps>

8010695a <vector6>:
.globl vector6
vector6:
  pushl $0
8010695a:	6a 00                	push   $0x0
  pushl $6
8010695c:	6a 06                	push   $0x6
  jmp alltraps
8010695e:	e9 a1 f8 ff ff       	jmp    80106204 <alltraps>

80106963 <vector7>:
.globl vector7
vector7:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $7
80106965:	6a 07                	push   $0x7
  jmp alltraps
80106967:	e9 98 f8 ff ff       	jmp    80106204 <alltraps>

8010696c <vector8>:
.globl vector8
vector8:
  pushl $8
8010696c:	6a 08                	push   $0x8
  jmp alltraps
8010696e:	e9 91 f8 ff ff       	jmp    80106204 <alltraps>

80106973 <vector9>:
.globl vector9
vector9:
  pushl $0
80106973:	6a 00                	push   $0x0
  pushl $9
80106975:	6a 09                	push   $0x9
  jmp alltraps
80106977:	e9 88 f8 ff ff       	jmp    80106204 <alltraps>

8010697c <vector10>:
.globl vector10
vector10:
  pushl $10
8010697c:	6a 0a                	push   $0xa
  jmp alltraps
8010697e:	e9 81 f8 ff ff       	jmp    80106204 <alltraps>

80106983 <vector11>:
.globl vector11
vector11:
  pushl $11
80106983:	6a 0b                	push   $0xb
  jmp alltraps
80106985:	e9 7a f8 ff ff       	jmp    80106204 <alltraps>

8010698a <vector12>:
.globl vector12
vector12:
  pushl $12
8010698a:	6a 0c                	push   $0xc
  jmp alltraps
8010698c:	e9 73 f8 ff ff       	jmp    80106204 <alltraps>

80106991 <vector13>:
.globl vector13
vector13:
  pushl $13
80106991:	6a 0d                	push   $0xd
  jmp alltraps
80106993:	e9 6c f8 ff ff       	jmp    80106204 <alltraps>

80106998 <vector14>:
.globl vector14
vector14:
  pushl $14
80106998:	6a 0e                	push   $0xe
  jmp alltraps
8010699a:	e9 65 f8 ff ff       	jmp    80106204 <alltraps>

8010699f <vector15>:
.globl vector15
vector15:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $15
801069a1:	6a 0f                	push   $0xf
  jmp alltraps
801069a3:	e9 5c f8 ff ff       	jmp    80106204 <alltraps>

801069a8 <vector16>:
.globl vector16
vector16:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $16
801069aa:	6a 10                	push   $0x10
  jmp alltraps
801069ac:	e9 53 f8 ff ff       	jmp    80106204 <alltraps>

801069b1 <vector17>:
.globl vector17
vector17:
  pushl $17
801069b1:	6a 11                	push   $0x11
  jmp alltraps
801069b3:	e9 4c f8 ff ff       	jmp    80106204 <alltraps>

801069b8 <vector18>:
.globl vector18
vector18:
  pushl $0
801069b8:	6a 00                	push   $0x0
  pushl $18
801069ba:	6a 12                	push   $0x12
  jmp alltraps
801069bc:	e9 43 f8 ff ff       	jmp    80106204 <alltraps>

801069c1 <vector19>:
.globl vector19
vector19:
  pushl $0
801069c1:	6a 00                	push   $0x0
  pushl $19
801069c3:	6a 13                	push   $0x13
  jmp alltraps
801069c5:	e9 3a f8 ff ff       	jmp    80106204 <alltraps>

801069ca <vector20>:
.globl vector20
vector20:
  pushl $0
801069ca:	6a 00                	push   $0x0
  pushl $20
801069cc:	6a 14                	push   $0x14
  jmp alltraps
801069ce:	e9 31 f8 ff ff       	jmp    80106204 <alltraps>

801069d3 <vector21>:
.globl vector21
vector21:
  pushl $0
801069d3:	6a 00                	push   $0x0
  pushl $21
801069d5:	6a 15                	push   $0x15
  jmp alltraps
801069d7:	e9 28 f8 ff ff       	jmp    80106204 <alltraps>

801069dc <vector22>:
.globl vector22
vector22:
  pushl $0
801069dc:	6a 00                	push   $0x0
  pushl $22
801069de:	6a 16                	push   $0x16
  jmp alltraps
801069e0:	e9 1f f8 ff ff       	jmp    80106204 <alltraps>

801069e5 <vector23>:
.globl vector23
vector23:
  pushl $0
801069e5:	6a 00                	push   $0x0
  pushl $23
801069e7:	6a 17                	push   $0x17
  jmp alltraps
801069e9:	e9 16 f8 ff ff       	jmp    80106204 <alltraps>

801069ee <vector24>:
.globl vector24
vector24:
  pushl $0
801069ee:	6a 00                	push   $0x0
  pushl $24
801069f0:	6a 18                	push   $0x18
  jmp alltraps
801069f2:	e9 0d f8 ff ff       	jmp    80106204 <alltraps>

801069f7 <vector25>:
.globl vector25
vector25:
  pushl $0
801069f7:	6a 00                	push   $0x0
  pushl $25
801069f9:	6a 19                	push   $0x19
  jmp alltraps
801069fb:	e9 04 f8 ff ff       	jmp    80106204 <alltraps>

80106a00 <vector26>:
.globl vector26
vector26:
  pushl $0
80106a00:	6a 00                	push   $0x0
  pushl $26
80106a02:	6a 1a                	push   $0x1a
  jmp alltraps
80106a04:	e9 fb f7 ff ff       	jmp    80106204 <alltraps>

80106a09 <vector27>:
.globl vector27
vector27:
  pushl $0
80106a09:	6a 00                	push   $0x0
  pushl $27
80106a0b:	6a 1b                	push   $0x1b
  jmp alltraps
80106a0d:	e9 f2 f7 ff ff       	jmp    80106204 <alltraps>

80106a12 <vector28>:
.globl vector28
vector28:
  pushl $0
80106a12:	6a 00                	push   $0x0
  pushl $28
80106a14:	6a 1c                	push   $0x1c
  jmp alltraps
80106a16:	e9 e9 f7 ff ff       	jmp    80106204 <alltraps>

80106a1b <vector29>:
.globl vector29
vector29:
  pushl $0
80106a1b:	6a 00                	push   $0x0
  pushl $29
80106a1d:	6a 1d                	push   $0x1d
  jmp alltraps
80106a1f:	e9 e0 f7 ff ff       	jmp    80106204 <alltraps>

80106a24 <vector30>:
.globl vector30
vector30:
  pushl $0
80106a24:	6a 00                	push   $0x0
  pushl $30
80106a26:	6a 1e                	push   $0x1e
  jmp alltraps
80106a28:	e9 d7 f7 ff ff       	jmp    80106204 <alltraps>

80106a2d <vector31>:
.globl vector31
vector31:
  pushl $0
80106a2d:	6a 00                	push   $0x0
  pushl $31
80106a2f:	6a 1f                	push   $0x1f
  jmp alltraps
80106a31:	e9 ce f7 ff ff       	jmp    80106204 <alltraps>

80106a36 <vector32>:
.globl vector32
vector32:
  pushl $0
80106a36:	6a 00                	push   $0x0
  pushl $32
80106a38:	6a 20                	push   $0x20
  jmp alltraps
80106a3a:	e9 c5 f7 ff ff       	jmp    80106204 <alltraps>

80106a3f <vector33>:
.globl vector33
vector33:
  pushl $0
80106a3f:	6a 00                	push   $0x0
  pushl $33
80106a41:	6a 21                	push   $0x21
  jmp alltraps
80106a43:	e9 bc f7 ff ff       	jmp    80106204 <alltraps>

80106a48 <vector34>:
.globl vector34
vector34:
  pushl $0
80106a48:	6a 00                	push   $0x0
  pushl $34
80106a4a:	6a 22                	push   $0x22
  jmp alltraps
80106a4c:	e9 b3 f7 ff ff       	jmp    80106204 <alltraps>

80106a51 <vector35>:
.globl vector35
vector35:
  pushl $0
80106a51:	6a 00                	push   $0x0
  pushl $35
80106a53:	6a 23                	push   $0x23
  jmp alltraps
80106a55:	e9 aa f7 ff ff       	jmp    80106204 <alltraps>

80106a5a <vector36>:
.globl vector36
vector36:
  pushl $0
80106a5a:	6a 00                	push   $0x0
  pushl $36
80106a5c:	6a 24                	push   $0x24
  jmp alltraps
80106a5e:	e9 a1 f7 ff ff       	jmp    80106204 <alltraps>

80106a63 <vector37>:
.globl vector37
vector37:
  pushl $0
80106a63:	6a 00                	push   $0x0
  pushl $37
80106a65:	6a 25                	push   $0x25
  jmp alltraps
80106a67:	e9 98 f7 ff ff       	jmp    80106204 <alltraps>

80106a6c <vector38>:
.globl vector38
vector38:
  pushl $0
80106a6c:	6a 00                	push   $0x0
  pushl $38
80106a6e:	6a 26                	push   $0x26
  jmp alltraps
80106a70:	e9 8f f7 ff ff       	jmp    80106204 <alltraps>

80106a75 <vector39>:
.globl vector39
vector39:
  pushl $0
80106a75:	6a 00                	push   $0x0
  pushl $39
80106a77:	6a 27                	push   $0x27
  jmp alltraps
80106a79:	e9 86 f7 ff ff       	jmp    80106204 <alltraps>

80106a7e <vector40>:
.globl vector40
vector40:
  pushl $0
80106a7e:	6a 00                	push   $0x0
  pushl $40
80106a80:	6a 28                	push   $0x28
  jmp alltraps
80106a82:	e9 7d f7 ff ff       	jmp    80106204 <alltraps>

80106a87 <vector41>:
.globl vector41
vector41:
  pushl $0
80106a87:	6a 00                	push   $0x0
  pushl $41
80106a89:	6a 29                	push   $0x29
  jmp alltraps
80106a8b:	e9 74 f7 ff ff       	jmp    80106204 <alltraps>

80106a90 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a90:	6a 00                	push   $0x0
  pushl $42
80106a92:	6a 2a                	push   $0x2a
  jmp alltraps
80106a94:	e9 6b f7 ff ff       	jmp    80106204 <alltraps>

80106a99 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a99:	6a 00                	push   $0x0
  pushl $43
80106a9b:	6a 2b                	push   $0x2b
  jmp alltraps
80106a9d:	e9 62 f7 ff ff       	jmp    80106204 <alltraps>

80106aa2 <vector44>:
.globl vector44
vector44:
  pushl $0
80106aa2:	6a 00                	push   $0x0
  pushl $44
80106aa4:	6a 2c                	push   $0x2c
  jmp alltraps
80106aa6:	e9 59 f7 ff ff       	jmp    80106204 <alltraps>

80106aab <vector45>:
.globl vector45
vector45:
  pushl $0
80106aab:	6a 00                	push   $0x0
  pushl $45
80106aad:	6a 2d                	push   $0x2d
  jmp alltraps
80106aaf:	e9 50 f7 ff ff       	jmp    80106204 <alltraps>

80106ab4 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ab4:	6a 00                	push   $0x0
  pushl $46
80106ab6:	6a 2e                	push   $0x2e
  jmp alltraps
80106ab8:	e9 47 f7 ff ff       	jmp    80106204 <alltraps>

80106abd <vector47>:
.globl vector47
vector47:
  pushl $0
80106abd:	6a 00                	push   $0x0
  pushl $47
80106abf:	6a 2f                	push   $0x2f
  jmp alltraps
80106ac1:	e9 3e f7 ff ff       	jmp    80106204 <alltraps>

80106ac6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ac6:	6a 00                	push   $0x0
  pushl $48
80106ac8:	6a 30                	push   $0x30
  jmp alltraps
80106aca:	e9 35 f7 ff ff       	jmp    80106204 <alltraps>

80106acf <vector49>:
.globl vector49
vector49:
  pushl $0
80106acf:	6a 00                	push   $0x0
  pushl $49
80106ad1:	6a 31                	push   $0x31
  jmp alltraps
80106ad3:	e9 2c f7 ff ff       	jmp    80106204 <alltraps>

80106ad8 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ad8:	6a 00                	push   $0x0
  pushl $50
80106ada:	6a 32                	push   $0x32
  jmp alltraps
80106adc:	e9 23 f7 ff ff       	jmp    80106204 <alltraps>

80106ae1 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ae1:	6a 00                	push   $0x0
  pushl $51
80106ae3:	6a 33                	push   $0x33
  jmp alltraps
80106ae5:	e9 1a f7 ff ff       	jmp    80106204 <alltraps>

80106aea <vector52>:
.globl vector52
vector52:
  pushl $0
80106aea:	6a 00                	push   $0x0
  pushl $52
80106aec:	6a 34                	push   $0x34
  jmp alltraps
80106aee:	e9 11 f7 ff ff       	jmp    80106204 <alltraps>

80106af3 <vector53>:
.globl vector53
vector53:
  pushl $0
80106af3:	6a 00                	push   $0x0
  pushl $53
80106af5:	6a 35                	push   $0x35
  jmp alltraps
80106af7:	e9 08 f7 ff ff       	jmp    80106204 <alltraps>

80106afc <vector54>:
.globl vector54
vector54:
  pushl $0
80106afc:	6a 00                	push   $0x0
  pushl $54
80106afe:	6a 36                	push   $0x36
  jmp alltraps
80106b00:	e9 ff f6 ff ff       	jmp    80106204 <alltraps>

80106b05 <vector55>:
.globl vector55
vector55:
  pushl $0
80106b05:	6a 00                	push   $0x0
  pushl $55
80106b07:	6a 37                	push   $0x37
  jmp alltraps
80106b09:	e9 f6 f6 ff ff       	jmp    80106204 <alltraps>

80106b0e <vector56>:
.globl vector56
vector56:
  pushl $0
80106b0e:	6a 00                	push   $0x0
  pushl $56
80106b10:	6a 38                	push   $0x38
  jmp alltraps
80106b12:	e9 ed f6 ff ff       	jmp    80106204 <alltraps>

80106b17 <vector57>:
.globl vector57
vector57:
  pushl $0
80106b17:	6a 00                	push   $0x0
  pushl $57
80106b19:	6a 39                	push   $0x39
  jmp alltraps
80106b1b:	e9 e4 f6 ff ff       	jmp    80106204 <alltraps>

80106b20 <vector58>:
.globl vector58
vector58:
  pushl $0
80106b20:	6a 00                	push   $0x0
  pushl $58
80106b22:	6a 3a                	push   $0x3a
  jmp alltraps
80106b24:	e9 db f6 ff ff       	jmp    80106204 <alltraps>

80106b29 <vector59>:
.globl vector59
vector59:
  pushl $0
80106b29:	6a 00                	push   $0x0
  pushl $59
80106b2b:	6a 3b                	push   $0x3b
  jmp alltraps
80106b2d:	e9 d2 f6 ff ff       	jmp    80106204 <alltraps>

80106b32 <vector60>:
.globl vector60
vector60:
  pushl $0
80106b32:	6a 00                	push   $0x0
  pushl $60
80106b34:	6a 3c                	push   $0x3c
  jmp alltraps
80106b36:	e9 c9 f6 ff ff       	jmp    80106204 <alltraps>

80106b3b <vector61>:
.globl vector61
vector61:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $61
80106b3d:	6a 3d                	push   $0x3d
  jmp alltraps
80106b3f:	e9 c0 f6 ff ff       	jmp    80106204 <alltraps>

80106b44 <vector62>:
.globl vector62
vector62:
  pushl $0
80106b44:	6a 00                	push   $0x0
  pushl $62
80106b46:	6a 3e                	push   $0x3e
  jmp alltraps
80106b48:	e9 b7 f6 ff ff       	jmp    80106204 <alltraps>

80106b4d <vector63>:
.globl vector63
vector63:
  pushl $0
80106b4d:	6a 00                	push   $0x0
  pushl $63
80106b4f:	6a 3f                	push   $0x3f
  jmp alltraps
80106b51:	e9 ae f6 ff ff       	jmp    80106204 <alltraps>

80106b56 <vector64>:
.globl vector64
vector64:
  pushl $0
80106b56:	6a 00                	push   $0x0
  pushl $64
80106b58:	6a 40                	push   $0x40
  jmp alltraps
80106b5a:	e9 a5 f6 ff ff       	jmp    80106204 <alltraps>

80106b5f <vector65>:
.globl vector65
vector65:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $65
80106b61:	6a 41                	push   $0x41
  jmp alltraps
80106b63:	e9 9c f6 ff ff       	jmp    80106204 <alltraps>

80106b68 <vector66>:
.globl vector66
vector66:
  pushl $0
80106b68:	6a 00                	push   $0x0
  pushl $66
80106b6a:	6a 42                	push   $0x42
  jmp alltraps
80106b6c:	e9 93 f6 ff ff       	jmp    80106204 <alltraps>

80106b71 <vector67>:
.globl vector67
vector67:
  pushl $0
80106b71:	6a 00                	push   $0x0
  pushl $67
80106b73:	6a 43                	push   $0x43
  jmp alltraps
80106b75:	e9 8a f6 ff ff       	jmp    80106204 <alltraps>

80106b7a <vector68>:
.globl vector68
vector68:
  pushl $0
80106b7a:	6a 00                	push   $0x0
  pushl $68
80106b7c:	6a 44                	push   $0x44
  jmp alltraps
80106b7e:	e9 81 f6 ff ff       	jmp    80106204 <alltraps>

80106b83 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b83:	6a 00                	push   $0x0
  pushl $69
80106b85:	6a 45                	push   $0x45
  jmp alltraps
80106b87:	e9 78 f6 ff ff       	jmp    80106204 <alltraps>

80106b8c <vector70>:
.globl vector70
vector70:
  pushl $0
80106b8c:	6a 00                	push   $0x0
  pushl $70
80106b8e:	6a 46                	push   $0x46
  jmp alltraps
80106b90:	e9 6f f6 ff ff       	jmp    80106204 <alltraps>

80106b95 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b95:	6a 00                	push   $0x0
  pushl $71
80106b97:	6a 47                	push   $0x47
  jmp alltraps
80106b99:	e9 66 f6 ff ff       	jmp    80106204 <alltraps>

80106b9e <vector72>:
.globl vector72
vector72:
  pushl $0
80106b9e:	6a 00                	push   $0x0
  pushl $72
80106ba0:	6a 48                	push   $0x48
  jmp alltraps
80106ba2:	e9 5d f6 ff ff       	jmp    80106204 <alltraps>

80106ba7 <vector73>:
.globl vector73
vector73:
  pushl $0
80106ba7:	6a 00                	push   $0x0
  pushl $73
80106ba9:	6a 49                	push   $0x49
  jmp alltraps
80106bab:	e9 54 f6 ff ff       	jmp    80106204 <alltraps>

80106bb0 <vector74>:
.globl vector74
vector74:
  pushl $0
80106bb0:	6a 00                	push   $0x0
  pushl $74
80106bb2:	6a 4a                	push   $0x4a
  jmp alltraps
80106bb4:	e9 4b f6 ff ff       	jmp    80106204 <alltraps>

80106bb9 <vector75>:
.globl vector75
vector75:
  pushl $0
80106bb9:	6a 00                	push   $0x0
  pushl $75
80106bbb:	6a 4b                	push   $0x4b
  jmp alltraps
80106bbd:	e9 42 f6 ff ff       	jmp    80106204 <alltraps>

80106bc2 <vector76>:
.globl vector76
vector76:
  pushl $0
80106bc2:	6a 00                	push   $0x0
  pushl $76
80106bc4:	6a 4c                	push   $0x4c
  jmp alltraps
80106bc6:	e9 39 f6 ff ff       	jmp    80106204 <alltraps>

80106bcb <vector77>:
.globl vector77
vector77:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $77
80106bcd:	6a 4d                	push   $0x4d
  jmp alltraps
80106bcf:	e9 30 f6 ff ff       	jmp    80106204 <alltraps>

80106bd4 <vector78>:
.globl vector78
vector78:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $78
80106bd6:	6a 4e                	push   $0x4e
  jmp alltraps
80106bd8:	e9 27 f6 ff ff       	jmp    80106204 <alltraps>

80106bdd <vector79>:
.globl vector79
vector79:
  pushl $0
80106bdd:	6a 00                	push   $0x0
  pushl $79
80106bdf:	6a 4f                	push   $0x4f
  jmp alltraps
80106be1:	e9 1e f6 ff ff       	jmp    80106204 <alltraps>

80106be6 <vector80>:
.globl vector80
vector80:
  pushl $0
80106be6:	6a 00                	push   $0x0
  pushl $80
80106be8:	6a 50                	push   $0x50
  jmp alltraps
80106bea:	e9 15 f6 ff ff       	jmp    80106204 <alltraps>

80106bef <vector81>:
.globl vector81
vector81:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $81
80106bf1:	6a 51                	push   $0x51
  jmp alltraps
80106bf3:	e9 0c f6 ff ff       	jmp    80106204 <alltraps>

80106bf8 <vector82>:
.globl vector82
vector82:
  pushl $0
80106bf8:	6a 00                	push   $0x0
  pushl $82
80106bfa:	6a 52                	push   $0x52
  jmp alltraps
80106bfc:	e9 03 f6 ff ff       	jmp    80106204 <alltraps>

80106c01 <vector83>:
.globl vector83
vector83:
  pushl $0
80106c01:	6a 00                	push   $0x0
  pushl $83
80106c03:	6a 53                	push   $0x53
  jmp alltraps
80106c05:	e9 fa f5 ff ff       	jmp    80106204 <alltraps>

80106c0a <vector84>:
.globl vector84
vector84:
  pushl $0
80106c0a:	6a 00                	push   $0x0
  pushl $84
80106c0c:	6a 54                	push   $0x54
  jmp alltraps
80106c0e:	e9 f1 f5 ff ff       	jmp    80106204 <alltraps>

80106c13 <vector85>:
.globl vector85
vector85:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $85
80106c15:	6a 55                	push   $0x55
  jmp alltraps
80106c17:	e9 e8 f5 ff ff       	jmp    80106204 <alltraps>

80106c1c <vector86>:
.globl vector86
vector86:
  pushl $0
80106c1c:	6a 00                	push   $0x0
  pushl $86
80106c1e:	6a 56                	push   $0x56
  jmp alltraps
80106c20:	e9 df f5 ff ff       	jmp    80106204 <alltraps>

80106c25 <vector87>:
.globl vector87
vector87:
  pushl $0
80106c25:	6a 00                	push   $0x0
  pushl $87
80106c27:	6a 57                	push   $0x57
  jmp alltraps
80106c29:	e9 d6 f5 ff ff       	jmp    80106204 <alltraps>

80106c2e <vector88>:
.globl vector88
vector88:
  pushl $0
80106c2e:	6a 00                	push   $0x0
  pushl $88
80106c30:	6a 58                	push   $0x58
  jmp alltraps
80106c32:	e9 cd f5 ff ff       	jmp    80106204 <alltraps>

80106c37 <vector89>:
.globl vector89
vector89:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $89
80106c39:	6a 59                	push   $0x59
  jmp alltraps
80106c3b:	e9 c4 f5 ff ff       	jmp    80106204 <alltraps>

80106c40 <vector90>:
.globl vector90
vector90:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $90
80106c42:	6a 5a                	push   $0x5a
  jmp alltraps
80106c44:	e9 bb f5 ff ff       	jmp    80106204 <alltraps>

80106c49 <vector91>:
.globl vector91
vector91:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $91
80106c4b:	6a 5b                	push   $0x5b
  jmp alltraps
80106c4d:	e9 b2 f5 ff ff       	jmp    80106204 <alltraps>

80106c52 <vector92>:
.globl vector92
vector92:
  pushl $0
80106c52:	6a 00                	push   $0x0
  pushl $92
80106c54:	6a 5c                	push   $0x5c
  jmp alltraps
80106c56:	e9 a9 f5 ff ff       	jmp    80106204 <alltraps>

80106c5b <vector93>:
.globl vector93
vector93:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $93
80106c5d:	6a 5d                	push   $0x5d
  jmp alltraps
80106c5f:	e9 a0 f5 ff ff       	jmp    80106204 <alltraps>

80106c64 <vector94>:
.globl vector94
vector94:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $94
80106c66:	6a 5e                	push   $0x5e
  jmp alltraps
80106c68:	e9 97 f5 ff ff       	jmp    80106204 <alltraps>

80106c6d <vector95>:
.globl vector95
vector95:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $95
80106c6f:	6a 5f                	push   $0x5f
  jmp alltraps
80106c71:	e9 8e f5 ff ff       	jmp    80106204 <alltraps>

80106c76 <vector96>:
.globl vector96
vector96:
  pushl $0
80106c76:	6a 00                	push   $0x0
  pushl $96
80106c78:	6a 60                	push   $0x60
  jmp alltraps
80106c7a:	e9 85 f5 ff ff       	jmp    80106204 <alltraps>

80106c7f <vector97>:
.globl vector97
vector97:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $97
80106c81:	6a 61                	push   $0x61
  jmp alltraps
80106c83:	e9 7c f5 ff ff       	jmp    80106204 <alltraps>

80106c88 <vector98>:
.globl vector98
vector98:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $98
80106c8a:	6a 62                	push   $0x62
  jmp alltraps
80106c8c:	e9 73 f5 ff ff       	jmp    80106204 <alltraps>

80106c91 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $99
80106c93:	6a 63                	push   $0x63
  jmp alltraps
80106c95:	e9 6a f5 ff ff       	jmp    80106204 <alltraps>

80106c9a <vector100>:
.globl vector100
vector100:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $100
80106c9c:	6a 64                	push   $0x64
  jmp alltraps
80106c9e:	e9 61 f5 ff ff       	jmp    80106204 <alltraps>

80106ca3 <vector101>:
.globl vector101
vector101:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $101
80106ca5:	6a 65                	push   $0x65
  jmp alltraps
80106ca7:	e9 58 f5 ff ff       	jmp    80106204 <alltraps>

80106cac <vector102>:
.globl vector102
vector102:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $102
80106cae:	6a 66                	push   $0x66
  jmp alltraps
80106cb0:	e9 4f f5 ff ff       	jmp    80106204 <alltraps>

80106cb5 <vector103>:
.globl vector103
vector103:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $103
80106cb7:	6a 67                	push   $0x67
  jmp alltraps
80106cb9:	e9 46 f5 ff ff       	jmp    80106204 <alltraps>

80106cbe <vector104>:
.globl vector104
vector104:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $104
80106cc0:	6a 68                	push   $0x68
  jmp alltraps
80106cc2:	e9 3d f5 ff ff       	jmp    80106204 <alltraps>

80106cc7 <vector105>:
.globl vector105
vector105:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $105
80106cc9:	6a 69                	push   $0x69
  jmp alltraps
80106ccb:	e9 34 f5 ff ff       	jmp    80106204 <alltraps>

80106cd0 <vector106>:
.globl vector106
vector106:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $106
80106cd2:	6a 6a                	push   $0x6a
  jmp alltraps
80106cd4:	e9 2b f5 ff ff       	jmp    80106204 <alltraps>

80106cd9 <vector107>:
.globl vector107
vector107:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $107
80106cdb:	6a 6b                	push   $0x6b
  jmp alltraps
80106cdd:	e9 22 f5 ff ff       	jmp    80106204 <alltraps>

80106ce2 <vector108>:
.globl vector108
vector108:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $108
80106ce4:	6a 6c                	push   $0x6c
  jmp alltraps
80106ce6:	e9 19 f5 ff ff       	jmp    80106204 <alltraps>

80106ceb <vector109>:
.globl vector109
vector109:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $109
80106ced:	6a 6d                	push   $0x6d
  jmp alltraps
80106cef:	e9 10 f5 ff ff       	jmp    80106204 <alltraps>

80106cf4 <vector110>:
.globl vector110
vector110:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $110
80106cf6:	6a 6e                	push   $0x6e
  jmp alltraps
80106cf8:	e9 07 f5 ff ff       	jmp    80106204 <alltraps>

80106cfd <vector111>:
.globl vector111
vector111:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $111
80106cff:	6a 6f                	push   $0x6f
  jmp alltraps
80106d01:	e9 fe f4 ff ff       	jmp    80106204 <alltraps>

80106d06 <vector112>:
.globl vector112
vector112:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $112
80106d08:	6a 70                	push   $0x70
  jmp alltraps
80106d0a:	e9 f5 f4 ff ff       	jmp    80106204 <alltraps>

80106d0f <vector113>:
.globl vector113
vector113:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $113
80106d11:	6a 71                	push   $0x71
  jmp alltraps
80106d13:	e9 ec f4 ff ff       	jmp    80106204 <alltraps>

80106d18 <vector114>:
.globl vector114
vector114:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $114
80106d1a:	6a 72                	push   $0x72
  jmp alltraps
80106d1c:	e9 e3 f4 ff ff       	jmp    80106204 <alltraps>

80106d21 <vector115>:
.globl vector115
vector115:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $115
80106d23:	6a 73                	push   $0x73
  jmp alltraps
80106d25:	e9 da f4 ff ff       	jmp    80106204 <alltraps>

80106d2a <vector116>:
.globl vector116
vector116:
  pushl $0
80106d2a:	6a 00                	push   $0x0
  pushl $116
80106d2c:	6a 74                	push   $0x74
  jmp alltraps
80106d2e:	e9 d1 f4 ff ff       	jmp    80106204 <alltraps>

80106d33 <vector117>:
.globl vector117
vector117:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $117
80106d35:	6a 75                	push   $0x75
  jmp alltraps
80106d37:	e9 c8 f4 ff ff       	jmp    80106204 <alltraps>

80106d3c <vector118>:
.globl vector118
vector118:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $118
80106d3e:	6a 76                	push   $0x76
  jmp alltraps
80106d40:	e9 bf f4 ff ff       	jmp    80106204 <alltraps>

80106d45 <vector119>:
.globl vector119
vector119:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $119
80106d47:	6a 77                	push   $0x77
  jmp alltraps
80106d49:	e9 b6 f4 ff ff       	jmp    80106204 <alltraps>

80106d4e <vector120>:
.globl vector120
vector120:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $120
80106d50:	6a 78                	push   $0x78
  jmp alltraps
80106d52:	e9 ad f4 ff ff       	jmp    80106204 <alltraps>

80106d57 <vector121>:
.globl vector121
vector121:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $121
80106d59:	6a 79                	push   $0x79
  jmp alltraps
80106d5b:	e9 a4 f4 ff ff       	jmp    80106204 <alltraps>

80106d60 <vector122>:
.globl vector122
vector122:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $122
80106d62:	6a 7a                	push   $0x7a
  jmp alltraps
80106d64:	e9 9b f4 ff ff       	jmp    80106204 <alltraps>

80106d69 <vector123>:
.globl vector123
vector123:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $123
80106d6b:	6a 7b                	push   $0x7b
  jmp alltraps
80106d6d:	e9 92 f4 ff ff       	jmp    80106204 <alltraps>

80106d72 <vector124>:
.globl vector124
vector124:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $124
80106d74:	6a 7c                	push   $0x7c
  jmp alltraps
80106d76:	e9 89 f4 ff ff       	jmp    80106204 <alltraps>

80106d7b <vector125>:
.globl vector125
vector125:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $125
80106d7d:	6a 7d                	push   $0x7d
  jmp alltraps
80106d7f:	e9 80 f4 ff ff       	jmp    80106204 <alltraps>

80106d84 <vector126>:
.globl vector126
vector126:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $126
80106d86:	6a 7e                	push   $0x7e
  jmp alltraps
80106d88:	e9 77 f4 ff ff       	jmp    80106204 <alltraps>

80106d8d <vector127>:
.globl vector127
vector127:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $127
80106d8f:	6a 7f                	push   $0x7f
  jmp alltraps
80106d91:	e9 6e f4 ff ff       	jmp    80106204 <alltraps>

80106d96 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d96:	6a 00                	push   $0x0
  pushl $128
80106d98:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d9d:	e9 62 f4 ff ff       	jmp    80106204 <alltraps>

80106da2 <vector129>:
.globl vector129
vector129:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $129
80106da4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106da9:	e9 56 f4 ff ff       	jmp    80106204 <alltraps>

80106dae <vector130>:
.globl vector130
vector130:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $130
80106db0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106db5:	e9 4a f4 ff ff       	jmp    80106204 <alltraps>

80106dba <vector131>:
.globl vector131
vector131:
  pushl $0
80106dba:	6a 00                	push   $0x0
  pushl $131
80106dbc:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106dc1:	e9 3e f4 ff ff       	jmp    80106204 <alltraps>

80106dc6 <vector132>:
.globl vector132
vector132:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $132
80106dc8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106dcd:	e9 32 f4 ff ff       	jmp    80106204 <alltraps>

80106dd2 <vector133>:
.globl vector133
vector133:
  pushl $0
80106dd2:	6a 00                	push   $0x0
  pushl $133
80106dd4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106dd9:	e9 26 f4 ff ff       	jmp    80106204 <alltraps>

80106dde <vector134>:
.globl vector134
vector134:
  pushl $0
80106dde:	6a 00                	push   $0x0
  pushl $134
80106de0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106de5:	e9 1a f4 ff ff       	jmp    80106204 <alltraps>

80106dea <vector135>:
.globl vector135
vector135:
  pushl $0
80106dea:	6a 00                	push   $0x0
  pushl $135
80106dec:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106df1:	e9 0e f4 ff ff       	jmp    80106204 <alltraps>

80106df6 <vector136>:
.globl vector136
vector136:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $136
80106df8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106dfd:	e9 02 f4 ff ff       	jmp    80106204 <alltraps>

80106e02 <vector137>:
.globl vector137
vector137:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $137
80106e04:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106e09:	e9 f6 f3 ff ff       	jmp    80106204 <alltraps>

80106e0e <vector138>:
.globl vector138
vector138:
  pushl $0
80106e0e:	6a 00                	push   $0x0
  pushl $138
80106e10:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106e15:	e9 ea f3 ff ff       	jmp    80106204 <alltraps>

80106e1a <vector139>:
.globl vector139
vector139:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $139
80106e1c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106e21:	e9 de f3 ff ff       	jmp    80106204 <alltraps>

80106e26 <vector140>:
.globl vector140
vector140:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $140
80106e28:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106e2d:	e9 d2 f3 ff ff       	jmp    80106204 <alltraps>

80106e32 <vector141>:
.globl vector141
vector141:
  pushl $0
80106e32:	6a 00                	push   $0x0
  pushl $141
80106e34:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106e39:	e9 c6 f3 ff ff       	jmp    80106204 <alltraps>

80106e3e <vector142>:
.globl vector142
vector142:
  pushl $0
80106e3e:	6a 00                	push   $0x0
  pushl $142
80106e40:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106e45:	e9 ba f3 ff ff       	jmp    80106204 <alltraps>

80106e4a <vector143>:
.globl vector143
vector143:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $143
80106e4c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106e51:	e9 ae f3 ff ff       	jmp    80106204 <alltraps>

80106e56 <vector144>:
.globl vector144
vector144:
  pushl $0
80106e56:	6a 00                	push   $0x0
  pushl $144
80106e58:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106e5d:	e9 a2 f3 ff ff       	jmp    80106204 <alltraps>

80106e62 <vector145>:
.globl vector145
vector145:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $145
80106e64:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e69:	e9 96 f3 ff ff       	jmp    80106204 <alltraps>

80106e6e <vector146>:
.globl vector146
vector146:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $146
80106e70:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e75:	e9 8a f3 ff ff       	jmp    80106204 <alltraps>

80106e7a <vector147>:
.globl vector147
vector147:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $147
80106e7c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e81:	e9 7e f3 ff ff       	jmp    80106204 <alltraps>

80106e86 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $148
80106e88:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e8d:	e9 72 f3 ff ff       	jmp    80106204 <alltraps>

80106e92 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $149
80106e94:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e99:	e9 66 f3 ff ff       	jmp    80106204 <alltraps>

80106e9e <vector150>:
.globl vector150
vector150:
  pushl $0
80106e9e:	6a 00                	push   $0x0
  pushl $150
80106ea0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106ea5:	e9 5a f3 ff ff       	jmp    80106204 <alltraps>

80106eaa <vector151>:
.globl vector151
vector151:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $151
80106eac:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106eb1:	e9 4e f3 ff ff       	jmp    80106204 <alltraps>

80106eb6 <vector152>:
.globl vector152
vector152:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $152
80106eb8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106ebd:	e9 42 f3 ff ff       	jmp    80106204 <alltraps>

80106ec2 <vector153>:
.globl vector153
vector153:
  pushl $0
80106ec2:	6a 00                	push   $0x0
  pushl $153
80106ec4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106ec9:	e9 36 f3 ff ff       	jmp    80106204 <alltraps>

80106ece <vector154>:
.globl vector154
vector154:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $154
80106ed0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106ed5:	e9 2a f3 ff ff       	jmp    80106204 <alltraps>

80106eda <vector155>:
.globl vector155
vector155:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $155
80106edc:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106ee1:	e9 1e f3 ff ff       	jmp    80106204 <alltraps>

80106ee6 <vector156>:
.globl vector156
vector156:
  pushl $0
80106ee6:	6a 00                	push   $0x0
  pushl $156
80106ee8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106eed:	e9 12 f3 ff ff       	jmp    80106204 <alltraps>

80106ef2 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $157
80106ef4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106ef9:	e9 06 f3 ff ff       	jmp    80106204 <alltraps>

80106efe <vector158>:
.globl vector158
vector158:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $158
80106f00:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106f05:	e9 fa f2 ff ff       	jmp    80106204 <alltraps>

80106f0a <vector159>:
.globl vector159
vector159:
  pushl $0
80106f0a:	6a 00                	push   $0x0
  pushl $159
80106f0c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106f11:	e9 ee f2 ff ff       	jmp    80106204 <alltraps>

80106f16 <vector160>:
.globl vector160
vector160:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $160
80106f18:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106f1d:	e9 e2 f2 ff ff       	jmp    80106204 <alltraps>

80106f22 <vector161>:
.globl vector161
vector161:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $161
80106f24:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106f29:	e9 d6 f2 ff ff       	jmp    80106204 <alltraps>

80106f2e <vector162>:
.globl vector162
vector162:
  pushl $0
80106f2e:	6a 00                	push   $0x0
  pushl $162
80106f30:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106f35:	e9 ca f2 ff ff       	jmp    80106204 <alltraps>

80106f3a <vector163>:
.globl vector163
vector163:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $163
80106f3c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106f41:	e9 be f2 ff ff       	jmp    80106204 <alltraps>

80106f46 <vector164>:
.globl vector164
vector164:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $164
80106f48:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106f4d:	e9 b2 f2 ff ff       	jmp    80106204 <alltraps>

80106f52 <vector165>:
.globl vector165
vector165:
  pushl $0
80106f52:	6a 00                	push   $0x0
  pushl $165
80106f54:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106f59:	e9 a6 f2 ff ff       	jmp    80106204 <alltraps>

80106f5e <vector166>:
.globl vector166
vector166:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $166
80106f60:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f65:	e9 9a f2 ff ff       	jmp    80106204 <alltraps>

80106f6a <vector167>:
.globl vector167
vector167:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $167
80106f6c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f71:	e9 8e f2 ff ff       	jmp    80106204 <alltraps>

80106f76 <vector168>:
.globl vector168
vector168:
  pushl $0
80106f76:	6a 00                	push   $0x0
  pushl $168
80106f78:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f7d:	e9 82 f2 ff ff       	jmp    80106204 <alltraps>

80106f82 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $169
80106f84:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f89:	e9 76 f2 ff ff       	jmp    80106204 <alltraps>

80106f8e <vector170>:
.globl vector170
vector170:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $170
80106f90:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f95:	e9 6a f2 ff ff       	jmp    80106204 <alltraps>

80106f9a <vector171>:
.globl vector171
vector171:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $171
80106f9c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106fa1:	e9 5e f2 ff ff       	jmp    80106204 <alltraps>

80106fa6 <vector172>:
.globl vector172
vector172:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $172
80106fa8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106fad:	e9 52 f2 ff ff       	jmp    80106204 <alltraps>

80106fb2 <vector173>:
.globl vector173
vector173:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $173
80106fb4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106fb9:	e9 46 f2 ff ff       	jmp    80106204 <alltraps>

80106fbe <vector174>:
.globl vector174
vector174:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $174
80106fc0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106fc5:	e9 3a f2 ff ff       	jmp    80106204 <alltraps>

80106fca <vector175>:
.globl vector175
vector175:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $175
80106fcc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106fd1:	e9 2e f2 ff ff       	jmp    80106204 <alltraps>

80106fd6 <vector176>:
.globl vector176
vector176:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $176
80106fd8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106fdd:	e9 22 f2 ff ff       	jmp    80106204 <alltraps>

80106fe2 <vector177>:
.globl vector177
vector177:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $177
80106fe4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106fe9:	e9 16 f2 ff ff       	jmp    80106204 <alltraps>

80106fee <vector178>:
.globl vector178
vector178:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $178
80106ff0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106ff5:	e9 0a f2 ff ff       	jmp    80106204 <alltraps>

80106ffa <vector179>:
.globl vector179
vector179:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $179
80106ffc:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107001:	e9 fe f1 ff ff       	jmp    80106204 <alltraps>

80107006 <vector180>:
.globl vector180
vector180:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $180
80107008:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010700d:	e9 f2 f1 ff ff       	jmp    80106204 <alltraps>

80107012 <vector181>:
.globl vector181
vector181:
  pushl $0
80107012:	6a 00                	push   $0x0
  pushl $181
80107014:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107019:	e9 e6 f1 ff ff       	jmp    80106204 <alltraps>

8010701e <vector182>:
.globl vector182
vector182:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $182
80107020:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107025:	e9 da f1 ff ff       	jmp    80106204 <alltraps>

8010702a <vector183>:
.globl vector183
vector183:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $183
8010702c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107031:	e9 ce f1 ff ff       	jmp    80106204 <alltraps>

80107036 <vector184>:
.globl vector184
vector184:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $184
80107038:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010703d:	e9 c2 f1 ff ff       	jmp    80106204 <alltraps>

80107042 <vector185>:
.globl vector185
vector185:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $185
80107044:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107049:	e9 b6 f1 ff ff       	jmp    80106204 <alltraps>

8010704e <vector186>:
.globl vector186
vector186:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $186
80107050:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107055:	e9 aa f1 ff ff       	jmp    80106204 <alltraps>

8010705a <vector187>:
.globl vector187
vector187:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $187
8010705c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107061:	e9 9e f1 ff ff       	jmp    80106204 <alltraps>

80107066 <vector188>:
.globl vector188
vector188:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $188
80107068:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010706d:	e9 92 f1 ff ff       	jmp    80106204 <alltraps>

80107072 <vector189>:
.globl vector189
vector189:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $189
80107074:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107079:	e9 86 f1 ff ff       	jmp    80106204 <alltraps>

8010707e <vector190>:
.globl vector190
vector190:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $190
80107080:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107085:	e9 7a f1 ff ff       	jmp    80106204 <alltraps>

8010708a <vector191>:
.globl vector191
vector191:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $191
8010708c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107091:	e9 6e f1 ff ff       	jmp    80106204 <alltraps>

80107096 <vector192>:
.globl vector192
vector192:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $192
80107098:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010709d:	e9 62 f1 ff ff       	jmp    80106204 <alltraps>

801070a2 <vector193>:
.globl vector193
vector193:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $193
801070a4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801070a9:	e9 56 f1 ff ff       	jmp    80106204 <alltraps>

801070ae <vector194>:
.globl vector194
vector194:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $194
801070b0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801070b5:	e9 4a f1 ff ff       	jmp    80106204 <alltraps>

801070ba <vector195>:
.globl vector195
vector195:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $195
801070bc:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801070c1:	e9 3e f1 ff ff       	jmp    80106204 <alltraps>

801070c6 <vector196>:
.globl vector196
vector196:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $196
801070c8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801070cd:	e9 32 f1 ff ff       	jmp    80106204 <alltraps>

801070d2 <vector197>:
.globl vector197
vector197:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $197
801070d4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801070d9:	e9 26 f1 ff ff       	jmp    80106204 <alltraps>

801070de <vector198>:
.globl vector198
vector198:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $198
801070e0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801070e5:	e9 1a f1 ff ff       	jmp    80106204 <alltraps>

801070ea <vector199>:
.globl vector199
vector199:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $199
801070ec:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801070f1:	e9 0e f1 ff ff       	jmp    80106204 <alltraps>

801070f6 <vector200>:
.globl vector200
vector200:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $200
801070f8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801070fd:	e9 02 f1 ff ff       	jmp    80106204 <alltraps>

80107102 <vector201>:
.globl vector201
vector201:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $201
80107104:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107109:	e9 f6 f0 ff ff       	jmp    80106204 <alltraps>

8010710e <vector202>:
.globl vector202
vector202:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $202
80107110:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107115:	e9 ea f0 ff ff       	jmp    80106204 <alltraps>

8010711a <vector203>:
.globl vector203
vector203:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $203
8010711c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107121:	e9 de f0 ff ff       	jmp    80106204 <alltraps>

80107126 <vector204>:
.globl vector204
vector204:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $204
80107128:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010712d:	e9 d2 f0 ff ff       	jmp    80106204 <alltraps>

80107132 <vector205>:
.globl vector205
vector205:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $205
80107134:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107139:	e9 c6 f0 ff ff       	jmp    80106204 <alltraps>

8010713e <vector206>:
.globl vector206
vector206:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $206
80107140:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107145:	e9 ba f0 ff ff       	jmp    80106204 <alltraps>

8010714a <vector207>:
.globl vector207
vector207:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $207
8010714c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107151:	e9 ae f0 ff ff       	jmp    80106204 <alltraps>

80107156 <vector208>:
.globl vector208
vector208:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $208
80107158:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010715d:	e9 a2 f0 ff ff       	jmp    80106204 <alltraps>

80107162 <vector209>:
.globl vector209
vector209:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $209
80107164:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107169:	e9 96 f0 ff ff       	jmp    80106204 <alltraps>

8010716e <vector210>:
.globl vector210
vector210:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $210
80107170:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107175:	e9 8a f0 ff ff       	jmp    80106204 <alltraps>

8010717a <vector211>:
.globl vector211
vector211:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $211
8010717c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107181:	e9 7e f0 ff ff       	jmp    80106204 <alltraps>

80107186 <vector212>:
.globl vector212
vector212:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $212
80107188:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010718d:	e9 72 f0 ff ff       	jmp    80106204 <alltraps>

80107192 <vector213>:
.globl vector213
vector213:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $213
80107194:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107199:	e9 66 f0 ff ff       	jmp    80106204 <alltraps>

8010719e <vector214>:
.globl vector214
vector214:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $214
801071a0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801071a5:	e9 5a f0 ff ff       	jmp    80106204 <alltraps>

801071aa <vector215>:
.globl vector215
vector215:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $215
801071ac:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801071b1:	e9 4e f0 ff ff       	jmp    80106204 <alltraps>

801071b6 <vector216>:
.globl vector216
vector216:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $216
801071b8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801071bd:	e9 42 f0 ff ff       	jmp    80106204 <alltraps>

801071c2 <vector217>:
.globl vector217
vector217:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $217
801071c4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801071c9:	e9 36 f0 ff ff       	jmp    80106204 <alltraps>

801071ce <vector218>:
.globl vector218
vector218:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $218
801071d0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801071d5:	e9 2a f0 ff ff       	jmp    80106204 <alltraps>

801071da <vector219>:
.globl vector219
vector219:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $219
801071dc:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801071e1:	e9 1e f0 ff ff       	jmp    80106204 <alltraps>

801071e6 <vector220>:
.globl vector220
vector220:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $220
801071e8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801071ed:	e9 12 f0 ff ff       	jmp    80106204 <alltraps>

801071f2 <vector221>:
.globl vector221
vector221:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $221
801071f4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801071f9:	e9 06 f0 ff ff       	jmp    80106204 <alltraps>

801071fe <vector222>:
.globl vector222
vector222:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $222
80107200:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107205:	e9 fa ef ff ff       	jmp    80106204 <alltraps>

8010720a <vector223>:
.globl vector223
vector223:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $223
8010720c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107211:	e9 ee ef ff ff       	jmp    80106204 <alltraps>

80107216 <vector224>:
.globl vector224
vector224:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $224
80107218:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010721d:	e9 e2 ef ff ff       	jmp    80106204 <alltraps>

80107222 <vector225>:
.globl vector225
vector225:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $225
80107224:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107229:	e9 d6 ef ff ff       	jmp    80106204 <alltraps>

8010722e <vector226>:
.globl vector226
vector226:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $226
80107230:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107235:	e9 ca ef ff ff       	jmp    80106204 <alltraps>

8010723a <vector227>:
.globl vector227
vector227:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $227
8010723c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107241:	e9 be ef ff ff       	jmp    80106204 <alltraps>

80107246 <vector228>:
.globl vector228
vector228:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $228
80107248:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010724d:	e9 b2 ef ff ff       	jmp    80106204 <alltraps>

80107252 <vector229>:
.globl vector229
vector229:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $229
80107254:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107259:	e9 a6 ef ff ff       	jmp    80106204 <alltraps>

8010725e <vector230>:
.globl vector230
vector230:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $230
80107260:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107265:	e9 9a ef ff ff       	jmp    80106204 <alltraps>

8010726a <vector231>:
.globl vector231
vector231:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $231
8010726c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107271:	e9 8e ef ff ff       	jmp    80106204 <alltraps>

80107276 <vector232>:
.globl vector232
vector232:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $232
80107278:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010727d:	e9 82 ef ff ff       	jmp    80106204 <alltraps>

80107282 <vector233>:
.globl vector233
vector233:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $233
80107284:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107289:	e9 76 ef ff ff       	jmp    80106204 <alltraps>

8010728e <vector234>:
.globl vector234
vector234:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $234
80107290:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107295:	e9 6a ef ff ff       	jmp    80106204 <alltraps>

8010729a <vector235>:
.globl vector235
vector235:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $235
8010729c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801072a1:	e9 5e ef ff ff       	jmp    80106204 <alltraps>

801072a6 <vector236>:
.globl vector236
vector236:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $236
801072a8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801072ad:	e9 52 ef ff ff       	jmp    80106204 <alltraps>

801072b2 <vector237>:
.globl vector237
vector237:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $237
801072b4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801072b9:	e9 46 ef ff ff       	jmp    80106204 <alltraps>

801072be <vector238>:
.globl vector238
vector238:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $238
801072c0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801072c5:	e9 3a ef ff ff       	jmp    80106204 <alltraps>

801072ca <vector239>:
.globl vector239
vector239:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $239
801072cc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801072d1:	e9 2e ef ff ff       	jmp    80106204 <alltraps>

801072d6 <vector240>:
.globl vector240
vector240:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $240
801072d8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801072dd:	e9 22 ef ff ff       	jmp    80106204 <alltraps>

801072e2 <vector241>:
.globl vector241
vector241:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $241
801072e4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801072e9:	e9 16 ef ff ff       	jmp    80106204 <alltraps>

801072ee <vector242>:
.globl vector242
vector242:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $242
801072f0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801072f5:	e9 0a ef ff ff       	jmp    80106204 <alltraps>

801072fa <vector243>:
.globl vector243
vector243:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $243
801072fc:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107301:	e9 fe ee ff ff       	jmp    80106204 <alltraps>

80107306 <vector244>:
.globl vector244
vector244:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $244
80107308:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010730d:	e9 f2 ee ff ff       	jmp    80106204 <alltraps>

80107312 <vector245>:
.globl vector245
vector245:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $245
80107314:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107319:	e9 e6 ee ff ff       	jmp    80106204 <alltraps>

8010731e <vector246>:
.globl vector246
vector246:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $246
80107320:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107325:	e9 da ee ff ff       	jmp    80106204 <alltraps>

8010732a <vector247>:
.globl vector247
vector247:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $247
8010732c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107331:	e9 ce ee ff ff       	jmp    80106204 <alltraps>

80107336 <vector248>:
.globl vector248
vector248:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $248
80107338:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010733d:	e9 c2 ee ff ff       	jmp    80106204 <alltraps>

80107342 <vector249>:
.globl vector249
vector249:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $249
80107344:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107349:	e9 b6 ee ff ff       	jmp    80106204 <alltraps>

8010734e <vector250>:
.globl vector250
vector250:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $250
80107350:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107355:	e9 aa ee ff ff       	jmp    80106204 <alltraps>

8010735a <vector251>:
.globl vector251
vector251:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $251
8010735c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107361:	e9 9e ee ff ff       	jmp    80106204 <alltraps>

80107366 <vector252>:
.globl vector252
vector252:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $252
80107368:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010736d:	e9 92 ee ff ff       	jmp    80106204 <alltraps>

80107372 <vector253>:
.globl vector253
vector253:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $253
80107374:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107379:	e9 86 ee ff ff       	jmp    80106204 <alltraps>

8010737e <vector254>:
.globl vector254
vector254:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $254
80107380:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107385:	e9 7a ee ff ff       	jmp    80106204 <alltraps>

8010738a <vector255>:
.globl vector255
vector255:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $255
8010738c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107391:	e9 6e ee ff ff       	jmp    80106204 <alltraps>
	...

80107398 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107398:	55                   	push   %ebp
80107399:	89 e5                	mov    %esp,%ebp
8010739b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010739e:	8b 45 0c             	mov    0xc(%ebp),%eax
801073a1:	83 e8 01             	sub    $0x1,%eax
801073a4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801073a8:	8b 45 08             	mov    0x8(%ebp),%eax
801073ab:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801073af:	8b 45 08             	mov    0x8(%ebp),%eax
801073b2:	c1 e8 10             	shr    $0x10,%eax
801073b5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801073b9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801073bc:	0f 01 10             	lgdtl  (%eax)
}
801073bf:	c9                   	leave  
801073c0:	c3                   	ret    

801073c1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801073c1:	55                   	push   %ebp
801073c2:	89 e5                	mov    %esp,%ebp
801073c4:	83 ec 04             	sub    $0x4,%esp
801073c7:	8b 45 08             	mov    0x8(%ebp),%eax
801073ca:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801073ce:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801073d2:	0f 00 d8             	ltr    %ax
}
801073d5:	c9                   	leave  
801073d6:	c3                   	ret    

801073d7 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801073d7:	55                   	push   %ebp
801073d8:	89 e5                	mov    %esp,%ebp
801073da:	83 ec 04             	sub    $0x4,%esp
801073dd:	8b 45 08             	mov    0x8(%ebp),%eax
801073e0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801073e4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801073e8:	8e e8                	mov    %eax,%gs
}
801073ea:	c9                   	leave  
801073eb:	c3                   	ret    

801073ec <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801073ec:	55                   	push   %ebp
801073ed:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801073ef:	8b 45 08             	mov    0x8(%ebp),%eax
801073f2:	0f 22 d8             	mov    %eax,%cr3
}
801073f5:	5d                   	pop    %ebp
801073f6:	c3                   	ret    

801073f7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801073f7:	55                   	push   %ebp
801073f8:	89 e5                	mov    %esp,%ebp
801073fa:	8b 45 08             	mov    0x8(%ebp),%eax
801073fd:	05 00 00 00 80       	add    $0x80000000,%eax
80107402:	5d                   	pop    %ebp
80107403:	c3                   	ret    

80107404 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107404:	55                   	push   %ebp
80107405:	89 e5                	mov    %esp,%ebp
80107407:	8b 45 08             	mov    0x8(%ebp),%eax
8010740a:	05 00 00 00 80       	add    $0x80000000,%eax
8010740f:	5d                   	pop    %ebp
80107410:	c3                   	ret    

80107411 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107411:	55                   	push   %ebp
80107412:	89 e5                	mov    %esp,%ebp
80107414:	53                   	push   %ebx
80107415:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107418:	e8 68 ba ff ff       	call   80102e85 <cpunum>
8010741d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107423:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107428:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010742b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107437:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010743d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107440:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107447:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010744b:	83 e2 f0             	and    $0xfffffff0,%edx
8010744e:	83 ca 0a             	or     $0xa,%edx
80107451:	88 50 7d             	mov    %dl,0x7d(%eax)
80107454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107457:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010745b:	83 ca 10             	or     $0x10,%edx
8010745e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107464:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107468:	83 e2 9f             	and    $0xffffff9f,%edx
8010746b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010746e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107471:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107475:	83 ca 80             	or     $0xffffff80,%edx
80107478:	88 50 7d             	mov    %dl,0x7d(%eax)
8010747b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107482:	83 ca 0f             	or     $0xf,%edx
80107485:	88 50 7e             	mov    %dl,0x7e(%eax)
80107488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010748f:	83 e2 ef             	and    $0xffffffef,%edx
80107492:	88 50 7e             	mov    %dl,0x7e(%eax)
80107495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107498:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010749c:	83 e2 df             	and    $0xffffffdf,%edx
8010749f:	88 50 7e             	mov    %dl,0x7e(%eax)
801074a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074a9:	83 ca 40             	or     $0x40,%edx
801074ac:	88 50 7e             	mov    %dl,0x7e(%eax)
801074af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074b6:	83 ca 80             	or     $0xffffff80,%edx
801074b9:	88 50 7e             	mov    %dl,0x7e(%eax)
801074bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bf:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801074c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801074cd:	ff ff 
801074cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801074d9:	00 00 
801074db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074de:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801074e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074ef:	83 e2 f0             	and    $0xfffffff0,%edx
801074f2:	83 ca 02             	or     $0x2,%edx
801074f5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fe:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107505:	83 ca 10             	or     $0x10,%edx
80107508:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010750e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107511:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107518:	83 e2 9f             	and    $0xffffff9f,%edx
8010751b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107524:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010752b:	83 ca 80             	or     $0xffffff80,%edx
8010752e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107537:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010753e:	83 ca 0f             	or     $0xf,%edx
80107541:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107551:	83 e2 ef             	and    $0xffffffef,%edx
80107554:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010755a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107564:	83 e2 df             	and    $0xffffffdf,%edx
80107567:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010756d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107570:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107577:	83 ca 40             	or     $0x40,%edx
8010757a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107583:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010758a:	83 ca 80             	or     $0xffffff80,%edx
8010758d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107596:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010759d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075a7:	ff ff 
801075a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ac:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075b3:	00 00 
801075b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075c9:	83 e2 f0             	and    $0xfffffff0,%edx
801075cc:	83 ca 0a             	or     $0xa,%edx
801075cf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075df:	83 ca 10             	or     $0x10,%edx
801075e2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075eb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075f2:	83 ca 60             	or     $0x60,%edx
801075f5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fe:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107605:	83 ca 80             	or     $0xffffff80,%edx
80107608:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010760e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107611:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107618:	83 ca 0f             	or     $0xf,%edx
8010761b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107624:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010762b:	83 e2 ef             	and    $0xffffffef,%edx
8010762e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107637:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010763e:	83 e2 df             	and    $0xffffffdf,%edx
80107641:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107651:	83 ca 40             	or     $0x40,%edx
80107654:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010765a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107664:	83 ca 80             	or     $0xffffff80,%edx
80107667:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010766d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107670:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107681:	ff ff 
80107683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107686:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010768d:	00 00 
8010768f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107692:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801076a3:	83 e2 f0             	and    $0xfffffff0,%edx
801076a6:	83 ca 02             	or     $0x2,%edx
801076a9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801076af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801076b9:	83 ca 10             	or     $0x10,%edx
801076bc:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801076c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801076cc:	83 ca 60             	or     $0x60,%edx
801076cf:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801076d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801076df:	83 ca 80             	or     $0xffffff80,%edx
801076e2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076f2:	83 ca 0f             	or     $0xf,%edx
801076f5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fe:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107705:	83 e2 ef             	and    $0xffffffef,%edx
80107708:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010770e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107711:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107718:	83 e2 df             	and    $0xffffffdf,%edx
8010771b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107724:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010772b:	83 ca 40             	or     $0x40,%edx
8010772e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107737:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010773e:	83 ca 80             	or     $0xffffff80,%edx
80107741:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107754:	05 b4 00 00 00       	add    $0xb4,%eax
80107759:	89 c3                	mov    %eax,%ebx
8010775b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775e:	05 b4 00 00 00       	add    $0xb4,%eax
80107763:	c1 e8 10             	shr    $0x10,%eax
80107766:	89 c1                	mov    %eax,%ecx
80107768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776b:	05 b4 00 00 00       	add    $0xb4,%eax
80107770:	c1 e8 18             	shr    $0x18,%eax
80107773:	89 c2                	mov    %eax,%edx
80107775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107778:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010777f:	00 00 
80107781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107784:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010778b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107797:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010779e:	83 e1 f0             	and    $0xfffffff0,%ecx
801077a1:	83 c9 02             	or     $0x2,%ecx
801077a4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801077aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ad:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801077b4:	83 c9 10             	or     $0x10,%ecx
801077b7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801077bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801077c7:	83 e1 9f             	and    $0xffffff9f,%ecx
801077ca:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801077d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801077da:	83 c9 80             	or     $0xffffff80,%ecx
801077dd:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801077e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801077ed:	83 e1 f0             	and    $0xfffffff0,%ecx
801077f0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107800:	83 e1 ef             	and    $0xffffffef,%ecx
80107803:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107813:	83 e1 df             	and    $0xffffffdf,%ecx
80107816:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010781c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107826:	83 c9 40             	or     $0x40,%ecx
80107829:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010782f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107832:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107839:	83 c9 80             	or     $0xffffff80,%ecx
8010783c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107845:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	83 c0 70             	add    $0x70,%eax
80107851:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107858:	00 
80107859:	89 04 24             	mov    %eax,(%esp)
8010785c:	e8 37 fb ff ff       	call   80107398 <lgdt>
  loadgs(SEG_KCPU << 3);
80107861:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107868:	e8 6a fb ff ff       	call   801073d7 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010786d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107870:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107876:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010787d:	00 00 00 00 
}
80107881:	83 c4 24             	add    $0x24,%esp
80107884:	5b                   	pop    %ebx
80107885:	5d                   	pop    %ebp
80107886:	c3                   	ret    

80107887 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107887:	55                   	push   %ebp
80107888:	89 e5                	mov    %esp,%ebp
8010788a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010788d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107890:	c1 e8 16             	shr    $0x16,%eax
80107893:	c1 e0 02             	shl    $0x2,%eax
80107896:	03 45 08             	add    0x8(%ebp),%eax
80107899:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010789c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010789f:	8b 00                	mov    (%eax),%eax
801078a1:	83 e0 01             	and    $0x1,%eax
801078a4:	84 c0                	test   %al,%al
801078a6:	74 17                	je     801078bf <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801078a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078ab:	8b 00                	mov    (%eax),%eax
801078ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078b2:	89 04 24             	mov    %eax,(%esp)
801078b5:	e8 4a fb ff ff       	call   80107404 <p2v>
801078ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078bd:	eb 4b                	jmp    8010790a <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801078bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801078c3:	74 0e                	je     801078d3 <walkpgdir+0x4c>
801078c5:	e8 2d b2 ff ff       	call   80102af7 <kalloc>
801078ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078d1:	75 07                	jne    801078da <walkpgdir+0x53>
      return 0;
801078d3:	b8 00 00 00 00       	mov    $0x0,%eax
801078d8:	eb 41                	jmp    8010791b <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801078da:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801078e1:	00 
801078e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801078e9:	00 
801078ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ed:	89 04 24             	mov    %eax,(%esp)
801078f0:	e8 79 d4 ff ff       	call   80104d6e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801078f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f8:	89 04 24             	mov    %eax,(%esp)
801078fb:	e8 f7 fa ff ff       	call   801073f7 <v2p>
80107900:	89 c2                	mov    %eax,%edx
80107902:	83 ca 07             	or     $0x7,%edx
80107905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107908:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010790a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010790d:	c1 e8 0c             	shr    $0xc,%eax
80107910:	25 ff 03 00 00       	and    $0x3ff,%eax
80107915:	c1 e0 02             	shl    $0x2,%eax
80107918:	03 45 f4             	add    -0xc(%ebp),%eax
}
8010791b:	c9                   	leave  
8010791c:	c3                   	ret    

8010791d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010791d:	55                   	push   %ebp
8010791e:	89 e5                	mov    %esp,%ebp
80107920:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107923:	8b 45 0c             	mov    0xc(%ebp),%eax
80107926:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010792b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010792e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107931:	03 45 10             	add    0x10(%ebp),%eax
80107934:	83 e8 01             	sub    $0x1,%eax
80107937:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010793c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010793f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107946:	00 
80107947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010794e:	8b 45 08             	mov    0x8(%ebp),%eax
80107951:	89 04 24             	mov    %eax,(%esp)
80107954:	e8 2e ff ff ff       	call   80107887 <walkpgdir>
80107959:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010795c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107960:	75 07                	jne    80107969 <mappages+0x4c>
      return -1;
80107962:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107967:	eb 46                	jmp    801079af <mappages+0x92>
    if(*pte & PTE_P)
80107969:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010796c:	8b 00                	mov    (%eax),%eax
8010796e:	83 e0 01             	and    $0x1,%eax
80107971:	84 c0                	test   %al,%al
80107973:	74 0c                	je     80107981 <mappages+0x64>
      panic("remap");
80107975:	c7 04 24 98 87 10 80 	movl   $0x80108798,(%esp)
8010797c:	e8 bc 8b ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107981:	8b 45 18             	mov    0x18(%ebp),%eax
80107984:	0b 45 14             	or     0x14(%ebp),%eax
80107987:	89 c2                	mov    %eax,%edx
80107989:	83 ca 01             	or     $0x1,%edx
8010798c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010798f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107994:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107997:	74 10                	je     801079a9 <mappages+0x8c>
      break;
    a += PGSIZE;
80107999:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801079a0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801079a7:	eb 96                	jmp    8010793f <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801079a9:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801079aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079af:	c9                   	leave  
801079b0:	c3                   	ret    

801079b1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079b1:	55                   	push   %ebp
801079b2:	89 e5                	mov    %esp,%ebp
801079b4:	53                   	push   %ebx
801079b5:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801079b8:	e8 3a b1 ff ff       	call   80102af7 <kalloc>
801079bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079c4:	75 0a                	jne    801079d0 <setupkvm+0x1f>
    return 0;
801079c6:	b8 00 00 00 00       	mov    $0x0,%eax
801079cb:	e9 98 00 00 00       	jmp    80107a68 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801079d0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801079d7:	00 
801079d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801079df:	00 
801079e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079e3:	89 04 24             	mov    %eax,(%esp)
801079e6:	e8 83 d3 ff ff       	call   80104d6e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801079eb:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801079f2:	e8 0d fa ff ff       	call   80107404 <p2v>
801079f7:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801079fc:	76 0c                	jbe    80107a0a <setupkvm+0x59>
    panic("PHYSTOP too high");
801079fe:	c7 04 24 9e 87 10 80 	movl   $0x8010879e,(%esp)
80107a05:	e8 33 8b ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a0a:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107a11:	eb 49                	jmp    80107a5c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107a16:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107a1c:	8b 50 04             	mov    0x4(%eax),%edx
80107a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a22:	8b 58 08             	mov    0x8(%eax),%ebx
80107a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a28:	8b 40 04             	mov    0x4(%eax),%eax
80107a2b:	29 c3                	sub    %eax,%ebx
80107a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a30:	8b 00                	mov    (%eax),%eax
80107a32:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107a36:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107a3a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a45:	89 04 24             	mov    %eax,(%esp)
80107a48:	e8 d0 fe ff ff       	call   8010791d <mappages>
80107a4d:	85 c0                	test   %eax,%eax
80107a4f:	79 07                	jns    80107a58 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107a51:	b8 00 00 00 00       	mov    $0x0,%eax
80107a56:	eb 10                	jmp    80107a68 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a58:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a5c:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107a63:	72 ae                	jb     80107a13 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a68:	83 c4 34             	add    $0x34,%esp
80107a6b:	5b                   	pop    %ebx
80107a6c:	5d                   	pop    %ebp
80107a6d:	c3                   	ret    

80107a6e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a6e:	55                   	push   %ebp
80107a6f:	89 e5                	mov    %esp,%ebp
80107a71:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a74:	e8 38 ff ff ff       	call   801079b1 <setupkvm>
80107a79:	a3 18 2a 11 80       	mov    %eax,0x80112a18
  switchkvm();
80107a7e:	e8 02 00 00 00       	call   80107a85 <switchkvm>
}
80107a83:	c9                   	leave  
80107a84:	c3                   	ret    

80107a85 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a85:	55                   	push   %ebp
80107a86:	89 e5                	mov    %esp,%ebp
80107a88:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107a8b:	a1 18 2a 11 80       	mov    0x80112a18,%eax
80107a90:	89 04 24             	mov    %eax,(%esp)
80107a93:	e8 5f f9 ff ff       	call   801073f7 <v2p>
80107a98:	89 04 24             	mov    %eax,(%esp)
80107a9b:	e8 4c f9 ff ff       	call   801073ec <lcr3>
}
80107aa0:	c9                   	leave  
80107aa1:	c3                   	ret    

80107aa2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107aa2:	55                   	push   %ebp
80107aa3:	89 e5                	mov    %esp,%ebp
80107aa5:	53                   	push   %ebx
80107aa6:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107aa9:	e8 b9 d1 ff ff       	call   80104c67 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107aae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ab4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107abb:	83 c2 08             	add    $0x8,%edx
80107abe:	89 d3                	mov    %edx,%ebx
80107ac0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ac7:	83 c2 08             	add    $0x8,%edx
80107aca:	c1 ea 10             	shr    $0x10,%edx
80107acd:	89 d1                	mov    %edx,%ecx
80107acf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ad6:	83 c2 08             	add    $0x8,%edx
80107ad9:	c1 ea 18             	shr    $0x18,%edx
80107adc:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107ae3:	67 00 
80107ae5:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107aec:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107af2:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107af9:	83 e1 f0             	and    $0xfffffff0,%ecx
80107afc:	83 c9 09             	or     $0x9,%ecx
80107aff:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107b05:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107b0c:	83 c9 10             	or     $0x10,%ecx
80107b0f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107b15:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107b1c:	83 e1 9f             	and    $0xffffff9f,%ecx
80107b1f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107b25:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107b2c:	83 c9 80             	or     $0xffffff80,%ecx
80107b2f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107b35:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b3c:	83 e1 f0             	and    $0xfffffff0,%ecx
80107b3f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b45:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b4c:	83 e1 ef             	and    $0xffffffef,%ecx
80107b4f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b55:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b5c:	83 e1 df             	and    $0xffffffdf,%ecx
80107b5f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b65:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b6c:	83 c9 40             	or     $0x40,%ecx
80107b6f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b75:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b7c:	83 e1 7f             	and    $0x7f,%ecx
80107b7f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b85:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107b8b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b91:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107b98:	83 e2 ef             	and    $0xffffffef,%edx
80107b9b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107ba1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ba7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107bad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107bb3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107bba:	8b 52 08             	mov    0x8(%edx),%edx
80107bbd:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107bc3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107bc6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107bcd:	e8 ef f7 ff ff       	call   801073c1 <ltr>
  if(p->pgdir == 0)
80107bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd5:	8b 40 04             	mov    0x4(%eax),%eax
80107bd8:	85 c0                	test   %eax,%eax
80107bda:	75 0c                	jne    80107be8 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107bdc:	c7 04 24 af 87 10 80 	movl   $0x801087af,(%esp)
80107be3:	e8 55 89 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107be8:	8b 45 08             	mov    0x8(%ebp),%eax
80107beb:	8b 40 04             	mov    0x4(%eax),%eax
80107bee:	89 04 24             	mov    %eax,(%esp)
80107bf1:	e8 01 f8 ff ff       	call   801073f7 <v2p>
80107bf6:	89 04 24             	mov    %eax,(%esp)
80107bf9:	e8 ee f7 ff ff       	call   801073ec <lcr3>
  popcli();
80107bfe:	e8 ac d0 ff ff       	call   80104caf <popcli>
}
80107c03:	83 c4 14             	add    $0x14,%esp
80107c06:	5b                   	pop    %ebx
80107c07:	5d                   	pop    %ebp
80107c08:	c3                   	ret    

80107c09 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107c09:	55                   	push   %ebp
80107c0a:	89 e5                	mov    %esp,%ebp
80107c0c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107c0f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107c16:	76 0c                	jbe    80107c24 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107c18:	c7 04 24 c3 87 10 80 	movl   $0x801087c3,(%esp)
80107c1f:	e8 19 89 ff ff       	call   8010053d <panic>
  mem = kalloc();
80107c24:	e8 ce ae ff ff       	call   80102af7 <kalloc>
80107c29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c2c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c33:	00 
80107c34:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c3b:	00 
80107c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3f:	89 04 24             	mov    %eax,(%esp)
80107c42:	e8 27 d1 ff ff       	call   80104d6e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4a:	89 04 24             	mov    %eax,(%esp)
80107c4d:	e8 a5 f7 ff ff       	call   801073f7 <v2p>
80107c52:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107c59:	00 
80107c5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107c5e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c65:	00 
80107c66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c6d:	00 
80107c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107c71:	89 04 24             	mov    %eax,(%esp)
80107c74:	e8 a4 fc ff ff       	call   8010791d <mappages>
  memmove(mem, init, sz);
80107c79:	8b 45 10             	mov    0x10(%ebp),%eax
80107c7c:	89 44 24 08          	mov    %eax,0x8(%esp)
80107c80:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c83:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8a:	89 04 24             	mov    %eax,(%esp)
80107c8d:	e8 af d1 ff ff       	call   80104e41 <memmove>
}
80107c92:	c9                   	leave  
80107c93:	c3                   	ret    

80107c94 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c94:	55                   	push   %ebp
80107c95:	89 e5                	mov    %esp,%ebp
80107c97:	53                   	push   %ebx
80107c98:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c9e:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ca3:	85 c0                	test   %eax,%eax
80107ca5:	74 0c                	je     80107cb3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107ca7:	c7 04 24 e0 87 10 80 	movl   $0x801087e0,(%esp)
80107cae:	e8 8a 88 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107cb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107cba:	e9 ad 00 00 00       	jmp    80107d6c <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cc5:	01 d0                	add    %edx,%eax
80107cc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107cce:	00 
80107ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80107cd6:	89 04 24             	mov    %eax,(%esp)
80107cd9:	e8 a9 fb ff ff       	call   80107887 <walkpgdir>
80107cde:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ce1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ce5:	75 0c                	jne    80107cf3 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107ce7:	c7 04 24 03 88 10 80 	movl   $0x80108803,(%esp)
80107cee:	e8 4a 88 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80107cf3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cf6:	8b 00                	mov    (%eax),%eax
80107cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cfd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	8b 55 18             	mov    0x18(%ebp),%edx
80107d06:	89 d1                	mov    %edx,%ecx
80107d08:	29 c1                	sub    %eax,%ecx
80107d0a:	89 c8                	mov    %ecx,%eax
80107d0c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d11:	77 11                	ja     80107d24 <loaduvm+0x90>
      n = sz - i;
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	8b 55 18             	mov    0x18(%ebp),%edx
80107d19:	89 d1                	mov    %edx,%ecx
80107d1b:	29 c1                	sub    %eax,%ecx
80107d1d:	89 c8                	mov    %ecx,%eax
80107d1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d22:	eb 07                	jmp    80107d2b <loaduvm+0x97>
    else
      n = PGSIZE;
80107d24:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2e:	8b 55 14             	mov    0x14(%ebp),%edx
80107d31:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107d34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d37:	89 04 24             	mov    %eax,(%esp)
80107d3a:	e8 c5 f6 ff ff       	call   80107404 <p2v>
80107d3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107d42:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107d46:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d4e:	8b 45 10             	mov    0x10(%ebp),%eax
80107d51:	89 04 24             	mov    %eax,(%esp)
80107d54:	e8 fd 9f ff ff       	call   80101d56 <readi>
80107d59:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d5c:	74 07                	je     80107d65 <loaduvm+0xd1>
      return -1;
80107d5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d63:	eb 18                	jmp    80107d7d <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107d65:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6f:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d72:	0f 82 47 ff ff ff    	jb     80107cbf <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d7d:	83 c4 24             	add    $0x24,%esp
80107d80:	5b                   	pop    %ebx
80107d81:	5d                   	pop    %ebp
80107d82:	c3                   	ret    

80107d83 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d83:	55                   	push   %ebp
80107d84:	89 e5                	mov    %esp,%ebp
80107d86:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d89:	8b 45 10             	mov    0x10(%ebp),%eax
80107d8c:	85 c0                	test   %eax,%eax
80107d8e:	79 0a                	jns    80107d9a <allocuvm+0x17>
    return 0;
80107d90:	b8 00 00 00 00       	mov    $0x0,%eax
80107d95:	e9 c1 00 00 00       	jmp    80107e5b <allocuvm+0xd8>
  if(newsz < oldsz)
80107d9a:	8b 45 10             	mov    0x10(%ebp),%eax
80107d9d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107da0:	73 08                	jae    80107daa <allocuvm+0x27>
    return oldsz;
80107da2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107da5:	e9 b1 00 00 00       	jmp    80107e5b <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107daa:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dad:	05 ff 0f 00 00       	add    $0xfff,%eax
80107db2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107dba:	e9 8d 00 00 00       	jmp    80107e4c <allocuvm+0xc9>
    mem = kalloc();
80107dbf:	e8 33 ad ff ff       	call   80102af7 <kalloc>
80107dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107dc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dcb:	75 2c                	jne    80107df9 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107dcd:	c7 04 24 21 88 10 80 	movl   $0x80108821,(%esp)
80107dd4:	e8 c8 85 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ddc:	89 44 24 08          	mov    %eax,0x8(%esp)
80107de0:	8b 45 10             	mov    0x10(%ebp),%eax
80107de3:	89 44 24 04          	mov    %eax,0x4(%esp)
80107de7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dea:	89 04 24             	mov    %eax,(%esp)
80107ded:	e8 6b 00 00 00       	call   80107e5d <deallocuvm>
      return 0;
80107df2:	b8 00 00 00 00       	mov    $0x0,%eax
80107df7:	eb 62                	jmp    80107e5b <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80107df9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e00:	00 
80107e01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e08:	00 
80107e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e0c:	89 04 24             	mov    %eax,(%esp)
80107e0f:	e8 5a cf ff ff       	call   80104d6e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e17:	89 04 24             	mov    %eax,(%esp)
80107e1a:	e8 d8 f5 ff ff       	call   801073f7 <v2p>
80107e1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e22:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107e29:	00 
80107e2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107e2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e35:	00 
80107e36:	89 54 24 04          	mov    %edx,0x4(%esp)
80107e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e3d:	89 04 24             	mov    %eax,(%esp)
80107e40:	e8 d8 fa ff ff       	call   8010791d <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107e45:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e52:	0f 82 67 ff ff ff    	jb     80107dbf <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107e58:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e5b:	c9                   	leave  
80107e5c:	c3                   	ret    

80107e5d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e5d:	55                   	push   %ebp
80107e5e:	89 e5                	mov    %esp,%ebp
80107e60:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e63:	8b 45 10             	mov    0x10(%ebp),%eax
80107e66:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e69:	72 08                	jb     80107e73 <deallocuvm+0x16>
    return oldsz;
80107e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e6e:	e9 a4 00 00 00       	jmp    80107f17 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80107e73:	8b 45 10             	mov    0x10(%ebp),%eax
80107e76:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e83:	e9 80 00 00 00       	jmp    80107f08 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e92:	00 
80107e93:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e97:	8b 45 08             	mov    0x8(%ebp),%eax
80107e9a:	89 04 24             	mov    %eax,(%esp)
80107e9d:	e8 e5 f9 ff ff       	call   80107887 <walkpgdir>
80107ea2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107ea5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ea9:	75 09                	jne    80107eb4 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80107eab:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107eb2:	eb 4d                	jmp    80107f01 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80107eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eb7:	8b 00                	mov    (%eax),%eax
80107eb9:	83 e0 01             	and    $0x1,%eax
80107ebc:	84 c0                	test   %al,%al
80107ebe:	74 41                	je     80107f01 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80107ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec3:	8b 00                	mov    (%eax),%eax
80107ec5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eca:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107ecd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ed1:	75 0c                	jne    80107edf <deallocuvm+0x82>
        panic("kfree");
80107ed3:	c7 04 24 39 88 10 80 	movl   $0x80108839,(%esp)
80107eda:	e8 5e 86 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80107edf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ee2:	89 04 24             	mov    %eax,(%esp)
80107ee5:	e8 1a f5 ff ff       	call   80107404 <p2v>
80107eea:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ef0:	89 04 24             	mov    %eax,(%esp)
80107ef3:	e8 66 ab ff ff       	call   80102a5e <kfree>
      *pte = 0;
80107ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107efb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107f01:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f0e:	0f 82 74 ff ff ff    	jb     80107e88 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107f14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f17:	c9                   	leave  
80107f18:	c3                   	ret    

80107f19 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107f19:	55                   	push   %ebp
80107f1a:	89 e5                	mov    %esp,%ebp
80107f1c:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107f1f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f23:	75 0c                	jne    80107f31 <freevm+0x18>
    panic("freevm: no pgdir");
80107f25:	c7 04 24 3f 88 10 80 	movl   $0x8010883f,(%esp)
80107f2c:	e8 0c 86 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f31:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f38:	00 
80107f39:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107f40:	80 
80107f41:	8b 45 08             	mov    0x8(%ebp),%eax
80107f44:	89 04 24             	mov    %eax,(%esp)
80107f47:	e8 11 ff ff ff       	call   80107e5d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107f4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f53:	eb 3c                	jmp    80107f91 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	c1 e0 02             	shl    $0x2,%eax
80107f5b:	03 45 08             	add    0x8(%ebp),%eax
80107f5e:	8b 00                	mov    (%eax),%eax
80107f60:	83 e0 01             	and    $0x1,%eax
80107f63:	84 c0                	test   %al,%al
80107f65:	74 26                	je     80107f8d <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80107f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6a:	c1 e0 02             	shl    $0x2,%eax
80107f6d:	03 45 08             	add    0x8(%ebp),%eax
80107f70:	8b 00                	mov    (%eax),%eax
80107f72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f77:	89 04 24             	mov    %eax,(%esp)
80107f7a:	e8 85 f4 ff ff       	call   80107404 <p2v>
80107f7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f85:	89 04 24             	mov    %eax,(%esp)
80107f88:	e8 d1 aa ff ff       	call   80102a5e <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107f8d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f91:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107f98:	76 bb                	jbe    80107f55 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80107f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9d:	89 04 24             	mov    %eax,(%esp)
80107fa0:	e8 b9 aa ff ff       	call   80102a5e <kfree>
}
80107fa5:	c9                   	leave  
80107fa6:	c3                   	ret    

80107fa7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107fa7:	55                   	push   %ebp
80107fa8:	89 e5                	mov    %esp,%ebp
80107faa:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107fb4:	00 
80107fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80107fbf:	89 04 24             	mov    %eax,(%esp)
80107fc2:	e8 c0 f8 ff ff       	call   80107887 <walkpgdir>
80107fc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107fca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fce:	75 0c                	jne    80107fdc <clearpteu+0x35>
    panic("clearpteu");
80107fd0:	c7 04 24 50 88 10 80 	movl   $0x80108850,(%esp)
80107fd7:	e8 61 85 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80107fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdf:	8b 00                	mov    (%eax),%eax
80107fe1:	89 c2                	mov    %eax,%edx
80107fe3:	83 e2 fb             	and    $0xfffffffb,%edx
80107fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe9:	89 10                	mov    %edx,(%eax)
}
80107feb:	c9                   	leave  
80107fec:	c3                   	ret    

80107fed <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107fed:	55                   	push   %ebp
80107fee:	89 e5                	mov    %esp,%ebp
80107ff0:	53                   	push   %ebx
80107ff1:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107ff4:	e8 b8 f9 ff ff       	call   801079b1 <setupkvm>
80107ff9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ffc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108000:	75 0a                	jne    8010800c <copyuvm+0x1f>
    return 0;
80108002:	b8 00 00 00 00       	mov    $0x0,%eax
80108007:	e9 fd 00 00 00       	jmp    80108109 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010800c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108013:	e9 cc 00 00 00       	jmp    801080e4 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108022:	00 
80108023:	89 44 24 04          	mov    %eax,0x4(%esp)
80108027:	8b 45 08             	mov    0x8(%ebp),%eax
8010802a:	89 04 24             	mov    %eax,(%esp)
8010802d:	e8 55 f8 ff ff       	call   80107887 <walkpgdir>
80108032:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108035:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108039:	75 0c                	jne    80108047 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010803b:	c7 04 24 5a 88 10 80 	movl   $0x8010885a,(%esp)
80108042:	e8 f6 84 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108047:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010804a:	8b 00                	mov    (%eax),%eax
8010804c:	83 e0 01             	and    $0x1,%eax
8010804f:	85 c0                	test   %eax,%eax
80108051:	75 0c                	jne    8010805f <copyuvm+0x72>
      panic("copyuvm: page not present");
80108053:	c7 04 24 74 88 10 80 	movl   $0x80108874,(%esp)
8010805a:	e8 de 84 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010805f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108062:	8b 00                	mov    (%eax),%eax
80108064:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108069:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010806c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806f:	8b 00                	mov    (%eax),%eax
80108071:	25 ff 0f 00 00       	and    $0xfff,%eax
80108076:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108079:	e8 79 aa ff ff       	call   80102af7 <kalloc>
8010807e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108081:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108085:	74 6e                	je     801080f5 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108087:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010808a:	89 04 24             	mov    %eax,(%esp)
8010808d:	e8 72 f3 ff ff       	call   80107404 <p2v>
80108092:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108099:	00 
8010809a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010809e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080a1:	89 04 24             	mov    %eax,(%esp)
801080a4:	e8 98 cd ff ff       	call   80104e41 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801080a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801080ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080af:	89 04 24             	mov    %eax,(%esp)
801080b2:	e8 40 f3 ff ff       	call   801073f7 <v2p>
801080b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080ba:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801080be:	89 44 24 0c          	mov    %eax,0xc(%esp)
801080c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080c9:	00 
801080ca:	89 54 24 04          	mov    %edx,0x4(%esp)
801080ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d1:	89 04 24             	mov    %eax,(%esp)
801080d4:	e8 44 f8 ff ff       	call   8010791d <mappages>
801080d9:	85 c0                	test   %eax,%eax
801080db:	78 1b                	js     801080f8 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801080dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080ea:	0f 82 28 ff ff ff    	jb     80108018 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801080f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f3:	eb 14                	jmp    80108109 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801080f5:	90                   	nop
801080f6:	eb 01                	jmp    801080f9 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801080f8:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801080f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080fc:	89 04 24             	mov    %eax,(%esp)
801080ff:	e8 15 fe ff ff       	call   80107f19 <freevm>
  return 0;
80108104:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108109:	83 c4 44             	add    $0x44,%esp
8010810c:	5b                   	pop    %ebx
8010810d:	5d                   	pop    %ebp
8010810e:	c3                   	ret    

8010810f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010810f:	55                   	push   %ebp
80108110:	89 e5                	mov    %esp,%ebp
80108112:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108115:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010811c:	00 
8010811d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108120:	89 44 24 04          	mov    %eax,0x4(%esp)
80108124:	8b 45 08             	mov    0x8(%ebp),%eax
80108127:	89 04 24             	mov    %eax,(%esp)
8010812a:	e8 58 f7 ff ff       	call   80107887 <walkpgdir>
8010812f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108135:	8b 00                	mov    (%eax),%eax
80108137:	83 e0 01             	and    $0x1,%eax
8010813a:	85 c0                	test   %eax,%eax
8010813c:	75 07                	jne    80108145 <uva2ka+0x36>
    return 0;
8010813e:	b8 00 00 00 00       	mov    $0x0,%eax
80108143:	eb 25                	jmp    8010816a <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108148:	8b 00                	mov    (%eax),%eax
8010814a:	83 e0 04             	and    $0x4,%eax
8010814d:	85 c0                	test   %eax,%eax
8010814f:	75 07                	jne    80108158 <uva2ka+0x49>
    return 0;
80108151:	b8 00 00 00 00       	mov    $0x0,%eax
80108156:	eb 12                	jmp    8010816a <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815b:	8b 00                	mov    (%eax),%eax
8010815d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108162:	89 04 24             	mov    %eax,(%esp)
80108165:	e8 9a f2 ff ff       	call   80107404 <p2v>
}
8010816a:	c9                   	leave  
8010816b:	c3                   	ret    

8010816c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010816c:	55                   	push   %ebp
8010816d:	89 e5                	mov    %esp,%ebp
8010816f:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108172:	8b 45 10             	mov    0x10(%ebp),%eax
80108175:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108178:	e9 8b 00 00 00       	jmp    80108208 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
8010817d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108180:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108185:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108188:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010818b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010818f:	8b 45 08             	mov    0x8(%ebp),%eax
80108192:	89 04 24             	mov    %eax,(%esp)
80108195:	e8 75 ff ff ff       	call   8010810f <uva2ka>
8010819a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010819d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801081a1:	75 07                	jne    801081aa <copyout+0x3e>
      return -1;
801081a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081a8:	eb 6d                	jmp    80108217 <copyout+0xab>
    n = PGSIZE - (va - va0);
801081aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
801081b0:	89 d1                	mov    %edx,%ecx
801081b2:	29 c1                	sub    %eax,%ecx
801081b4:	89 c8                	mov    %ecx,%eax
801081b6:	05 00 10 00 00       	add    $0x1000,%eax
801081bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801081be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c1:	3b 45 14             	cmp    0x14(%ebp),%eax
801081c4:	76 06                	jbe    801081cc <copyout+0x60>
      n = len;
801081c6:	8b 45 14             	mov    0x14(%ebp),%eax
801081c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801081cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801081d2:	89 d1                	mov    %edx,%ecx
801081d4:	29 c1                	sub    %eax,%ecx
801081d6:	89 c8                	mov    %ecx,%eax
801081d8:	03 45 e8             	add    -0x18(%ebp),%eax
801081db:	8b 55 f0             	mov    -0x10(%ebp),%edx
801081de:	89 54 24 08          	mov    %edx,0x8(%esp)
801081e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801081e9:	89 04 24             	mov    %eax,(%esp)
801081ec:	e8 50 cc ff ff       	call   80104e41 <memmove>
    len -= n;
801081f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801081f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081fa:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801081fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108200:	05 00 10 00 00       	add    $0x1000,%eax
80108205:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108208:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010820c:	0f 85 6b ff ff ff    	jne    8010817d <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108212:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108217:	c9                   	leave  
80108218:	c3                   	ret    
