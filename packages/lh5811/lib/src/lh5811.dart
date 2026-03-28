/// LH5810/LH5811 I/O port controller emulator.
///
/// The LH5810/LH5811 is a single-chip CMOS I/O port controller featuring:
/// - Two pairs of 8-bit bidirectional ports (PA, PB)
/// - One pair of 8-bit output port (PC)
/// - Interrupt controller with mask register
/// - Serial data transfer control
/// - CPU wait control
///
/// Register map (selected by RS3-RS0):
///   0100 (0x04) - Divider reset (write resets internal divider)
///   0101 (0x05) - U register (serial receive data, read clears RD flag)
///   0110 (0x06) - Serial transfer (write starts transmit, clears TD flag)
///   0111 (0x07) - F register (modulation clock configuration)
///   1000 (0x08) - OPC register (port C output)
///   1001 (0x09) - G register (clock rate, wait time configuration)
///   1010 (0x0A) - MSK register (interrupt mask)
///   1011 (0x0B) - IF register (interrupt flags, IF0/IF1 writable, RD/TD read-only)
///   1100 (0x0C) - DDA register (port A direction: 0=input, 1=output)
///   1101 (0x0D) - DDB register (port B direction: 0=input, 1=output)
///   1110 (0x0E) - OPA register (port A: write sets output, read returns pins)
///   1111 (0x0F) - OPB register (port B: write sets output, read returns pins)
class LH5811 {
  LH5811({this.onInterrupt, this.onPortARead, this.onPortBRead});

  /// Callback invoked when the INT output is asserted.
  final void Function()? onInterrupt;

  /// Called when the CPU reads port A (register 0x0E).
  /// Should return the current state of external PA input pins.
  /// This allows external hardware (e.g. keyboard matrix) to provide
  /// input lazily at read time rather than pushing state continuously.
  final int Function()? onPortARead;

  /// Called when the CPU reads port B (register 0x0F).
  /// Should return the current state of external PB input pins.
  final int Function()? onPortBRead;

  // Internal registers.
  int _opc = 0; // Port C output register.
  int _g = 0; // Clock rate / wait time register.
  int _msk = 0; // Interrupt mask register.
  int _if = 0; // Interrupt flag register.
  int _dda = 0; // Port A direction register.
  int _ddb = 0; // Port B direction register.
  int _opa = 0; // Port A output register.
  int _opb = 0; // Port B output register.
  int _f = 0; // Modulation clock register.
  int _u = 0; // Serial receive data register.

  // External pin state (directly driven by outside hardware).
  int _pinPA = 0; // Current state of PA0-PA7 input pins.
  int _pinPB = 0; // Current state of PB0-PB7 input pins.

  /// Resets all registers to their power-on state.
  void reset() {
    _opc = 0;
    _g = 0;
    _msk = 0;
    _if = 0;
    _dda = 0;
    _ddb = 0;
    _opa = 0;
    _opb = 0;
    _f = 0;
    _u = 0;
    _pinPA = 0;
    _pinPB = 0;
  }

  /// Sets the external state of port A input pins.
  /// Bits where DDA=0 (input mode) will be read from these values.
  void setPortAInput(int value) => _pinPA = value & 0xFF;

  /// Sets the external state of port B input pins.
  /// Bits where DDB=0 (input mode) will be read from these values.
  void setPortBInput(int value) => _pinPB = value & 0xFF;

  /// Returns the current output state of port A.
  /// Only bits where DDA=1 (output mode) are driven.
  int get portAOutput => _opa & _dda;

  /// Returns the current output state of port B.
  /// Only bits where DDB=1 (output mode) are driven.
  int get portBOutput => _opb & _ddb;

  /// Returns the current state of port C output.
  int get portCOutput => _opc;

