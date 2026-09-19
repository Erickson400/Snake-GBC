INCLUDE "hardware.inc"

SECTION "Splash Screen", ROM0
SplashScreen::
        ; Copy tiles to VRAM
        ld de, tiles
        ld hl, $8000
        ld bc, tiles.end - tiles
        call Memcopy

        ; Copy tilemap and attributes to VRAM
        ld bc, 0
        push bc                 ; X counter. + 8
        push bc                 ; Y Counter. + 6
        ld bc, tilemap
        push bc                 ; Tilemap read pointer. + 4
        ld bc, attribute_map
        push bc                 ; Attributes read pointer. + 2
        ld bc, TILEMAP0
        push bc                 ; Tilemap/Attributes write pointer. + 0
                ; for {
                ;         Memcopy(tilemap, TILEMAP0, 20)
                ;         switch_vbank
                ;         Memcopy(attribute_map, TILEMAP0, 20)
                ;         switch_vbank
                ;         x++
                ;         if x == 20 {
                ;                 x = 0
                ;                 y++
                ;                }
                ;         if y == 18 {
                ;                 break
                ;         }
                ;         tilemap += 20
                ;         attribute_map += 20
                ;         TILEMAP0 += 32
                ; }
.copy_loop:
        ; Copy section
        ld hl, sp + 4           ; Tilemap read pointer
        ld d, h :: ld e, l
        ld hl, sp + 0           ; Tilemap write pointer
        ld bc, 20
        call Memcopy
        ld a, 1
        ld [rVBK], a            ; Switch to bank 1
        ld hl, sp + 2           ; Attributes read pointer
        ld d, h :: ld e, l
        ld hl, sp + 0           ; Attributes write pointer
        ld bc, 20
        call Memcopy
        xor a
        ld [rVBK], a            ; Switch to bank 0

        ; Update counters
        ld hl, sp + 8   ; X
        ld a, [hl]
        inc a
        ld [hl], a
        cp 20 :: jp nz, :+
        xor a
        ld [hl], a
        ld hl, sp + 6   ; Y
        ld a, [hl]
        inc a
        ld [hl], a
:       ld hl, sp + 6   ; Y
        ld a, [hl]
        cp 18 :: jp z, .break
        ; Increment pointers
        ld hl, sp + 4           ; Tilemap read pointer
        ld a, [hl]
        add 20
        ld [hl], a
        ld hl, sp + 2           ; Attributes read pointer
        ld a, [hl]
        add 20
        ld [hl], a
        ld hl, sp + 0           ; Tilemap/Attributes write pointer
        ld a, [hl]
        add 32
        ld [hl], a
        jp .copy_loop
.break:

        ; Copy palettes to CRAM
        ld a, %1000_0000        ; auto-increment, CRAM address 0
        ld [rBGPI], a
        ld hl, palette
        ld c, palette.end - palette
:       ld a, [hl+]
        ld [rBGPD], a
        dec c
        jr nz, :-

        ; Turn on screen
        ld a, LCDC_ENABLE | LCDC_BLOCK01
        ld [rLCDC], a
        
        ; Fade out to black
        ret


SECTION "Splash Assets", ROM0
tiles:
        INCBIN "assets/splash.2bpp"
.end
attribute_map:
        INCBIN "assets/splash.attrmap"
.end
tilemap:
        INCBIN "assets/splash.tilemap"
.end
palette:
        INCBIN "assets/splash.pal"
.end