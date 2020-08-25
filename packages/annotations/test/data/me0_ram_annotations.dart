const String json = '''
{
    "7600-7BFF": {
        "name": "STANDARD USER SYSTEM MEMORY (RAM), 1.5KB",
        "areas": {
            "7600-764F": {
                "name": "Display Buffer #1",
                "data": {
                    "764E": {
                        "label": "LCDSYM1",
                        "comment": "DEF, I, II, II, SMALL, SML, SHIFT and BUSY"
                    },
                    "764F": {
                        "label": "LCDSYM2",
                        "comment": "RUN, PRO, RESERVE, RAD, G and DE"
                    }
                }
            },
            "7650-76FF": {
                "name": "Fixed character variables #1",
                "data": {
                    "7650-765F": {
                        "label": "VARIABLE_E\$",
                        "comment": "Fixed character variable E\$",
                        "type": "fixed_char_var"
                    },
                    "7660-766F": {
                        "label": "VARIABLE_F\$",
                        "comment": "Fixed character variable F\$",
                        "type": "fixed_char_var"
                    },
                    "7670-767F": {
                        "label": "VARIABLE_G\$",
                        "comment": "Fixed character variable G\$",
                        "type": "fixed_char_var"
                    },
                    "7680-768F": {
                        "label": "VARIABLE_H\$",
                        "comment": "Fixed character variable H\$",
                        "type": "fixed_char_var"
                    },
                    "7690-769F": {
                        "label": "VARIABLE_I\$",
                        "comment": "Fixed character variable I\$",
                        "type": "fixed_char_var"
                    },
                    "76A0-76AF": {
                        "label": "VARIABLE_J\$",
                        "comment": "Fixed character variable J\$",
                        "type": "fixed_char_var"
                    },
                    "76B0-76BF": {
                        "label": "VARIABLE_K\$",
                        "comment": "Fixed character variable K\$",
                        "type": "fixed_char_var"
                    },
                    "76C0-76CF": {
                        "label": "VARIABLE_L\$",
                        "comment": "Fixed character variable L\$",
                        "type": "fixed_char_var"
                    },
                    "76D0-76DF": {
                        "label": "VARIABLE_M\$",
                        "comment": "Fixed character variable M\$",
                        "type": "fixed_char_var"
                    },
                    "76E0-76EF": {
                        "label": "VARIABLE_N\$",
                        "comment": "Fixed character variable N\$",
                        "type": "fixed_char_var"
                    },
                    "76F0-76FF": {
                        "label": "VARIABLE_O\$",
                        "comment": "Fixed character variable O\$",
                        "type": "fixed_char_var"
                    }
                }
            },
            "7700-774D": {
                "name": "Display Buffer #2"
            },
            "7750-77FF": {
                "name": "Fixed character variables #2",
                "data": {
                    "7750-775F": {
                        "label": "VARIABLE_P\$",
                        "comment": "Fixed character variable P\$",
                        "type": "fixed_char_var"
                    },
                    "7760-776F": {
                        "label": "VARIABLE_Q\$",
                        "comment": "Fixed character variable Q\$",
                        "type": "fixed_char_var"
                    },
                    "7770-777F": {
                        "label": "VARIABLE_R\$",
                        "comment": "Fixed character variable R\$",
                        "type": "fixed_char_var"
                    },
                    "7780-778F": {
                        "label": "VARIABLE_S\$",
                        "comment": "Fixed character variable S\$",
                        "type": "fixed_char_var"
                    },
                    "7790-779F": {
                        "label": "VARIABLE_T\$",
                        "comment": "Fixed character variable T\$",
                        "type": "fixed_char_var"
                    },
                    "77A0-77AF": {
                        "label": "VARIABLE_U\$",
                        "comment": "Fixed character variable U\$",
                        "type": "fixed_char_var"
                    },
                    "77B0-77BF": {
                        "label": "VARIABLE_V\$",
                        "comment": "Fixed character variable V\$",
                        "type": "fixed_char_var"
                    },
                    "77C0-77CF": {
                        "label": "VARIABLE_W\$",
                        "comment": "Fixed character variable W\$",
                        "type": "fixed_char_var"
                    },
                    "77D0-77DF": {
                        "label": "VARIABLE_X\$",
                        "comment": "Fixed character variable X\$",
                        "type": "fixed_char_var"
                    },
                    "77E0-77EF": {
                        "label": "VARIABLE_Y\$",
                        "comment": "Fixed character variable Y\$",
                        "type": "fixed_char_var"
                    },
                    "77F0-77FF": {
                        "label": "VARIABLE_Z\$",
                        "comment": "Fixed character variable Z\$",
                        "type": "fixed_char_var"
                    }
                }
            },
            "7800-784F": {
                "name": "System stack"
            },
            "7850-78BF": {
                "name": "System Memory #1",
                "data": {
                    "786B": {
                        "label": "RMT_BEEP",
                        "comment": "Remote and beep on/off pointer"
                    },
                    "7871": {
                        "label": "WAIT_Y_N",
                        "comment": "WAIT(0), WAIT0(3), WAIT1(2)"
                    },
                    "7872-7873": {
                        "label": "WAIT_COUNTER",
                        "comment": "Wait counter"
                    },
                    "7874": {
                        "label": "CURSOR_ENABLE",
                        "comment": "(01H) if used, (00H) if not"
                    },
                    "7875": {
                        "label": "CURSOR_POINTER",
                        "comment": "Cursor pointer (0~155)"
                    },
                    "787D": {
                        "label": "BLINK_CHARACTER",
                        "comment": "Character code to be blinked"
                    },
                    "787E-787F": {
                        "label": "BLINK_CURSOR",
                        "comment": "Blinking cursor position (address of the display buffer)"
                    },
                    "788D": {
                        "label": "TRACE",
                        "comment": "Trace on/off pointer"
                    },
                    "788E": {
                        "label": "TRACE_CONDITION",
                        "comment": "Status when trace on"
                    },
                    "788F": {
                        "label": "OUTPUT_BUFFER_POINTER",
                        "comment": "Output buffer pointer"
                    },
                    "7890": {
                        "label": "FOR_POINTER",
                        "comment": "FOR-NEXT stack pointer"
                    },
                    "7891": {
                        "label": "GOSUB_POINTER",
                        "comment": "GOSUB pointer"
                    },
                    "7894": {
                        "label": "STRING_BUFFER_POINTER",
                        "comment": "String buffer pointer"
                    },
                    "7895": {
                        "label": "USING_F_F",
                        "comment": "Using format (presence of decimal point, comma, etc.)"
                    },
                    "7896": {
                        "label": "USING_M",
                        "comment": "Integer part of Using"
                    },
                    "7897": {
                        "label": "USINg_AMPERSAND",
                        "comment": "Using of charcater string"
                    },
                    "7898": {
                        "label": "USING_m",
                        "comment": "Decimal part of Using"
                    },
                    "7899-789A": {
                        "label": "VARIABLE_POINTER",
                        "comment": "Variable pointer"
                    },
                    "789B": {
                        "label": "ERL",
                        "comment": "Error number when occurred"
                    },
                    "789C-789D": {
                        "label": "CURRENT_LINE",
                        "comment": "Current line number"
                    },
                    "789E-789F": {
                        "label": "CURRENT_TOP",
                        "comment": "Leading address of program of the current line"
                    },
                    "78A0-78A1": {
                        "label": "PREVIOUS_ADDRESS",
                        "comment": "Address of immediately preceding line"
                    },
                    "78A2-78A3": {
                        "label": "PREVIOUS_LINE",
                        "comment": "Line number immediately preceding"
                    },
                    "78A4-78A5": {
                        "label": "PREVIOUS_TOP",
                        "comment": "Leading address of program of the line immediately preceding"
                    },
                    "78A6-78A7": {
                        "label": "SEARCH_ADDRESS",
                        "comment": "Address of the line found during search"
                    },
                    "78A8-78A9": {
                        "label": "SEARCH_LINE",
                        "comment": "Line number found after search"
                    },
                    "78AA-78AB": {
                        "label": "SEARCH_TOP",
                        "comment": "Line address of the search program block"
                    },
                    "78AC-78AD": {
                        "label": "BREAK_ADDRESS",
                        "comment": "Address of breakpoint"
                    },
                    "78AE-78AF": {
                        "label": "BREAK_LINE",
                        "comment": "Address of breakpoint line number"
                    },
                    "78B0-78B1": {
                        "label": "BREAK_TOP",
                        "comment": "Top address of the program block to which break is applied"
                    },
                    "78B2-78B3": {
                        "label": "ERROR_ADDRESS",
                        "comment": "Address where error is met"
                    },
                    "78B4-78B5": {
                        "label": "ERROR_LINE",
                        "comment": "Line number where error is met"
                    },
                    "78B6-78B7": {
                        "label": "ERROR_TOP",
                        "comment": "Line address of the program block in which error is met"
                    },
                    "78B8-78B9": {
                        "label": "ON_ERROR_ADDRESS",
                        "comment": "Address to which program jumps when an error is met"
                    },
                    "78BA-78BB": {
                        "label": "ON_ERROR_LINE",
                        "comment": "Line number to which program jumps when an error is met"
                    },
                    "78BC-78BD": {
                        "label": "ON_ERROR_TOP",
                        "comment": "Leading address of program block in which an error is met"
                    },
                    "78BE-78BF": {
                        "label": "DATA_POINTER",
                        "comment": "Pointer for data statement"
                    }
                }
            },
            "78C0-78FF": {
                "name": "Fixed character variables #3",
                "data": {
                    "78C0-78CF": {
                        "label": "VARIABLE_A\$",
                        "comment": "Fixed character variable A\$",
                        "type": "fixed_char_var"
                    },
                    "78D0-78DF": {
                        "label": "VARIABLE_B\$",
                        "comment": "Fixed character variable B\$",
                        "type": "fixed_char_var"
                    },
                    "78E0-78EF": {
                        "label": "VARIABLE_C\$",
                        "comment": "Fixed character variable C\$",
                        "type": "fixed_char_var"
                    },
                    "78F0-78FF": {
                        "label": "VARIABLE_D\$",
                        "comment": "Fixed character variable D\$",
                        "type": "fixed_char_var"
                    }
                }
            },
            "7900-79CF": {
                "name": "Fixed numerical variables",
                "data": {
                    "7900-7907": {
                        "label": "VARIABLE_A",
                        "comment": "Fixed numerical variable A",
                        "type": "fixed_num_var"
                    },
                    "7908-790F": {
                        "label": "VARIABLE_B",
                        "comment": "Fixed numerical variable B",
                        "type": "fixed_num_var"
                    },
                    "7910-7917": {
                        "label": "VARIABLE_C",
                        "comment": "Fixed numerical variable C",
                        "type": "fixed_num_var"
                    },
                    "7918-791F": {
                        "label": "VARIABLE_D",
                        "comment": "Fixed numerical variable D",
                        "type": "fixed_num_var"
                    },
                    "7920-7927": {
                        "label": "VARIABLE_E",
                        "comment": "Fixed numerical variable E",
                        "type": "fixed_num_var"
                    },
                    "7928-792F": {
                        "label": "VARIABLE_F",
                        "comment": "Fixed numerical variable F",
                        "type": "fixed_num_var"
                    },
                    "7930-7937": {
                        "label": "VARIABLE_G",
                        "comment": "Fixed numerical variable G",
                        "type": "fixed_num_var"
                    },
                    "7938-793F": {
                        "label": "VARIABLE_H",
                        "comment": "Fixed numerical variable H",
                        "type": "fixed_num_var"
                    },
                    "7940-7947": {
                        "label": "VARIABLE_I",
                        "comment": "Fixed numerical variable I",
                        "type": "fixed_num_var"
                    },
                    "7948-794F": {
                        "label": "VARIABLE_J",
                        "comment": "Fixed numerical variable J",
                        "type": "fixed_num_var"
                    },
                    "7950-7957": {
                        "label": "VARIABLE_K",
                        "comment": "Fixed numerical variable K",
                        "type": "fixed_num_var"
                    },
                    "7958-795F": {
                        "label": "VARIABLE_L",
                        "comment": "Fixed numerical variable L",
                        "type": "fixed_num_var"
                    },
                    "7960-7967": {
                        "label": "VARIABLE_M",
                        "comment": "Fixed numerical variable M",
                        "type": "fixed_num_var"
                    },
                    "7968-796F": {
                        "label": "VARIABLE_N",
                        "comment": "Fixed numerical variable N",
                        "type": "fixed_num_var"
                    },
                    "7970-7977": {
                        "label": "VARIABLE_O",
                        "comment": "Fixed numerical variable O",
                        "type": "fixed_num_var"
                    },
                    "7978-797F": {
                        "label": "VARIABLE_P",
                        "comment": "Fixed numerical variable P",
                        "type": "fixed_num_var"
                    },
                    "7980-7987": {
                        "label": "VARIABLE_Q",
                        "comment": "Fixed numerical variable Q",
                        "type": "fixed_num_var"
                    },
                    "7988-798F": {
                        "label": "VARIABLE_R",
                        "comment": "Fixed numerical variable R",
                        "type": "fixed_num_var"
                    },
                    "7990-7997": {
                        "label": "VARIABLE_S",
                        "comment": "Fixed numerical variable S",
                        "type": "fixed_num_var"
                    },
                    "7998-799F": {
                        "label": "VARIABLE_T",
                        "comment": "Fixed numerical variable T",
                        "type": "fixed_num_var"
                    },
                    "79A0-79A7": {
                        "label": "VARIABLE_U",
                        "comment": "Fixed numerical variable U",
                        "type": "fixed_num_var"
                    },
                    "79A8-79AF": {
                        "label": "VARIABLE_V",
                        "comment": "Fixed numerical variable V",
                        "type": "fixed_num_var"
                    },
                    "79B0-79B7": {
                        "label": "VARIABLE_W",
                        "comment": "Fixed numerical variable W",
                        "type": "fixed_num_var"
                    },
                    "79B8-79BF": {
                        "label": "VARIABLE_X",
                        "comment": "Fixed numerical variable X",
                        "type": "fixed_num_var"
                    },
                    "79C0-79C7": {
                        "label": "VARIABLE_Y",
                        "comment": "Fixed numerical variable Y",
                        "type": "fixed_num_var"
                    },
                    "79C8-79CF": {
                        "label": "VARIABLE_Z",
                        "comment": "Fixed numerical variable Z",
                        "type": "fixed_num_var"
                    }
                }
            },
            "79D0-79FF": {
                "name": "System Memory #2",
                "data": {
                    "79D1": {
                        "label": "OPN_DV",
                        "comment": "Peripheral device select"
                    },
                    "79E0-79E1": {
                        "label": "USER_COUNTER_X",
                        "comment": "Counter to which X-coordinates of the pen are indicated"
                    },
                    "79E2-79E3": {
                        "label": "USER_COUNTER_Y",
                        "comment": "Counter to which Y-coordinates of the pen are indicated"
                    },
                    "79E4-79E5": {
                        "label": "SCISSORING_COUNTER_Y",
                        "comment": "Y-direction scissoring counter"
                    },
                    "79E6": {
                        "label": "ABSOLUTE_POSITION_X",
                        "comment": "X-direction absolute pointer counter"
                    },
                    "79E7-79E8": {
                        "label": "SCISSORING_COUNTER_X",
                        "comment": "X-direction scissoring counter"
                    },
                    "79EA": {
                        "label": "LINE_TYPE",
                        "comment": "Kind of line"
                    },
                    "79EB": {
                        "label": "DOT_LINE_COUNTER",
                        "comment": "Dot line counter"
                    },
                    "79EC": {
                        "label": "UP_DOWN",
                        "comment": "Pen up/down position select"
                    },
                    "79ED": {
                        "label": "X_MOTOR_HOLD_COUNTER",
                        "comment": "X motor hold counter"
                    },
                    "79EE": {
                        "label": "PORT_C",
                        "comment": "Indicates current motor phase"
                    },
                    "79EF": {
                        "label": "Y_MOTOR_HOLD_COUNTER",
                        "comment": "Y motor hold counter"
                    },
                    "79F0": {
                        "label": "GRAPH_TEXT",
                        "comment": "Printer mode select (graph=FFH, text=00H)"
                    },
                    "79F2": {
                        "label": "ROTATE",
                        "comment": "Printer direction select (0~3)"
                    },
                    "79F3": {
                        "label": "COLOR",
                        "comment": "Color select"
                    },
                    "79F4": {
                        "label": "CSIZE",
                        "comment": "Printing character size select (1~9)"
                    },
                    "79FF": {
                        "label": "LOCK",
                        "comment": "Lock/unlock select"
                    }
                }
            },
            "7A00-7A37": {
                "name": "Arithmetic registers",
                "data": {
                    "7A00-7A07": {
                        "label": "VARIABLE_X",
                        "comment": "Arithmetic register X",
                        "type": "arith_reg"
                    },
                    "7A08-7A0F": {
                        "label": "VARIABLE_Z",
                        "comment": "Arithmetic register Z",
                        "type": "arith_reg"
                    },
                    "7A10-7A17": {
                        "label": "VARIABLE_Y",
                        "comment": "Arithmetic register Y",
                        "type": "arith_reg"
                    },
                    "7A18-7A1F": {
                        "label": "VARIABLE_U",
                        "comment": "Arithmetic register U",
                        "type": "arith_reg"
                    },
                    "7A20-7A27": {
                        "label": "VARIABLE_V",
                        "comment": "Arithmetic register V",
                        "type": "arith_reg"
                    },
                    "7A28-7A2F": {
                        "label": "VARIABLE_W",
                        "comment": "Arithmetic register W",
                        "type": "arith_reg"
                    },
                    "7A30-7A37": {
                        "label": "VARIABLE_S",
                        "comment": "Arithmetic register S",
                        "type": "arith_reg"
                    }
                }
            },
            "7A38-7AFF": {
                "name": "BASIC stack includes stacks for FOR-NEXT, GOSUB, DATA and FUNCTION"
            },
            "7B00-7B0F": {
                "name": "System Memory #3",
                "data": {
                    "7B00-7B07": {
                        "label": "RND_NUMBER",
                        "comment": "Random number"
                    },
                    "7B0A": {
                        "label": "AUTO_P_OFF_COUNTER_U",
                        "comment": "Auto power off counter U"
                    },
                    "7B0B": {
                        "label": "AUTO_P_OFF_COUNTER_M",
                        "comment": "Auto power off counter M"
                    },
                    "7B0C": {
                        "label": "AUTO_P_OFF_COUNTER_L",
                        "comment": "Auto power off counter L"
                    }
                }
            },
            "7B10-7B5F": {
                "name": "String Buffer"
            },
            "7B60-7BAF": {
                "name": "Output Buffer"
            },
            "7BB0-7BFF": {
                "name": "Input Buffer"
            }
        }
    },
    "7C01-7FFF": {
        "name": "MACHINE LANGUAGE AREA (RAM), 1.5KB"
    }
}
''';
