INCLUDE "hardware.inc"

SECTION "Title ram", WRAM0
wCopyOffset: 
        dw
wRowCount:
        db

SECTION "Title Screen", ROM0
TitleScreen::
        ; Dont add fade-in for now

        ; HDMA transfer for screen and digit tiles
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
        ld [rVDMA_LEN], a                       ; Title transfer 1/2
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
        ld [rVDMA_LEN], a                       ; Title transfer 2/2
        ld de, digit_tiles
        ld hl, $88B0
        ld bc, 4 * 16
        call Memcopy                            ; Digits transfer 1/3
        call wait_for_VBlank
        ld de, digit_tiles + (4 * 16)
        ld hl, $88B0 + (4 * 16)
        ld bc, 4 * 16
        call Memcopy                            ; Digits transfer 2/3
        call wait_for_VBlank
        ld de, digit_tiles + (8 * 16)
        ld hl, $88B0 + (8 * 16)
        ld bc, 2 * 16
        call Memcopy                            ; Digits transfer 3/3
        call wait_for_VBlank

        ; Copy tilemap to VRAM
        ld a, 18
        ld [wRowCount], a
        ld a, LOW(screen_tilemap)
        ld [wCopyOffset], a
        ld a, HIGH(screen_tilemap)
        ld [wCopyOffset + 1], a
        ld hl, $9800
.copyLoopTilemap:
        call wait_for_VBlank
        ld a, [wCopyOffset] :: ld e, a
        ld a, [wCopyOffset + 1] :: ld d, a
        ld bc, 20
        call Memcopy
        ld bc, 32
        add hl, bc
        push hl
        ld a, [wCopyOffset] :: ld l, a
        ld a, [wCopyOffset + 1] :: ld h, a
        ld de, 20
        add hl, de
        ld a, l
        ld [wCopyOffset], a
        ld a, h
        ld [wCopyOffset + 1], a
        pop hl
        ld a, [wRowCount]
        dec a
        ld [wRowCount], a
        jp nz, .copyLoopTilemap

        ; Clear the attributes
        ld a, 1
        ld [rVBK], a
        ld a, 18
        ld [wRowCount], a
        ld hl, $9800
.copyLoopAttr:
        call wait_for_VBlank
        ld d, 0
        ld bc, 20
        call Memset
        ld bc, 32
        add hl, bc
        ld a, [wRowCount]
        dec a
        ld [wRowCount], a
        jp nz, .copyLoopAttr
        xor a
        ld [rVBK], a

        ; Scroll
        xor a
        ld [rSCX], a
        ld [rSCY], a

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
screen_tilemap:
        INCBIN "assets/title.tilemap"
.end
screen_palette:
        INCBIN "assets/title.pal"
.end
digit_tiles:
        INCBIN "assets/digits.2bpp"
.end
