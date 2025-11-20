# Demo Script

RiscV 64-bit
- Integer Instructions
- Multiply/Divide
- Atomic Instructions
- Compressed Instructions

Fork from GitHub repository

- Core as is
- UVM created by me

👉 SCM Graph View

## Project setup

Workspace | Project | Librariess
---|---|----
Scope for VS Code | Scope for HDL files | Scope for Continuous Compiler
Explorer | Project View | Library View

## Dependencies

- Dependency View
- Continous Incremental Compile
- Compilation Order

## Problems

- SYNTAX: Move include file

- BEST PRACTICES and COMPLIANCE: Rules
  - Dissalow Reg Type (error)
  - Naming convention Module `[a-z01]+(_[a-z0-9]+)*`

- CI/CD: CLI
  - `sigasi-cli --help`
  - `sigasi-cli verify --fail-on-error .`
  - `echo $?`

## Visualization

Up to date documentation

👉 tb_top : Open Block Diagram

  - riscv_vif : Hover | Show in Block Diagram

👉 Hierarchy View

-  dut : cross probe to HDL
- Hover | Show in Block Diagram
- Cross probe clk/rst from Block Diagram

  - dut : Open Module (3 instances)
  - dut : Confirm in Hierarchy

  - rename i_riscv_core_clock_rename
  - Find all references: in two files!

  ## Statemachine

  Explore the power of the preprocessor

- Symbol search controller riscv_core_dcache controller

👉 State machine Diagram

👉 State machine Transition Table

- Cross probe from diagram

- Go to Definition
- Create typedef
- Create import
- Create include file

```sv
`include "types.svh"

import types::*;
```

```sv
`ifndef TYPES_SVH
`define TYPES_SVH

package types;
    typedef enum logic [2:0] {
    IDLE           = 3'b000,
    MEM_REQ        = 3'b001,
    UPDATE_CACHE   = 3'b010,
    MEM_WRITE      = 3'b011,
    AMO_OP         = 3'b100} state_t;
endpackage

`endif
```

- Add DUMMY
- Crossprobe to default
- Comment out default


