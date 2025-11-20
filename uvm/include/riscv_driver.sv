/*
 * RISC-V Driver Class
 * Drives the RISC-V core interface based on transactions
 */

class riscv_driver extends uvm_driver #(riscv_transaction);

    // `uvm_component_utils(riscv_driver)

    virtual riscv_if vif;

    function new(input string name = "riscv_driver", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual riscv_if)::get(this, "", "riscv_vif", vif)) begin
            `uvm_fatal(get_type_name(), "Failed to get virtual interface from config DB")
        end
    endfunction

    virtual task run_phase(input uvm_phase phase);
        riscv_transaction tr;

        `uvm_info(get_type_name(), "Driver run_phase started", UVM_MEDIUM)

        forever begin
            seq_item_port.get_next_item(tr);
            `uvm_info(get_type_name(), $sformatf("Driving transaction: %s", tr.convert2string()), UVM_HIGH)

            drive_transaction(tr);

            seq_item_port.item_done();
        end
    endtask

    virtual task drive_transaction(input riscv_transaction tr);
        `uvm_info(get_type_name(), "Starting to drive transaction", UVM_HIGH);

        // Reset sequence
        reset_dut();

        // Load program file
        load_program(tr.program_file);

        // Initialize registers
        initialize_registers();

        // Start execution and wait for completion
        run_test(tr);

        `uvm_info(get_type_name(), "Transaction driving complete", UVM_HIGH)
    endtask

    virtual task reset_dut();
        `uvm_info(get_type_name(), "Asserting reset", UVM_HIGH)

        vif.reset_assert();
        repeat(10) @(vif.cb_driver);
        vif.reset_deassert();
        repeat(5) @(vif.cb_driver);

        `uvm_info(get_type_name(), "Reset deasserted", UVM_HIGH)
    endtask

    virtual task load_program(input string filename);
        `uvm_info(get_type_name(), $sformatf("Loading program: %s", filename), UVM_MEDIUM)

        // For simplicity, skip actual file loading in UVM version
        // This would normally use proper memory interface or BFM
        `uvm_info(get_type_name(), "Program loading skipped - using pre-loaded memory", UVM_MEDIUM)

        // In a real UVM environment, you would:
        // 1. Use proper memory interface/BFM
        // 2. Load through virtual interface
        // 3. Use memory model instead of forcing signals

    endtask

    virtual task initialize_registers();
        `uvm_info(get_type_name(), "Initializing registers", UVM_MEDIUM)

        // Use direct force assignments instead of loops to avoid compile errors
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[0] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[1] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[2] = 64'h000000007ffffff0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[3] = 64'h0000000010000000;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[4] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[5] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[6] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[7] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[8] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[9] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[10] = 64'h0;
        force tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[11] = 64'h0;

        @(vif.cb_driver);

        // Release forces with direct assignments
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[0];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[1];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[2];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[3];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[4];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[5];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[6];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[7];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[8];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[9];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[10];
        release tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[11];
        // release tb_top.dut.u_main_mem_data.u_main_mem.MEM;  // Skip array release

        `uvm_info(get_type_name(), "Register initialization complete", UVM_MEDIUM)
    endtask

    virtual task run_test(input riscv_transaction tr);
        int cycle_count = 0;
        logic [63:0] prev_pc = 0;
        logic [63:0] current_pc;
        int loop_counter = 0;

        `uvm_info(get_type_name(), "Starting test execution", UVM_MEDIUM)

        while (cycle_count < tr.max_cycles) begin
            @(vif.cb_driver);
            cycle_count++;

            // Get current PC
            current_pc = tb_top.dut.u_riscv_core_top_2.pcf;

            // Check for infinite loop (early termination)
            if (cycle_count > 200) begin
                if (current_pc == prev_pc && prev_pc != 0) begin
                    loop_counter++;
                    if (loop_counter > 100) begin
                        `uvm_info(get_type_name(), $sformatf("Infinite loop detected at PC=0x%08x, stopping early", current_pc), UVM_MEDIUM)
                        break;
                    end
                end else begin
                    loop_counter = 0;
                    prev_pc = current_pc;
                end
            end

            // Progress reporting
            if (cycle_count % 500 == 0) begin
                `uvm_info(get_type_name(), $sformatf("Execution progress: %0d/%0d cycles", cycle_count, tr.max_cycles), UVM_LOW)
            end
        end

        // Update transaction with results
        tr.actual_cycles = cycle_count;
        tr.final_pc = current_pc;

        // Copy final register state
        for (int i = 0; i < REGS; i++) begin
            tr.register_values[i] = tb_top.dut.u_riscv_core_top_2.u_riscv_core_rf.rf[i];
        end

        // Determine test status
        tr.test_status = tr.register_values[9][3:0]; // x9 contains test flags

        `uvm_info(get_type_name(), $sformatf("Test execution complete: %0d cycles, PC=0x%08x", cycle_count, current_pc), UVM_MEDIUM)
    endtask

endclass : riscv_driver