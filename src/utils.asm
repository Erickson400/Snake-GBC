INCLUDE "hardware.inc"
SECTION "Utilities", ROM0

; @mods: None
wait_for_VBlank_busy::
        push af
:       ld a, [rLY]
        cp LY_VBLANK
        jp nz, :-
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
        or a, c
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
