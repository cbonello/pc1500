/// Tracks whether the PC-1500's 40-pin expansion connector is in use.
///
/// Only one expansion module can be connected at a time (CE-151, CE-155, etc.).
/// This class manages the slot metadata; the actual RAM mapping is handled
/// by the [Emulator].
class ExtensionModule {
  bool _used = false;
  String _name = '';
  int _capacity = 0;

  /// Whether an expansion module is currently installed.
  bool get isUsed => _used;

  /// Name of the installed module (e.g. 'CE151'), or empty if none.
  String get name => _name;

  /// Capacity of the installed module in bytes, or 0 if none.
  int get capacity => _capacity;

  /// Registers an expansion module on this connector.
  ///
  /// Throws [ArgumentError] if [name] is empty or [capacity] is out of range.
  void addModule(String name, int capacity) {
    if (name.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (capacity < 2 * 1024 || capacity > 16 * 1024) {
      throw ArgumentError.value(
        capacity,
        'capacity',
        'must be between 2KB and 16KB',
      );
    }
    _name = name;
    _capacity = capacity;
    _used = true;
  }

  /// Removes the installed module, freeing the connector slot.
  ///
  /// Note: this only resets the slot metadata. The caller is responsible
  /// for removing the corresponding RAM chips from the chip-select decoder.
  void removeModule() {
    _name = '';
    _capacity = 0;
    _used = false;
  }
}
