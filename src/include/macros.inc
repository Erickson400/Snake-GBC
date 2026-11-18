if !def(MACROS_INC)
def MACROS_INC equ 1

def _enum_name equs ""
def _enum_offset equ 0
def _enum_step equ 0
def _is_inside_enum equ 0

; \1 Symbol: Enum name
; \2 Int:    Offset (Optional)
; \3 Int:    Step   (Optional)
macro enum
        if _NARG == 1
                redef _enum_offset equ 0
                redef _enum_step equ 1
        elif _NARG == 2
                redef _enum_offset equ \2
                redef _enum_step equ 1
        elif _NARG == 3
                redef _enum_offset equ \2
                redef _enum_step equ \3
                assert _enum_step > 0
        else
                fail "Invalid enum definition"
        endc
        redef _enum_name equs "\1"
        redef _is_inside_enum equ 1
endm

; \1 Symbol: Enum value name
macro enum_value
        assert _is_inside_enum == 1
        def {_enum_name}_\1 equ _enum_offset
        redef _enum_offset equ _enum_offset + _enum_step
endm

macro enumend
        assert _is_inside_enum == 1
        redef _is_inside_enum equ 0
endm

endc

