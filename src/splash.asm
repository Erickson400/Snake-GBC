INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "Splash Screen", ROM0
SplashScreen::
        ; Copy tiles to VRAM
        ld de, tiles
        ld hl, $8000
        ld bc, tiles.end - tiles
        call Memcopy

        ; Clear the tilemap
        ld hl, $9800
        ld bc, $400
        ld d, $0D
        call Memset

        ; Copy tilemap to VRAM
        ld de, tilemap
        ld hl, TILEMAP0
        ld bc, tilemap.end - tilemap
        call Memcopy

        ; Clear the attributes
        ld a, 1
        ld [rVBK], a
        ld hl, $9800
        ld bc, $400
        ld d, 0
        call Memset
        xor a
        ld [rVBK], a

        ; Copy attributes to VRAM 
        ld a, 1
        ld [rVBK], a
        ld de, attribute_map
        ld hl, TILEMAP0
        ld bc, attribute_map.end - attribute_map
        call Memcopy
        xor a
        ld [rVBK], a

        ; Copy palettes to CRAM
        ld a, %1000_0000        ; auto-increment, CRAM address 0
        ld [rBGPI], a
        ld hl, palette
        ld c, palette.end - palette
:       ld a, [hl+]
        ld [rBGPD], a
        dec c
        jr nz, :-

        ; Scroll
        ld a, -25
        ld [rSCX], a
        ld a, -50
        ld [rSCY], a

        ; Turn on screen
        ld a, LCDC_ENABLE | LCDC_BLOCK01
        ld [rLCDC], a
        
        ; Fade out to black
        ; Setup VBlank interrupt
        ld bc, VBlank_ISR
        ld hl, VBlankRoutineAddress
        ld a, c
        ld [hl+], a
        ld a, b
        ld [hl], a
        ld a, IE_VBLANK
        ldh [rIE], a
        ei

        ; Wait 120 frames (2 seconds)
        ld a, 120
:       halt
        dec a
        jp nz, :-

        ;       fade_out_palette_address = fade_out_palettes
        ;       for {
        ;               wait_for_VBlank()
        ;               Memcopy(game_palette, fade_out_palette_address, 16)
        ;               fade_out_palette_address += 16
        ;                if fade_out_palette_address == fade_out_palettes.end{
        ;                        break
        ;                }
        ;       }
        ; Fade palettes
        ld bc, fade_out_palettes
        push bc                         ; sp + 0. Fade-out palettes, 60 entries of 16 bytes
:       halt
        ld a, %1000_0000                ; auto-increment, CRAM address 0
        ld [rBGPI], a
        DerefStackOffset 0
        ld b, 16                         ; paste 16 bytes
:       ld a, [hl+]
        ld [rBGPD], a
        dec b
        jr nz, :-
        
        ; Increment palette address
        pop de
        pop hl
        ld bc, 16
        add hl, bc
        push hl
        push de
        pop hl                           ; Increment Counter
        ld bc, 1
        add hl, bc
        push hl
        ld a, h
        or l
        cp 60
        jp nz, :--
        di
        ret

SECTION "Splash VBlank Interrupt Routine", ROM0
VBlank_ISR:
    reti

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
fade_out_palettes:
        INCBIN "assets/splash_fade_out_palettes.bin"
.end