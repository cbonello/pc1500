import 'package:annotations/annotations.dart';

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
                    }
                }
            }
        }
    }
}
''';

void main() {
  final MemoryBanksAnnotations annotations = MemoryBanksAnnotations();

  annotations.load(<String>[json]);

  if (annotations.isAnnotated(0x764E)) {
    print(annotations.getAnnotationFromAddress(0x764E).toString());
  }
}
