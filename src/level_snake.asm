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
wEmptyTilesListPointer: dw      ; Points to the next empty slot
wEmptyTilesList: ds 300 * 2     ; Each byte has an X and Y nybble

wSnakeDirection: db             ; RIGHT, DOWN, LEFT, UP
wSnakeBodyPointer: dw           ; Points to the next empty slot
wSnakeBodyList: ds 300 * 2      ; Each byte has a tilemap address. The first is the head, the last is the tail

SECTION "Snake Screen", ROM0

InitializeSnake::
        ld a, RIGHT :: ld [wSnakeDirection], a

        ld hl, $99A8    
        ld a, 33        ; Head
        ld [hl], a
        ld a, l :: ld [wSnakeBodyList], a
        ld a, h :: ld [wSnakeBodyList + 1], a
        ld a, 1 :: ld [rVBK], a
        ld a, 2
        ld [hl], a
        xor a :: ld [rVBK], a
        dec hl
        ld a, 37        ; Body
        ld [hl], a
        ld a, l :: ld [wSnakeBodyList + 2], a
        ld a, h :: ld [wSnakeBodyList + 3], a
        ld a, 1 :: ld [rVBK], a
        ld a, 2
        ld [hl], a
        xor a :: ld [rVBK], a
        dec hl
        ld a, 35        ; Tail
        ld [hl], a
        ld a, l :: ld [wSnakeBodyList + 4], a
        ld a, h :: ld [wSnakeBodyList + 5], a
        ld a, 1 :: ld [rVBK], a
        ld a, 2
        ld [hl], a
        xor a :: ld [rVBK], a
        
        ld hl, wSnakeBodyList
        ld bc, 3 * 2
        add hl, bc
        ld a, l :: ld [wSnakeBodyPointer], a
        ld a, h :: ld [wSnakeBodyPointer + 1], a
        ret

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

InitializeApple::
        ; Count and append the addresses of the empty tiles.

        ; Get a random tile from that list.


        ; Set that tilemap location to the Apple tile.

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

