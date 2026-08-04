//////////////////////////////////////////////////////////////////////////////////
// Author:        Computer Organization and Design 5.12
// Editor:        Dhanunjay M 
// Edit Date:  
// Design Name: basic_cache_core
// Module Name: dm_cache_tag
// Description:
//     
// Dependencies: 
//      
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////
/*cache: tag memory, single port, 1024 blocks*/
import cache_def::*; 
module dm_cache_tag(
    input  logic clk, //write clock    
    input  cache_def::cache_req_type tag_req, //tag request/command, e.g. RW, valid    
    input  cache_def::cache_tag_type tag_write,//write port        
    output cache_def::cache_tag_type tag_read
    );//read port  

//timeunit 1ns; timeprecision 1ps;  

//(* mem2reg *)cache_def::cache_tag_type tag_mem[0:1023];  
logic [19:0] tag_mem[0:1023];  

 //initial  begin      
 //    for (int i=0; i<1024; i++)       
 //        tag_mem[i] = '0;  
 //end  

assign tag_read =   tag_mem[tag_req.index]   ; 

always_ff  @(posedge(clk))  begin    
    if  (tag_req.we)      
        tag_mem[tag_req.index] <= tag_write;
    end 

 
endmodule
