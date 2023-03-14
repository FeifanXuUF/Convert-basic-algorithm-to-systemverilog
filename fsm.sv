module fsm
  #(parameter int WIDTH)
   (
    input logic 		       clk,
    input logic 		       rst,
    input logic 		       go,
    input logic            n_eq_0,
    output logic 		       done ,
    output logic           n_sel,
    output logic           count_sel,
    output logic           n_en,
    output logic           count_en,
    output logic           out_en
    );

  typedef enum logic [1:0] {START, COMPUTE, RESTART, XXX='x} state_t;
  state_t state_r, next_state;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state_r <= START;
    end else begin
      state_r <= next_state;    
    end
  end

  always_comb begin
    next_state = state_r;
    done = 1'b0;
    n_sel = 1'b0;
    count_sel = 1'b0;
    out_en = 1'b0;
    n_en = 1'b0;
    count_en = 1'b0;
    case (state_r)
        START : begin
            //n_r = in;
            n_sel = 1'b1;
            n_en = 1'b1;
            //count_r = '0;
            count_sel = 1'b1;
            count_en = 1'b1;
            if (go) next_state = COMPUTE;
        end

        COMPUTE : begin
            //n_r and count_r still works when computing, but n_sel and count_sel selects new values
            n_en = 1'b1;
            count_en = 1'b1;
            if (n_eq_0 == 1'b1) begin
              //n_r and count_r stops reading new values, at this time, n_sel and count_sel do not matter.
              n_en = 1'b0;
              count_en = 1'b0;
              //out_r read the lastest count_r value and transfer the lastest value to port out;
              out_en = 1'b1;
              next_state = RESTART;
            end
        end

        RESTART : begin
            //assign done and out_r stops reading count_r value, let port out keep the same vaule instead of changing in respective of count_r
            done = 1'b1;
            if (go) begin
              //when go asserted, reset n_r and count_r
              n_sel = 1'b1;
              n_en = 1'b1;
              count_sel = 1'b1;
              count_en = 1'b1;
              next_state = COMPUTE;
            end

        end

        default : next_state = XXX;
    endcase
  end



endmodule