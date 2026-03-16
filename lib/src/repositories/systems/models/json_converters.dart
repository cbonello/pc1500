/// Converts a JSON integer to a double.
/// Used by json_serializable for fields that are stored as int in JSON
/// but represented as double in Dart (e.g. pixel coordinates).
double intToDouble(int value) => value.toDouble();

/// Converts a hex color string (e.g. "FF8800FF") to an int.
int colorToInt(String value) => int.parse(value, radix: 16);
