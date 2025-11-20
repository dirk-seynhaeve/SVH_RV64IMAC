# Demo Script

💡 DEMO.png

👉 Explorer View

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
👉 Explorer | 👉Project View | 👉 Library View


## Dependencies

👉 Hierarchy View

- Cross probe into `tb_top`


👉 Dependency View
- Continous Incremental Compile
- Export and open documentation
- Compilation Order

## Problems

### Syntax

- Move include file from  uvm/include` to `uvm/source` (Problem count increases)
- Filter for `include`
- Cross probe to problem
- Move the file back (Problem count decreases, error decoration is removed)

### Best Practices and Compliance

  - Project Settings: Verilog Errors/Warnings
  - `datatype` : Dissalow Reg Type (error)
  - `naming` : Naming convention Module `[a-z01]+(_[a-z0-9]+)*` (snake_case)

  ### CI/CD compliance enforcement

- CI/CD: CLI
  - `sigasi-cli --help`
  - `sigasi-cli verify --fail-on-error .`

  - `echo $?`

## Visualization

Up to date documentation

👉 tb_top : Open Block Diagram

  - `riscv_if riscv_vif(clk)` : Hover | Show in Block Diagram

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

## Verification/UVM

👉 UVM Topologoy

- Explain Hierarchy
- Cross probe to environment

👉 UVM Diagram

- Explain hierarchy
- Cross probe to interface

- Deployment: JSON handoff (recipe)

💡 WORKFLOW.png
