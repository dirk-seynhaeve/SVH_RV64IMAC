/*
 * RISC-V UVM Testbench Top Level
 * Top module that instantiates DUT and interface
 */

module tb_top;

    import uvm_pkg::*;
    import riscv_pkg::*;
    `include "uvm_macros.svh"

    // Clock and reset
    logic clk = 0;
    logic rst_n = 0;

    // Clock generation
    always #50 clk = ~clk; // 10MHz clock (100ns period)

    // Interface instantiation
    riscv_if riscv_vif(clk);

    // DUT instantiation
    riscv_core_top dut (
        .i_riscv_core_clk(clk),
        .i_riscv_core_rst_n(rst_n)
    );

    // Connect interface signals to DUT
    assign rst_n = riscv_vif.rst_n;

    // Connect interface monitoring signals
    assign riscv_vif.pc = dut.u_riscv_core_top_2.pcf;

    // Connect register file for monitoring
    genvar i;
    generate
        for (i = 0; i < riscv_pkg::REGS; i++) begin : gen_reg_connect
            assign riscv_vif.registers[i] = dut.u_riscv_core_top_2.u_riscv_core_rf.rf[i];
        end
    endgenerate

    // Memory monitoring (if needed)
    assign riscv_vif.memory_write = 1'b0; // Connect to actual memory write signal
    assign riscv_vif.memory_read = 1'b0;  // Connect to actual memory read signal
    assign riscv_vif.memory_addr = 64'h0; // Connect to actual memory address
    assign riscv_vif.memory_data = 64'h0; // Connect to actual memory data

    // Test completion detection
    assign riscv_vif.test_complete = 1'b0; // Can be enhanced with actual completion logic
    assign riscv_vif.test_status = dut.u_riscv_core_top_2.u_riscv_core_rf.rf[9][3:0];

    initial begin
        // Set interface in config DB
        uvm_config_db#(virtual riscv_if)::set(null, "*", "riscv_vif", riscv_vif);

        // Print banner
        $display("========================================");
        $display("    🚀 RISC-V UVM TESTBENCH ACTIVE 🚀");
        $display("========================================");

        // Set default test if none specified
        if (!$test$plusargs("UVM_TESTNAME")) begin
            $display("No test specified, running default: riscv_simple_test");
        end

        // Start UVM test
        run_test();
    end

    // Optional: VCD dump for debugging
    initial begin
        if ($test$plusargs("DUMP_VCD")) begin
            $dumpfile("riscv_uvm.vcd");
            $dumpvars(0, tb_top);
        end
    end

    // Optional: Timeout protection
    initial begin
        #50ms; // 50 millisecond timeout
        $display("========================================");
        $display("ERROR: SIMULATION TIMEOUT!");
        $display("========================================");
        $finish;
    end

endmodule : tb_top