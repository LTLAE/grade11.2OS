%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
; remember last time we set 0x900 as loader start?
; A stack is needed in protected mode
; make mbr_end to 0x900 as a stack, stack top is 0x900

; print loader msg
mov byte [gs:0xA0],'R'
mov byte [gs:0xA1],0x0F
mov byte [gs:0xA2],'e'
mov byte [gs:0xA3],0x0F
mov byte [gs:0xA4],'a'
mov byte [gs:0xA5],0x0F
mov byte [gs:0xA6],'l'
mov byte [gs:0xA7],0x0F
mov byte [gs:0xA8],'Y'
mov byte [gs:0xA9],0x0D
mov byte [gs:0xAA],'J'
mov byte [gs:0xAB],0x0D
mov byte [gs:0xAC],'Y'
mov byte [gs:0xAD],0x0D
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
times 60 dd 0

SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0         
; aka (CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

; gdt ptrs: gdt limit(2B) + gdt start addr(4B)
gdt_ptr  dw  GDT_LIMIT 
	     dd  GDT_BASE

LoaderStart:
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

jmp  SELECTOR_CODE:p_mode_start
; refresh assembly line to avoid cpu predict
; IDK what is this but put it in it will surely work (with convince)

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
mov byte [gs:325], 0x1f
mov byte [gs:326], 'Y'
mov byte [gs:327], 0x0d
mov byte [gs:328], 'J'
mov byte [gs:329], 0x0d
mov byte [gs:330], 'Y'
mov byte [gs:331], 0x0d


; print finished

jmp $