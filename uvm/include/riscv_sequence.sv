/*
 * RISC-V Sequence Classes
 * Defines test sequences for RISC-V core testing
 */

// Base sequence class
class riscv_base_sequence extends uvm_sequence #(riscv_transaction);

    `uvm_object_utils(riscv_base_sequence)

    function new(input string name = "riscv_base_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_error(get_type_name(), "Base sequence body() not implemented")
    endtask

endclass : riscv_base_sequence

// Simple test sequence (equivalent to original testbench)
class riscv_simple_test_sequence extends riscv_base_sequence;

    `uvm_object_utils(riscv_simple_test_sequence)

    function new(input string name = "riscv_simple_test_sequence");
        super.new(name);
    endfunction

    virtual task body();
        riscv_transaction tr;

        `uvm_info(get_type_name(), "Starting RISC-V simple test sequence", UVM_MEDIUM)

        tr = riscv_transaction::type_id::create("simple_test_tr");

        start_item(tr);
        if (!tr.randomize() with {
            program_file == "ls.hex";
            max_cycles == 4000;
            expected_result inside {[1:7]}; // Expected counter values for simple program
        }) begin
            `uvm_error(get_type_name(), "Randomization failed for simple test")
        end
        finish_item(tr);

        `uvm_info(get_type_name(), $sformatf("Sent transaction: %s", tr.convert2string()), UVM_HIGH)

    endtask

endclass : riscv_simple_test_sequence

// Comprehensive test sequence
class riscv_comprehensive_test_sequence extends riscv_base_sequence;

    `uvm_object_utils(riscv_comprehensive_test_sequence)

    function new(input string name = "riscv_comprehensive_test_sequence");
        super.new(name);
    endfunction

    virtual task body();
        riscv_transaction tr;

        `uvm_info(get_type_name(), "Starting RISC-V comprehensive test sequence", UVM_MEDIUM)

        tr = riscv_transaction::type_id::create("comprehensive_test_tr");

        start_item(tr);
        if (!tr.randomize() with {
            program_file == "prog_2.hex";
            max_cycles == 4000;
            expected_result == 64'hF; // All tests should pass
        }) begin
            `uvm_error(get_type_name(), "Randomization failed for comprehensive test")
        end
        finish_item(tr);

        `uvm_info(get_type_name(), $sformatf("Sent transaction: %s", tr.convert2string()), UVM_HIGH)

    endtask

endclass : riscv_comprehensive_test_sequence

// Random test sequence
class riscv_random_test_sequence extends riscv_base_sequence;

    rand int num_tests;

    constraint c_num_tests { num_tests inside {[1:5]}; }

    `uvm_object_utils_begin(riscv_random_test_sequence)
        `uvm_field_int(num_tests, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(input string name = "riscv_random_test_sequence");
        super.new(name);
        num_tests = 3;
    endfunction

    virtual task body();
        riscv_transaction tr;

        `uvm_info(get_type_name(), $sformatf("Starting RISC-V random test sequence with %0d tests", num_tests), UVM_MEDIUM)

        for (int i = 0; i < num_tests; i++) begin
            tr = riscv_transaction::type_id::create($sformatf("random_test_tr_%0d", i));

            start_item(tr);
            if (!tr.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed for random test")
            end
            finish_item(tr);

            `uvm_info(get_type_name(), $sformatf("Sent transaction %0d: %s", i, tr.convert2string()), UVM_HIGH)
        end

    endtask

endclass : riscv_random_test_sequence