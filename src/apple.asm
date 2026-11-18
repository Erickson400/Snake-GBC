INCLUDE "hardware.inc"

SECTION "Apple ram", WRAM0
wEmptyTilesCounterX: db
wEmptyTilesCounterY: db
wEmptyTilesCounterAddress: dw
wEmptyTilesListPointer: dw      ; Points to the next empty slot
wEmptyTilesList: ds 300 * 2     ; Each byte has an X and Y nybble

SECTION "Apple", ROM0
InitializeApple::
        call UpdateEmptyTilesListLCDOff

        ; Get a random tile from that list.

        ; Set that tilemap location to the Apple tile.

        ret

UpdateEmptyTilesListLCDOff::
        ;ld a, wEmptyTilesList     :: ld [wEmptyTilesListPointer], a
        ;ld a, wEmptyTilesList + 1 :: ld [wEmptyTilesListPointer + 1], a

        ld a, 20  :: ld [wEmptyTilesCounterX], a
        ld a, 18  :: ld [wEmptyTilesCounterY], a
        xor a     :: ld [wEmptyTilesCounterAddress], a
        ld a, $98 :: ld [wEmptyTilesCounterAddress + 1], a
.loopY:
        ld a, [wEmptyTilesCounterAddress]     :: ld l, a
        ld a, [wEmptyTilesCounterAddress + 1] :: ld h, a
        call deref_hl
        ld a, [hl]
        cp 2
        jr nz, .isNotEmpty
.isEmpty:

.isNotEmpty:



.loopX:

        ret

AppendHLToEmptyList::
        push hl
        ld a, [wEmptyTilesListPointer] :: ld c, a
        ld a, [wEmptyTilesListPointer + 1] :: ld b, a
        

        ret




