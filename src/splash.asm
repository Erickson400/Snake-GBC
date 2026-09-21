INCLUDE "hardware.inc"

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
        
        sleep(120 frames)
        for 240 {
                Dim the first color on palette 0
                sleep(30 frames)
                If color reached 0 or is lower than 0 then exit loop
        }
        
        
        



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