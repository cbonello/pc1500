class ExtensionModule {
  ExtensionModule() {
    _reset();
  }

  bool _used = false;

  // Module name
  String name = '';

  // Capacity in bytes
  int capacity = 0;

  bool get isUsed => _used;

  void addModule(String name, int capacity) {
    assert(name.isNotEmpty);
    assert(capacity >= 2 * 1024 && capacity <= 16 * 1024);

    this.name = name;
    this.capacity = capacity;
    _used = true;
  }

  void removeModule() => _reset();

  void _reset() {
    name = '';
    capacity = 0;
    _used = false;
  }
}
