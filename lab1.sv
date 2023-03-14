// TODO: Put your one 1-process FSMD here.
module asserted_bit_count_fsmd_1p
  #(parameter int WIDTH)
   (
    input logic 		       clk,
    input logic 		       rst,
    input logic 		       go,
    input logic [WIDTH-1:0] 	       in,
    output logic [$clog2(WIDTH+1)-1:0] out,
    output logic 		       done 
    );

  typedef enum logic[1:0] {START, COMPUTE, RESTART, XXX='x} state_t;
  state_t state_r;
  logic done_r;
  logic [$clog2(WIDTH+1)-1:0] count_r;
  logic [WIDTH-1:0] n_r;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      out <= '0;
      n_r <= '0;
      done_r <= 1'b0;
      count_r <= '0;
      state_r <= START;
    end else begin
      case (state_r)
        START : begin
          if (go) begin
            n_r <= in;
            count_r <= '0;
            done_r <= 1'b0;
            state_r <= COMPUTE;
          end
        end

        COMPUTE : begin
          if (n_r != '0) begin
            n_r = n_r & (n_r - 1'b1);
            count_r = count_r + 1'b1;
          end else begin
            state_r <= RESTART;
          end
        end

        RESTART : begin
          out <= count_r;
          done_r <= 1'b1;
          if (go) begin
            n_r <= in;
            count_r <= '0;
            done_r <= 1'b0;
            state_r <= COMPUTE;
            end
        end

        default : state_r <= XXX;
      endcase
    end
  end

  //assign out = count_r;
  assign done = done_r;
endmodule

// TODO: Put your one 2-process FSMD here.
module asserted_bit_count_fsmd_2p
  #(parameter int WIDTH)
   (
    input logic 		       clk,
    input logic 		       rst,
    input logic 		       go,
    input logic [WIDTH-1:0] 	       in,
    output logic [$clog2(WIDTH+1)-1:0] out,
    output logic 		       done 
    );

  typedef enum logic[1:0] {START, COMPUTE, RESTART, XXX='x} state_t;
  state_t state_r, next_state;
  logic done_r, next_done_r;
  logic [$clog2(WIDTH+1)-1:0] count_r, next_count_r;
  logic [WIDTH-1:0] n_r, next_n_r;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      n_r <= '0;
      done_r <= 1'b0;
      count_r <= '0;
      state_r <= START;
    end else begin
      n_r <= next_n_r;
      done_r <= next_done_r;
      count_r <= next_count_r;
      state_r <= next_state;    
    end
  end

  always_comb begin

      next_n_r = n_r;
      next_done_r = done_r;
      next_count_r = count_r;
      next_state = state_r;
      out = '0;
    case (state_r)
      START : begin
          if (go) begin
            next_n_r = in;
            next_count_r = '0;
            next_done_r = 1'b0;
            next_state = COMPUTE;
          end        
      end

      COMPUTE : begin
          if (n_r != '0) begin
            next_n_r = n_r & (n_r - 1'b1);
            next_count_r = count_r + 1'b1;
          end else begin
            next_state = RESTART;
          end
      end

      RESTART : begin
          next_done_r = 1'b1;
          out = next_count_r;
          if (go) begin
            next_n_r = in;
            next_count_r = '0;
            next_done_r = 1'b0;
            next_state = COMPUTE;
          end        
      end

      default : next_state = XXX;
    endcase
  end
  assign done = done_r;
endmodule


// TODO: Put your FSM+D here. Add your datapath and FSM modules in other files.

module asserted_bit_count_fsm_plus_d
  #(parameter int WIDTH)
   (
    input logic 		       clk,
    input logic 		       rst,
    input logic 		       go,
    input logic [WIDTH-1:0] 	       in,
    output logic [$clog2(WIDTH+1)-1:0] out,
    output logic 		       done 
    );

  logic n_en;
  logic count_en;
  logic count_sel;
  logic n_sel;
  logic out_en;
  logic n_eq_0;
  
  fsm #(.WIDTH(WIDTH)) CONTROLLER (.*);
  datapath #(.WIDTH(WIDTH)) DATAPATH (.*);
endmodule


// Top-level for synthesis. Change the comments to synthesize each module.

module asserted_bit_count
  #(parameter int WIDTH=32)
   (
    input logic 		       clk,
    input logic 		       rst,
    input logic 		       go,
    input logic [WIDTH-1:0] 	       in,
    output logic [$clog2(WIDTH+1)-1:0] out,
    output logic 		       done 
    );


   //asserted_bit_count_fsmd_1p #(.WIDTH(WIDTH)) top (.*);
   //asserted_bit_count_fsmd_2p #(.WIDTH(WIDTH)) top (.*);
   asserted_bit_count_fsm_plus_d #(.WIDTH(WIDTH)) top (.*);   
   
endmodule