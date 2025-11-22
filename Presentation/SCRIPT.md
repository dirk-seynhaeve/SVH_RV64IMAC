# SVH Demo Script - RISC-V Design Example

## Preparation

- Make sure that PowerShell supports color (use $PROFILE startup script)

```ps
# Unix/Linux conventions that many cross-platform tools respect:
$env:CLICOLOR = 1          # Enable colors (0 to disable)
$env:CLICOLOR_FORCE = 1    # Force colors even in non-TTY
$env:FORCE_COLOR = 1       # Node.js/npm convention
$env:TERM = "xterm-256color"  # Set terminal type to support 256 colors (compatible with many terminals)
$env:COLORTERM = "truecolor"  # Indicate support for true color (available in VS Code and Windows Terminal)
```

## 🎯 Opening - From Chaos to Control

💡 **Show:** DEMO.png (workflow diagram)

📢 **Say:**

> Today I'll demonstrate how Sigasi Visual HDL (SVH) accelerates HDL development with a real 64-bit RISC-V core.
>
> This starts by finding the relevant HDL files - whether they're scattered across your enterprise network or hosted in the cloud.
> These HDL files are organized into an SVH project
>
>
> SVH's language server continuously monitors these files, helping you:
> - **Understand** the design structure
> - **Improve** the implementation
> - **Ensure compliance** with your company guidelines
>
> Once you're confident in your robust, compliant design, it's ready for deployment into your downstream workflow.

### 👉 Explorer View - VS Code Workspace

**Show:** File tree with project structure

> For this demo, I've forked a GitHub repository with a RISC-V processor that includes:
> - Integer Instructions
> - Multiply/Divide
> - Atomic Instructions
> - Compressed Instructions

> I haven't touched the original design - just added a UVM testbench for demonstration.


📢 **CONTEXT:** "Here's our workspace - we've narrowed the chaos of network drives and cloud repos down to one specific directory that deserves VS Code's and our attention"

📢 **WHAT YOU SEE:** "Hundreds of HDL files, scattered across directories - the design is in here somewhere..."

📢 **TRANSITION:** "Now let's check out the project and watch how SVH make sense of all this..."

---

## 🏗️ Project Setup - From Files to Libraries

### 👉 Project View - Mapping Files to Work Libraries

**Show:** Project View panel

📢 **KEY CONCEPT:** "Not all files need compilation - in the Project View, we map only the relevant HDL files to work libraries"

### 👉 Libraries View - Library Organization

**Show:** Libraries View with work library

📢 **SYSTEMVERILOG APPROACH:** "For SystemVerilog, we keep it simple - all relevant files mapped to a single work library"

📢 **VHDL CAPABILITY:** "For VHDL designs, this same mechanism maps files to their specific work libraries"

📢 **BENEFIT:** "Just map files to work libraries - that's it! SVH automatically figures out compilation order and dependencies. No makefiles, no scripts, no manual dependency lists"

📢 **DIFFERENTIATION:** "Unlike other tools that require explicit compilation order or complex build scripts, SVH's intelligent compiler determines all dependencies automatically"

### 👉 Central Library Database - Resource Libraries

**Show:** Resource libraries selection

📢 **RESOURCE LIBRARIES:** "Pre-verified 'golden' libraries - unlike work libraries, these won't report issues but provide all their definitions for your design"

---

## 🔍 Design Intelligence & Navigation

### 👉 Hierarchy View

**Action:** Cross-probe into `tb_top`

📢 **BENEFIT:** "Understanding your design is no longer about hunting through scattered files - it's about browsing through intelligent, design-centric views"

📢 **KEY POINT:** "SVH automatically sorted out all dependencies - you're navigating the actual design structure, not file structures"

### 👉 Dependency View

**Show:**

- Continuous Incremental Compile
  - Filter problems to active file only
  - Comment out closing parenthesis of `dut` instantiation
  - ✅ Note immediate error identification (but it recovers)
  - Uncomment to restore
  - Reset Filter problems to all files

```sv
    // DUT instantiation
    riscv_core_top dut (
        .i_riscv_core_clk(clk),
        .i_riscv_core_rst_n(rst_n)
    // );
    ```
- 📊 Compilation Order (automatically computed)
- 📄 Export documentation capability

📢 **BENEFIT:** "See the compilation order SVH figured out automatically - no dependency errors, no manual ordering, just works"

📢 **DIFFERENTIATION:** "While others require you to maintain makefiles or compilation scripts, SVH continuously compiles everything in the right order - automatically"

