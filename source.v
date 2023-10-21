`timescale 1ns/1ps

module FIFO_Async
#(parameter DEAPTH = 16,
parameter ASIZE = 4,
parameter D_SIZE = 8)
( d_input, wr_inc, wr_clk,
  rd_inc, rd_clk, d_output,
  wr_full, rd_empty, w_rst,r_rst);
 
 input [D_SIZE-1:0]d_input;
 input wr_inc,wr_clk;
 input rd_inc, rd_clk;
 input w_rst,r_rst;
 
 output reg [D_SIZE-1:0]d_output;
 output wr_full;
 output rd_empty;
 
 reg [ASIZE:0]wr_ptr,wr_ptr_rd_sync,wr_ptr_rd;
 reg [ASIZE:0]rd_ptr,rd_ptr_wr_sync,rd_ptr_wr;
 reg [D_SIZE-1:0] mem[0:DEAPTH-1];
 integer i;
 wire [ASIZE:0] wr_ptr_gray, rd_ptr_gray;
 
 
 //Binary to Gray conversion 
 assign wr_ptr_gray = wr_ptr ^ (wr_ptr>>1);
 assign rd_ptr_gray = rd_ptr ^ (rd_ptr>>1);
 
 // empty condition check
assign rd_empty = (wr_ptr_rd_sync == rd_ptr_gray)?1'b1:1'b0;

//full condition check 
assign wr_full = (rd_ptr_wr_sync[ASIZE:0] == {~wr_ptr_gray[ASIZE:(ASIZE-2)] , wr_ptr_gray[(ASIZE-2):0]});      

 //Write Clock domain 
 always @ (posedge wr_clk or negedge w_rst)
 begin
    if(!w_rst)
    begin
        wr_ptr <= {(ASIZE){1'b0}};
        for(i = 0;i<DEAPTH-1;i=i+1)
        begin
            mem[i] <= {(D_SIZE){1'b0}};
            wr_ptr_rd_sync <= {(ASIZE){1'b0}};
            rd_ptr_wr <= {(ASIZE){1'b0}};
            end
            end
     else
     begin
     if(!wr_full && wr_inc)
     begin
        mem[wr_ptr] <= d_input;
        wr_ptr <= wr_ptr + 1'b1;
     end    
     
     wr_ptr_rd <= wr_ptr_rd_sync;
     wr_ptr_rd_sync <= wr_ptr_gray;
     end
  end
     
// read clock domain

always @(posedge rd_clk or negedge r_rst)
begin
    if(!r_rst)
    begin
      rd_ptr <= {(ASIZE){1'b0}};
      d_output <= {(D_SIZE-1) {1'b0}};
      
      rd_ptr_wr_sync <= {(ASIZE){1'b0}};
      rd_ptr_wr <= {(ASIZE){1'b0}};
    end
    else
    begin
        if(!rd_empty && rd_inc)
        begin
            d_output <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1'b1;
        end    
         rd_ptr_wr <= rd_ptr_wr_sync;
         rd_ptr_wr_sync <= rd_ptr_gray;  
    end
end  

endmodule
