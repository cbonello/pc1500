import 'dart:convert';

import 'package:annotations/annotations.dart';
import 'package:test/test.dart';

void main() {
  const String jsonData = '''
{
  "label": "VARIABLE_A\$",
  "comment": "Fixed character variable A\$",
  "type": "fixed_char_var"
}
''';
  final Map<String, dynamic> json =
      jsonDecode(jsonData) as Map<String, dynamic>;

  group('DataAnnotation', () {
    test('should raise an AssertionError for invalid arguments', () {
      // Parent must not be null.
      expect(
        () => DataAnnotation.fromJson(
          null,
          AddressSpace.fromTag('78C0-78FF'),
          json,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // Address-space must not be null.
      expect(
        () => DataAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('7850-78BF'),
            name: 'Fixed character variables #3',
          ),
          null,
          json,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // Address-space of a code annotation must be included in its parent
      // address-space.
      expect(
        () => DataAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('7850-78BF'),
            name: 'Fixed character variables #3',
          ),
          AddressSpace.fromTag('7672-7673'),
          json,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );

      // A code annotation must include a comment.
      const String jsonData1 = '{}';
      final Map<String, dynamic> json1 =
          jsonDecode(jsonData1) as Map<String, dynamic>;

      expect(
        () => DataAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('7850-78BF'),
            name: 'Fixed character variables #3',
          ),
          AddressSpace.fromTag('78C0-78CF'),
          json1,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );

      // Type is either 'data', 'fixed_char_var', 'fixed_num_var' or 'arith_reg'.
      const String jsonDataNoLabel =
          '{ "comment": "Fixed character variable A\$", "type": "abcd" }';
      final Map<String, dynamic> jsonNoLabel =
          jsonDecode(jsonDataNoLabel) as Map<String, dynamic>;

      expect(
        () => DataAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('7850-78BF'),
            name: 'Fixed character variables #3',
          ),
          AddressSpace.fromTag('78C0-78CF'),
          jsonNoLabel,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should create an instance of DataAnnotation successfully', () {
      DataAnnotation dataAnnotation;

      expect(
        dataAnnotation = DataAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('78C0-78FF'),
            name: 'Fixed character variables #3',
          ),
          AddressSpace.fromTag('78C0-78CF'),
          json,
        ),
        equals(const TypeMatcher<DataAnnotation>()),
      );
      expect(dataAnnotation.label, equals('VARIABLE_A\$'));
      expect(
        dataAnnotation.comment,
        equals('Fixed character variable A\$'),
      );
      expect(
        dataAnnotation.type,
        equals(DataAnnotationType.fixedCharacterVariable),
      );

      const String jsonDataNoLabel =
          '{ "comment": "Fixed character variable A\$", "type": "fixed_char_var" }';
      final Map<String, dynamic> jsonNoLabel =
          jsonDecode(jsonDataNoLabel) as Map<String, dynamic>;

      expect(
        dataAnnotation = DataAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('78C0-78FF'),
            name: 'Fixed character variables #3',
          ),
          AddressSpace.fromTag('78C0-78CF'),
          jsonNoLabel,
        ),
        equals(const TypeMatcher<DataAnnotation>()),
      );
      expect(dataAnnotation.label, isNull);
      expect(
        dataAnnotation.comment,
        equals('Fixed character variable A\$'),
      );
      expect(
        dataAnnotation.type,
        equals(DataAnnotationType.fixedCharacterVariable),
      );

      // Default type is DataAnnotationType.data.
      const String jsonDataCommentOnly =
          '{ "comment": "Fixed character variable A\$" }';
      final Map<String, dynamic> jsonCommentOnly =
          jsonDecode(jsonDataCommentOnly) as Map<String, dynamic>;

      expect(
        dataAnnotation = DataAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('78C0-78FF'),
            name: 'Fixed character variables #3',
          ),
          AddressSpace.fromTag('78C0-78CF'),
          jsonCommentOnly,
        ),
        equals(const TypeMatcher<DataAnnotation>()),
      );
      expect(dataAnnotation.label, isNull);
      expect(
        dataAnnotation.comment,
        equals('Fixed character variable A\$'),
      );
      expect(
        dataAnnotation.type,
        equals(DataAnnotationType.data),
      );
    });
  });
}
