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

