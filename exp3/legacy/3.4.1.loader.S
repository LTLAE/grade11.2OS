%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR

; 这里其实就是GDT的起始地址，第一个描述符为空
GDT_BASE: dd 0x00000000
          dd 0x00000000

; 代码段描述符，一个dd为4字节，段描述符为8字节，上面为低4字节
CODE_DESC: dd 0x0000FFFF
           dd DESC_CODE_HIGH4

; 栈段描述符，和数据段共用
DATA_STACK_DESC: dd 0x0000FFFF
                 dd DESC_DATA_HIGH4

; 显卡段，非平坦
VIDEO_DESC: dd 0x80000007
            dd DESC_VIDEO_HIGH4

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1
times 120 dd 0
SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

; 内存大小，单位字节，此处的内存地址是0xb00
total_memory_bytes dd 0

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

ards_buf times 244 db 0
ards_nr dw 0

loader_start: 

; print loader msg
    mov byte [gs:0x0C],'R'
    mov byte [gs:0x0D],0x0F
    mov byte [gs:0x0E],'e'
    mov byte [gs:0x0F],0x0F
    mov byte [gs:0x10],'a'
    mov byte [gs:0x11],0x0F
    mov byte [gs:0x12],'l'
    mov byte [gs:0x13],0x0F
    mov byte [gs:0x14],'Y'
    mov byte [gs:0x15],0x0D
    mov byte [gs:0x16],'J'
    mov byte [gs:0x17],0x0D
    mov byte [gs:0x18],'Y'
    mov byte [gs:0x19],0x0D
; print finished

    xor ebx, ebx
    mov edx, 0x534d4150
    mov di, ards_buf

mov byte [gs:0x22],'M'
mov byte [gs:0x23],0x0F
mov byte [gs:0x24],'E'
mov byte [gs:0x25],0x0F
mov byte [gs:0x26],'M'
mov byte [gs:0x27],0x0F
mov byte [gs:0x28],'T'
mov byte [gs:0x29],0x0F
mov byte [gs:0x2A],'E'
mov byte [gs:0x2B],0x0F
mov byte [gs:0x2C],'S'
mov byte [gs:0x2D],0x0F
mov byte [gs:0x2E],'T'
mov byte [gs:0x2F],0x0F

;;;;; cal total mem bytes
;------------------------------
; method 1: eax = 0xe820, edx = 0x534d4150 aka traverse all memory blocks
xor ebx, ebx		               ;第一次调用时，ebx值要为0
mov edx, 0x534d4150	            ;edx只赋值一次，循环体中不会改变
mov di, ards_buf	               ;ards结构缓冲区

; print using method 1
mov byte [gs:160],'1'
mov byte [gs:161],0x0D

.e820_mem_get_loop:	            ;循环获取每个ARDS内存范围描述结构
   mov eax, 0x0000e820	         ;执行int 0x15后,eax值变为0x534d4150,所以每次执行int前都要更新为子功能号。
   mov ecx, 20		               ;ARDS地址范围描述符结构大小是20字节
   int 0x15
   jc .e820_failed_so_try_e801   ;若cf位为1则有错误发生，尝试0xe801子功能
   add di, cx		               ;使di增加20字节指向缓冲区中新的ARDS结构位置
   inc word [ards_nr]	         ;记录ARDS数量
   cmp ebx, 0		               ;若ebx为0且cf不为1,这说明ards全部返回，当前已是最后一个
   jnz .e820_mem_get_loop

;在所有ards结构中，找出(base_add_low + length_low)的最大值，即内存的容量。
mov cx, [ards_nr]	      ;遍历每一个ARDS结构体,循环次数是ARDS的数量
mov ebx, ards_buf 
xor edx, edx		      ;edx为最大的内存容量,在此先清0
.find_max_mem_area:	      ;无须判断type是否为1,最大的内存块一定是可被使用
   mov eax, [ebx]	      ;base_add_low
   add eax, [ebx+8]	      ;length_low
   add ebx, 20		      ;指向缓冲区中下一个ARDS结构
   cmp edx, eax		      ;冒泡排序，找出最大,edx寄存器始终是最大的内存容量
   jge .next_ards
   mov edx, eax		      ;edx为总内存大小
.next_ards:
   loop .find_max_mem_area
   jmp .mem_get_ok

;------------------------------
; method 2: ax = 0xe801 aka traverse 4G
; 返回后, ax cx 值一样,以KB为单位,bx dx值一样,以64KB为单位
; 在ax和cx寄存器中为低16M,在bx和dx寄存器中为16MB到4G。
; print using method 2
mov byte [gs:162],'2'
mov byte [gs:163],0x0D

.e820_failed_so_try_e801:
   mov ax,0xe801
   int 0x15
   jc .e801_failed_so_try88   ;若当前e801方法失败,就尝试0x88方法

