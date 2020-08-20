const String json = '''
{
    "memory-bank": 0,
    "sections": {
        "C000-FFFF": {
            "name": "PC-1500 SYSTEM PROGRAM (ROM), 16KB",
            "type": "rom",
            "content": {
                "D925": {
                    "name": "COMBINATION_OF_CHARACTERS"
                    "comment": "System subroutine: Combination of two character strings"
                },
                "D9DC": {
                    "name": "CHR\$"
                    "comment": "System subroutine: Convert ASCII code to character"
                },
                "D9CF": {
                    "name": "STR\$"
                    "comment": "System subroutine: Convert a numerical expression to a string"
                },
                "D9D7": {
                    "name": "VAL"
                    "comment": "System subroutine: Convert a string to a number"
                },
                "D9DD": {
                    "name": "RIGHT\$_MID\$_LEFT\$"
                    "comment": "System subroutines: Extract characters from a string"
                },
                "EFB6": {
                    "name": "SUBTRACT"
                    "comment": "System subroutine: Subtract"
                },
                "EFBA": {
                    "name": "ADD"
                    "comment": "System subroutine: Add"
                },
                "F01A": {
                    "name": "MULTIPLY"
                    "comment": "System subroutine: Multiply"
                },
                "F084": {
                    "name": "DIVIDE"
                    "comment": "System subroutine: Divide"
                },
                "F161": {
                    "name": "LN"
                    "comment": "System subroutine: Natural logarithm to base e"
                },
                "F165": {
                    "name": "LOG"
                    "comment": "System subroutine: Common logarithm to base 10"
                },
                "F1CB": {
                    "name": "EXP"
                    "comment": "System subroutine: Natural antilog (e^n)"
                },
                "F1D4": {
                    "name": "10N"
                    "comment": "System subroutine: 10 to the power of N"
                },
                "F391": {
                    "name": "COS"
                    "comment": "System subroutine: Cosine"
                },
                "F39E": {
                    "name": "TAN"
                    "comment": "System subroutine: Tangent"
                },
                "F3A2": {
                    "name": "SIN"
                    "comment": "System subroutine: Sine"
                },
                "F492": {
                    "name": "ACS",
                    "comment": "System subroutine: Arccosine"
                },
                "F496": {
                    "name": "ATN",
                    "comment": "System subroutine: Arctangent"
                },
                "F49A": {
                    "name": "ASN",
                    "comment": "System subroutine: Arcsine"
                },
                "F531": {
                    "name": "DEG",
                    "comment": "System subroutine: Convert degrees, minutes and seconds into decimal degrees"
                },
                "F564": {
                    "name": "DMS",
                    "comment": "System subroutine: Convert decimal degrees into degrees, minutes and seconds"
                },
                "F597": {
                    "name": "ABS",
                    "comment": "System subroutine: Absolute value"
                },
                "F59D": {
                    "name": "SGN",
                    "comment": "System subroutine: Return -1 if negative, 0 if zero and 1 if positive"
                },
                "F5BE": {
                    "name": "INT",
                    "comment": "System subroutine: Return largest whole number not greater than N"
                },
                "F89C": {
                    "name": "POWER_RAISE",
                    "comment": "System subroutine: Power raise"
                },
                "D0D2": {
                    "name": "NUMERICAL_COMPARISON",
                    "comment": "System subroutine: Comparison of two numeric values"
                },
                "D0F9": {
                    "name": "CHARACTER_STRING_COMPARISON",
                    "comment": "System subroutine: Comparison of two strings"
                },
                "D2EA": {
                    "name": "LINE_NUMBER_SEARCH",
                    "comment": "System subroutine: Search for a BASIC line number"
                },
                "E42C": {
                    "name": "KEY_SCAN_I",
                    "comment": "System subroutine: Return the keycode of the key that was depressed"
                },
                "D461": {
                    "name": "VARIABLE_SEARCH",
                    "comment": "System subroutine: Search for a BASIC variable"
                },
                "E243": {
                    "name": "KEY_SCAN_II",
                    "comment": "System subroutine: Wit for a key to be depressed"
                },
                "E33F": {
                    "name": "AUTO_POWER_OFF",
                    "comment": "System subroutine: Configure auto-power off"
                },
                "E8CA": {
                    "name": "PROGRAM_DISPLAY",
                    "comment": "System subroutine: Display a BASIC line number"
                },
                "EDEF": {
                    "name": "GRAPHIC_DISPLAY",
                    "comment": "System subroutine: Display a grpahic"
                },
                "ED95": {
                    "name": "HEXADECIMAL",
                    "comment": "System subroutine: Convert an hexadecimal string into a numeric value"
                },
                "ED57": {
                    "name": "ONE_CHARACTER_DISPLAY",
                    "comment": "System subroutine: Display one character at cursor position"
                },
                "ED3B": {
                    "name": "N_CHARACTER_DISPLAY'",
                    "comment": "System subroutine: Display N characters starting from cursor position"
                },
                "ED4D": {
                    "name": "CURSOR_MOVE_AFTER_ON_CHARACTER_DISPLAY",
                    "comment": "System subroutine: Display one character and update cursor position"
                },
                "ED00": {
                    "name": "CURSOR_MOVE_AFTER_N_CHARACTER_DISPLAY",
                    "comment": "System subroutine: Display N characters and update cursor position"
                },
                "E000": {
                    "name": "RESET_SUBROUTINE",
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
        }
    }
}
''';
