# PC-1500 Keyboard Scan — Hardware Architecture

## Overview

The PC-1500 keyboard matrix uses **two I/O chips** and the **CPU input pins** to scan 64+ keys. The matrix is organized as 6 strobe columns x 16 input rows, split across two separate input paths.

## Hardware Components

### Strobe Lines (Column Select)

The **PC-1500 main I/O** (LH5811 at ME1 address `$F000`) provides the strobe lines:

- **PA0–PA5**: 6 key strobe columns (directly drive keyboard matrix columns)
- **PA6–PA7**: Scanned by the ROM but have no keys connected

The ROM activates one column at a time by:
1. Writing to **DDA** (`$F00C`) to set one PA bit as output (e.g., `$01` for PA0)
2. Writing `$00` to **OPA** (`$F00E`) to drive that pin low
3. All other PA pins remain as high-impedance inputs (DDA=0), effectively deselected

This technique uses the **direction register as the strobe selector** rather than the output register.

### Input Lines (Row Read) — Two Sets

The 16 rows in the key code chart are physically split across two separate input paths:

#### Rows 0–7: CPU IN0–IN7 Pins

Read by the **ITA instruction** (opcode `$FD $BA`), which loads the CPU's hardware input port (IN0–IN7) into the accumulator.

These 8 input lines carry the response for keys with **key code low nibble 0–7**.

#### Rows 8–F: CE-153 PA0–PA7

Read from the **CE-153 I/O** (LH5811 at ME1 address `$8000`), port A register (`$800E`).

These 8 input lines carry the response for keys with **key code low nibble 8–F**, where:
- Row 8 = CE-153 PA0
- Row 9 = CE-153 PA1
- ...
- Row F = CE-153 PA7

### ON Key (Special)

The ON key is **not part of the keyboard matrix**. It connects directly to **PB7 of the PC-1500 I/O** (`$F00F`). The ROM checks it separately via the key scan subroutine (see p.105 of the Technical Reference Manual).

## Key Code Encoding

The key code chart on p.109 of the Technical Reference Manual encodes each key as a single byte:

```
Key code = (column << 4) | row

  column = high nibble (0–5) = PA strobe line
  row    = low nibble  (0–F) = input line
             0–7: IN0–IN7
             8–F: CE-153 PA0–PA7
```

### Key Code Chart

```
         Col 0    Col 1    Col 2    Col 3    Col 4    Col 5
         (PA0)    (PA1)    (PA2)    (PA3)    (PA4)    (PA5)
Row 0             —        SPACE    0        —        P
Row 1    SHIFT    F1       —        1        A        Q
Row 2    SML      F2       —        2        B        R
Row 3    —        F3       —        3        C        S
Row 4    ↕        F4       —        4        D        T
Row 5    RCL      F5       —        5        E        U
Row 6    —        F6       —        6        F        V
Row 7    —        —        —        7        G        W
  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —  —
Row 8    ◄        CL       (        8        H        X
Row 9    —        —        )        9        I        Y
Row A    ↑        *        —        —        J        Z
Row B    ↓        DEF      +        —        K        —
Row C    ►        —        —        —        L        —
Row D    ENTER    —        -        =        M        —
Row E    —        —        .        —        N        —
Row F    OFF      MODE     /        —        O        —
```

Rows 0–7 are read via ITA (CPU IN pins). Rows 8–F are read via CE-153 PA.

## ROM Scan Routine

The KEY SCAN I subroutine at `$E42C` performs a column-by-column scan:

### Quick-Check (Any Key Pressed?)

Before the full scan, the subroutine at `$E418` performs a fast check:

1. Set `DDA = $FF` (all PA pins as outputs)
2. Set `OPA = $00` (drive all columns low simultaneously)
3. Execute `ITA` + `EAI #$FF` (read and invert IN0–IN7)
4. If result is non-zero, at least one key in rows 0–7 is pressed

### Full Column Scan

```
For each column C (PA0 through PA7):
    1. Write DDA = (1 << C)     ; Only PA(C) is output
    2. Write OPA = $00           ; Drive PA(C) low
    3. Execute ITA               ; Read IN0–IN7 into A
    4. EAI #$FF                  ; Invert (pressed keys become 1)
    5. Shift-and-count loop:
       - SHL A                   ; Shift left, MSB into carry
       - If carry set: key found at current position
       - INC XL                  ; Track bit position
    6. Also read CE-153 PA ($800E) for rows 8–F
    7. Compute key code from column index and bit position
```

The XL register tracks the scan position, starting at `$80` and incrementing by 8 per column and by 1 per bit within a column. The final key code is derived from XL.

## Signal Flow Diagram

```
                    PC-1500 I/O (LH5811 @ $F000)
                    ┌─────────────────────────┐
     ROM writes ──► │ DDA ($F00C)             │
     ROM writes ──► │ OPA ($F00E)             │
                    │                         │
                    │ PA0 ──────────┐         │
                    │ PA1 ──────────┤         │
                    │ PA2 ──────────┤         │
                    │ PA3 ──────────┤ Strobe  │
                    │ PA4 ──────────┤ Lines   │
                    │ PA5 ──────────┤         │
                    │ (PA6) ────────┤ unused  │
                    │ (PA7) ────────┤ unused  │
                    │               │         │
                    │ PB7 ◄──── ON key        │
                    └─────────────────────────┘
                                    │
                                    ▼
                         ┌──────────────────┐
                         │  KEYBOARD MATRIX │
                         │   (6 col x 16 row) │
                         └──────────────────┘
                            │              │
                     Rows 0–7         Rows 8–F
                            │              │
                            ▼              ▼
                    ┌──────────┐   ┌──────────────────┐
                    │ CPU      │   │ CE-153 (LH5811   │
                    │ IN0–IN7  │   │ @ $8000)         │
                    │          │   │ PA0–PA7           │
                    │ ITA instr│   │ Read $800E        │
                    └──────────┘   └──────────────────┘
                            │              │
                            ▼              ▼
                         ROM key scan routine
                         computes key code
```

## References

- Technical Reference Manual, p.105: PC-1500 I/O PC pin assignments
- Technical Reference Manual, p.107: CE-153 I/O PC pin assignments
- Technical Reference Manual, p.109: Key matrix and key code chart
- Technical Reference Manual, p.120: KEY SCAN subroutine addresses (`$E42C`, `$E243`)
