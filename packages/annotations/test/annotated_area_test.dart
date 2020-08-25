import 'dart:convert';

import 'package:annotations/src/models/models.dart';
import 'package:test/test.dart';

void main() {
  const String jsonData = '''
{
  "name": "Fixed character variables #3",
  "areas": {
    "78F0-78FF": {
      "name": "Other fixed character variable",
      "data": {
        "78F0-78FF": {
          "label": "VARIABLE_D\$",
          "comment": "Fixed character variable D\$",
          "type": "fixed_char_var"
        }
      }
    }
  },
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
    }
  },
  "code": {
    "78E0": {
      "label": "fixedCharacterVariables"
    }
  }
}
''';
  final Map<String, dynamic> json =
      jsonDecode(jsonData) as Map<String, dynamic>;

  group('AnnotatedArea', () {
    test('should raise an AssertionError for invalid arguments', () {});

    test('should create an instance of AnnotatedArea successfully', () {
      AnnotatedArea annotatedArea;

      expect(
        annotatedArea = AnnotatedArea.fromJson(
          null,
          AddressSpace.fromTag('78C0-78FF'),
          json,
        ),
        equals(const TypeMatcher<AnnotatedArea>()),
      );
      expect(annotatedArea.parent, isNull);
      expect(annotatedArea.name, equals('Fixed character variables #3'));

      // "78F0-78FF": {
      //   "label": "VARIABLE_D\$",
      //   "comment": "Fixed character variable D\$",
      //   "type": "fixed_char_var"
      // }
      expect(annotatedArea.subAreas.length, equals(1));

      expect(
        annotatedArea.subAreas[0].parent.name,
        equals(annotatedArea.name),
      );
      expect(
        annotatedArea.subAreas[0].name,
        equals('Other fixed character variable'),
      );
      expect(annotatedArea.subAreas[0].subAreas, isEmpty);
      expect(annotatedArea.subAreas[0].codeAnnotations, isEmpty);
      expect(
        annotatedArea.subAreas[0].dataAnnotations.length,
        equals(1),
      );

      expect(
        annotatedArea.subAreas[0].dataAnnotations[0].area.name,
        equals(annotatedArea.subAreas[0].name),
      );
      expect(
        annotatedArea.subAreas[0].dataAnnotations[0].addressSpace,
        equals(AddressSpace.fromTag('78F0-78FF')),
      );
      expect(annotatedArea.subAreas[0].dataAnnotations[0].label,
          equals('VARIABLE_D\$'));
      expect(
        annotatedArea.subAreas[0].dataAnnotations[0].comment,
        equals('Fixed character variable D\$'),
      );
      expect(
        annotatedArea.subAreas[0].dataAnnotations[0].type,
        equals(DataAnnotationType.fixedCharacterVariable),
      );

      // "78E0": {
      //   "label": "fixedCharacterVariables"
      // }
      expect(annotatedArea.codeAnnotations.length, equals(1));

      expect(
        annotatedArea.codeAnnotations[0].area.name,
        equals(annotatedArea.name),
      );
      expect(
        annotatedArea.codeAnnotations[0].label,
        equals('fixedCharacterVariables'),
      );
      expect(annotatedArea.codeAnnotations[0].comment, isNull);

      // "78C0-78CF": {
      //   "label": "VARIABLE_A\$",
      //   "comment": "Fixed character variable A\$",
      //   "type": "fixed_char_var"
      // },
      expect(annotatedArea.dataAnnotations.length, equals(2));

      expect(
        annotatedArea.dataAnnotations[0].area.name,
        equals(annotatedArea.name),
      );
      expect(
        annotatedArea.dataAnnotations[0].addressSpace,
        equals(AddressSpace.fromTag('78C0-78CF')),
      );
      expect(annotatedArea.dataAnnotations[0].label, equals('VARIABLE_A\$'));
      expect(
        annotatedArea.dataAnnotations[0].comment,
        equals('Fixed character variable A\$'),
      );
      expect(
        annotatedArea.dataAnnotations[0].type,
        equals(DataAnnotationType.fixedCharacterVariable),
      );

      // "78D0-78DF": {
      //   "label": "VARIABLE_B\$",
      //   "comment": "Fixed character variable B\$",
      //   "type": "fixed_char_var"
      // }
      expect(
        annotatedArea.dataAnnotations[1].area.name,
        equals(annotatedArea.name),
      );
      expect(
        annotatedArea.dataAnnotations[1].addressSpace,
        equals(AddressSpace.fromTag('78D0-78DF')),
      );
      expect(annotatedArea.dataAnnotations[1].label, equals('VARIABLE_B\$'));
      expect(
        annotatedArea.dataAnnotations[1].comment,
        equals('Fixed character variable B\$'),
      );
      expect(
        annotatedArea.dataAnnotations[1].type,
        equals(DataAnnotationType.fixedCharacterVariable),
      );
    });
  });
}
