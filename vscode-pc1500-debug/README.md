# PC-1500 Debugger for VS Code

A VS Code debug adapter extension for the Sharp PC-1500 emulator. Connects to the emulator's built-in DAP (Debug Adapter Protocol) server over TCP, giving you a full machine-level debugging experience.

## Features

- **Attach** to a running PC-1500 emulator instance
- **Step** through LH5801 instructions (step in, step over, step out)
- **Breakpoints** on instruction addresses
- **Disassembly** view with ROM annotations (labels, comments)
- **Registers** and **flags** inspection (A, X, Y, U, S, P, C, Z, V, H, IE)
- **Modify registers** and flags from the Variables pane
- **Memory** read/write
- **Debug console** with expression evaluation:
  - Register names: `A`, `X`, `Y`, `U`, `S`, `P`
  - Flags: `C`, `Z`, `V`, `H`, `IE`, `HLT`
  - Memory reads: `[7600]` (single byte) or `[C000:10]` (10 bytes)
  - Hex literals: `$FF`, `0xFF`

## Prerequisites

- [VS Code](https://code.visualstudio.com/) 1.80 or later
- [Node.js](https://nodejs.org/) 16 or later (for building)
- The PC-1500 emulator running with its debug server enabled (default port 3756)

## Installation

### From source (development)

1. **Build the extension:**

   ```bash
   cd vscode-pc1500-debug
   npm install
   npm run compile
   ```

2. **Install into VS Code** using one of these methods:

   **Option A -- Symlink (recommended for development):**

   Create a symlink in the VS Code extensions directory so changes are picked up on reload:

   ```bash
   ln -s "$(pwd)" ~/.vscode/extensions/pc1500-debug
   ```

   **Option B -- Copy:**

   ```bash
   cp -r . ~/.vscode/extensions/pc1500-debug
   ```

3. **Reload VS Code** (`Cmd+Shift+P` > `Developer: Reload Window`).

### As a VSIX package

1. Install the `vsce` packaging tool if you don't have it:

   ```bash
   npm install -g @vscode/vsce
   ```

2. Package the extension:

   ```bash
   cd vscode-pc1500-debug
   npm install
   npm run compile
   vsce package
   ```

3. Install the generated `.vsix` file:

   ```bash
   code --install-extension pc1500-debug-0.1.0.vsix
   ```

## Usage

### 1. Start the emulator

Run the PC-1500 Flutter app. The debug server starts automatically on port 3756.

### 2. Add a launch configuration

Create or edit `.vscode/launch.json` in your workspace:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "pc1500",
      "request": "attach",
      "name": "Attach to PC-1500",
      "host": "localhost",
      "port": 3756
    }
  ]
}
```

### 3. Attach the debugger

Press `F5` or go to **Run > Start Debugging**. The debugger attaches to the emulator and pauses execution, showing the current instruction in the disassembly view.

### 4. Debug

| Action | Shortcut |
|---|---|
| Continue | `F5` |
| Step Over / Step In | `F10` / `F11` |
| Step Out | `Shift+F11` |
| Pause | `F6` |
| Toggle Breakpoint | Click the gutter in the Disassembly view |

Use the **Variables** pane to inspect and modify registers and flags. Use the **Debug Console** to evaluate expressions (e.g., type `X` to see the X register, or `[7600:8]` to dump 8 bytes at address $7600).

## Configuration

| Property | Type | Default | Description |
|---|---|---|---|
| `host` | string | `localhost` | Host where the emulator is running |
| `port` | number | `3756` | TCP port of the emulator's debug server |

## Architecture

The extension is a thin pass-through: it registers a `DebugAdapterServer` that tells VS Code to connect directly to the emulator's TCP socket. All DAP message handling happens inside the emulator isolate (`packages/device/lib/src/emulator_isolate/dap_server.dart`).

```
VS Code  <--DAP/TCP-->  Emulator Isolate (DapServer)
                              |
                         LH5801 CPU
```
