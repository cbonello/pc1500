import 'dart:convert';

import 'package:annotations/annotations.dart';
import 'package:test/test.dart';

void main() {
  const String jsonData = '''
{
  "label": "PUSH78",
  "comment": "System subroutine: Write X register"
}
''';
  final Map<String, dynamic> json =
      jsonDecode(jsonData) as Map<String, dynamic>;

  group('CodeAnnotation', () {
    test('should raise an AssertionError for invalid arguments', () {
      // Parent must not be null.
      expect(
        () => CodeAnnotation.fromJson(
          null,
          AddressSpace.fromTag('C001'),
          json,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // Address-space must not be null.
      expect(
        () => CodeAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('C000-C01C'),
            name: 'Code Section #1',
          ),
          null,
          json,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // Address-space length of a code annotation must be 1.
      expect(
        () => CodeAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('C000-C01C'),
            name: 'Code Section #1',
          ),
          AddressSpace.fromTag('C001-C002'),
          json,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // Address-space of a code annotation must be included in its parent
      // address-space.
      expect(
        () => CodeAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('C000-C01C'),
            name: 'Code Section #1',
          ),
          AddressSpace.fromTag('A000'),
          json,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );

      // A code annotation must include either a label or a comment, or both.
      const String jsonData1 = '{}';
      final Map<String, dynamic> json1 =
          jsonDecode(jsonData1) as Map<String, dynamic>;

      expect(
        () => CodeAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('C000-C01C'),
            name: 'Code Section #1',
          ),
          AddressSpace.fromTag('C001'),
          json1,
        ),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should create an instance of CodeAnnotation successfully', () {
      CodeAnnotation codeAnnotation;

      expect(
        codeAnnotation = CodeAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('C000-C01C'),
            name: 'Code Section #1',
          ),
          AddressSpace.fromTag('C001'),
          json,
        ),
        equals(const TypeMatcher<CodeAnnotation>()),
      );
      expect(codeAnnotation.label, equals('PUSH78'));
      expect(
        codeAnnotation.comment,
        equals('System subroutine: Write X register'),
      );

      const String jsonDataLabelOnly = '{ "label": "PUSH78" }';
      final Map<String, dynamic> jsonLabelOnly =
          jsonDecode(jsonDataLabelOnly) as Map<String, dynamic>;

      expect(
        codeAnnotation = CodeAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('C000-C01C'),
            name: 'Code Section #1',
          ),
          AddressSpace.fromTag('C001'),
          jsonLabelOnly,
        ),
        equals(const TypeMatcher<CodeAnnotation>()),
      );
      expect(codeAnnotation.label, equals('PUSH78'));
      expect(codeAnnotation.comment, isNull);

      const String jsonDataCommentOnly =
          '{ "comment": "System subroutine: Write X register" }';
      final Map<String, dynamic> jsonCommentOnly =
          jsonDecode(jsonDataCommentOnly) as Map<String, dynamic>;

      expect(
        codeAnnotation = CodeAnnotation.fromJson(
          AnnotatedArea.empty(
            addressSpace: AddressSpace.fromTag('C000-C01C'),
            name: 'Code Section #1',
          ),
          AddressSpace.fromTag('C001'),
          jsonCommentOnly,
        ),
        equals(const TypeMatcher<CodeAnnotation>()),
      );
      expect(codeAnnotation.label, isNull);
      expect(
        codeAnnotation.comment,
        equals('System subroutine: Write X register'),
      );
    });
  });
}
