`timescale 1ns / 1ps

module testbench;

parameter DSIZE=8;
parameter DEAPTH =16;
parameter ASIZE = 4;

reg [DSIZE-1:0] d_output;
wire wr_full,rd_empty;
reg [DSIZE-1:0] d_input;
reg rd_inc,wr_inc,rd_clk,wr_clk;
reg r_rst,w_rst;
integer i;

// Queue to push data_in
 reg [DSIZE-1:0]wdata_q[$];

// Instantiate the FIFO
  FIFO_Async DUT (
  .wr_clk     (wr_clk)     ,
  .w_rst   (w_rst)     ,
  .wr_inc    (wr_inc)     ,
  .rd_clk    (rd_clk)     ,
  .r_rst   (r_rst)     ,
  .rd_inc     (rd_inc)     ,
  .d_input    (d_input)    ,
  .wr_full     (wr_full)      ,
  .d_output    (d_output)    ,
  .rd_empty   (rd_empty)     );

initial 
begin
wr_clk = 1'b0; 
rd_clk = 1'b0;
w_rst = 1'b0;
wr_inc = 1'b0;
d_input = 0;
rd_clk = 1'b0; 
r_rst = 1'b0;
rd_inc = 1'b0;

    fork
      forever #5 wr_clk = ~wr_clk;
      forever #7 rd_clk = ~rd_clk;
      rd_inc = 1'b1;
      wr_inc = 1'b1;
      #10 w_rst = 1'b1;
      #10 r_rst = 1'b1;
    join
  end  
  initial begin
 
    repeat(5) @(posedge wr_clk);
    begin
      repeat(2)
      begin
       
      for (i=0; i<30; i=i+1) begin
        @(posedge wr_clk && !wr_full);
        if (wr_inc) begin
          d_input = $random;
         wdata_q.push_back(d_input);
          
        end
        end
      end
  end
  end
    
  initial begin
    
    repeat(5) @(posedge rd_clk);
    begin
      repeat(2)
      begin
      
      for (int j=0; j<30; j=j+1) begin
        @(posedge rd_clk && !rd_empty);
        if (rd_inc) begin
          d_output = wdata_q.pop_front();
          if(d_output !== d_input) $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, d_input, d_output);
          else 
          $monitor("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h, ",$time, d_input, d_output);
        end
      end
      end
      $finish;
    end
    end

  initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars;

  end
  
endmodule
