%include "boot.inc"
SECTION MBR vstart=0x7c00         ;mbr starts at 0x7c00
;init
mov ax,cs      
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00
;idk what is this
mov ax,0xb800
mov gs,ax

;clear screen
mov     ax, 0x600
mov     bx, 0x700
mov     cx, 0           ; Upper left corner: (0, 0)
mov     dx, 0x184f	    ; Bottom right corner: (80,25),
; In VGA text mode, max length of a line is 80, 25 lines in total.
; Line index starts from 0, so 0x18=24, 0x4f=79.
int     0x10            ; 0x10 interrupt

; show MBR message
mov byte [gs:0x00],'M'
mov byte [gs:0x01],0x0F

mov byte [gs:0x04],'B'
mov byte [gs:0x05],0x0F

mov byte [gs:0x08],'R'
mov byte [gs:0x09],0x0F
; MBR message end

mov eax, LOADER_START_SECTOR    ; addr of start sector
mov bx, LOADER_BASE_ADDR        ; addr to read
mov cx, 4                       ; read n sectors

call ReadDisk_M16               ; run sector read function
jmp LOADER_BASE_ADDR

; sector read function
; eax = LBA sector number
; ebx = addr to write in
; ecx = how many sectors to read

ReadDisk_M16 :
mov esi,eax ; backup eax
mov di,cx   ; backup cx

; 1. how many sector(s) to read?
mov dx, 0x1f2
mov al, cl
out dx, al      ; sectorCount cx->al->dx
mov eax, esi    ; restore eax

; 2. 0x1f3 - 0x1f6 <- LBA address
; 0x1f3 <- bit 7 - 0
mov dx,0x1f3                       
out dx,al                          
; 0x1f4 <- bit 15 - 8
mov cl,8
shr eax,cl
mov dx,0x1f4
out dx,al
; 0x1f5 <- bit 23 - 16
shr eax,cl
mov dx,0x1f5
out dx,al
; 0x1f6 <- bit 27 - 24
shr eax,cl
and al,0x0f
or al,0xe0	   ; set bit 7 - 4 to 1110 aka LBA mode
mov dx,0x1f6
out dx,al

; 3. 0x1f7 <- 0x20 aka read command
mov dx,0x1f7
mov al,0x20                        
out dx,al

; 4. disk ready?
.DiskNotReady:
    ; when reading a disk, dx shows disk status
    nop
    in al,dx         ; get disk status from dx
    and al,0x88	   
    ; x1xx xxxx disk busy
    ; xxxx 1xxx disk ready
    cmp al,0x08      ; if ready?
jnz .DiskNotReady    ; not ready: loop

; 5. read data from 0x1f0
mov ax, di       ; di: sectorCount (2 sectors here)
mov dx, 256
; dx = Bytes per sector / di (512 / 2 = 256)
mul dx
mov cx, ax	   
mov dx, 0x1f0
.ReadNotFinish:
    in ax,dx
    mov [bx],ax
    add bx,2		  
    loop .ReadNotFinish
    ret ;return

; rest bits of current sector = 0
times 510-($-$$) db 0
; last 8B of current sector = 55 AA indicates this is a mbr sector
db 0x55,0xaa