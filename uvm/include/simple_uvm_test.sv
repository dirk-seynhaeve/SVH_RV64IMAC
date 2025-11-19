/*
 * Simple UVM Test - Just to verify UVM is working
 */

class simple_uvm_test extends uvm_test;

    `uvm_component_utils(simple_uvm_test)

    function new(string name = "simple_uvm_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        $display("\n" + "="*50);
        $display("    UVM IS DEFINITELY WORKING!");
        $display("="*50);

        `uvm_info("SIMPLE_TEST", "✅ UVM Message System is Active!", UVM_NONE)
        `uvm_info("SIMPLE_TEST", "✅ This confirms UVM infrastructure!", UVM_NONE)

        $display("="*50 + "\n");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);

        `uvm_info("SIMPLE_TEST", "🎯 Running simple UVM test...", UVM_NONE)

        #1000; // Wait 1000 time units

        `uvm_info("SIMPLE_TEST", "✅ Simple UVM test completed successfully!", UVM_NONE)

        phase.drop_objection(this);
    endtask

endclass : simple_uvm_test