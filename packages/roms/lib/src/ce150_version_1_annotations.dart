const String json = '''
{
    "memory-bank": 0,
    "sections": {
        "7600-7BFF": {
            "name": "CE-150 SYSTEM PROGRAM (ROM), 8KB",
            "type": "rom",
            "content": {
                "A519": {
                    "name": "COLOR_DESIGNATION",
                    "comment": "Printer subroutine: Color designation"
                },
                "A781": {
                    "name": "PRINT",
                    "comment": "Printer subroutine: Print"
                },
                "A800": {
                    "name": "CE150_ROM_VERSION",
                    "comment": "CE-150 ROM version: 44H = version 0, BEH = version 1"
                },
                "A9F1": {
                    "name": "LINEFEED",
                    "comment": "Printer subroutine: Linefeed"
                },
                "AA04": {
                    "name": "PAPER_FEED",
                    "comment": "Printer subroutine: Paper feed"
                },
                "ACBB": {
                    "name": "GET_TEXT_MODE_READY",
                    "comment": "Printer subroutine: Get TEXT mode ready"
                },
                "AAE3": {
                    "name": "PEN_UP_DOWN",
                    "comment": "Printer subroutine: Pen up/down"
                },
                "A8DD": {
                    "name": "MOTOR_DRIVE",
                    "comment": "Printer subroutine: Motor drive"
                },
                "A769": {
                    "name": "MOTOR_OFF",
                    "comment": "Printer subroutine: Motor off"
                },
                "ABEF": {
                    "name": "GET_GRAPHIC_MODE_READY",
                    "comment": "Printer subroutine: Get GRAPHIC mode ready"
                },
                "BF11": {
                    "name": "REMOTE_ON",
                    "comment": "Cassette tape: Remote on"
                },
                "BF43": {
                    "name": "REMOTE_OFF",
                    "comment": "Cassette tape: Remote off"
                },
                "BDCC": {
                    "name": "ONE_CHARACTER_SAVE",
                    "comment": "Cassette tape: One character save"
                },
                "BDF0": {
                    "name": "ONE_CHARACTER_LOAD",
                    "comment": "Cassette tape: One character load"
                },
                "BCEB": {
                    "name": "HEADER_INPUT_OUTPUT",
                    "comment": "Cassette tape: Header input/output"
                },
                "BBF5": {
                    "name": "CMT_IO_CONTROL",
                    "comment": "Cassette tape: CMT I/O control"
                },
                "BBD6": {
                    "name": "CREATE_HEADER",
                    "comment": "Cassette tape: Create header"
                },
                "BD3C": {
                    "name": "TRANSFER_FILE",
                    "comment": "Cassette tape: Transfer file"
                }
            }
        }
    }
}
''';
