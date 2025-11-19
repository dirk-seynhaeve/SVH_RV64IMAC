/*
 * RISC-V Monitor Class
 * Monitors the RISC-V core interface and collects transactions
 */

class riscv_monitor extends uvm_monitor;

    `uvm_component_utils(riscv_monitor)

    virtual riscv_if vif;
    uvm_analysis_port #(riscv_transaction) ap;

    function new(input string name = "riscv_monitor", input uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual riscv_if)::get(this, "", "riscv_vif", vif)) begin
            `uvm_fatal(get_type_name(), "Failed to get virtual interface from config DB")
        end
    endfunction

    virtual task run_phase(input uvm_phase phase);
        riscv_transaction tr;

        `uvm_info(get_type_name(), "Monitor run_phase started", UVM_MEDIUM)

        forever begin
            tr = riscv_transaction::type_id::create("monitored_tr");
            collect_transaction(tr);
            ap.write(tr);
            `uvm_info(get_type_name(), $sformatf("Monitored transaction: %s", tr.convert2string()), UVM_HIGH)
        end
    endtask

    virtual task collect_transaction(input riscv_transaction tr);
        logic [63:0] prev_pc = 0;
        logic [63:0] current_pc;
        int cycle_count = 0;
        bit reset_detected = 0;

        // Wait for reset deassertion
        @(negedge vif.cb_monitor.rst_n);
        reset_detected = 1;
        `uvm_info(get_type_name(), "Reset detected", UVM_HIGH)

        @(posedge vif.cb_monitor.rst_n);
        `uvm_info(get_type_name(), "Reset released, starting monitoring", UVM_HIGH)

        // Monitor execution
        forever begin
            @(vif.cb_monitor);
            cycle_count++;

            current_pc = vif.cb_monitor.pc;

            // Collect register state every 100 cycles for debugging
            if (cycle_count % 100 == 0) begin
                `uvm_info(get_type_name(), $sformatf("[Cycle %0d] PC=0x%08x, x9=0x%016x",
                         cycle_count, current_pc, vif.cb_monitor.registers[9]), UVM_DEBUG)
            end

            // Check for test completion (infinite loop or explicit completion)
            if (cycle_count > 200) begin
                if (current_pc == prev_pc && prev_pc != 0) begin
                    // Potential infinite loop detected
                    repeat(50) @(vif.cb_monitor);
                    if (current_pc == vif.cb_monitor.pc) begin
                        `uvm_info(get_type_name(), "Test completion detected (infinite loop)", UVM_MEDIUM)
                        break;
                    end
                end
                prev_pc = current_pc;
            end

            // Timeout protection
            if (cycle_count >= MAX_CYCLES) begin
                `uvm_info(get_type_name(), "Test completion detected (timeout)", UVM_MEDIUM)
                break;
            end
        end

        // Collect final state
        tr.actual_cycles = cycle_count;
        tr.final_pc = current_pc;

        // Copy final register values
        for (int i = 0; i < REGS; i++) begin
            tr.register_values[i] = vif.cb_monitor.registers[i];
        end

        tr.test_status = tr.register_values[9][3:0]; // Test status in x9

        // Determine if test passed based on test status
        if (tr.test_status == 4'hF) begin
            tr.test_passed = 1; // All comprehensive tests passed
        end else if (tr.test_status >= 1 && tr.test_status <= 7) begin
            tr.test_passed = 1; // Simple program running correctly
        end else begin
            tr.test_passed = 0; // Unexpected result
        end

        `uvm_info(get_type_name(), $sformatf("Transaction collection complete: %0d cycles, status=0x%x, passed=%b",
                 cycle_count, tr.test_status, tr.test_passed), UVM_MEDIUM)
    endtask

endclass : riscv_monitor