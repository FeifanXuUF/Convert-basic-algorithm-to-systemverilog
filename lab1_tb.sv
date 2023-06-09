// Greg Stitt
// University of Florida

`timescale 1 ns / 10 ps

module asserted_bit_count_tb;

   localparam int NUM_RAND_TESTS = 10000;
   localparam int WIDTH = 32;
   
   logic          clk, rst, go, done;
   logic [WIDTH-1:0] in;
   logic [$clog2(WIDTH+1)-1:0] out, correct_out;

   int                         passed, failed;

   //asserted_bit_count_fsmd_1p #(.WIDTH(WIDTH)) DUT (.*);
   //asserted_bit_count_fsmd_2p #(.WIDTH(WIDTH)) DUT (.*);
   asserted_bit_count_fsm_plus_d #(.WIDTH(WIDTH)) DUT (.*);

   // Reference model
   function int model(logic [WIDTH-1:0] n);
      
      automatic int count = 0;
      while (n != 0) begin
         n = n & (n-1);
         count ++;       
      end
      
      return count;      
   endfunction
   
   initial begin : generate_clock
      clk = 1'b0;
      while (1) #5 clk = ~clk;      
   end

   initial begin
      int delay;
      
      $timeformat(-9, 0, " ns");
      passed = 0;
      failed = 0;
            
      // Reset the circuit
      rst = 1'b1;
      go = 1'b0;
      in = '0;      
      for (int i=0; i < 5; i++)
        @(posedge clk);

      // Clear reset
      rst = 1'b0;
      @(posedge clk);

      // Run the tests
      for (int i=0; i < NUM_RAND_TESTS; i++) begin

         // Start the test with a random input
         in = $random;

         // Assert go for one cycle. NOTE: This is not an ideal test strategy
         // because it won't expose errors caused by leaving go asserted
         // indefinitely, or toggling go during the middle of the execution.
         go = 1'b1;
         @(posedge clk);
         go = 1'b0;

         // Wait until completion.
         @(posedge clk iff done == 1'b1);

         // Validate
         correct_out = model(in);        
         if (out != correct_out) begin
           $display("ERROR (time %0t): out = %0d instead of %0d for in = h%h.",$time, out, correct_out, in);
            failed ++;
         end
         else
           passed ++;

         // Wait between 1 and 100 cycles before starting the next test.
         delay=$urandom_range(1,100);
         for (int i=0; i < delay; i++) @(posedge clk);
      end
      
      // Test all 0s
      in = '0;
      go = 1'b1;
      @(posedge clk);
      go = 1'b0;
      
      // Wait until completion.
      @(posedge clk iff done == 1'b1);
      
      // Validate
      correct_out = model(in);   
      if (out != correct_out) begin
         $display("ERROR (time %0t): out = %0d instead of %0d for in = h%h.",$time, out, correct_out, in);
         failed ++;
      end
      else
        passed ++;

      // Test all 1s
      in = '1;
      go = 1'b1;
      @(posedge clk);
      go = 1'b0;
      
      // Wait until completion.
      @(posedge clk iff done == 1'b1);
      
      // Validate
      correct_out = model(in);   
      if (out != correct_out) begin
         $display("ERROR (time %0t): out = %0d instead of %0d for in = h%h.",$time, out, correct_out, in);
         failed ++;
      end
      else
        passed ++;          
      
      // Report stats.
      $display("Tests completed: %d passed, %d failed", passed, failed);      
      disable generate_clock;      
   end // initial begin

   // Check to make sure done cleared within a cycle. Go is anded with done
   // because go should have no effect when the circuit is already active.
   assert property (@(posedge clk) disable iff (rst) go && done |=> !done);
   
   // Check to make sure done is only cleared one cycle after go is asserted 
   // (i.e. done is left asserted indefinitely).
   assert property (@(posedge clk) disable iff (rst) $fell(done) |-> $past(go,1));
   
endmodule
