const String json = '''
{
    "memory-bank": 0,
    "sections": {
        "7600-7BFF": {
            "name": "STANDARD USER SYSTEM MEMORY (RAM), 1.5KB",
            "type": "ram",
            "content": {
                "7600-764F": {
                    "name":" "DISPLAY_BUFFER_0",
                    "comment": "Display buffer"
                },
                "7650-765F": {
                    "name": "VARIABLE_E\$",
                    "comment": "Fixed character variable E\$"
                },
                "7660-766F": {
                    "name": "VARIABLE_F\$",
                    "comment": "Fixed character variable F\$"
                },
                "7670-767F": {
                    "name": "VARIABLE_G\$",
                    "comment": "Fixed character variable G\$"
                },
                "7680-768F": {
                    "name": "VARIABLE_H\$",
                    "comment": "Fixed character variable H\$"
                },
                "7690-769F": {
                    "name": "VARIABLE_I\$",
                    "comment": "Fixed character variable I\$"
                },
                "76A0-76AF": {
                    "name": "VARIABLE_J\$",
                    "comment": "Fixed character variable J\$"
                },
                "76B0-76BF": {
                    "name": "VARIABLE_K\$",
                    "comment": "Fixed character variable K\$"
                },
                "76C0-76CF": {
                    "name": "VARIABLE_L\$",
                    "comment": "Fixed character variable L\$"
                },
                "76D0-76DF": {
                    "name": "VARIABLE_M\$",
                    "comment": "Fixed character variable M\$"
                },
                "76E0-76EF": {
                    "name": "VARIABLE_N\$",
                    "comment": "Fixed character variable N\$"
                },
                "76F0-76FF": {
                    "name": "VARIABLE_O\$",
                    "comment": "Fixed character variable O\$"
                },
                "7700-774F": {
                    "name":" "DISPLAY_BUFFER_1",
                    "comment": "Display buffer"
                },
                "7750-775F": {
                    "name": "VARIABLE_P\$",
                    "comment": "Fixed character variable P\$"
                },
                "7760-776F": {
                    "name": "VARIABLE_Q\$",
                    "comment": "Fixed character variable Q\$"
                },
                "7770-777F": {
                    "name": "VARIABLE_R\$",
                    "comment": "Fixed character variable R\$"
                },
                "7780-778F": {
                    "name": "VARIABLE_S\$",
                    "comment": "Fixed character variable S\$"
                },
                "7790-779F": {
                    "name": "VARIABLE_T\$",
                    "comment": "Fixed character variable T\$"
                },
                "77A0-77AF": {
                    "name": "VARIABLE_U\$",
                    "comment": "Fixed character variable U\$"
                },
                "77B0-77BF": {
                    "name": "VARIABLE_V\$",
                    "comment": "Fixed character variable V\$"
                },
                "77C0-77CF": {
                    "name": "VARIABLE_W\$",
                    "comment": "Fixed character variable W\$"
                },
                "77D0-77DF": {
                    "name": "VARIABLE_X\$",
                    "comment": "Fixed character variable X\$"
                },
                "77E0-77EF": {
                    "name": "VARIABLE_Y\$",
                    "comment": "Fixed character variable Y\$"
                },
                "77F0-77FF": {
                    "name": "VARIABLE_Z\$",
                    "comment": "Fixed character variable Z\$"
                },
                "7800-784F": {
                    "name": "SYSTEM_STACK",
                    "comment": "System stack"
                },
                "786B": {
                    "name": "RMT_BEEP",
                    "comment": "Remote and beep on/off pointer"
                },
                "7871": {
                    "name": "WAIT_Y_N",
                    "comment": "WAIT(0), WAIT0(3), WAIT1(2)"
                },
                "7872-7873": {
                    "name": "WAIT_COUNTER",
                    "comment": "Wait counter"
                },
                "7874": {
                    "name": "CURSOR_ENABLE",
                    "comment": "(01H) if used, (00H) if not)"
                },
                "7875": {
                    "name": "CURSOR_POINTER",
                    "comment": "Cursor pointer (0~155)"
                },
                "787D": {
                    "name": "BLINK_CHARACTER",
                    "comment": "Character code to be blinked"
                },
                "787E-787F": {
                    "name": "BLINK_CURSOR",
                    "comment": "Blinking cursor position (address of the display buffer)"
                },
                "788D": {
                    "name": "TRACE",
                    "comment": "Trace on/off pointer"
                },
                "788E": {
                    "name": "TRACE_CONDITION",
                    "comment": "Status when trace on"
                },
                "788F": {
                    "name": "OUTPUT_BUFFER_POINTER",
                    "comment": "Output buffer pointer"
                },
                "7890": {
                    "name": "FOR_POINTER",
                    "comment": "FOR-NEXT stack pointer"
                },
                "7891": {
                    "name": "GOSUB_POINTER",
                    "comment": "GOSUB pointer"
                },
                "7894": {
                    "name": "STRING_BUFFER_POINTER",
                    "comment": "String buffer pointer"
                },
                "7895": {
                    "name": "USING_F_F",
                    "comment": "Using format (presence of decimal point, comma, etc.)"
                },
                "7896": {
                    "name": "USING_M",
                    "comment": "Integer part of Using"
                },
                "7897": {
                    "name": "USINg_AMPERSAND",
                    "comment": "Using of charcater string"
                },
                "7898": {
                    "name": "USING_m",
                    "comment": "Decimal part of Using"
                },
                "7899-789A": {
                    "name": "VARIABLE_POINTER",
                    "comment": "Variable pointer"
                },
                "789B": {
                    "name": "ERL",
                    "comment": "Error number when occurred"
                },
                "789C-789D": {
                    "name": "CURRENT_LINE",
                    "comment": "Current line number"
                },
                "789E-789F": {
                    "name": "CURRENT_TOP",
                    "comment": "Leading address of program of the current line"
                },
                "78A0-78A1": {
                    "name": "PREVIOUS_ADDRESS",
                    "comment": "Address of immediately preceding line"
                },
                "78A2-78A3": {
                    "name": "PREVIOUS_LINE",
                    "comment": "Line number immediately preceding"
                },
                "78A4-78A5": {
                    "name": "PREVIOUS_TOP",
                    "comment": "Leading address of program of the line immediately preceding"
                },
                "78A6-78A7": {
                    "name": "SEARCH_ADDRESS",
                    "comment": "Address of the line found during search"
                },
                "78A8-78A9": {
                    "name": "SEARCH_LINE",
                    "comment": "Line number found after search"
                },
                "78AA-78AB": {
                    "name": "SEARCH_TOP",
                    "comment": "Line address of the search program block"
                },
                "78AC-78AD": {
                    "name": "BREAK_ADDRESS",
                    "comment": "Address of breakpoint"
                },
                "78AE-78AF": {
                    "name": "BREAK_LINE",
                    "comment": "Address of breakpoint line number"
                },
                "78B0-78B1": {
                    "name": "BREAK_TOP",
                    "comment": "Top address of the program block to which break is applied"
                },
                "78B2-78B3": {
                    "name": "ERROR_ADDRESS",
                    "comment": "Address where error is met"
                },
                "78B4-78B5": {
                    "name": "ERROR_LINE",
                    "comment": "Line number where error is met"
                },
                "78B6-78B7": {
                    "name": "ERROR_TOP",
                    "comment": "Line address of the program block in which error is met"
                },
                "78B8-78B9": {
                    "name": "ON_ERROR_ADDRESS",
                    "comment": "Address to which program jumps when an error is met"
                },
                "78BA-78BB": {
                    "name": "ON_ERROR_LINE",
                    "comment": "Line number to which program jumps when an error is met"
                },
                "78BC-78BD": {
                    "name": "ON_ERROR_TOP",
                    "comment": "Leading address of program block in which an error is met"
                },
                "78BE-78BF": {
                    "name": "DATA_POINTER",
                    "comment": "Pointer for data statement"
                },
                "7900-7907": {
                    "name": "VARIABLE_A",
                    "comment": "Fixed numerical variable A"
                },
                "7908-790F": {
                    "name": "VARIABLE_B",
                    "comment": "Fixed numerical variable B"
                },
                "7910-7917": {
                    "name": "VARIABLE_C",
                    "comment": "Fixed numerical variable C"
                },
                "7918-791F": {
                    "name": "VARIABLE_D",
                    "comment": "Fixed numerical variable D"
                },
                "7920-7927": {
                    "name": "VARIABLE_E",
                    "comment": "Fixed numerical variable E"
                },
                "7928-792F": {
                    "name": "VARIABLE_F",
                    "comment": "Fixed numerical variable F"
                },
                "7930-7937": {
                    "name": "VARIABLE_G",
                    "comment": "Fixed numerical variable G"
                },
                "7938-793F": {
                    "name": "VARIABLE_H",
                    "comment": "Fixed numerical variable H"
                },
                "7940-7947": {
                    "name": "VARIABLE_I",
                    "comment": "Fixed numerical variable I"
                },
                "7948-794F": {
                    "name": "VARIABLE_J",
                    "comment": "Fixed numerical variable J"
                },
                "7950-7957": {
                    "name": "VARIABLE_K",
                    "comment": "Fixed numerical variable K"
                },
                "7958-795F": {
                    "name": "VARIABLE_L",
                    "comment": "Fixed numerical variable L"
                },
                "7960-7967": {
                    "name": "VARIABLE_M",
                    "comment": "Fixed numerical variable M"
                },
                "7968-796F": {
                    "name": "VARIABLE_N",
                    "comment": "Fixed numerical variable N"
                },
                "7970-7977": {
                    "name": "VARIABLE_O",
                    "comment": "Fixed numerical variable O"
                },
                "7978-797F": {
                    "name": "VARIABLE_P",
                    "comment": "Fixed numerical variable P"
                },
                "7980-7987": {
                    "name": "VARIABLE_Q",
                    "comment": "Fixed numerical variable Q"
                },
                "7988-798F": {
                    "name": "VARIABLE_R",
                    "comment": "Fixed numerical variable R"
                },
                "7990-7997": {
                    "name": "VARIABLE_S",
                    "comment": "Fixed numerical variable S"
                },
                "7998-799F": {
                    "name": "VARIABLE_T",
                    "comment": "Fixed numerical variable T"
                },
                "79A0-79A7": {
                    "name": "VARIABLE_U",
                    "comment": "Fixed numerical variable U"
                },
                "79A8-79AF": {
                    "name": "VARIABLE_V",
                    "comment": "Fixed numerical variable V"
                },
                "79B0-79B7": {
                    "name": "VARIABLE_W",
                    "comment": "Fixed numerical variable W"
                },
                "79B8-79BF": {
                    "name": "VARIABLE_X",
                    "comment": "Fixed numerical variable X"
                },
                "79C0-79C7": {
                    "name": "VARIABLE_Y",
                    "comment": "Fixed numerical variable Y"
                },
                "79C8-79CF": {
                    "name": "VARIABLE_Z",
                    "comment": "Fixed numerical variable Z"
                },
                "79D1": {
                    "name": "OPN_DV",
                    "comment": "Perioheral device select"
                },
                "79E0-79E1": {
                    "name": "USER_COUNTER_X",
                    "comment": "Counter to which X-coordinates of the pen are indicated"
                },
                "79E2-79E3": {
                    "name": "USER_COUNTER_Y",
                    "comment": "Counter to which Y-coordinates of the pen are indicated"
                },
                "79E4-79E5": {
                    "name": "SCISSORING_COUNTER_Y",
                    "comment": "Y-direction scissoring counter"
                },
                "79E6": {
                    "name": "ABSOLUTE_POSITION_X",
                    "comment": "X-direction absolute pointer counter"
                },
                "79E7-79E8": {
                    "name": "SCISSORING_COUNTER_X",
                    "comment": "X-direction scissoring counter"
                },
                "79EA": {
                    "name": "LINE_TYPE",
                    "comment": "Kind of line"
                },
                "79EB": {
                    "name": "DOT_LINE_COUNTER",
                    "comment": "Dot line counter"
                },
                "79EC": {
                    "name": "UP_DOWN",
                    "comment": "Pen up/down position select"
                },
                "79ED": {
                    "name": "X_MOTOR_HOLD_COUNTER",
                    "comment": "X motor hold counter"
                },
                "79EE": {
                    "name": "PORT_C",
                    "comment": "Indicates current motor phase"
                },
                "79EF": {
                    "name": "Y_MOTOR_HOLD_COUNTER",
                    "comment": "Y motor hold counter"
                },
                "79F0": {
                    "name": "GRAPH_TEXT",
                    "comment": "Printer mode select (graph=FFH, text=00H)"
                },
                "79F2": {
                    "name": "ROTATE",
                    "comment": "Printer direction select (0~3)"
                },
                "79F3": {
                    "name": "COLOR",
                    "comment": "Color select"
                },
                "79F4": {
                    "name": "CSIZE",
                    "comment": "Printing character size select (1~9)"
                },
                "79FF": {
                    "name": "LOCK",
                    "comment": "Lock/unlock select"
                },
                "7A00-7A07": {
                    "name": "VARIABLE_X",
                    "comment": "Arithmetic register X"
                },
                "7A08-7A0F": {
                    "name": "VARIABLE_Z",
                    "comment": "Arithmetic register Z"
                },
                "7A10-7A17": {
                    "name": "VARIABLE_Y",
                    "comment": "Arithmetic register Y"
                },
                "7A18-7A1F": {
                    "name": "VARIABLE_U",
                    "comment": "Arithmetic register U"
                },
                "7A20-7A27": {
                    "name": "VARIABLE_V",
                    "comment": "Arithmetic register V"
                },
                "7A28-7A2F": {
                    "name": "VARIABLE_W",
                    "comment": "Arithmetic register W"
                },
                "7A30-7A37": {
                    "name": "VARIABLE_S",
                    "comment": "Arithmetic register S"
                },
                "7A38-7AFF": {
                    "name": "BASIC_STACK",
                    "comment": "BASIC stack includes stacks for FOR-NEXT, GOSUB, DATA and FUNCTION"
                },
                "7B00-7B07": {
                    "name": "RND_NUMBER",
                    "comment": "Random number"
                },
                "7B0A": {
                    "name": "AUTO_P_OFF_COUNTER_U",
                    "comment": "Auto power off counter U"
                },
                "7B0B": {
                    "name": "AUTO_P_OFF_COUNTER_M",
                    "comment": "Auto power off counter M"
                },
                "7B0C": {
                    "name": "AUTO_P_OFF_COUNTER_L",
                    "comment": "Auto power off counter L"
                },
                "78C0-78CF": {
                    "name": "VARIABLE_A\$",
                    "comment": "Fixed character variable A\$"
                },
                "78D0-78DF": {
                    "name": "VARIABLE_B\$",
                    "comment": "Fixed character variable B\$"
                },
                "78E0-78EF": {
                    "name": "VARIABLE_C\$",
                    "comment": "Fixed character variable C\$"
                },
                "78F0-78FF": {
                    "name": "VARIABLE_D\$",
                    "comment": "Fixed character variable D\$"
                },
                "7B10-7B5F": {
                    "name": "STRING_BUFFER"
                },
                "7B60-7BAF": {
                    "name": "OUTPUT_BUFFER"
                },
                "7BB0-7BFF": {
                    "name": "INPUT_BUFFER"
                }
            }
        },
        "7C00-7FFF": {
            "name": "MACHINE LANGUAGE AREA (RAM), 1.5KB",
            "type": "ram",
        }
    }
}
''';
