INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
        nop
        jp entry_point
        ds $150 - @, 0
SECTION "Main", ROM0
entry_point:
        ld sp, Stack.top       ; Initialize the stack to be on WRAM
        
        ; Turn off screen
:       ld a, [rLY]
        cp LY_VBLANK
        jp nz, :-
        xor a
        ld [rLCDC], a

        ld [rAUDENA], a         ; Disable audio

        call SplashScreen

:
        jp :-



SECTION "Stack", WRAM0
Stack::
    ds 256
.top::