// Code your design here
// 1-bit Full Adder Module
module full_adder (
    input  logic a, b, cin,
    output logic sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule

// 4-bit Ripple Carry Adder
module rca_4bit (
    input  logic [3:0] a, b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
    logic [2:0] c;

    full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin),  .sum(sum[0]), .cout(c[0]));
    full_adder fa1 (.a(a[1]), .b(b[1]), .cin(c[0]), .sum(sum[1]), .cout(c[1]));
    full_adder fa2 (.a(a[2]), .b(b[2]), .cin(c[1]), .sum(sum[2]), .cout(c[2]));
    full_adder fa3 (.a(a[3]), .b(b[3]), .cin(c[2]), .sum(sum[3]), .cout(cout));
endmodule

// 4-bit Carry Select Block (calculates both paths,then chooses via MUX)
module csa_block_4bit (
    input  logic [3:0] a, b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
    logic [3:0] sum0, sum1;
    logic       cout0, cout1;

    // Speculative path assuming Carry-in = 0
    rca_4bit rca_0 (.a(a), .b(b), .cin(1'b0), .sum(sum0), .cout(cout0));

    // Speculative path assuming Carry-in = 1
    rca_4bit rca_1 (.a(a), .b(b), .cin(1'b1), .sum(sum1), .cout(cout1));

    // SystemVerilog multiplexer logic
    always_comb begin
        sum  = cin ? sum1  : sum0;
        cout = cin ? cout1 : cout0;
    end
endmodule

// Top-level 16-bit Carry Select Adder
module csa_16bit (
    input  logic [15:0] a, b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
    logic [2:0] c; // Internal carry links

    // Block 0: Directly takes the external cin
    csa_block_4bit b0 (.a(a[3:0]),   .b(b[3:0]),   .cin(cin),  .sum(sum[3:0]),   .cout(c[0]));
    
    // Blocks 1-3: Choose path dynamically based on previous carry output
    csa_block_4bit b1 (.a(a[7:4]),   .b(b[7:4]),   .cin(c[0]), .sum(sum[7:4]),   .cout(c[1]));
    csa_block_4bit b2 (.a(a[11:8]),  .b(b[11:8]),  .cin(c[1]), .sum(sum[11:8]),  .cout(c[2]));
    csa_block_4bit b3 (.a(a[15:12]), .b(b[15:12]), .cin(c[2]), .sum(sum[15:12]), .cout(cout));
endmodule
