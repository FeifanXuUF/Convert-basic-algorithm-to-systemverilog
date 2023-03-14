module datapath
    #(
        parameter int WIDTH
    )
    (
        input logic clk,
        input logic rst,
        input logic [WIDTH-1:0] in,
        output logic [$clog2(WIDTH+1)-1:0] out,

        input logic n_en,
        input logic count_en,
        input logic count_sel,
        input logic n_sel,
        input logic out_en,
        output logic n_eq_0

    );

    logic [WIDTH-1:0] n_r;
    logic [WIDTH-1:0] n_mux_out;
    logic [WIDTH-1:0] n_add_out;
    logic [$clog2(WIDTH+1)-1:0] count_r;
    logic [$clog2(WIDTH+1)-1:0] count_mux_out;
    logic [$clog2(WIDTH+1)-1:0] count_add_out;
    logic [$clog2(WIDTH+1)-1:0] out_r;
    logic [WIDTH-1:0] and_out;

    always_ff @ (posedge clk or posedge rst)begin
        if (rst) begin
            count_r <= '0;
            n_r <= '0;
            out_r <= '0;
        end else begin
            if (n_en) n_r <= n_mux_out;
            if (count_en) count_r <= count_mux_out;
            if (out_en) out_r <= count_r;
        end
    end

    //always_comb begin
        assign count_mux_out = count_sel == 1'b0 ? count_add_out : '0;
        assign n_mux_out = n_sel == 1'b0 ? and_out : in;
        assign count_add_out = count_r + 1'b1;
        assign n_add_out = n_r + WIDTH'(-1);
        assign and_out = n_r & n_add_out;
        assign n_eq_0 = n_r == 1'b0 ? 1'b1 : 1'b0;
        assign out = out_r;
    //end
endmodule