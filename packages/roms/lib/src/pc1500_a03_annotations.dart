const String json = '''
{
    "A800": {
        "comment": "CE-150 ROM version: 44 = version 0, BE = version 1"
    },
    "7894": {
        "comment": "String buffer pointer"
    },
    "7A00-7A07": {
        "comment": "Arithmetic register"
    },
    "D925": {
        "comment": "System Subroutine: Combination of character"
    },
    "D9DC": {
        "comment": "System Subroutine: CHR\$"
    },
    "D9CF": {
        "comment": "System Subroutine: STR\$"
    },
    "D9D7": {
        "comment": "System Subroutine: VAL"
    },
    "D9DD": {
        "comment": "System Subroutine: RIGHT\$, MID\$, LEFT\$"
    },
    "EFB6": {
        "comment": "System Subroutine: Subtract"
    },
    "EFBA": {
        "comment": "System Subroutine: Add"
    },
    "F01A": {
        "comment": "System Subroutine: Multiply"
    },
    "F084": {
        "comment": "System Subroutine: Divide"
    },
    "F161": {
        "comment": "System Subroutine: LN"
    },
    "F165": {
        "comment": "System Subroutine: LOG"
    },
    "F1CB": {
        "comment": "System Subroutine: EXP"
    },
    "F1D4": {
        "comment": "System Subroutine: 10^n"
    },
    "F391": {
        "comment": "System Subroutine: COS"
    },
    "F39E": {
        "comment": "System Subroutine: TAN"
    },
    "F3A2": {
        "comment": "System Subroutine: SIN"
    },
    "F492": {
        "comment": "System Subroutine: ACS"
    },
    "F496": {
        "comment": "System Subroutine: ATN"
    },
    "F49A": {
        "comment": "System Subroutine: ASN"
    },
    "F531": {
        "comment": "System Subroutine: DEG"
    },
    "F564": {
        "comment": "System Subroutine: DMS"
    },
    "F597": {
        "comment": "System Subroutine: ABS"
    },
    "F59D": {
        "comment": "System Subroutine: SGN"
    },
    "F5BE": {
        "comment": "System Subroutine: INT"
    },
    "F89C": {
        "comment": "System Subroutine: Power raise"
    },
    "D0D2": {
        "comment": "System Subroutine: Numerical comparison"
    },
    "D0F9": {
        "comment": "System Subroutine: Character string comparison"
    },
    "D2EA": {
        "comment": "System Subroutine: Line number search"
    },
    "E42C": {
        "comment": "System Subroutine: KEY scan (I)"
    },
    "D461": {
        "comment": "System Subroutine: Variable search"
    },
    "E243": {
        "comment": "System Subroutine: KEY scan (II)"
    },
    "E33F": {
        "comment": "System Subroutine: Auto-power-off"
    },
    "E8CA": {
        "comment": "System Subroutine: Program display"
    },
    "EDEF": {
        "comment": "System Subroutine: Graphic display"
    },
    "ED95": {
        "comment": "System Subroutine: Hexadecimal display (2 bytes - 1 byte)"
    },
    "ED57": {
        "comment": "System Subroutine: One character display"
    },
    "ED3B": {
        "comment": "System Subroutine: 'n' character display"
    },
    "ED4D": {
        "comment": "System Subroutine: Cursor move after one character display"
    },
    "ED00": {
        "comment": "System Subroutine: Cursor move after 'n' character display"
    },
    "D9F3": {
        "comment": "System Subroutine: STR\$"
    },
    "E000": {
        "comment": "Reset Subroutine"
    },
    "E004": {
        "comment": "Disable timer"
    },
    "E006": {
        "comment": "LCD off"
    },
    "E00A": {
        "comment": "Wait for 192*11 CPU cycles (about 1.6 ms)"
    },
    "E00C": {
        "comment": "LCD on"
    },
    "E010": {
        "comment": "Wait for 1.6 ms"
    },
    "E012": {
        "comment": "LCD off"
    },
    "E014-E01C": {
        "comment": "Wait for 11,496 CPU cycles (about 9 ms)"
    }
}
''';
