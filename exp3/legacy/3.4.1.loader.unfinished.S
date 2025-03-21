%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
; remember last time we set 0x900 as loader start?
; A stack is needed in protected mode
; make mbr_end to 0x900 as a stack, stack top is 0x900

; whatever auther said addr here is 0x900
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

jmp LoaderStart

; init gdt
; global discriptor
GDT_BASE:           dd    0x00000000 
	                 dd    0x00000000

CODE_DESC:          dd    0x0000FFFF 
	                 dd    DESC_CODE_HIGH4

DATA_STACK_DESC:    dd    0x0000FFFF
		             dd    DESC_DATA_HIGH4

VIDEO_DESC:         dd    0x80000007	       
                    ; limit=(0xbffff-0xb8000)/4k=0x7
	                 dd    DESC_VIDEO_HIGH4  
                    ; dpl is already 0

; GDT size
GDT_SIZE   equ   $ - GDT_BASE
GDT_LIMIT  equ   GDT_SIZE - 1 
; times 60 dq 0	 ; reserve slot, size = 60 discriptors
; Apple版本的nasm这样写会报错，原因是不能把int型的0赋给dq。稍加变通即可:
; by seaswalker/tiny-os @github
; https://github.com/seaswalker/tiny-os
times 120 dd 0

SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0         
; aka (CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

TotalMemBytes dd 0
; blah blah whatever but TotalMemBytes is 0xB00

; gdt ptrs: gdt limit(2B) + gdt start addr(4B)
gdt_ptr  dw  GDT_LIMIT 
	      dd  GDT_BASE

; ----- problem here
; memory alignment: TotalMemBytes 4B + gdt_ptr 6B + ards_buf 244B + adrs_nr 2B = 256B
ards_buf times 244 db 0
ards_nr dw 0		      ;ards struct count
; -----problem here


LoaderStart:
mov byte [gs:0x22],'M'
mov byte [gs:0x23],0x0F
mov byte [gs:0x24],'T'
mov byte [gs:0x25],0x0F

; jmp $
; for debug, ignore it

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
   mov byte [gs:0x28],'O'
   mov byte [gs:0x29],0x0F
   mov byte [gs:0x2A],'K'
   mov byte [gs:0x2B],0x0F
   mov [TotalMemBytes], edx	 ;将内存换为byte单位后存入total_mem_bytes处。




; cal mem finished

; enter protect mode

; 1. Activate A20
in al,0x92
; or al,0000_0010B
; Mac上的nasm并不支持数字中间以下划线分割的写法，会出现编译错误。
; by seaswalker/tiny-os @github
; https://github.com/seaswalker/tiny-os
or al, 00000010B
out 0x92,al

; 2. Load GDT
lgdt [gdt_ptr]

; 3. Set reg cr0 bit 0 to 1
mov eax, cr0
or eax, 0x00000001
mov cr0, eax

jmp SELECTOR_CODE:p_mode_start
; refresh assembly line to avoid cpu predict
; IDK what is this but put it in it will surely work (with convince)

.error_hlt:		      ;出错则挂起
   hlt

[bits 32]
p_mode_start:

; Some "Unknown" init here
mov ax, SELECTOR_DATA
mov ds, ax
mov es, ax
mov ss, ax
mov esp,LOADER_STACK_TOP
mov ax, SELECTOR_VIDEO
mov gs, ax

; print protected msg
mov byte [gs:320], 'P'
mov byte [gs:321], 0x1f
mov byte [gs:322], 'T'
mov byte [gs:323], 0x1f
mov byte [gs:324], ' '
mov byte [gs:325], 0x0f
mov byte [gs:326], 'Y'
mov byte [gs:327], 0x0d
mov byte [gs:328], 'J'
mov byte [gs:329], 0x0d
mov byte [gs:330], 'Y'
mov byte [gs:331], 0x0d
; print finished
; above 3.4.1

