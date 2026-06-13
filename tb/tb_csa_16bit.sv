// Code your testbench here
// or browse Examples
module tb_csa_16bit_manual;

    logic [15:0] a, b, sum;
    logic        cin, cout;
    logic [16:0] expected;
    int          error_count = 0;
    int          tc_num      = 0;

    // DUT instantiation
    csa_16bit dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    // ─── Task: Apply inputs ───────────────────────
    task apply_and_check(
        input logic [15:0] in_a,
        input logic [15:0] in_b,
        input logic        in_cin
    );
        a   = in_a;
        b   = in_b;
        cin = in_cin;
        #10;

        tc_num++;
        expected = a + b + cin;

        if ((sum !== expected[15:0]) || (cout !== expected[16])) begin
            $display("TC%-3d | A=%h  B=%h  Cin=%b | Expected: Sum=%h Cout=%b | Got: Sum=%h Cout=%b | FAIL ",
                     tc_num, a, b, cin,
                     expected[15:0], expected[16],
                     sum, cout);
            error_count++;
        end else begin
            $display("TC%-3d | A=%h  B=%h  Cin=%b | Sum=%h  Cout=%b | PASS ",
                     tc_num, a, b, cin, sum, cout);
        end
    endtask
  initial begin
    
    $dumpfile("dump.vcd");      // creates the waveform file
    $dumpvars(0, tb_csa_16bit_manual);  // dumps ALL signals in testbench
  end

    // ─── All Test Cases ─────────────────────────────────────────────
    initial begin
        $display("===========================================================");
        $display("      16-bit Carry Select Adder — Manual Testbench         ");
        $display("===========================================================");

        // ── Group 1: Basic / Corner Cases ──────────────────────────
        $display("\n--- Group 1: Corner Cases ---");
        apply_and_check(16'h0000, 16'h0000, 1'b0);  // TC1:  All zeros
        apply_and_check(16'hFFFF, 16'hFFFF, 1'b1);  // TC2:  All ones + carry
        apply_and_check(16'hFFFF, 16'h0001, 1'b0);  // TC3:  Overflow boundary
        apply_and_check(16'h0000, 16'hFFFF, 1'b0);  // TC4:  Zero + max
        apply_and_check(16'h0000, 16'h0000, 1'b1);  // TC5:  Zero + carry only
        apply_and_check(16'hFFFF, 16'h0000, 1'b0);  // TC6:  Max + zero
        apply_and_check(16'h8000, 16'h8000, 1'b0);  // TC7:  MSB overflow
        apply_and_check(16'h7FFF, 16'h0001, 1'b0);  // TC8:  Just below overflow

        // ── Group 2: Carry Propagation ──────────────────────────────
        $display("\n--- Group 2: Carry Propagation ---");
        apply_and_check(16'h0001, 16'h0001, 1'b0);  // TC9:  Small values
        apply_and_check(16'h000F, 16'h0001, 1'b0);  // TC10: 4-bit carry out
        apply_and_check(16'h00FF, 16'h0001, 1'b0);  // TC11: 8-bit carry out
        apply_and_check(16'h0FFF, 16'h0001, 1'b0);  // TC12: 12-bit carry out
        apply_and_check(16'h0001, 16'h0001, 1'b1);  // TC13: Small + carry
        apply_and_check(16'hFFFE, 16'h0001, 1'b1);  // TC14: Near max + carry

        // ── Group 3: Alternating Bit Patterns ───────────────────────
        $display("\n--- Group 3: Alternating Patterns ---");
        apply_and_check(16'hAAAA, 16'h5555, 1'b0);  // TC15: 1010 + 0101 = FFFF
        apply_and_check(16'hAAAA, 16'h5555, 1'b1);  // TC16: 1010 + 0101 + 1
        apply_and_check(16'h5555, 16'hAAAA, 1'b0);  // TC17: 0101 + 1010
        apply_and_check(16'hF0F0, 16'h0F0F, 1'b0);  // TC18: Nibble alternating
        apply_and_check(16'hF0F0, 16'h0F0F, 1'b1);  // TC19: Nibble alt + carry
        apply_and_check(16'hFF00, 16'h00FF, 1'b0);  // TC20: Byte alternating

        // ── Group 4: Same Value Additions ───────────────────────────
        $display("\n--- Group 4: Same Value (Doubling) ---");
        apply_and_check(16'h0001, 16'h0001, 1'b0);  // TC21: 1+1
        apply_and_check(16'h0010, 16'h0010, 1'b0);  // TC22: 16+16
        apply_and_check(16'h0100, 16'h0100, 1'b0);  // TC23: 256+256
        apply_and_check(16'h1000, 16'h1000, 1'b0);  // TC24: 4096+4096
        apply_and_check(16'h1234, 16'h1234, 1'b0);  // TC25: same random
        apply_and_check(16'hABCD, 16'hABCD, 1'b1);  // TC26: same + carry

        // ── Group 5: Typical Real-World Values ──────────────────────
        $display("\n--- Group 5: Typical Values ---");
        apply_and_check(16'h1234, 16'h5678, 1'b0);  // TC27
        apply_and_check(16'hABCD, 16'h1234, 1'b1);  // TC28
        apply_and_check(16'hBEEF, 16'hDEAD, 1'b0);  // TC29
        apply_and_check(16'hCAFE, 16'hBABE, 1'b1);  // TC30
        apply_and_check(16'h1111, 16'h2222, 1'b0);  // TC31
        apply_and_check(16'h3333, 16'h4444, 1'b1);  // TC32
        apply_and_check(16'h6789, 16'h9876, 1'b0);  // TC33
        apply_and_check(16'hFACE, 16'h1ACE, 1'b1);  // TC34

        // ── Group 6: Power of 2 Boundaries ──────────────────────────
        $display("\n--- Group 6: Power of 2 Boundaries ---");
        apply_and_check(16'h0001, 16'h0000, 1'b0);  // TC35: 2^0
        apply_and_check(16'h0002, 16'h0000, 1'b0);  // TC36: 2^1
        apply_and_check(16'h0004, 16'h0000, 1'b0);  // TC37: 2^2
        apply_and_check(16'h0080, 16'h0080, 1'b0);  // TC38: 2^7 + 2^7
        apply_and_check(16'h4000, 16'h4000, 1'b0);  // TC39: 2^14 + 2^14
        apply_and_check(16'h8000, 16'h7FFF, 1'b1);  // TC40: full wrap

        // ── Summary ──────────────────────────────────────────────────
        $display("\n===========================================================");
        $display("  Total: %0d | Passed: %0d | Failed: %0d",
                  tc_num, tc_num - error_count, error_count);

        if (error_count == 0)
            $display("  [RESULT] ALL TEST CASES PASSED ");
        else
            $display("  [RESULT] %0d FAILURE(S) FOUND ", error_count);        $display("===========================================================");
        $finish;
    end
endmodule