;1 先算出低15M的内存,ax和cx中是以KB为单位的内存数量,将其转换为以byte为单位
   mov cx,0x400	     ;cx和ax值一样,cx用做乘数
   mul cx 
   shl edx,16
   and eax,0x0000FFFF
   or edx,eax
   add edx, 0x100000 ;ax只是15MB,故要加1MB
   mov esi,edx	     ;先把低15MB的内存容量存入esi寄存器备份

;2 再将16MB以上的内存转换为byte为单位,寄存器bx和dx中是以64KB为单位的内存数量
   xor eax,eax
   mov ax,bx		
   mov ecx, 0x10000	;0x10000十进制为64KB
   mul ecx		;32位乘法,默认的被乘数是eax,积为64位,高32位存入edx,低32位存入eax.
   add esi,eax		;由于此方法只能测出4G以内的内存,故32位eax足够了,edx肯定为0,只加eax便可
   mov edx,esi		;edx为总内存大小
   jmp .mem_get_ok

;------------------------------
; method 3: ah=0x88, traverse 64MB
; print using method 3
mov byte [gs:164],'3'
mov byte [gs:165],0x0D

.e801_failed_so_try88: 
   ;int 15后，ax存入的是以kb为单位的内存容量
   mov  ah, 0x88
   int  0x15
   jc .error_hlt
   and eax,0x0000FFFF
      
   ;16位乘法，被乘数是ax,积为32位.积的高16位在dx中，积的低16位在ax中
   mov cx, 0x400     ;0x400等于1024,将ax中的内存容量换为以byte为单位
   mul cx
   shl edx, 16	     ;把dx移到高16位
   or edx, eax	     ;把积的低16位组合到edx,为32位的积
   add edx,0x100000  ;0x88子功能只会返回1MB以上的内存,故实际内存大小要加上1MB

.mem_get_ok:
   ;print memGetOk msg
   mov byte [gs:0x32],'O'
   mov byte [gs:0x33],0x0F
   mov byte [gs:0x34],'K'
   mov byte [gs:0x35],0x0F
   mov [total_memory_bytes], edx	 ;将内存换为byte单位后存入total_mem_bytes处。




; cal mem finished

    ; 开始进入保护模式
    ; 打开A20地址线
    in al, 0x92
    or al, 00000010B
    out 0x92, al

    ; 加载gdt
    lgdt [gdt_ptr]

    ; cr0第0位置1
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    ; 刷新流水线
    jmp dword SELECTOR_CODE:p_mode_start

.error_hlt:		      ;出错则挂起
   hlt

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax

    mov es, ax
    mov ss, ax

    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax
    
    call setup_page

    ; 保存gdt表
    sgdt [gdt_ptr]

    ; 重新设置gdt描述符， 使虚拟地址指向内核的第一个页表
    mov ebx, [gdt_ptr + 2]
    or dword [ebx + 0x18 + 4], 0xc0000000
    add dword [gdt_ptr + 2], 0xc0000000
    
    add esp, 0xc0000000

    ; 页目录基地址寄存器
    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax

    ; 打开分页
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [gdt_ptr]

    mov byte [gs:320], 'V'
    mov byte [gs:321], 0x0F
    mov byte [gs:322], ' '
    mov byte [gs:323], 0x0F
    mov byte [gs:324], 'Y'
    mov byte [gs:325], 0x0D
    mov byte [gs:326], 'J'
    mov byte [gs:327], 0x0D
    mov byte [gs:328], 'Y'
    mov byte [gs:329], 0x0D

    jmp $

; 创建页目录以及页表
setup_page:
    ; 页目录表占据4KB空间，清零之
    mov ecx, 4096
    mov esi, 0
.clear_page_dir:   
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

; 创建页目录表(PDE)
.create_pde:
    mov eax, PAGE_DIR_TABLE_POS
    ; 0x1000为4KB，加上页目录表起始地址便是第一个页表的地址
    add eax, 0x1000
    mov ebx, eax

    ; 设置页目录项属性
    or eax, PG_US_U | PG_RW_W | PG_P
    ; 设置第一个页目录项
    mov [PAGE_DIR_TABLE_POS], eax
    ; 第768(内核空间的第一个)个页目录项，与第一个相同，这样第一个和768个都指向低端4MB空间
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax
    ; 最后一个表项指向自己，用于访问页目录本身
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 4092], eax

; 创建页表
    mov ecx, 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx + esi * 4], edx
    add edx, 4096
    inc esi
    loop .create_pte

; 创建内核的其它PDE
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254
    mov esi, 769
.create_kernel_pde:
    mov [ebx + esi * 4], eax
    inc esi
    add eax, 0x1000
    loop .create_kernel_pde
    ret