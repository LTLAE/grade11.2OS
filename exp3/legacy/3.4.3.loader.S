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

.e820_mem_get_loop:
    mov eax, 0x0000e820
    mov ecx, 20
    int 0x15
    
    jc .e820_mem_get_failed
    
    add di, cx
    inc word [ards_nr]
    cmp ebx, 0
    jnz .e820_mem_get_loop

    mov cx, [ards_nr]
    mov ebx, ards_buf
    xor edx, edx

.find_max_mem_area:
    mov eax, [ebx]
    add eax, [ebx + 8]
    add ebx, 20
    cmp edx, eax
    jge .next_ards
    mov edx, eax

.next_ards:
    loop .find_max_mem_area
    jmp .mem_get_ok

.e820_mem_get_failed:
    mov byte [gs:0x32], 'f'
    mov byte [gs:0x33], 0x0F
    mov byte [gs:0x34], 'a'
    mov byte [gs:0x35], 0x0F
    mov byte [gs:0x36], 'i'
    mov byte [gs:0x37], 0x0F
    mov byte [gs:0x38], 'l'
    mov byte [gs:0x39], 0x0F
    ; 内存检测失败，不再继续向下执行
    jmp $

.mem_get_ok:
    mov byte [gs:0x32], 'o'
    mov byte [gs:0x33], 0x0F
    mov byte [gs:0x34], 'k'
    mov byte [gs:0x35], 0x0F
    mov [total_memory_bytes], edx

    ; 开始进入保护模式
    ; 打开A20地址线
    in al, 0x92
    or al, 00000010B
    out 0x92, al

    ; 加载gdt
    lgdt [gdt_ptr]

    ; print V msg
    mov byte [gs:160], 'V'
    mov byte [gs:161], 0x0F
    mov byte [gs:162], ' '
    mov byte [gs:163], 0x0F
    mov byte [gs:164], 'Y'
    mov byte [gs:165], 0x0D
    mov byte [gs:166], 'J'
    mov byte [gs:167], 0x0D
    mov byte [gs:168], 'Y'
    mov byte [gs:169], 0x0D

    ; cr0第0位置1
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    ; 刷新流水线
    jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax

    mov es, ax
    mov ss, ax

    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:0x42], 'P'
    mov byte [gs:0x43], 0x0F
    mov byte [gs:0x44], 'r'
    mov byte [gs:0x45], 0x0F
    mov byte [gs:0x46], 'o'
    mov byte [gs:0x47], 0x0F
    mov byte [gs:0x48], 't'
    mov byte [gs:0x49], 0x0F
    mov byte [gs:0x4A], 'e'
    mov byte [gs:0x4B], 0x0F
    mov byte [gs:0x4C], 'c'
    mov byte [gs:0x4D], 0x0F
    mov byte [gs:0x4E], 't'
    mov byte [gs:0x4F], 0x0F

    ; 加载kernel
    mov eax, KERNEL_START_SECTOR
    mov ebx, KERNEL_BIN_BASE_ADDR
    mov ecx, 200

    call rd_disk_m_32
    
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

    ; 初始化kernel
    jmp SELECTOR_CODE:enter_kernel

    enter_kernel:
        call kernel_init
        mov esp, 0xc009f000
        jmp KERNEL_ENTRY_POINT

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

; 保护模式的硬盘读取函数
rd_disk_m_32:

    mov esi, eax
    mov di, cx

    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi

    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl
    mov dx, 0x1f4
    out dx, al

    shr eax, cl
    mov dx, 0x1f5
    out dx, al

    shr eax, cl
    and al, 0x0f
    or al, 0xe0
    mov dx, 0x1f6
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.not_ready:
    nop
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .not_ready

    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
    mov dx, 0x1f0

.go_on_read:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret

kernel_init:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx

    mov dx, [KERNEL_BIN_BASE_ADDR + 42]
    mov ebx, [KERNEL_BIN_BASE_ADDR + 28]

    add ebx, KERNEL_BIN_BASE_ADDR
    mov cx, [KERNEL_BIN_BASE_ADDR + 44]

.each_segment:
    cmp byte [ebx], PT_NULL
    je .PTNULL

    ; 准备mem_cpy参数
    push dword [ebx + 16]
    mov eax, [ebx + 4]
    add eax, KERNEL_BIN_BASE_ADDR
    push eax
    push dword [ebx + 8]

    call mem_cpy
    add esp, 12

.PTNULL:
    add ebx, edx
    loop .each_segment
    ret

mem_cpy:
    cld
    push ebp
    mov ebp, esp
    push ecx

    mov edi, [ebp + 8]
    mov esi, [ebp + 12]
    mov ecx, [ebp + 16]
    rep movsb

    pop ecx
    pop ebp
    ret