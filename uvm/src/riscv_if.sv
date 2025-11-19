/*
 * RISC-V Interface
 * UVM Interface for RISC-V Core Testing
 */

interface riscv_if(input logic clk);

    // Control signals
    logic rst_n;

    // Debug and monitoring signals
    logic [63:0] pc;
    logic [63:0] registers[32];
    logic [63:0] memory_addr;
    logic [63:0] memory_data;
    logic        memory_write;
    logic        memory_read;

    // Test control
    logic        test_complete;
    logic [3:0]  test_status;

    // Clocking blocks for different agents
    clocking cb_driver @(posedge clk);
        default input #1 output #1;
        output rst_n;
        input  pc;
        input  registers;
        input  test_complete;
        input  test_status;
    endclocking

    clocking cb_monitor @(posedge clk);
        default input #1;
        input rst_n;
        input pc;
        input registers;
        input memory_addr;
        input memory_data;
        input memory_write;
        input memory_read;
        input test_complete;
        input test_status;
    endclocking

    // Modports
    modport driver  (clocking cb_driver, input clk);
    modport monitor (clocking cb_monitor, input clk);

    // Tasks for common operations
    task automatic reset_assert();
        rst_n <= 1'b0;
    endtask

    task automatic reset_deassert();
        rst_n <= 1'b1;
    endtask

    // Function to check if test is complete
    function bit is_test_complete();
        return test_complete;
    endfunction

    // Function to get test status
    function logic [3:0] get_test_status();
        return test_status;
    endfunction

endinterface : riscv_if