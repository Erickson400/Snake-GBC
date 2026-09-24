INCLUDE "hardware.inc"

SECTION "Splash ram", WRAM0
wFadePalettesAddress: 
        dw
wFadeOutCounter:
        db

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
        ld a, -55
        ld [rSCY], a

        ; Turn on screen
        ld a, LCDC_ENABLE | LCDC_BLOCK01
        ldh [rLCDC], a
        
        ; Setup VBlank interrupt
        ld bc, VBlank_ISR
        ld hl, wVBlankRoutineAddress
        call store_bc_at_address_hl
        ld a, IE_VBLANK
        ldh [rIE], a
        ld hl, wVBlankRoutineAddress
        call deref_hl
        ei
        halt
        nop

        ; Wait 120 frames (2 seconds)
        ld c, 120
:       ld hl, wVBlankRoutineAddress
        call deref_hl
        halt
        nop
        dec c
        jp nz, :-

        ; Start fading animation
        ld bc, fade_out_palettes        ; Initialize fade palette address
        ld a, c
        ld [wFadePalettesAddress], a
        ld a, b
        ld [wFadePalettesAddress + 1], a
        ld a, 60
        ld [wFadeOutCounter], a
.palette_animation_loop:
        ld hl, wVBlankRoutineAddress
        call deref_hl
        halt
        nop
        ld a, %1000_0000                ; auto-increment, CRAM address 0
        ld [rBGPI], a
        ld hl, wFadePalettesAddress
        call deref_hl
        ld b, 16                         ; paste 16 bytes
:       ld a, [hl+]
        ld [rBGPD], a
        dec b
        jr nz, :-

        ; Update palette address
        ld b, h :: ld c, l
        ld hl, wFadePalettesAddress
        call store_bc_at_address_hl

        ; Update counter
        ld hl, wFadeOutCounter
        ld a, [hl]
        dec a
        ld [hl], a
        jp nz, .palette_animation_loop
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