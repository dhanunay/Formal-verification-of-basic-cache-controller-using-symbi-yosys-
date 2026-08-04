//////////////////////////////////////////////////////////////////////////////////
// Author:        Computer Organization and Design 5.12
// Editor:      Dhanunjay M 
// Edit Date:  
// Design Name: basic_cache_core
// Module Name: dm_cache_data
// Description:
//      
// Dependencies: 
//      
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////
import cache_def::*; 
module dm_cache_data(
    input  logic clk,     
    input cache_def::cache_req_type  data_req,//data request/command, e.g. RW, valid    
    input  cache_def::cache_data_type data_write, //write port (128-bit line)     
    output cache_def::cache_data_type data_read
    ); //read port  

//timeunit 1ns; timeprecision 1ps;  
    
//cache_def::cache_data_type data_mem[0:1023];  
logic [127:0] data_mem[0:1023];  
    
 initial  begin    
     for (int i=0; i<1024; i++)           
         data_mem[i] = '0;  
 end  

assign  data_read  = data_mem[data_req.index];  

always_ff  @(posedge(clk))  begin    
    if  (data_req.we)        
        data_mem[data_req.index] <= data_write; 
end 
      

endmodule
