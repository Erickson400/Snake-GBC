if !def(MACROS_INC)
def MACROS_INC equ 1

; Dereferences the value stored on the stack to the hl register.
; @param \1: stack offset
; @return hl: Dereferenced address 
; @mods: None
MACRO DerefStackOffset
        push bc
        ld hl, sp + \1
        ld a, [hl+] :: ld c, a
        ld a, [hl] :: ld b, a
        ld h, b :: ld l, c
        pop bc

ENDM

endc