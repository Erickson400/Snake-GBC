INCLUDE "hardware.inc"



SECTION "Title Screen", ROM0
TitleScreen::
        ; HDMA transfer for screen tiles
        ld a, HIGH(screen_tiles)
        ld [rVDMA_SRC_HIGH], a
        ld a, LOW(screen_tiles)
        ld [rVDMA_SRC_LOW], a
        ld a, HIGH($8000)
        ld [rVDMA_DEST_HIGH], a
        ld a, LOW($8000)
        ld [rVDMA_DEST_LOW], a
        call wait_for_VBlank
        ld a, 127
        ld [rVDMA_LEN], a                       ; Block 0
        ld a, HIGH(screen_tiles + (16 * 127))
        ld [rVDMA_SRC_HIGH], a
        ld a, LOW(screen_tiles + (16 * 127))
        ld [rVDMA_SRC_LOW], a
        ld a, HIGH($8000 + (16 * 127))
        ld [rVDMA_DEST_HIGH], a
        ld a, LOW($8000 + (16 * 127))
        ld [rVDMA_DEST_LOW], a
        call wait_for_VBlank
        ld a, 11
        ld [rVDMA_LEN], a                       ; Block 1
        call wait_for_VBlank



        ; Copy title screen tiles to VRAM
;        ld de, screen_tiles
;        ld hl, $8000
;        ld bc, screen_tiles.end - screen_tiles
;        call Memcopy
        
        ; Copy tilemap to VRAM
;        ld de, screen_tilemap
;        ld hl, TILEMAP0
;        ld bc, screen_tilemap.end - screen_tilemap
;        call Memcopy
;        
;        ; Copy attributes to VRAM 
;        ld a, 1
;        ld [rVBK], a
;        ld de, screen_attribute_map
;        ld hl, TILEMAP0
;        ld bc, screen_attribute_map.end - screen_attribute_map
;        call Memcopy
;        xor a
;        ld [rVBK], a

        ; Copy palettes to CRAM
        ld a, %1000_0000        ; auto-increment, CRAM address 0
        ld [rBGPI], a
        ld hl, screen_palette
        ld c, screen_palette.end - screen_palette
:       ld a, [hl+]
        ld [rBGPD], a
        dec c
        jr nz, :-



        ret



SECTION "Title Assets", ROM0
ALIGN 4
screen_tiles:
        INCBIN "assets/title.2bpp"
        DS ALIGN [4, 0]
.end
ALIGN 4
screen_attribute_map:
        INCBIN "assets/title.attrmap"
        DS ALIGN [4, 0]
.end
ALIGN 4
screen_tilemap:
        INCBIN "assets/title.tilemap"
        DS ALIGN [4, 0]
.end
ALIGN 4
screen_palette:
        INCBIN "assets/title.pal"
        DS ALIGN [4, 0]
.end

