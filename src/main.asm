INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
        nop
        jp entry_point
        ds $150 - @, 0
SECTION "Main", ROM0
entry_point:
        di
        ld sp, Stack.top       ; Initialize the stack to be in WRAM
        
        ; Turn off screen
        call wait_for_VBlank
        xor a :: ld [rLCDC], a

        ld [rAUDENA], a         ; Disable audio

        call SplashScreen
        call TitleScreen

:       jp :-

SECTION "System", WRAM0
Stack::
        ds 256
.top::