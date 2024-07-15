%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR

; mov ax, jmpmsg			; for debug
; mov bp, ax
; mov cx, 15
; mov ax, 0x1301
; mov bx, 0x2				; for debug

mov byte [gs:0x00],'2'
mov byte [gs:0x01],0x1E

mov byte [gs:0x02],' '
mov byte [gs:0x03],0x0F

mov byte [gs:0x04],'L'
mov byte [gs:0x05],0x0F

mov byte [gs:0x06],'O'
mov byte [gs:0x07],0x0F

mov byte [gs:0x08],'A'
mov byte [gs:0x09],0x0F

mov byte [gs:0x0A],'D'
mov byte [gs:0x0B],0x0F

mov byte [gs:0x0C],'E'
mov byte [gs:0x0D],0x0F

mov byte [gs:0x0E],'R'
mov byte [gs:0x0F],0x0F

mov byte [gs:0x10],'Y'
mov byte [gs:0x11],0x0D

mov byte [gs:0x12],'J'
mov byte [gs:0x13],0x0D

mov byte [gs:0x14],'Y'
mov byte [gs:0x15],0x0D

; How dare you Dear Longtail
; How could you do that?

; mov byte [gs:0x10],'D'
; mov byte [gs:0x11],0x0F

; mov byte [gs:0x12],'E'
; mov byte [gs:0x13],0x0F

; mov byte [gs:0x14],'R'
; mov byte [gs:0x15],0x0F

; mov byte [gs:0x16],'Y'
; mov byte [gs:0x17],0x0D

; mov byte [gs:0x18],'J'
; mov byte [gs:0x19],0x0D

; mov byte [gs:0x20],'Y'
; mov byte [gs:0x21],0x0D

jmp $   ;float

; jmpmsg db "Loader running."