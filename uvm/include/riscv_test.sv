/*
 * RISC-V Test Classes
 * UVM test classes for different test scenarios
 */

// Base test class
class riscv_base_test extends uvm_test;

    `uvm_component_utils(riscv_base_test)

    riscv_env env;
    virtual riscv_if vif;

    function new(input string name = "riscv_base_test", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        // Multiple ways to show UVM is active
        $display("\n🚀🚀🚀 UVM VERIFICATION METHODOLOGY ACTIVE 🚀🚀🚀");
        `uvm_info(get_type_name(), "🚀 RISC-V UVM Verification Infrastructure Active 🚀", UVM_NONE)
        `uvm_info(get_type_name(), "Universal Verification Methodology (UVM) is running!", UVM_LOW)
        `uvm_info(get_type_name(), "Building base test", UVM_MEDIUM)

        // Get virtual interface
        if (!uvm_config_db#(virtual riscv_if)::get(this, "", "riscv_vif", vif)) begin
            `uvm_fatal(get_type_name(), "Failed to get virtual interface from config DB")
        end

        // Set virtual interface for all components
        uvm_config_db#(virtual riscv_if)::set(this, "*", "riscv_vif", vif);

        // Create environment
        env = riscv_env::type_id::create("env", this);

        `uvm_info(get_type_name(), "Base test build complete", UVM_MEDIUM)
    endfunction

    virtual function void end_of_elaboration_phase(input uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_type_name(), "Test topology:", UVM_NONE)
        print();
    endfunction

    virtual task run_phase(input uvm_phase phase);
        `uvm_fatal(get_type_name(), "Base test run_phase() not implemented - use derived test")
    endtask

endclass : riscv_base_test

// Simple test (equivalent to original testbench)
class riscv_simple_test extends riscv_base_test;

    `uvm_component_utils(riscv_simple_test)

    function new(input string name = "riscv_simple_test", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(input uvm_phase phase);
        riscv_simple_test_sequence seq;

        phase.raise_objection(this, "Starting simple test");
        `uvm_info(get_type_name(), "=== Starting RISC-V Simple Test ===", UVM_LOW)

        seq = riscv_simple_test_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        `uvm_info(get_type_name(), "=== Simple Test Complete ===", UVM_LOW)
        phase.drop_objection(this, "Simple test complete");
    endtask

endclass : riscv_simple_test

// Comprehensive test
class riscv_comprehensive_test extends riscv_base_test;

    `uvm_component_utils(riscv_comprehensive_test)

    function new(input string name = "riscv_comprehensive_test", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(input uvm_phase phase);
        riscv_comprehensive_test_sequence seq;

        phase.raise_objection(this, "Starting comprehensive test");
        `uvm_info(get_type_name(), "=== Starting RISC-V Comprehensive Test ===", UVM_LOW)

        seq = riscv_comprehensive_test_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        `uvm_info(get_type_name(), "=== Comprehensive Test Complete ===", UVM_LOW)
        phase.drop_objection(this, "Comprehensive test complete");
    endtask

endclass : riscv_comprehensive_test

// Random test
class riscv_random_test extends riscv_base_test;

    `uvm_component_utils(riscv_random_test)

    function new(input string name = "riscv_random_test", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(input uvm_phase phase);
        riscv_random_test_sequence seq;

        phase.raise_objection(this, "Starting random test");
        `uvm_info(get_type_name(), "=== Starting RISC-V Random Test ===", UVM_LOW)

        seq = riscv_random_test_sequence::type_id::create("seq");
        if (!seq.randomize()) begin
            `uvm_error(get_type_name(), "Failed to randomize test sequence")
        end
        seq.start(env.agent.sequencer);

        `uvm_info(get_type_name(), "=== Random Test Complete ===", UVM_LOW)
        phase.drop_objection(this, "Random test complete");
    endtask

endclass : riscv_random_test

// Regression test (runs multiple scenarios)
class riscv_regression_test extends riscv_base_test;

    `uvm_component_utils(riscv_regression_test)

    function new(input string name = "riscv_regression_test", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(input uvm_phase phase);
        riscv_simple_test_sequence simple_seq;
        riscv_comprehensive_test_sequence comp_seq;
        riscv_random_test_sequence rand_seq;

        phase.raise_objection(this, "Starting regression test");
        `uvm_info(get_type_name(), "=== Starting RISC-V Regression Test ===", UVM_LOW)

        // Run simple test
        `uvm_info(get_type_name(), "Running simple test...", UVM_MEDIUM)
        simple_seq = riscv_simple_test_sequence::type_id::create("simple_seq");
        simple_seq.start(env.agent.sequencer);

        // Run comprehensive test
        `uvm_info(get_type_name(), "Running comprehensive test...", UVM_MEDIUM)
        comp_seq = riscv_comprehensive_test_sequence::type_id::create("comp_seq");
        comp_seq.start(env.agent.sequencer);

        // Run random tests
        `uvm_info(get_type_name(), "Running random tests...", UVM_MEDIUM)
        for (int i = 0; i < 3; i++) begin
            rand_seq = riscv_random_test_sequence::type_id::create($sformatf("rand_seq_%0d", i));
            if (!rand_seq.randomize()) begin
                `uvm_error(get_type_name(), "Failed to randomize test sequence")
            end
            rand_seq.start(env.agent.sequencer);
        end

        `uvm_info(get_type_name(), "=== Regression Test Complete ===", UVM_LOW)
        phase.drop_objection(this, "Regression test complete");
    endtask

endclass : riscv_regression_test