/*
 * RISC-V Agent Class
 * Contains driver, monitor, and sequencer for RISC-V testing
 */

typedef uvm_sequencer #(riscv_transaction) riscv_sequencer;

class riscv_agent extends uvm_agent;

    `uvm_component_utils(riscv_agent)

    riscv_driver driver;
    riscv_monitor monitor;
    riscv_sequencer sequencer;

    uvm_analysis_port #(riscv_transaction) ap;

    function new(input string name = "riscv_agent", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        `uvm_info(get_type_name(), "Building RISC-V agent components", UVM_MEDIUM)

        // Create monitor (always needed)
        monitor = riscv_monitor::type_id::create("monitor", this);

        // Create driver and sequencer only for ACTIVE agents
        if (get_is_active() == UVM_ACTIVE) begin
            `uvm_info(get_type_name(), "Creating active agent components", UVM_MEDIUM)
            driver = riscv_driver::type_id::create("driver", this);
            sequencer = riscv_sequencer::type_id::create("sequencer", this);
        end else begin
            `uvm_info(get_type_name(), "Creating passive agent (monitor only)", UVM_MEDIUM)
        end
    endfunction

    virtual function void connect_phase(input uvm_phase phase);
        super.connect_phase(phase);

        `uvm_info(get_type_name(), "Connecting RISC-V agent components", UVM_MEDIUM)

        // Connect analysis port
        ap = monitor.ap;

        // Connect driver to sequencer for active agents
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass : riscv_agent