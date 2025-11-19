# RISC-V UVM Testbench

This directory contains a complete UVM (Universal Verification Methodology) testbench for the RISC-V 64-bit core, converted from the original SystemVerilog testbench.

## Directory Structure

```
uvm/
├── src/                    # UVM source files
│   ├── riscv_if.sv        # Interface definition
│   ├── riscv_pkg.sv       # UVM package
│   ├── riscv_transaction.sv # Transaction class
│   ├── riscv_sequence.sv   # Sequence classes
│   ├── riscv_driver.sv    # Driver class
│   ├── riscv_monitor.sv   # Monitor class
│   ├── riscv_scoreboard.sv # Scoreboard class
│   ├── riscv_agent.sv     # Agent class
│   ├── riscv_env.sv       # Environment class
│   ├── riscv_test.sv      # Test classes
│   └── tb_top.sv          # Top-level testbench
├── sim/                   # Simulation files
│   ├── file_list_uvm.txt  # File list for compilation
│   ├── run_uvm_sim.sh     # Linux/Unix run script
│   └── run_uvm_sim.bat    # Windows run script
└── tests/                 # Test-specific files
```

## Features

### 🎯 **Test Classes Available:**
- **`riscv_simple_test`** - Equivalent to original testbench (ls.hex program)
- **`riscv_comprehensive_test`** - Full instruction set test (prog_2.hex)
- **`riscv_random_test`** - Randomized test scenarios
- **`riscv_regression_test`** - Complete regression suite

### 🔍 **Advanced Verification Features:**
- **Functional Coverage** - Tracks instruction types, execution patterns
- **Scoreboard Checking** - Automatic pass/fail determination
- **Transaction Recording** - Complete execution history
- **Configurable Timeouts** - Prevents runaway simulations
- **Multiple Program Support** - Easy to add new test programs

### 📊 **Monitoring & Debug:**
- Real-time PC and register monitoring
- Cycle-by-cycle execution tracking
- Automatic infinite loop detection
- Detailed test result analysis
- Coverage reporting

## Quick Start

### 1. **Copy Test Programs**
```bash
cd uvm/sim
cp ../../FPGA/sim/ls.hex .
# Copy other test programs as needed
```

### 2. **Run Simple Test**
```bash
# Linux/Unix
./run_uvm_sim.sh -test riscv_simple_test

# Windows
run_uvm_sim.bat -test riscv_simple_test
```

### 3. **Run All Tests**
```bash
./run_uvm_sim.sh -test riscv_regression_test
```

## Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-test <name>` | Specify test to run | `-test riscv_comprehensive_test` |
| `-verbosity <level>` | Set UVM verbosity | `-verbosity UVM_HIGH` |
| `-seed <number>` | Set random seed | `-seed 12345` |
| `-dump` | Generate VCD waveform | `-dump` |

### Available Tests:
- `riscv_simple_test` - Basic functionality (default)
- `riscv_comprehensive_test` - Full ISA test
- `riscv_random_test` - Randomized scenarios
- `riscv_regression_test` - Complete test suite

### Verbosity Levels:
- `UVM_NONE` - Minimal output
- `UVM_LOW` - Essential messages
- `UVM_MEDIUM` - Standard output (default)
- `UVM_HIGH` - Detailed debug info
- `UVM_FULL` - Maximum verbosity

## Expected Results

### Simple Test (ls.hex):
```
=== TEST DETAILS ===
Program: ls.hex
Execution time: 347 cycles
Final PC: 0x00000064
Test status: 0x3
Result: PASS
Key registers:
  x00 = 0x0000000000000000
  x09 = 0x0000000000000003
  x10 = 0x0000000000000052
  x11 = 0x0000000010000000
==================
```

### Comprehensive Test (prog_2.hex):
```
=== TEST DETAILS ===
Program: prog_2.hex
Execution time: 2847 cycles
Final PC: 0x000001a4
Test status: 0xf
Result: PASS
✓ Basic Instructions PASSED
✓ Multiplication Extension PASSED
✓ Compressed Instructions PASSED
✓ Atomic Instructions PASSED
🎉 ALL COMPREHENSIVE TESTS PASSED! 🎉
```

## Comparison: SystemVerilog vs UVM

| Feature | Original SystemVerilog | UVM Version |
|---------|----------------------|-------------|
| **Lines of Code** | ~85 lines | ~1000+ lines |
| **Setup Time** | Minutes | Hours/Days |
| **Flexibility** | Limited | Highly configurable |
| **Reusability** | Low | High |
| **Debugging** | Manual `$display` | Built-in reporting |
| **Coverage** | None | Automatic functional coverage |
| **Scalability** | Difficult | Easy to extend |
| **Industry Standard** | No | Yes |
| **Learning Curve** | Low | High |

## When to Use UVM vs SystemVerilog

### ✅ **Use UVM When:**
- Long-term project maintenance
- Multiple test scenarios needed
- Team familiar with UVM
- Professional verification environment required
- Coverage and advanced reporting needed

### ✅ **Use Original SystemVerilog When:**
- Quick verification needs
- Simple test scenarios
- Learning/educational purposes
- Small team or individual work
- Rapid prototyping

## Adding New Tests

### 1. **Create New Sequence:**
```systemverilog
class my_custom_sequence extends riscv_base_sequence;
    `uvm_object_utils(my_custom_sequence)

    virtual task body();
        riscv_transaction tr;
        tr = riscv_transaction::type_id::create("my_tr");
        start_item(tr);
        // Configure transaction
        finish_item(tr);
    endtask
endclass
```

### 2. **Create New Test:**
```systemverilog
class my_custom_test extends riscv_base_test;
    `uvm_component_utils(my_custom_test)

    virtual task run_phase(uvm_phase phase);
        my_custom_sequence seq;
        phase.raise_objection(this);
        seq = my_custom_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
```

### 3. **Run New Test:**
```bash
./run_uvm_sim.sh -test my_custom_test
```

## Troubleshooting

### Common Issues:

1. **"Failed to get virtual interface"**
   - Check that `tb_top.sv` sets interface in config DB correctly

2. **"Cannot open ls.hex"**
   - Copy test programs from `../../FPGA/sim/` directory

3. **Compilation errors**
   - Ensure UVM library is available in simulator
   - Check file paths in `file_list_uvm.txt`

4. **Simulation hangs**
   - Increase verbosity: `-verbosity UVM_HIGH`
   - Check timeout settings in `tb_top.sv`

### Debug Tips:

1. **Enable VCD dump:** `-dump`
2. **Increase verbosity:** `-verbosity UVM_FULL`
3. **Add debug prints in sequences/driver**
4. **Check scoreboard analysis messages**

## Simulator Requirements

- **Altair DSim** 2020.1+ (recommended)
- **ModelSim/Questa** 2020.1+ with UVM
- **Vivado Simulator** 2020.1+ with UVM library
- **UVM Library** 1.2+

## Performance Notes

- **Compilation:** ~2-5 minutes (vs ~30 seconds for SystemVerilog)
- **Execution:** ~10-30 seconds per test (similar to original)
- **Memory Usage:** Higher due to UVM infrastructure
- **Coverage Collection:** Additional overhead but valuable insights

This UVM testbench provides a professional, scalable verification environment while maintaining the same core functionality as the original SystemVerilog testbench.