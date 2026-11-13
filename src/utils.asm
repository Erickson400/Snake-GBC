INCLUDE "hardware.inc"

SECTION "Utilities RAM", WRAM0
wRNGNumberLow:: db
wRNGNumberHigh:: db

SECTION "Utilities", ROM0
; Modified the wRNGNumbeber variable.
rng_function::
        ; Shift right
        ld a, [wRNGNumberHigh]
        srl a
        ld [wRNGNumberHigh], a
        ld a, [wRNGNumberLow]
        rr a
        ld [wRNGNumberLow], a

        ; Return if shifted bit is 0
        ret z

        ; XOR the Low
        ld a, [wRNGNumberLow]
        ld b, %0011_0010
        xor b
        ld [wRNGNumberLow], a

        ; XOR the High
        ld a, [wRNGNumberHigh]
        ld b, %1010_0101
        xor b
        ld [wRNGNumberHigh], a
        ret

; @mods: None
wait_for_VBlank::
        push af
        di
        xor a
        ldh [rIF], a
        ld a, IE_VBLANK
        ldh [rIE], a
        halt
        nop
        pop af
        ret

; Sets hl to the value at the address in hl
; @mods: None
deref_hl::
        push af
        push bc
        ld a, [hl+]
        ld c, a
        ld a, [hl]
        ld b, a
        ld h, b :: ld l, c
        pop bc
        pop af
        ret

; @mods: None
store_bc_at_address_hl::
        push af
        ld a, c
        ld [hl+], a
        ld a, b
        ld [hl], a
        dec hl
        pop af
        ret

; Copy bytes from one area to another
; @param de: Source
; @param hl: Destination 
; @param bc: Length
; @mods: None
Memcopy::
        push af
        push bc
        push de
        push hl
:       ld a, [de]
        ld [hl+], a
        inc de
        dec bc
        ld a, b
        or c
        jp nz, :-
        pop hl
        pop de
        pop bc
        pop af
        ret

; Set a range of bytes to a single value
; @param hl: Destination 
; @param bc: Length
; @param d: Value
; @mods: None
Memset::
        push af
        push bc
        push de
        push hl
:       ld a, d
        ld [hl+], a
        dec bc
        ld a, b
        or a, c
        jp nz, :-
        pop hl
        pop de
        pop bc
        pop af
        ret
