/*
 * RISC-V Scoreboard Class
 * Checks test results and provides coverage analysis
 */

class riscv_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(riscv_scoreboard)

    uvm_analysis_imp #(riscv_transaction, riscv_scoreboard) ap;

    // Statistics
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    riscv_transaction current_tr;

    // Program encoding for coverage (avoids function calls in coverage groups)
    int program_id;

    // Helper function for coverage - convert program string to integer ID
    function int get_program_id(input string program);
        case (program)
            "ls.hex": return 0;
            "prog_1.hex": return 1;
            "prog_2.hex": return 2;
            default: return 3;
        endcase
    endfunction

    // Simplified coverage group (remove complex expressions)
    covergroup test_coverage;
        cycles_cp: coverpoint current_tr.actual_cycles {
            bins low = {[1:500]};
            bins med = {[501:1500]};
            bins high = {[1501:4000]};
        }

        test_status_cp: coverpoint current_tr.test_status {
            bins basic_only = {4'h1};
            bins basic_mult = {4'h3};
            bins basic_mult_comp = {4'h7};
            bins all_tests = {4'hF};
        }

        result_cp: coverpoint current_tr.test_passed {
            bins pass = {1};
            bins fail = {0};
        }
    endgroup

    function new(input string name = "riscv_scoreboard", input uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
        test_coverage = new();
    endfunction

    virtual function void write(input riscv_transaction tr);
        current_tr = tr;
        test_count++;

        // Set program ID for coverage
        program_id = get_program_id(tr.program_file);

        `uvm_info(get_type_name(), $sformatf("Received transaction #%0d", test_count), UVM_MEDIUM)

        // Check test results
        check_test_results(tr);

        // Sample coverage
        test_coverage.sample();

        // Update statistics
        if (tr.test_passed) begin
            pass_count++;
            `uvm_info(get_type_name(), $sformatf("TEST #%0d PASSED", test_count), UVM_LOW)
        end else begin
            fail_count++;
            `uvm_error(get_type_name(), $sformatf("TEST #%0d FAILED", test_count))
        end

        // Print detailed results
        print_test_details(tr);
    endfunction

    virtual function void check_test_results(input riscv_transaction tr);
        `uvm_info(get_type_name(), "Analyzing test results...", UVM_HIGH);

        // Analyze based on program type
        if (tr.program_file == "ls.hex") begin
            check_simple_program_results(tr);
        end else if (tr.program_file == "prog_2.hex" || tr.program_file == "prog_1.hex") begin
            check_comprehensive_test_results(tr);
        end else begin
            `uvm_warning(get_type_name(), $sformatf("Unknown program file: %s", tr.program_file))
        end

        // Additional checks
        check_execution_sanity(tr);
    endfunction

    virtual function void check_simple_program_results(input riscv_transaction tr);
        `uvm_info(get_type_name(), "Checking simple program results (ls.hex)", UVM_HIGH);

        // For simple program, expect counter progression in x9
        if (tr.register_values[9] >= 1 && tr.register_values[9] <= 7) begin
            tr.test_passed = 1;
            `uvm_info(get_type_name(), $sformatf("Simple program counter correct: x9=%0d", tr.register_values[9]), UVM_MEDIUM)
        end else begin
            tr.test_passed = 0;
            `uvm_error(get_type_name(), $sformatf("Simple program counter unexpected: x9=%0d", tr.register_values[9]))
        end

        // Check if x10 contains ASCII values
        if (tr.register_values[10] >= 32 && tr.register_values[10] <= 126) begin
            `uvm_info(get_type_name(), $sformatf("ASCII character in x10: 0x%02x ('%c')",
                     tr.register_values[10], tr.register_values[10][7:0]), UVM_MEDIUM)
        end

        // Check if x11 contains expected base address
        if (tr.register_values[11] == 64'h10000000) begin
            `uvm_info(get_type_name(), "Base address correct in x11", UVM_MEDIUM)
        end
    endfunction

    virtual function void check_comprehensive_test_results(input riscv_transaction tr);
        logic [3:0] test_flags;
        test_flags = tr.test_status;

        `uvm_info(get_type_name(), "Checking comprehensive test results", UVM_HIGH)

        // Check individual test components
        if (test_flags[0]) begin
            `uvm_info(get_type_name(), "✓ Basic Instructions PASSED", UVM_MEDIUM)
        end else begin
            `uvm_error(get_type_name(), "✗ Basic Instructions FAILED")
        end

        if (test_flags[1]) begin
            `uvm_info(get_type_name(), "✓ Multiplication Extension PASSED", UVM_MEDIUM)
        end else begin
            `uvm_error(get_type_name(), "✗ Multiplication Extension FAILED")
        end

        if (test_flags[2]) begin
            `uvm_info(get_type_name(), "✓ Compressed Instructions PASSED", UVM_MEDIUM)
        end else begin
            `uvm_error(get_type_name(), "✗ Compressed Instructions FAILED")
        end

        if (test_flags[3]) begin
            `uvm_info(get_type_name(), "✓ Atomic Instructions PASSED", UVM_MEDIUM)
        end else begin
            `uvm_error(get_type_name(), "✗ Atomic Instructions FAILED")
        end

        // Overall result
        if (test_flags == 4'hF) begin
            tr.test_passed = 1;
            `uvm_info(get_type_name(), "🎉 ALL COMPREHENSIVE TESTS PASSED! 🎉", UVM_LOW)
        end else begin
            tr.test_passed = 0;
            `uvm_error(get_type_name(), $sformatf("Comprehensive tests incomplete: status=0x%x", test_flags))
        end
    endfunction

    virtual function void check_execution_sanity(input riscv_transaction tr);
        // Check for reasonable execution time
        if (tr.actual_cycles < 10) begin
            `uvm_warning(get_type_name(), $sformatf("Very short execution: %0d cycles", tr.actual_cycles))
        end

        if (tr.actual_cycles >= MAX_CYCLES) begin
            `uvm_warning(get_type_name(), "Execution reached maximum cycle limit")
        end

        // Check PC progression
        if (tr.final_pc == 0) begin
            `uvm_warning(get_type_name(), "Program counter still at 0 - possible execution issue")
        end
    endfunction

    virtual function void print_test_details(input riscv_transaction tr);
        string details;

        details = "\n=== TEST DETAILS ===\n";
        details = {details, $sformatf("Program: %s\n", tr.program_file)};
        details = {details, $sformatf("Execution time: %0d cycles\n", tr.actual_cycles)};
        details = {details, $sformatf("Final PC: 0x%08x\n", tr.final_pc)};
        details = {details, $sformatf("Test status: 0x%x\n", tr.test_status)};
        details = {details, $sformatf("Result: %s\n", tr.test_passed ? "PASS" : "FAIL")};
        details = {details, "Key registers:\n"};
        for (int i = 0; i < 16; i++) begin
            if (tr.register_values[i] != 0 || i == 0) begin
                details = {details, $sformatf("  x%02d = 0x%016x\n", i, tr.register_values[i])};
            end
        end
        details = {details, "==================\n"};

        `uvm_info(get_type_name(), details, UVM_LOW)
    endfunction

    virtual function void report_phase(input uvm_phase phase);
        string report;

        report = "\n========== FINAL TEST REPORT ==========\n";
        report = {report, $sformatf("Total Tests: %0d\n", test_count)};
        report = {report, $sformatf("Passed: %0d\n", pass_count)};
        report = {report, $sformatf("Failed: %0d\n", fail_count)};
        report = {report, $sformatf("Pass Rate: %0.1f%%\n", (pass_count * 100.0) / test_count)};
        report = {report, $sformatf("Coverage: %0.1f%%\n", test_coverage.get_coverage())};
        report = {report, "========================================\n"};

        `uvm_info(get_type_name(), report, UVM_NONE)

        if (fail_count > 0) begin
            `uvm_error(get_type_name(), $sformatf("%0d test(s) failed!", fail_count))
        end
    endfunction

endclass : riscv_scoreboard