  /// Reads a register at the given offset (0x00-0x0F).
  /// The offset corresponds to RS3-RS0 in the hardware.
  int read(int offset) {
    switch (offset & 0x0F) {
      case 0x05: // U register: read serial receive data, clear RD flag.
        final int value = _u;
        _if &= ~0x04; // Clear RD (bit 2).

        return value;
      case 0x07: // F register.
        return _f;
      case 0x08: // OPC register.
        return _opc;
      case 0x09: // G register.
        return _g;
      case 0x0A: // MSK register.
        // High nibble returns CL1, SD1, PB7, IRQ status.
        return _msk & 0x0F;
      case 0x0B: // IF register.
        return _if & 0x0F;
      case 0x0C: // DDA register.
        return _dda;
      case 0x0D: // DDB register.
        return _ddb;
      case 0x0E: // OPA/PA register: read returns pin state.
        // Query external hardware for current pin state if provider exists.
        if (onPortARead != null) _pinPA = onPortARead!() & 0xFF;
        // Output bits return OPA value, input bits return external pin state.
        return (_opa & _dda) | (_pinPA & ~_dda);
      case 0x0F: // OPB/PB register: read returns pin state.
        if (onPortBRead != null) _pinPB = onPortBRead!() & 0xFF;
        return (_opb & _ddb) | (_pinPB & ~_ddb);
      default:
        return 0xFF;
    }
  }

  /// Writes a value to a register at the given offset (0x00-0x0F).
  void write(int offset, int value) {
    final int v = value & 0xFF;
    switch (offset & 0x0F) {
      case 0x04: // Divider reset.
        // Resets the internal clock divider. No register state to update.
        return;
      case 0x06: // Serial transfer: load data for transmission.
        // In a full emulation, this would start serial output.
        // Clear TD flag (bit 3) to indicate transmitter busy.
        _if &= ~0x08;
      case 0x07: // F register.
        _f = v & 0x7F; // Bit 7 is unused.
      case 0x08: // OPC register.
        _opc = v;
      case 0x09: // G register.
        _g = v;
      case 0x0A: // MSK register.
        _msk = v & 0x0F;
        _checkInterrupt();
      case 0x0B: // IF register (only IF0 and IF1 are writable).
        _if = (_if & 0x0C) | (v & 0x03);
        _checkInterrupt();
      case 0x0C: // DDA register.
        _dda = v;
      case 0x0D: // DDB register.
        _ddb = v;
      case 0x0E: // OPA register.
        _opa = v;
      case 0x0F: // OPB register.
        _opb = v;
    }
  }

  /// Toggles OPB bit 5. Used to simulate the 64 Hz timer signal
  /// connected to PB5 on the real PC-1500 hardware.
  void toggleOPB5() => _opb ^= 0x20;

  /// Sets IF1 without firing _checkInterrupt. Use for frame-rate timer
  /// ticks where the flag should be pollable but not generate an IRQ.
  void setIF1() => _if |= 0x02;

  /// Clears IF1 without firing _checkInterrupt.
  void clearIF1() => _if &= ~0x02;

  /// Sets the IRQ interrupt flag (IF0) on a rising edge of the IRQ input.
  void triggerIRQ() {
    _if |= 0x01;
    _checkInterrupt();
  }

  /// Sets the PB7 interrupt flag (IF1) on a rising edge of PB7 input.
  void triggerPB7() {
    _if |= 0x02;
    _checkInterrupt();
  }

  /// Sets the RD flag (IF bit 2) when serial data reception completes.
  void serialReceiveComplete(int data) {
    _u = data & 0xFF;
    _if |= 0x04; // Set RD flag.
    _checkInterrupt();
  }

  /// Sets the TD flag (IF bit 3) when serial data transmission completes.
  void serialTransmitComplete() {
    _if |= 0x08; // Set TD flag.
    _checkInterrupt();
  }

  /// Checks if any unmasked interrupt flags are set and invokes the callback.
  void _checkInterrupt() {
    if ((_if & _msk & 0x0F) != 0) {
      onInterrupt?.call();
    }
  }
}
