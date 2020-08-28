class AnnotationsError extends Error {
  AnnotationsError(this.message);

  final String message;

  @override
  String toString() => 'System: $message';
}
