// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:annotations/annotations.dart';

const String annotationsStr = '''
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
            }
        }
    }
}
''';

void main() {
  final MemoryBanksAnnotations annotations = MemoryBanksAnnotations();
  final Map<String, dynamic> json =
      jsonDecode(annotationsStr) as Map<String, dynamic>;

  annotations.load(json);

  if (annotations.isAnnotated(0x764E)) {
    final AnnotationBase annotation =
        annotations.getAnnotationFromAddress(0x764E);
    if (annotation is CodeAnnotation) {
      final String label =
          annotation.label == null ? '' : '${annotation.label}: ';
      final String comment =
          annotation.comment == null ? '' : '; ${annotation.comment}';

      print('${annotation.addressSpace} $label$comment');
    } else if (annotation is DataAnnotation) {
      final String label =
          annotation.label == null ? '' : '${annotation.label}: ';
      final String comment =
          annotation.comment == null ? '' : '; ${annotation.comment}';

      print('${annotation.addressSpace} $label$comment');
    }
  }
}
