module full_adder (
    input logic     in_1,
    input logic     in_2,
    input logic     carry_in,
    output logic    sum,
    output logic    carry_out
);
    assign sum = in_1 ^ in_2 ^ carry_in;
    assign carry_out = in_1 & in_2 | in_1 & carry_in | in_2 & carry_in;

endmodule

module ripple_carry_adder #(
    parameter int WIDTH = 16
) (
    input logic  [WIDTH - 1: 0] signal_1,
    input logic  [WIDTH - 1: 0] signal_2,
    input logic                 carry_in,
    output logic [WIDTH - 1: 0] sum,
    output logic                carry_out
);

    genvar i;

    logic [WIDTH: 0] carry;
   
    assign carry[0] = carry_in;

    generate
        for (i = 0; i < WIDTH; i++) begin: gen_full_adders
            full_adder fa (
                .in_1     (signal_1[i]),
                .in_2     (signal_2[i]),
                .carry_in (carry[i]),
                .sum      (sum[i]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate

    assign carry_out = carry[WIDTH];

endmodule

module CLA_4_bit (
    input logic  [3:0] signal_1,
    input logic  [3:0] signal_2,
    input logic        carry_in,
    output logic [3:0] sum,
    output logic       carry_out
);
    ripple_carry_adder #(
        .WIDTH(4)
    ) rca (
        .signal_1 (signal_1),
        .signal_2 (signal_2),
        .carry_in (carry_in),
        .sum      (sum),
        .carry_out() // not used
    );

    logic [3:0] G;
    logic [3:0] P;

    assign G = signal_1 & signal_2;
    assign P = signal_1 | signal_2;

    assign carry_out = G[3] | P[3] & G[2] | P[3] & P[2] & G[1] |
                       P[3] & P[2] & P[1] & G[0] |
                       P[3] & P[2] & P[1] & P[0] & carry_in;

endmodule

module carry_lookahead_adder #(
    parameter int WIDTH = 16 // 4 must divide WIDTH
) (
    input logic  [WIDTH - 1: 0] signal_1,
    input logic  [WIDTH - 1: 0] signal_2,
    input logic                 carry_in,
    output logic [WIDTH - 1: 0] sum,
    output logic                carry_out
);
    localparam int C_WIDTH = WIDTH / 4;

    genvar i;

    logic [C_WIDTH: 0] carry;

    assign carry[0] = carry_in;

    generate
        for (i = 0; i < C_WIDTH; i++) begin: gen_CLAs
            CLA_4_bit cla (
                .signal_1 (signal_1[4*i +: 4]),
                .signal_2 (signal_2[4*i +: 4]),
                .carry_in (carry[i]),
                .sum      (sum[4*i+: 4]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate

    assign carry_out = carry[C_WIDTH];

endmodule

module black_cell (
    input  logic [1:0] P_in,
    input  logic [1:0] G_in,
    output logic       P_out,
    output logic       G_out
);

    assign P_out = P_in[1] & P_in[0];
    assign G_out = G_in[1] | (P_in[1] & G_in[0]);

endmodule


module prefix_adder #(
    parameter int WIDTH = 16   // WIDTH must be a power of 2
) (
    input  logic [WIDTH-1:0] signal_1,
    input  logic [WIDTH-1:0] signal_2,
    input  logic             carry_in,
    output logic [WIDTH-1:0] sum
);

    localparam int LEVELS = $clog2(WIDTH);

    logic [WIDTH-1:-1] G_level [0:LEVELS];
    logic [WIDTH-1:-1] P_level [0:LEVELS];

    // Normal bit generate/propagate values
  assign G_level[0] = {signal_1[WIDTH-1:0] & signal_2[WIDTH-1:0], carry_in};

    assign P_level[0] = {signal_1[WIDTH-1:0] | signal_2[WIDTH-1:0], 1'b0};

    genvar i, j;

    generate
        for (j = 0; j < LEVELS; j++) begin : gen_levels

            for (i = 0; i < WIDTH/2; i++) begin : gen_black_cells

                localparam int s      = 1 << j;
                localparam int offset = i % s;
                localparam int group  = i / s;

                localparam int group_base = group * (2*s) - 1;

                localparam int upper_idx = group_base + s + offset;

                localparam int lower_idx = group_base + s - 1;

                localparam int pass_idx = group_base + offset;

                black_cell bc (
                    .P_in ({
                        P_level[j][upper_idx],
                        P_level[j][lower_idx]
                    }),
                    .G_in ({
                        G_level[j][upper_idx],
                        G_level[j][lower_idx]
                    }),
                    .P_out(P_level[j+1][upper_idx]),
                    .G_out(G_level[j+1][upper_idx])
                );

                assign P_level[j+1][pass_idx] = P_level[j][pass_idx];

                assign G_level[j+1][pass_idx] = G_level[j][pass_idx];

            end
        end
    endgenerate

    assign sum = signal_1 ^ signal_2 ^ G_level[LEVELS][WIDTH-2:-1];

endmodule