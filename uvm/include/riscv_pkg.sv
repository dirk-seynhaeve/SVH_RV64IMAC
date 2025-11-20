/*
 * RISC-V UVM Package
 * Contains all UVM components for RISC-V core testing
 */

package riscv_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Parameters
    parameter int XLEN = 64;
    parameter int REGS = 32;
    parameter int MAX_CYCLES = 4000;

    // Include all UVM components
    `include "riscv_transaction.sv"
    `include "riscv_sequence.sv"
    `include "riscv_driver.sv"
    `include "riscv_monitor.sv"
    // `include "riscv_scoreboard.sv"  // Temporarily commented out
    `include "riscv_agent.sv"
    `include "riscv_env.sv"
    `include "riscv_test.sv"
    `include "simple_uvm_test.sv"

endpackage : riscv_pkg