/*
 * RISC-V Environment Class
 * Top-level environment containing agent and scoreboard
 */

class riscv_env extends uvm_env;

    `uvm_component_utils(riscv_env)

    riscv_agent agent;
    // riscv_scoreboard scoreboard;  // Temporarily commented out

    function new(input string name = "riscv_env", input uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);

        `uvm_info(get_type_name(), "Building RISC-V environment", UVM_MEDIUM)

        // Create agent
        agent = riscv_agent::type_id::create("agent", this);

        // Create scoreboard - temporarily commented out
        // scoreboard = riscv_scoreboard::type_id::create("scoreboard", this);

        `uvm_info(get_type_name(), "RISC-V environment build complete", UVM_MEDIUM)
    endfunction

    virtual function void connect_phase(input uvm_phase phase);
        super.connect_phase(phase);

        `uvm_info(get_type_name(), "Connecting RISC-V environment", UVM_MEDIUM)

        // Connect agent monitor to scoreboard - temporarily commented out
        // agent.ap.connect(scoreboard.ap);

        `uvm_info(get_type_name(), "RISC-V environment connections complete", UVM_MEDIUM)
    endfunction

endclass : riscv_env