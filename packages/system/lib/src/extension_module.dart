class ExtensionModule {
  ExtensionModule() {
    _reset();
  }

  bool _used;

  // Module name
  String name;

  // Capacity in bytes
  int capacity;

  bool get isUsed => _used;

  void addModule(String name, int capacity) {
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
