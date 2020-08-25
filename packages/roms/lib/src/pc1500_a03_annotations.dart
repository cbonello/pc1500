const String json = '''
{
    "C000-FFFF": {
        "name": "PC-1500 System Program (ROM), 16KB",
        "areas": {
            "C000-C01C": {
                "name": "Code Section #1",
                "code": {
                    "C001": {
                        "label": "PUSH78",
                        "comment": "System subroutine: Write X register"
                    },
                    "C00E": {
                        "label": "STRCDSPR",
                        "comment": "System subroutine: String data management"
                    }
                }
            },
            "C020-C34E": {
                "name": "BASIC Keywords Table"
            },
            "C34F-C36B": {
                "name": "System Messages"
            },
            "C36C-C385": {
                "name": "DEF Keyboard"
            },
            "C386-C3FF": {
                "name": "Misc Data"
            },
            "C400-D6AC": {
                "name": "Code Section #2",
                "data": {
                    "C443": {
                        "comment": "PC-1500 ROM version data #1"
                    },
                    "C5BD": {
                        "comment": "PC-1500 ROM version data #2"
                    }
                },
                "code": {
                    "C400": {
                        "label": "NXBASEXEC",
                        "comment": "System subroutine: Return BASIC command following a NEXT"
                    },
                    "C401": {
                        "label": "URBASEXEC",
                        "comment": "## System subroutine: Return BASIC command following a NEXT"
                    },
                    "CA58": {
                        "label": "BASINPUT1",
                        "comment": "System subroutine: Standard input with '>' prompt"
                    },
                    "CA7A": {
                        "label": "BASINPUT2",
                        "comment": "System subroutine: Standard input with bel. prompt"
                    },
                    "CA80": {
                        "label": "BASINPUT3",
                        "comment": "System subroutine: Standard input without prompt"
                    },
                    "CC86": {
                        "label": "LINESEAR",
                        "comment": "System subroutine: Find line number"
                    },
                    "CCDE": {
                        "label": "LINEEND",
                        "comment": "System subroutine: Set end of line"
                    },
                    "CD71": {
                        "label": "OFF",
                        "comment": "System subroutine: Turn off pocket computer"
                    },
                    "CD89": {
                        "label": "ERROR1",
                        "comment": "System subroutine: Standard error message #1"
                    },
                    "CD8B": {
                        "label": "ERROR2",
                        "comment": "System subroutine: Output error message (UH = error ID)"
                    },
                    "CE87": {
                        "label": "RSVFKTCODE",
                        "comment": "System subroutine: Calculate RESERVE key code"
                    },
                    "CE9F": {
                        "label": "INITRSV",
                        "comment": "System subroutine: Initialize RESERVE start address"
                    },
                    "CEAF": {
                        "label": "RSVTXTSER",
                        "comment": "System subroutine: Search RESERVE start of text"
                    },
                    "CEC4": {
                        "label": "RSVFKTSER",
                        "comment": "System subroutine: Search for RESERVE key assignment"
                    },
                    "CED0": {
                        "label": "RSVFKTLOAD",
                        "comment": "System subroutine: Set RESERVE keys"
                    },
                    "CF0B": {
                        "label": "RSVTXTLOAD",
                        "comment": "System subroutine: Load RESERVE keys"
                    },
                    "CFCC": {
                        "label": "BASIC1",
                        "comment": "System subroutine: Prepare BASIC start"
                    },
                    "CFD0": {
                        "label": "BASIC2",
                        "comment": "System subroutine: Prepare BASIC start"
                    },
                    "CFFB": {
                        "label": "INITPOI",
                        "comment": "System subroutine: Initialize registers and pointers"
                    },
                    "D021": {
                        "label": "CLRINP2",
                        "comment": "System subroutine: Clear input buffer"
                    },
                    "D02B": {
                        "label": "CLRINP1",
                        "comment": "System subroutine: Clear input buffer"
                    },
                    "D03E": {
                        "label": "ADVICE",
                        "comment": "System subroutine: Handling of system messages"
                    },
                    "D065": {
                        "label": "POPU",
                        "comment": "System subroutine: Pop U from BASIC stack"
                    },
                    "D071": {
                        "label": "PUSHU",
                        "comment": "System subroutine: Save U on BASIC stack"
                    },
                    "D080": {
                        "label": "CLRVAR",
                        "comment": "System subroutine: Clear variable"
                    },
                    "D0B4": {
                        "label": "INITSEAR",
                        "comment": "System subroutine: Initialize search memory"
                    },
                    "D0D2": {
                        "label": "NUMCOMP",
                        "comment": "System subroutine: Comparison of two numeric values"
                    },
                    "D0F9": {
                        "label": "CHARCOMP",
                        "comment": "System subroutine: Comparison of two strings"
                    },
                    "D14C": {
                        "label": "NUMBERCD",
                        "comment": "System subroutine: Read numbers in decimal"
                    },
                    "D14F": {
                        "label": "NUMBERY",
                        "comment": "System subroutine: Read numbers in decimal"
                    },
                    "D2D0": {
                        "label": "BASTRANS",
                        "comment": "System subroutine: BASIC line in input buffer"
                    },
                    "D2E6": {
                        "label": "LINESERU",
                        "comment": "System subroutine: Search for line number during program run"
                    },
                    "D2EA": {
                        "label": "PROGSER",
                        "comment": "System subroutine: Search for a program number"
                    },
                    "D371": {
                        "label": "VARSPACE",
                        "comment": "System subroutine: Reserve variable-space"
                    },
                    "D407": {
                        "label": "VARNAME",
                        "comment": "System subroutine: Variable name determination"
                    },
                    "D45D": {
                        "label": "VARIAB",
                        "comment": "System subroutine: Search for variable address"
                    },
                    "D461": {
                        "label": "VARSEAR",
                        "comment": "System subroutine: Search for variable address"
                    },
                    "D5F9": {
                        "label": "DEZHEXTEST",
                        "comment": "System subroutine: Conversion decimal -> hexadecimal"
                    }
                },
                "D6AD-D6BE": {
                    "name": "Parameters Data"
                },
                "D6BF-DCB2": {
                    "name": "Code Section #3",
                    "code": {
                        "D6C0": {
                            "label": "PARAM",
                            "comment": "System subroutine: Prepare parameters"
                        },
                        "D6DF": {
                            "label": "ARICALC",
                            "comment": "System subroutine: Function analysis and calculation"
                        },
                        "D925": {
                            "label": "COMBINE",
                            "comment": "System subroutine: Combination of two character strings"
                        },
                        "D9B1": {
                            "label": "CHR\$",
                            "comment": "System subroutine: Convert ASCII code to character"
                        },
                        "D9CF": {
                            "label": "STR\$",
                            "comment": "System subroutine: Convert a numerical expression to a string"
                        },
                        "D9D7": {
                            "label": "VAL",
                            "comment": "System subroutine: Convert a string to a number"
                        },
                        "D9DD": {
                            "label": "LEN",
                            "comment": "System subroutine: LEN"
                        },
                        "D9F3": {
                            "label": "LFTMIDRIGT",
                            "comment": "System subroutine: LEFT\$, MID\$ and RIGHT\$"
                        },
                        "DA71": {
                            "label": "MULTIPLY",
                            "comment": "System subroutine: Multiply two 16-bit values"
                        },
                        "DA98": {
                            "label": "FINDOP",
                            "comment": "System subroutine: Operator priority assignment"
                        },
                        "DAA8": {
                            "label": "UNEGATE",
                            "comment": "System subroutine: Negate 16-bit values"
                        },
                        "DAB2": {
                            "label": "USINGCR",
                            "comment": "System subroutine: Generate USING coding"
                        },
                        "DB87": {
                            "label": "ARITEST",
                            "comment": "System subroutine: Test of arithmetic register"
                        },
                        "DB95": {
                            "label": "STRTEST",
                            "comment": "System subroutine: String test"
                        },
                        "DBB1": {
                            "label": "ARRAYTEST1",
                            "comment": "System subroutine: Test field dimensions"
                        },
                        "DBB3": {
                            "label": "ARRAYTEST2",
                            "comment": "System subroutine: Test field dimensions"
                        },
                        "DBBC": {
                            "label": "UREAD",
                            "comment": "System subroutine: Read U register"
                        },
                        "DBD3": {
                            "label": "CMDLOAD",
                            "comment": "System subroutine: Unlock BASIC token"
                        },
                        "DBE0": {
                            "label": "CMDSAVE",
                            "comment": "System subroutine: Secure BASIC token"
                        },
                        "DBF5": {
                            "label": "ARISAVEBAS",
                            "comment": "System subroutine: Store value on BASIC stack"
                        },
                        "DC0C": {
                            "label": "ARIXCOPY",
                            "comment": "System subroutine: Takeover of value"
                        },
                        "DC16": {
                            "label": "ARILOADBAS",
                            "comment": "System subroutine: Load value from BASIC stack"
                        },
                        "DC20": {
                            "label": "VARLOAD",
                            "comment": "System subroutine: Load value from variable"
                        },
                        "DCA6": {
                            "label": "DIMCALC",
                            "comment": "System subroutine: Compute field indexes"
                        }
                    }
                },
                "DCB6-E167": {
                    "name": "Code Section #4",
                    "code": {
                        "DCB6": {
                            "label": "NXRANGE",
                            "comment": "System subroutine: Range test against U and read"
                        },
                        "DCB7": {
                            "label": "URRANGE",
                            "comment": "## System subroutine: Range test against U and read"
                        },
                        "DCC5": {
                            "label": "NXENDE",
                            "comment": "System subroutine: End test against U and read"
                        },
                        "DCC6": {
                            "label": "URENDE",
                            "comment": "## System subroutine: End test against U and read"
                        },
                        "DCD4": {
                            "label": "NXDIRECT",
                            "comment": "System subroutine: Comparison with U and read"
                        },
                        "DCD5": {
                            "label": "URDIRECT",
                            "comment": "## System subroutine: Comparison with U and read"
                        },
                        "DCE9": {
                            "label": "RETURNNJ",
                            "comment": "System subroutine: Return routine"
                        },
                        "DCED": {
                            "label": "RETURNNJY",
                            "comment": "System subroutine: Return routine"
                        },
                        "DCF9": {
                            "label": "RETURNJP",
                            "comment": "System subroutine: Return routine"
                        },
                        "DCFD": {
                            "label": "RETURNJPY",
                            "comment": "System subroutine: Return routine"
                        },
                        "DD08": {
                            "label": "NEXTCHAR",
                            "comment": "System subroutine: Read characters"
                        },
                        "DD13": {
                            "label": "LASTCHAR",
                            "comment": "System subroutine: Return to the last character"
                        },
                        "DD1A": {
                            "label": "HEXDEZTEST",
                            "comment": "System subroutine: Conversion hexadecimal -> decimal"
                        },
                        "DD2D": {
                            "label": "HEXOEZ",
                            "comment": "System subroutine: Conversion hexadecimal -> decimal"
                        },
                        "DDB5": {
                            "label": "UWRITE",
                            "comment": "System subroutine: Write U register"
                        },
                        "DDC8": {
                            "label": "POP78",
                            "comment": "System subroutine: Read X register"
                        },
                        "DDD9": {
                            "label": "VARSTORE",
                            "comment": "System subroutine: Store values in variables"
                        },
                        "DE82": {
                            "label": "TIME",
                            "comment": "System subroutine: Determine time and date"
                        },
                        "DE97": {
                            "label": "SERSTR",
                            "comment": "System subroutine: Find the end of the string"
                        },
                        "DEAF": {
                            "label": "STORESTR",
                            "comment": "System subroutine: Save string"
                        },
                        "DEBC": {
                            "label": "LOADSTR",
                            "comment": "System subroutine: Read message"
                        },
                        "DED1": {
                            "label": "DATALOAD",
                            "comment": "System subroutine: Load BASIC data"
                        },
                        "DEE3": {
                            "label": "DATASAVE",
                            "comment": "System subroutine: Save BASIC data"
                        },
                        "DF0F": {
                            "label": "STRPAR",
                            "comment": "System subroutine: String data management"
                        },
                        "DF23": {
                            "label": "CASE",
                            "comment": "System subroutine: Simulation of a selection loop"
                        },
                        "DF3B": {
                            "label": "BASTEST",
                            "comment": "System subroutine: Check whether the BASIC program is running"
                        },
                        "DF72": {
                            "label": "NEXTLINE",
                            "comment": "System subroutine: Set pointer to next line"
                        },
                        "DF93": {
                            "label": "INITBST",
                            "comment": "System subroutine: Initialize BASIC start address"
                        },
                        "DFB4": {
                            "label": "STRFIND",
                            "comment": "System subroutine: Determine string parameters"
                        },
                        "DFC4": {
                            "label": "STRSPR",
                            "comment": "System subroutine: String data management"
                        },
                        "DFC5": {
                            "label": "STRSTORE",
                            "comment": "System subroutine: String data management"
                        },
                        "DFD9": {
                            "label": "MEMTEST1",
                            "comment": "System subroutine: Testing for memory overlap"
                        },
                        "DFEE": {
                            "label": "MEMTEST2",
                            "comment": "System subroutine: Testing for memory overlap"
                        },
                        "DFF3": {
                            "label": "MEMTEST3",
                            "comment": "System subroutine: Testing for memory overlap"
                        },
                        "DFF5": {
                            "label": "MEMTEST4",
                            "comment": "System subroutine: Testing for memory overlap"
                        },
                        "DFFA": {
                            "label": "MEMTEST5",
                            "comment": "System subroutine: Testing for memory overlap"
                        },
                        "E000": {
                            "label": "RESETINT",
                            "comment": "Reset Interrupt Subroutine"
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
                        },
                        "E153": {
                            "label": "PORTINIT",
                            "comment": "System subroutine: Port register initialization"
                        }
                    },
                    "data": {
                        "DF4A": {
                            "comment": "Number of character tests: 4"
                        },
                        "DF4B": {
                            "comment": "1st character to test: ','"
                        },
                        "DF4C": {
                            "comment": "Branch offset if test is successful"
                        },
                        "DF4D": {
                            "comment": "2nd character to test: '\\"'"
                        },
                        "DF4E": {
                            "comment": "Branch offset if test is successful"
                        },
                        "DF4F": {
                            "comment": "3rd character to test: end-of-line"
                        },
                        "DF50": {
                            "comment": "Branch offset if test is successful"
                        },
                        "DF51": {
                            "comment": "4th character to test: end-of-instruction"
                        },
                        "DF52": {
                            "comment": "Branch offset if test is successful"
                        }
                    }
                },
                "E168-E170": {
                    "name": "I/O Ports Default Values"
                },
                "E171-FBE8": {
                    "name": "Code Section #5",
                    "code": {
                        "E234": {
                            "label": "PVADMINSTR",
                            "comment": "System subroutine: PV pin management"
                        },
                        "E243": {
                            "label": "KEYSCAN2",
                            "comment": "System subroutine: Wait for a key to be depressed"
                        },
                        "E33F": {
                            "label": "AUPOWOFF",
                            "comment": "System subroutine: Auto-power-off"
                        },
                        "E41A": {
                            "label": "KEYIN",
                            "comment": "System subroutine: Key test"
                        },
                        "E42C": {
                            "label": "KEYSCANl",
                            "comment": "System subroutine: Return the keycode of the key that was depressed"
                        },
                        "E451": {
                            "label": "IFBREAK",
                            "comment": "System subroutine: Break test"
                        },
                        "E4A0": {
                            "label": "TXTEQU",
                            "comment": "System subroutine: Compare two strings"
                        },
                        "E4A8": {
                            "label": "BTABSEAR1",
                            "comment": "System subroutine: Search for BASIC tables"
                        },
                        "E4B7": {
                            "label": "BTABSEAR2",
                            "comment": "System subroutine: Search for BASIC tables"
                        },
                        "E573": {
                            "label": "TIMER",
                            "comment": "System subroutine: Timer IC operation via PC"
                        },
                        "E655": {
                            "label": "BEEPSET",
                            "comment": "System subroutine: Treatment of the BEEP-PC6"
                        },
                        "E669": {
                            "label": "STDBEEP",
                            "comment": "System subroutine: Standard beep"
                        },
                        "E66F": {
                            "label": "BEEPUX",
                            "comment": "System subroutine: Beep with regards to U and X registers"
                        },
                        "E88c": {
                            "label": "WAIT64",
                            "comment": "System subroutine: Wait loop"
                        },
                        "E8CA": {
                            "label": "PROGDISP",
                            "comment": "System subroutine: Program display"
                        },
                        "EC5C": {
                            "label": "WAIT64",
                            "comment": "System subroutine: Write to output buffer"
                        },
                        "ED00": {
                            "label": "STRDISP",
                            "comment": "System subroutine: Display N characters and update cursor position"
                        },
                        "ED3B": {
                            "label": "TOPDISP'",
                            "comment": "System subroutine: Display N characters starting from cursor position"
                        },
                        "ED4D": {
                            "label": "WROUT",
                            "comment": "System subroutine: Display one character and update cursor position"
                        },
                        "ED57": {
                            "label": "DISP",
                            "comment": "System subroutine: Display one character at cursor position"
                        },
                        "ED5B": {
                            "label": "ASCIIDIS",
                            "comment": "System subroutine: Display of an ASCII character"
                        },
                        "ED7D": {
                            "label": "HEXTEST",
                            "comment": "System subroutine: Verify hexadecimal numbers"
                        },
                        "ED95": {
                            "label": "HEXA",
                            "comment": "System subroutine: Convert an hexadecimal string into a numeric value"
                        },
                        "EDAB": {
                            "label": "LOALCPOI",
                            "comment": "System subroutine: Load matrix pointer"
                        },
                        "EDB1": {
                            "label": "INCLCPOI",
                            "comment": "System subroutine: Increase matrix pointer"
                        },
                        "EDC1": {
                            "label": "LCDSAVE",
                            "comment": "System subroutine: Backup of display"
                        },
                        "EDD8": {
                            "label": "LCDLOAD",
                            "comment": "System subroutine: Load display"
                        },
                        "EDEF": {
                            "label": "GRAPHIC",
                            "comment": "System subroutine: Graphic display (similar to GPRINT)"
                        },
                        "EDF6": {
                            "label": "GPRNT",
                            "comment": "System subroutine: Graphic display"
                        },
                        "EE1F": {
                            "label": "COLCALC2",
                            "comment": "System subroutine: Calculation of column addresses 2"
                        },
                        "EE22": {
                            "label": "COLCALC1",
                            "comment": "System subroutine: Calculation of column addresses 1"
                        },
                        "EE48": {
                            "label": "LCDSEAR",
                            "comment": "System subroutine: Find address of LCD characters"
                        },
                        "EE71": {
                            "label": "CLRLCD",
                            "comment": "System subroutine: Clear LCD"
                        },
                        "EE80": {
                            "label": "CURSAVE",
                            "comment": "System subroutine: Save cursor and display"
                        },
                        "EE99": {
                            "label": "CURLOAD",
                            "comment": "System subroutine: Load cursor and display"
                        },
                        "EF00": {
                            "label": "BLNKOFF",
                            "comment": "System subroutine: Switch off blinking cursor"
                        },
                        "EFB6": {
                            "label": "SUBTRACT",
                            "comment": "System subroutine: Subtract"
                        },
                        "EFBA": {
                            "label": "ADD",
                            "comment": "System subroutine: Add"
                        },
                        "F01A": {
                            "label": "MULTIPLY",
                            "comment": "System subroutine: Multiply"
                        },
                        "F080": {
                            "label": "CMPLNT",
                            "comment": "System subroutine: Complement"
                        },
                        "F084": {
                            "label": "DIVIDE",
                            "comment": "System subroutine: Divide"
                        },
                        "F0E9": {
                            "label": "SQR",
                            "comment": "System subroutine: Square root"
                        },
                        "F161": {
                            "label": "LN",
                            "comment": "System subroutine: Natural logarithm to base e"
                        },
                        "F165": {
                            "label": "LOG",
                            "comment": "System subroutine: Common logarithm to base 10"
                        },
                        "F1CB": {
                            "label": "EXP",
                            "comment": "System subroutine: Natural antilog (e^n)"
                        },
                        "F1D4": {
                            "label": "10N",
                            "comment": "System subroutine: 10 to the power of N"
                        },
                        "F391": {
                            "label": "COS",
                            "comment": "System subroutine: Cosine"
                        },
                        "F39E": {
                            "label": "TAN",
                            "comment": "System subroutine: Tangent"
                        },
                        "F3A2": {
                            "label": "SIN",
                            "comment": "System subroutine: Sine"
                        },
                        "F492": {
                            "label": "ACS",
                            "comment": "System subroutine: Arccosine"
                        },
                        "F496": {
                            "label": "ATN",
                            "comment": "System subroutine: Arctangent"
                        },
                        "F49A": {
                            "label": "ASN",
                            "comment": "System subroutine: Arcsine"
                        },
                        "F531": {
                            "label": "DEG",
                            "comment": "System subroutine: Convert degrees, minutes and seconds into decimal degrees"
                        },
                        "F564": {
                            "label": "DMS",
                            "comment": "System subroutine: Convert decimal degrees into degrees, minutes and seconds"
                        },
                        "F597": {
                            "label": "ABS",
                            "comment": "System subroutine: Absolute value"
                        },
                        "F59D": {
                            "label": "SGN",
                            "comment": "System subroutine: Return -1 if negative, 0 if zero and 1 if positive"
                        },
                        "F5BE": {
                            "label": "INT",
                            "comment": "System subroutine: Return largest whole number not greater than N"
                        },
                        "F61B": {
                            "label": "NEWRNDCD",
                            "comment": "System subroutine: Generate new random number"
                        },
                        "F661": {
                            "label": "ARIFORMUS",
                            "comment": "System subroutine: Forming calculation results"
                        },
                        "F663": {
                            "label": "ARIFORMAS",
                            "comment": "System subroutine: Forming calculation results"
                        },
                        "F6B4": {
                            "label": "ARIOP01",
                            "comment": "System subroutine: Copy variable X to Y and set to zero"
                        },
                        "F6E6": {
                            "label": "ARISGNTST",
                            "comment": "System subroutine: Sign test between variables X and Y"
                        },
                        "F6FB": {
                            "label": "SGNX",
                            "comment": "System subroutine: Sign of X"
                        },
                        "F707": {
                            "label": "COPYXY",
                            "comment": "System subroutine: Copy variable X to Y"
                        },
                        "F70D": {
                            "label": "COPYXS",
                            "comment": "System subroutine: Copy variable X to S"
                        },
                        "F715": {
                            "label": "COPYSY",
                            "comment": "System subroutine: Copy variable S to Y"
                        },
                        "F729": {
                            "label": "COPYXYPT",
                            "comment": "System subroutine: Copy variable X partially to Y"
                        },
                        "F72F": {
                            "label": "COPYXZPT",
                            "comment": "System subroutine: Copy variable X partially to Z"
                        },
                        "F737": {
                            "label": "COPYSX",
                            "comment": "System subroutine: Copy variable S to X"
                        },
                        "F73D": {
                            "label": "COPYYX",
                            "comment": "System subroutine: Copy variable Y to X"
                        },
                        "F741": {
                            "label": "STDCOPY",
                            "comment": "System subroutine: Standard copying"
                        },
                        "F747": {
                            "label": "CLEARY",
                            "comment": "System subroutine: Clear variable Y"
                        },
                        "F757": {
                            "label": "CLEARX",
                            "comment": "System subroutine: Clear variable X"
                        },
                        "F763": {
                            "label": "CLRMEM",
                            "comment": "System subroutine: Clear memory areas"
                        },
                        "F775": {
                            "label": "ARISHFTR",
                            "comment": "System subroutine: Right shift"
                        },
                        "F79C": {
                            "label": "ARISHFTL",
                            "comment": "System subroutine: Left shift"
                        },
                        "F7A7": {
                            "label": "ARIRND",
                            "comment": "System subroutine: Load the RND register"
                        },
                        "F7B0": {
                            "label": "ARISET",
                            "comment": "System subroutine: Set arithmetic addresses"
                        },
                        "F7B5": {
                            "label": "CHANGXS",
                            "comment": "System subroutine: Swap X and S"
                        },
                        "F7B9": {
                            "label": "CHANGXY",
                            "comment": "System subroutine: Swap X and Y"
                        },
                        "F7CC": {
                            "label": "ARIADDXPT",
                            "comment": "System subroutine: Arithmetic add"
                        },
                        "F7CE": {
                            "label": "ARIADDYXPT",
                            "comment": "System subroutine: Arithmetic add"
                        },
                        "F7DD": {
                            "label": "ARISUBPT",
                            "comment": "System subroutine: Partially subtract Y from X"
                        },
                        "F87F": {
                            "label": "ARIOP04",
                            "comment": "System subroutine: Load decimal 0.9"
                        },
                        "F883": {
                            "label": "ARIOP05",
                            "comment": "System subroutine: Load decimal 90"
                        },
                        "F887": {
                            "label": "ARIOP06",
                            "comment": "System subroutine: Load decimal 180"
                        },
                        "F88B": {
                            "label": "ARIOP02",
                            "comment": "System subroutine: Load decimal 0.6"
                        },
                        "F88F": {
                            "label": "ARIOP03",
                            "comment": "System subroutine: Load decimal 1.0"
                        },
                        "F89C": {
                            "label": "POWER_RAISE",
                            "comment": "System subroutine: Power raise"
                        },
                        "F957": {
                            "label": "TOKGEN",
                            "comment": "System subroutine: Generation of BASIC tokens"
                        },
                        "FA74": {
                            "label": "OPNACCESS",
                            "comment": "System subroutine: BASIC table access"
                        },
                        "FA89": {
                            "label": "BASACCESS",
                            "comment": "System subroutine: BASIC table access"
                        },
                        "FB2A": {
                            "label": "PVRESET",
                            "comment": "System subroutine: PV pin reset"
                        },
                        "FB9D": {
                            "label": "PROTOCOL",
                            "comment": "System subroutine: Logging and tracing"
                        },
                        "FBCB": {
                            "label": "BUFCOPY",
                            "comment": "System subroutine: Copy between out and string buffer"
                        }
                    }
                },
                "FBE9-FBF7": {
                    "name": "3 Bytes Constants"
                },
                "FBF8-FC9F": {
                    "name": "8 Bytes Constants"
                },
                "FCA0-FE7F": {
                    "name": "Characters Bitmap",
                    "bitmaps": {}
                },
                "FE80-FEBF": {
                    "name": "Regular Keyboard"
                },
                "FEC0-FEFF": {
                    "name": "Shifted Keyboard"
                },
                "FF00-FFFF": {
                    "name": "Macro Instructions"
                }
            }
        }
    }
}
''';