---

## ⚠️ Problem Detection & Resolution

### Syntax Error Detection

**Demo Flow:**

1. Move include file: `uvm/include` → `uvm/source`
   - ⚠️ Problem count increases automatically
2. Filter problems for `include`
3. Cross-probe to exact problem location
4. Move file back → ✅ Problem count decreases, decorations removed

📢 **BENEFIT:** "Find and fix issues in seconds, not hours - with precise error locations"

### Compliance & Best Practices

**Configure:** Project Settings → Verilog Errors/Warnings

- `datatype`: Disallow reg datatype: Apply as `error`
- Filter for `logic` and cross-probe
- Show and apply QuikFix

- `naming`: Module convention `[a-z0-9]+(_[a-z0-9]+)*` (snake_case)
- Filter for `naming` and cross-probe (camelCase)

📢 **BENEFIT:** "Enforce company coding standards automatically - ensure clean, maintainable code"

### CI/CD Integration

**Command Line Demo:**

```bash
sigasi-cli --help
sigasi-cli verify --fail-on-error .
echo $?
```

```ps
sigasi-cli --help
sigasi-cli verify --fail-on-error .
echo $LASTEXITCODE
```

📢 **BENEFIT:** "Seamlessly integrate with your CI/CD pipeline - catch issues before merge"

---

## Navigation



## 📊 Visualization & Documentation

### 👉 Block Diagram Generation

**Demo Flow:**

1. Open `tb_top` → Show Block Diagram
2. Hover on `riscv_if riscv_vif(clk)` → Show in Block Diagram
3. Cross-probe `clk/rst` from diagram back to source

📢 **BENEFIT:** "Auto-generated, always up-to-date documentation - perfect for design reviews"

### 👉 Instance Navigation

**Demo Flow:**

1. Select `dut` → Open Module (shows 3 instances)
2. Confirm in Hierarchy View
3. Rename to `i_riscv_core_clock_rename`
4. Find All References → Shows updates in 2 files!

📢 **BENEFIT:** "Refactor with confidence - SVH tracks every instance and connection"

---

## 🎮 State Machine Analysis

### 👉 State Machine Views

**Symbol Search:** `controller riscv_core_dcache_controller`

**Show:**

- State Machine Diagram view
- State Machine Transition Table
- Cross-probe between views

📢 **BENEFIT:** "Visualize complex FSMs instantly - debug state transitions visually"

### Advanced Preprocessing

**Demo Flow:**

1. Go to Definition → Create typedef
2. Generate import statement
3. Create include file structure

**Generated Code:**

```systemverilog
// types.svh
`ifndef TYPES_SVH
`define TYPES_SVH

package types;
    typedef enum logic [2:0] {
        IDLE           = 3'b000,
        MEM_REQ        = 3'b001,
        UPDATE_CACHE   = 3'b010,
        MEM_WRITE      = 3'b011,
        AMO_OP         = 3'b100
    } state_t;
endpackage
`endif
```

4. Add `DUMMY` state → Watch real-time update
5. Cross-probe to `default` case
6. Comment out default → See immediate warnings

📢 **BENEFIT:** "SVH understands preprocessor directives - no more macro debugging nightmares"

---

## ✅ Verification & UVM Support

### 👉 UVM Topology View

**Show:** Complete testbench hierarchy
**Action:** Cross-probe to environment

📢 **BENEFIT:** "Understand complex UVM testbenches visually - accelerate verification development"

### 👉 UVM Diagram

**Show:** Component connections and TLM interfaces
**Action:** Cross-probe to interface definitions

### Deployment Integration

**Show:** JSON handoff (recipe) generation
💡 **Show:** WORKFLOW.png

📢 **BENEFIT:** "Seamless handoff between teams - from design to verification to implementation"

---

## 🎯 Key Takeaways

✅ **faster navigation** even in complex designs
✅ **Real-time error detection** before simulation
✅ **Automatic documentation** generation
✅ **Enforced coding standards** across teams
✅ **Visual debugging** for FSMs and UVM
✅ **CI/CD ready** from day one


# Problem Notes:

- Rule should have same wording as the diagnostic
- I need a list of "accidental tops", or uninstantiated modules, to clean up my project
- Compile order doesn't work for RV64IMAC
- Working on an include file without an include statement using the file takes away autocomplete
- Common Libraries in Project View is confusing, Project view should just focus on file mapping.
- UVM does not belong with the work libraries, there should be a separate RESOURCE LIBRARIES VIEW, that also includes the VHDL libraries