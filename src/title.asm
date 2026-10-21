INCLUDE "hardware.inc"

SECTION "Title ram", WRAM0
wCopyOffset: 
        dw
wRowCount:
        db
wHiScore:
        dw
wFadePalettesAddress: 
        dw
wFadeInCounter:
        db
wFrameCounter:
        db
wIsStartVisible:
        db

SECTION "Saved data", SRAM
sHiScore:
        dw      ; In BCD form
sSignature:
        ds 3    ; 9, 10, 21

SECTION "Title Screen", ROM0
TitleScreen::
        call wait_for_VBlank

        ; Set palette to black
        ld a, %1000_0000        ; auto-increment, CRAM address 0
        ld [rBGPI], a
        xor a
        ld c, 8
:       ld [rBGPD], a
        dec c
        jr nz, :-

        ; HDMA transfer for screen and digit tiles
        ld a, HIGH(screen_tiles) :: ld [rVDMA_SRC_HIGH], a
        ld a, LOW(screen_tiles)  :: ld [rVDMA_SRC_LOW], a
        ld a, HIGH($8000)        :: ld [rVDMA_DEST_HIGH], a
        ld a, LOW($8000)         :: ld [rVDMA_DEST_LOW], a
        ld a, ((screen_tiles.end - screen_tiles) / 16) - 1
        ld [rVDMA_LEN], a                                       ; Title transfer
        call wait_for_VBlank
        ld a, HIGH(digit_tiles) :: ld [rVDMA_SRC_HIGH], a
        ld a, LOW(digit_tiles)  :: ld [rVDMA_SRC_LOW], a
        ld a, HIGH($8800)       :: ld [rVDMA_DEST_HIGH], a
        ld a, LOW($8800)        :: ld [rVDMA_DEST_LOW], a
        ld a, ((digit_tiles.end - digit_tiles) / 16) - 1
        ld [rVDMA_LEN], a                                       ; Digits transfer

        ; Copy tilemap to VRAM
        ld a, 18                   :: ld [wRowCount], a
        ld a, LOW(screen_tilemap)  :: ld [wCopyOffset], a
        ld a, HIGH(screen_tilemap) :: ld [wCopyOffset + 1], a
        ld hl, $9800
.copyLoopTilemap:
        call wait_for_VBlank
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

        ; Clear the attributes
        ld a, 1  :: ld [rVBK], a
        ld a, 18 :: ld [wRowCount], a
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
        xor a :: ld [rVBK], a

        ; Scroll
        xor a
        ld [rSCX], a
        ld [rSCY], a

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

        ; Render digits
        ld a, [wHiScore + 1]
        and $F
        add $80
        ld hl, $9A26
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

        ; Start fading animation
        ld bc, fade_in_palette          ; Initialize fade palette address
        ld a, c  :: ld [wFadePalettesAddress], a
        ld a, b  :: ld [wFadePalettesAddress + 1], a
        ld a, 60 :: ld [wFadeInCounter], a
.palette_animation_loop:
        call wait_for_VBlank
        ld a, %1000_0000                ; auto-increment, CRAM address 0
        ld [rBGPI], a
        ld hl, wFadePalettesAddress
        call deref_hl
        ld b, 8                         ; paste 8 bytes
:       ld a, [hl+]
        ld [rBGPD], a
        dec b
        jr nz, :-
        ld b, h :: ld c, l              ; Update palette address
        ld hl, wFadePalettesAddress
        call store_bc_at_address_hl
        ld hl, wFadeInCounter           ; Update counter
        ld a, [hl]
        dec a
        ld [hl], a
        jp nz, .palette_animation_loop

        ; Wait 60 frames (1 second)
        ld c, 60
:       call wait_for_VBlank
        dec c
        jp nz, :-

        ; Blinking Press Start To Play
        call wait_for_VBlank
        ld a, 6 :: ld [rBGPI], a        ; CRAM address 6
        ld a, [rBGPD]
        ld b, a
        ld a, 7 :: ld [rBGPI], a        ; CRAM address 7
        ld a, [rBGPD]
        ld c, a
        push bc                         ; Store the original color
        xor a :: ld [wFrameCounter], a
        ld a, 1 :: ld [wIsStartVisible], a
.titleLoop:
        call wait_for_VBlank
        ;
        ; Check if start is pressed,
        ; if so then exit loop or return.
        ;
        ld a, [wFrameCounter]
        cp 30
        jp nz, .counterNotFinished
        ld a, [wIsStartVisible]
        cp 1
        jr nz, .isNotVisible
.isVisible:
        ld a, $80 | 6 :: ld [rBGPI], a        ; auto-increment, CRAM address 6
        ld a, $FF
        ld [rBGPD], a           ; Hide
        ld [rBGPD], a
        ld [wIsStartVisible], a
        jr .endVisiblityCheck
.isNotVisible:
        ld a, $80 | 6 :: ld [rBGPI], a        ; auto-increment, CRAM address 6
        pop bc
        ld a, b
        ld [rBGPD], a           ; Show
        ld a, c
        ld [rBGPD], a
        push bc
        ld a, 1
        ld [wIsStartVisible], a
.endVisiblityCheck:
        xor a
        ld [wFrameCounter], a   ; Reset counter
.counterNotFinished:
        ld a, [wFrameCounter]
        inc a
        ld [wFrameCounter], a
        jp .titleLoop
        ret

SECTION "Title Assets", ROM0
DS ALIGN [4, 0]
screen_tiles:
        INCBIN "assets/title.2bpp"
        DS ALIGN [4, 0]
.end
screen_tilemap:
        INCBIN "assets/title.tilemap"
.end
DS ALIGN [4, 0]
digit_tiles:
        INCBIN "assets/digits.2bpp"
        DS ALIGN [4, 0]
.end
fade_in_palette:
        INCBIN "assets/title_fade_in_palette.bin"
.end