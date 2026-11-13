INCLUDE "hardware.inc"

SECTION "Level ram", WRAM0
wCopyOffset: 
        dw
wRowCount:
        db
wScore::
        dw

SECTION "Level Screen", ROM0
LevelScreen::
        call wait_for_VBlank

        ; Turn off screen
        xor a :: ld [rLCDC], a

        ; Clear Block0
        ld hl, $8000
        ld d, 0
        ld bc, 2048
        call Memset

        ; HDMA transfer level tiles
        ld a, HIGH(level_tiles)  :: ld [rVDMA_SRC_HIGH], a
        ld a, LOW(level_tiles)   :: ld [rVDMA_SRC_LOW], a
        ld a, HIGH($8000)        :: ld [rVDMA_DEST_HIGH], a
        ld a, LOW($8000)         :: ld [rVDMA_DEST_LOW], a
        ld a, ((level_tiles.end - level_tiles) / 16) - 1
        ld [rVDMA_LEN], a

        call LoadSnakeTiles

        ; Copy tilemap to VRAM
        ld a, 18                  :: ld [wRowCount], a
        ld a, LOW(level_tilemap)  :: ld [wCopyOffset], a
        ld a, HIGH(level_tilemap) :: ld [wCopyOffset + 1], a
        ld hl, $9800
.copyLoopTilemap:
        ld a, [wCopyOffset]     :: ld e, a
        ld a, [wCopyOffset + 1] :: ld d, a
        ld bc, 20
        call Memcopy
        ld bc, 32
        add hl, bc
        push hl
        ld a, [wCopyOffset]     :: ld l, a
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

        ; Load palette
        ld a, $80 | 0 :: ld [rBGPI], a        ; auto-increment, CRAM address 0
        ld c, 8
        ld hl, level_palette
:       ld a, [hl+]
        ld [rBGPD], a
        dec c
        jr nz, :-
        ld c, 8
        ld hl, level_digit_palette
:       ld a, [hl+]
        ld [rBGPD], a
        dec c
        jr nz, :-

        call LoadSnakePalette

        ; Set digit palette to 1 in attributes
        ld a, 1  :: ld [rVBK], a
        ld a, 1
        ld [$9A26], a
        ld [$9A26 + 1], a
        ld [$9A26 + 2], a
        ld [$9A30], a
        ld [$9A30 + 1], a
        ld [$9A30 + 2], a
        xor a :: ld [rVBK], a

        ; Load hi-score
        ld a, $A
        ld [0], a               ; Enable sram
        ld a, [sHiScore]     :: ld [wHiScore], a
        ld a, [sHiScore + 1] :: ld [wHiScore + 1], a
        ld hl, sSignature
        ld a, [hl+]
        cp 9
        jr nz, .falseSignature
        ld a, [hl+]
        cp 10
        jr nz, .falseSignature
        ld a, [hl+]
        cp 21
        jr nz, .falseSignature
        jr .validSignature
.falseSignature:
        ; Set score to 0 if false signature
        xor a
        ld [wHiScore], a
        ld [wHiScore + 1], a
.validSignature:
        xor a
        ld [0], a               ; Disable sram

        ; Reset score
        xor a
        ld [wScore], a
        ld [wScore + 1], a

        ; Render HiScore digits
        ld a, [wHiScore + 1]
        and $F
        add $80
        ld hl, $9A26    ; Hi-score tiles
        ld [hl], a
        ld a, [wHiScore]
        srl a :: srl a :: srl a :: srl a
        add $80
        ld hl, $9A27
        ld [hl], a
        ld a, [wHiScore]
        and $F
        add $80
        ld hl, $9A28
        ld [hl], a

        call RenderScoreDigits

        ; Turn on screen
        ld a, LCDC_ENABLE | LCDC_BLOCK01
        ldh [rLCDC], a

        ret

RenderScoreDigits:
        ld a, [wScore + 1]
        and $F
        add $80
        ld hl, $9A30    ; Score tiles
        ld [hl], a
        ld a, [wScore]
        srl a :: srl a :: srl a :: srl a
        add $80
        ld hl, $9A31
        ld [hl], a
        ld a, [wScore]
        and $F
        add $80
        ld hl, $9A32
        ld [hl], a
        ret

SECTION "Level Assets", ROM0
DS ALIGN [4, 0]
level_tiles:
        INCBIN "assets/level.2bpp"
        DS ALIGN [4, 0]
.end
level_tilemap:
        INCBIN "assets/level.tilemap"
.end
level_palette:
        INCBIN "assets/level.pal"
.end
level_digit_palette:
        INCBIN "assets/level_digit.pal"
.end
