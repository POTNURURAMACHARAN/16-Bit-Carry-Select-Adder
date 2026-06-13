# 16-bit Carry Select Adder (CSA) — SystemVerilog

A fully verified RTL implementation of a 16-bit Carry Select Adder
written in SystemVerilog, with a self-checking testbench.

---

## Architecture

```
csa_16bit  (top)
├── csa_block_4bit  [bits 3:0]
│   ├── rca_4bit (cin=0)
│   └── rca_4bit (cin=1)  → MUX selects based on actual cin
├── csa_block_4bit  [bits 7:4]
├── csa_block_4bit  [bits 11:8]
└── csa_block_4bit  [bits 15:12]
    └── rca_4bit → full_adder (x4)
```

Each block pre-computes both `cin=0` and `cin=1` paths in parallel,
then selects the correct result once the real carry arrives — reducing
carry propagation delay compared to a plain ripple carry adder.

---

## File Structure

```
16bit-carry-select-adder/
├── README.md
├── rtl/
│   └── csa_16bit.sv       # Design: full_adder, rca_4bit,
│                          #         csa_block_4bit, csa_16bit
└── tb/
    └── tb_csa_16bit.sv    # Self-checking testbench (40 test cases)
```

---

## Test Coverage (40 Test Cases)

| Group | Description              | TCs     |
|-------|--------------------------|---------|
| 1     | Corner Cases             | 1–8     |
| 2     | Carry Propagation        | 9–14    |
| 3     | Alternating Bit Patterns | 15–20   |
| 4     | Same Value (Doubling)    | 21–26   |
| 5     | Typical Values           | 27–34   |
| 6     | Power of 2 Boundaries    | 35–40   |

---

## How to Simulate (EDA Playground)

1. Go to [edaplayground.com](https://edaplayground.com)
2. Paste `rtl/csa_16bit.sv` into the **Design** (right) pane
3. Paste `tb/tb_csa_16bit.sv` into the **Testbench** (left) pane
4. Select **Aldec Riviera-PRO** or **Cadence Xcelium**
5. Check **"Open EPWave after run"** for waveforms
6. Click **Run ▶**

---

## Expected Output

```
===========================================================
      16-bit Carry Select Adder — Verification Report
===========================================================
--- Group 1: Corner Cases ---
TC1  | A=0000  B=0000  Cin=0 | Sum=0000  Cout=0 | PASS
TC2  | A=ffff  B=ffff  Cin=1 | Sum=ffff  Cout=1 | PASS
...
===========================================================
  Total: 40 | Passed: 40 | Failed: 0
  [RESULT] ALL TEST CASES PASSED
===========================================================
```
