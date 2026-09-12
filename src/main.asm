INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
        nop
        jp EntryPoint
        ds $150 - @, 0

SECTION "Main", ROM0[$150]
EntryPoint:
        jp EntryPoint
