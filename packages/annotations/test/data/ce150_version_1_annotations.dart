const String json = '''
{
    "A000-BFFF": {
        "name": "CE-150 SYSTEM PROGRAM (ROM), 8KB",
        "areas": {
            "A000-A28A": {
                "name": "Characters Bitmap"
            },
            "A28B-AFF9": {
                "name": "Code Section Printer #1",
                "code": {
                    "A306": {
                        "label": "LFOFF",
                        "comment": "Printer subroutine: Paper feed interrupt off"
                    },
                    "A519": {
                        "label": "COLORSEL",
                        "comment": "Printer subroutine: Color designation"
                    },
                    "A769": {
                        "label": "MOTOROFF",
                        "comment": "Printer subroutine: Motor off"
                    },
                    "A781": {
                        "label": "PRNT",
                        "comment": "Printer subroutine: Print"
                    },
                    "A8DD": {
                        "label": "MOTDRIVE",
                        "comment": "Printer subroutine: Motor drive"
                    },
                    "A9F1": {
                        "label": "LINEFEED",
                        "comment": "Printer subroutine: Linefeed"
                    },
                    "AA04": {
                        "label": "PAPFEED",
                        "comment": "Printer subroutine: Paper feed"
                    },
                    "AAE3": {
                        "label": "PENUPDOW",
                        "comment": "Printer subroutine: Pen up/down"
                    },
                    "ABEF": {
                        "label": "GRAPHSEL",
                        "comment": "Printer subroutine: Switch to graphic mode"
                    },
                    "ACBB": {
                        "label": "TEXTSEL",
                        "comment": "Printer subroutine: Get TEXT mode ready"
                    }
                },
                "data": {
                    "A800": {
                        "label": "CE150VERS",
                        "comment": "CE-150 ROM version: 44H = version 0, BEH = version 1"
                    }
                }
            },
            "AFFA-B009": {
                "name": "Printer Peripheral Name"
            },
            "B00A-B015": {
                "name": "Code Section Printer #2"
            },
            "B020-B0E9": {
                "name": "BASIC Printer Keywords Table"
            },
            "B0EA-B7FF": {
                "name": "Code Section Printer #3",
                "code": {
                    "B4F4": {
                        "label": "TXTPRNT",
                        "comment": "Cassette tape: Print string"
                    }
                }
            },
            "B800-B809": {
                "name": "Cassette Peripheral Name"
            },
            "B80A-B81C": {
                "name": "Code Section Cassette #1"
            },
            "B820-B884": {
                "name": "BASIC Cassette Keywords Table"
            },
            "B888-BFFC": {
                "name": "Code Section Cassette #2",
                "code": {
                    "BBA5": {
                        "label": "CMTINIT",
                        "comment": "Cassette tape: Initialize the CMT sequence"
                    },
                    "BBB9": {
                        "label": "UHITEST",
                        "comment": "Cassette tape: U-register maximum value test"
                    },
                    "BBD6": {
                        "label": "HEADERCR",
                        "comment": "Cassette tape: Create header"
                    },
                    "BBF5": {
                        "label": "CMTIO",
                        "comment": "Cassette tape: Set the CMT input/output control"
                    },
                    "BCE8": {
                        "label": "HEADERIO",
                        "comment": "Cassette tape: Header input/output"
                    },
                    "BD3C": {
                        "label": "FILETRNS",
                        "comment": "Cassette tape: Transfer file"
                    },
                    "BDC7": {
                        "label": "YSAVE",
                        "comment": "Cassette tape: Save Y register"
                    },
                    "BDCC": {
                        "label": "CHARSAVE",
                        "comment": "Cassette tape: One character save"
                    },
                    "BDF0": {
                        "label": "CHARLOAD",
                        "comment": "Cassette tape: One character load"
                    },
                    "BF11": {
                        "label": "RMTON",
                        "comment": "Cassette tape: Remote on"
                    },
                    "BF28": {
                        "label": "RMTSWCH",
                        "comment": "Cassette tape: Switch recorder"
                    },
                    "BF43": {
                        "label": "RMTOFF",
                        "comment": "Cassette tape: Remote off"
                    }
                }
            }
        }
    }
}
''';
