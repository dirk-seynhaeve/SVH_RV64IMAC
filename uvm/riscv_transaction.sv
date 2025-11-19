/*
 * RISC-V Transaction Class
 * Defines the transaction item for RISC-V core testing
 */

class riscv_transaction extends uvm_sequence_item;

    // Transaction fields
    rand logic                reset_n;
    string                    program_file;  // Cannot be rand (string type)
    rand int                  max_cycles;
    rand logic [XLEN-1:0]    expected_result;

    // Observed fields (set by monitor)
    logic [XLEN-1:0]         final_pc;
    logic [XLEN-1:0]         register_values[REGS];
    int                      actual_cycles;
    logic [3:0]              test_status;
    bit                      test_passed;

    // Constraints
    constraint c_reset { reset_n == 1'b1; }
    constraint c_max_cycles { max_cycles inside {[100:4000]}; }
    constraint c_program_file { program_file inside {"ls.hex", "prog_1.hex", "prog_2.hex"}; }

    // UVM macros
    `uvm_object_utils_begin(riscv_transaction)
        `uvm_field_int(reset_n, UVM_DEFAULT)
        `uvm_field_string(program_file, UVM_DEFAULT)
        `uvm_field_int(max_cycles, UVM_DEFAULT)
        `uvm_field_int(expected_result, UVM_DEFAULT)
        `uvm_field_int(final_pc, UVM_DEFAULT)
        `uvm_field_sarray_int(register_values, UVM_DEFAULT)
        `uvm_field_int(actual_cycles, UVM_DEFAULT)
        `uvm_field_int(test_status, UVM_DEFAULT)
        `uvm_field_int(test_passed, UVM_DEFAULT)
    `uvm_object_utils_end

    // Constructor
    function new(input string name = "riscv_transaction");
        super.new(name);
        program_file = "ls.hex";
        max_cycles = 1000;
        expected_result = 0;
        test_passed = 0;
    endfunction

    // Convert to string for printing
    function string convert2string();
        string s;
        s = $sformatf("RISC-V Transaction:\n");
        s = {s, $sformatf("  Program: %s\n", program_file)};
        s = {s, $sformatf("  Max Cycles: %0d\n", max_cycles)};
        s = {s, $sformatf("  Expected Result: 0x%0h\n", expected_result)};
        s = {s, $sformatf("  Final PC: 0x%0h\n", final_pc)};
        s = {s, $sformatf("  Actual Cycles: %0d\n", actual_cycles)};
        s = {s, $sformatf("  Test Status: 0x%0h\n", test_status)};
        s = {s, $sformatf("  Test Passed: %0b\n", test_passed)};
        return s;
    endfunction

    // Clone function
    function uvm_object clone();
        riscv_transaction tr;
        tr = riscv_transaction::type_id::create("cloned_tr");
        tr.copy(this);
        return tr;
    endfunction

endclass : riscv_transaction