SECTION MBR vstart=0x7c00         ;mbr starts at 0x7c00
;init
mov ax,cs      
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00

;clear screen
mov     ax, 0x600
mov     bx, 0x700
mov     cx, 0           ; Upper left corner: (0, 0)
mov     dx, 0x184f	    ; Bottom right corner: (80,25),
; In VGA text mode, max length of a line is 80, 25 lines in total.
; Line index starts from 0, so 0x18=24, 0x4f=79.
int     0x10            ; 0x10 interrupt

;get cursor position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; register ah stores function    ;
; register bh stores page number ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov ah, 3		; Function3: Get cursor position.
mov bh, 0		; page number of the cursor
int 0x10		; 0x10 interrupt
;Output: ch = cursor start row, cl = cursor end row, dh = cursor at row, dl = cursor at column

;print string
mov ax, message         ; put string into register ax
mov bp, ax              
mov cx, 14		        ; cx = string.length, \0 is not included
mov ax, 0x1301	        ; Funtion 13: show characters and its properties
			            ; al: how to print, ah=01: print string with cursor follows
mov bx, 0x2		        ; bh: page number
			            ; bl: properties, bl = 02h: green char and black bg
int 0x10		        ; 0x10 interrupt
;print finished

; for debug
mov bp, jmpmsg
mov cx, 33
mov bx, 0x2
int 0x10	
; for debug


jmp $           ; make program floats here

message db "1 MBR YeJianyu"
jmpmsg db "Jumping to loader at sector 3..."
; I don't know the fowllowing codes but I copied them here.
; I guess it fills 0 to the rest of spaces in this sector
times 510-($-$$) db 0
; Tell hardware this is a MBR sector
db 0x55,0xaa
