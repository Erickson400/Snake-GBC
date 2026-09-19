SECTION "Utilities", ROM0

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
        ld [hli], a
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
