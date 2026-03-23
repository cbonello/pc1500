# PC-1500 MCP Server

An [MCP](https://modelcontextprotocol.io/) server that bridges Claude to the
PC-1500 emulator via the Debug Adapter Protocol (DAP). It exposes emulator
debugging tools — register inspection, memory access, stepping, breakpoints,
and disassembly — through the Model Context Protocol.

## Architecture

```
Claude  -->  MCP (stdio)  -->  DAP client (TCP)  -->  DAP server (emulator isolate)  -->  LH5801 CPU
```

The server translates MCP tool calls into DAP requests sent over a TCP
connection to the emulator's built-in DAP server (default `localhost:3756`).

## Setup

Requires Dart SDK `>=3.10.0`.

```bash
cd tools/mcp_server
dart pub get
```

### Register with Claude Code

The project's `.mcp.json` already registers the server:

```json
{
  "mcpServers": {
    "pc1500": {
      "command": "tools/mcp_server/bin/start.sh",
      "args": []
    }
  }
}
```

### Optional: compile to native executable

```bash
dart compile exe bin/pc1500_mcp_server.dart -o bin/pc1500_mcp_server
```

Then update `bin/start.sh` to run the compiled binary instead of `dart run`.

## Usage

1. Start the PC-1500 emulator (the DAP server listens on port 3756).
2. In Claude Code, call `emulator_connect` to establish the DAP connection.
3. Use any of the tools below.

## Tools

### Connection

| Tool | Description |
|------|-------------|
| `emulator_connect` | Connect to the running emulator. Must be called first. |
| `emulator_disconnect` | Disconnect from the emulator. |

### Inspection

| Tool | Parameters | Description |
|------|------------|-------------|
| `emulator_cpu_state` | — | Read registers (A, X, Y, U, S, P), flags (C, Z, V, H, IE), and system state (HLT, IRQ, timer, DISP). |
| `emulator_read_memory` | `address` (hex, required), `count` (int, default 64, max 4096) | Read bytes and return a hex dump with ASCII. |
| `emulator_disassemble` | `address` (hex, default current PC), `count` (int, default 20, max 100) | Disassemble LH5801 instructions with ROM annotations. |
| `emulator_screenshot` | — | Capture the 156×7 LCD as a PNG image (scaled 10× to 1560×70) with active status symbols (DEF, SHIFT, RUN, PRO, etc.). |

### Control

| Tool | Parameters | Description |
|------|------------|-------------|
| `emulator_step` | `count` (int, default 1, max 10000) | Execute instruction(s) and return the new CPU state. Each step is a DAP round-trip, so large counts (>100) will be slow. |
| `emulator_continue` | — | Resume execution until a breakpoint or pause. |
| `emulator_pause` | — | Pause execution and return the CPU state. |

### Memory & Breakpoints

| Tool | Parameters | Description |
|------|------------|-------------|
| `emulator_write_memory` | `address` (hex, required), `bytes` (hex string, e.g. `"FF 00 40 58"`) | Write bytes to emulator memory. |
| `emulator_set_breakpoints` | `addresses` (list of hex strings, e.g. `["0xE967"]`) | Set instruction breakpoints. Replaces all existing breakpoints; pass `[]` to clear. |

### Address format

All addresses are hexadecimal strings. Both `"0x4000"` and `"4000"` are
accepted. The LH5801 address space is `0x0000`–`0xFFFF` for ME0 and
`0x10000`–`0x1FFFF` for ME1.

## Project structure

```
mcp_server/
  bin/
    start.sh                  Shell wrapper (entry point for .mcp.json)
    pc1500_mcp_server.dart    CLI entry point
  lib/
    server.dart               Barrel file (re-exports)
    src/
      pc1500_server.dart      MCP server — tool definitions and handlers
      dap_client.dart         Lightweight DAP-over-TCP client
  pubspec.yaml
```

## Dependencies

- [dart_mcp](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp) — MCP server framework
- [stream_channel](https://pub.dev/packages/stream_channel) — bidirectional communication
