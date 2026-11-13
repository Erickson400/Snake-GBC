INCLUDE "hardware.inc"

def RIGHT equ 0
def DOWN  equ 1
def LEFT  equ 2
def UP    equ 3

def EMPTY     equ 2
def APPLE     equ 32
def HEAD_H    equ 33
def HEAD_V    equ 34
def TAIL_H    equ 35
def TAIL_V    equ 36
def BODY_H    equ 37
def BODY_V    equ 38
def CORNER_LU equ 38

SECTION "Snake ram", WRAM0
wEmptyTilesIndex: dw 
wEmptyTilesPool: ds 300 * 2
wSnakeDirection: db

SECTION "Snake Screen", ROM0
LoadSnakeTiles::
        ld a, HIGH(snake_tiles)  :: ld [rVDMA_SRC_HIGH], a
        ld a, LOW(snake_tiles)   :: ld [rVDMA_SRC_LOW], a
        ld a, HIGH($8200)        :: ld [rVDMA_DEST_HIGH], a
        ld a, LOW($8200)         :: ld [rVDMA_DEST_LOW], a
        ld a, ((snake_tiles.end - snake_tiles) / 16) - 1
        ld [rVDMA_LEN], a
        ret

LoadSnakePalette::
        ld a, $80 | 16 :: ld [rBGPI], a        ; auto-increment, CRAM address 16
        ld c, 8
        ld hl, snake_palette
:       ld a, [hl+]
        ld [rBGPD], a
        dec c
        jr nz, :-
        ret


SECTION "Snake Assets", ROM0
DS ALIGN [4, 0]
snake_tiles:
        INCBIN "assets/level_snake.2bpp"
        DS ALIGN [4, 0]
.end
snake_palette:
        INCBIN "assets/level_snake.pal"
.end

