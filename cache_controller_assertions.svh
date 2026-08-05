
logic f_past_valid;
initial f_past_valid = 1'b0;
logic init =1;
always @(posedge clk) begin 
 assume(rst == init );
   init <= 0;

end 


//(* anyconst *) wire [9:0] sym_index;
 wire [9:0] sym_index;

logic tb_cpu_req_valid;
logic tb_cpu_req_rw;
logic [31:0]tb_cpu_req_addr;
logic [31:0]tb_cpu_req_data;

logic [18-1:0]tb_tag_read_tag;

logic [31:0] tb_mem_req_addr;
logic [127:0] tb_mem_req_data;
logic	     tb_mem_req_rw;
logic        tb_mem_req_valid;

logic [127:0] tb_mem_data_data  ;
logic tb_mem_data_ready ;
logic is_tag_read_x =0 ;

logic cache_hit;
assign cache_hit =   (cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag); 

assign tb_cpu_req_valid = cpu_req.valid;
assign tb_cpu_req_rw    = cpu_req.rw;
assign tb_cpu_req_addr  = cpu_req.addr;
assign tb_cpu_req_data  = cpu_req.data;


assign tb_tag_read_tag  = tag_read.tag;

assign tb_mem_req_addr  =  mem_req.addr; 
assign tb_mem_req_data  =  mem_req.data;
assign tb_mem_req_rw    =  mem_req.rw;
assign tb_mem_req_valid  =  mem_req.valid;

assign  tb_mem_data_data   = mem_data.data;
assign  tb_mem_data_ready   = mem_data.ready;

assign is_tag_read_x = ^tb_tag_read_tag;


always@(posedge clk)
	f_past_valid <= 'b1;

always @(posedge clk) begin 
// memory -> cache controller
   // memory controller responds to cache controller requests in 2 cycles
  if( f_past_valid &&   $past(tb_mem_req_valid,2) && ($past(rst,2) ==1'b0)  )
 begin 
	m1 : assume ($past(mem_data.ready) == 1'b0);
	m1_1 : assume(mem_data.ready == 1'b1);
 end 

   if($past(mem_data.ready) == 1'b1) 
      m2 :assume(mem_data.ready == 1'b0);

       //  assume( $changed(data_write ));   // over constraints the constraint- solver

// The cpu request should be held constant in other than idle fsm stage
if( rstate !=  cache_state_type'(idle))	begin
 	 m5: assume(cpu_req.valid ==0);
      m6: assume($stable(cpu_req.addr)  );
  	 m7: assume($stable(cpu_req.data)  );
  	 m8: assume($stable(cpu_req.rw)  );

end 

end 

always @(posedge clk) begin 

if(  f_past_valid &&  ($past(rstate,1) ==  cache_state_type'(idle))  && $past(cpu_req.valid,1) && $past(!rst) )  
 a1: assert (rstate == cache_state_type'(compare_tag) );
  // a6: assert( s_eventually  tag_read.valid==1 );

     c1: cover( f_past_valid&&  rstate ==  cache_state_type'( compare_tag ));
     c2: cover (f_past_valid&&  rstate ==  cache_state_type'( compare_tag )     &&  (cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag )); 
     c3: cover (f_past_valid&&  rstate ==  cache_state_type'( compare_tag )     &&  (cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag) && (tag_read.valid)   );
     c3_1: cover (f_past_valid&&  rstate ==  cache_state_type'( compare_tag )     &&  (cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag) && (tag_read.valid) && (tag_read.dirty)  );
     c4: cover (f_past_valid&&  rstate ==  cache_state_type'( compare_tag )     &&  (cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag) && (tag_read.valid==0)  );
     c5: cover (f_past_valid  &&  tag_read.valid);
     c5_1: cover (f_past_valid && tag_req.we==1 && tag_write.valid );
     c6: cover (f_past_valid && rstate == cache_state_type'(compare_tag) &&  tag_read.valid);

    c5_iso: cover(f_past_valid && $past(tag_req.we) && $past(tag_write.valid) && $past(cpu_req.addr) == cpu_req.addr && $past(tag_req.index) == tag_req.index && tag_read.valid);
    c_allocate : cover  (f_past_valid && rstate == cache_state_type'( allocate ) );

//c_mem_valid: cover(  f_past_valid &&   ctag.tag_mem[10].valid );

c5_is1: cover(f_past_valid &&  $past(tag_req.index) == tag_req.index );
c5_is2: cover(f_past_valid &&  $past(tag_req.index) == tag_req.index &&  $past(cpu_req.addr) == cpu_req.addr  );
c5_is3: cover(f_past_valid &&  $past(tag_req.index) == tag_req.index &&  $past(cpu_req.addr) == cpu_req.addr  &&  $past(tag_req.we)  && tag_req.we==0  );
c5_is4: cover(f_past_valid &&  $past(tag_req.index) == tag_req.index &&  $past(cpu_req.addr) == cpu_req.addr  &&  $past(tag_req.we)&& $past(tag_write.valid) && tag_req.we==0  );
c5_is5: cover(f_past_valid &&  $past(tag_req.index) == tag_req.index &&  $past(cpu_req.addr) == cpu_req.addr  &&  $past(tag_req.we)&& $past(tag_write.valid) && tag_req.we==0 && tag_read.tag ==$past(tag_write.tag)  );

c5_is6: cover(f_past_valid &&  $past(tag_req.index) == tag_req.index &&  $past(cpu_req.addr) == cpu_req.addr  &&  $past(tag_req.we)&& $past(tag_write.valid) && tag_req.we==0 && tag_read.tag ==$past(tag_write.tag) && tag_read.tag == $past(tag_write.tag)  );


c5_is7: cover(f_past_valid &&  $past(tag_req.index) == tag_req.index &&  $past(cpu_req.addr) == cpu_req.addr  &&  $past(tag_req.we)&& $past(tag_write.valid) && tag_req.we==0 && tag_read.tag ==$past(tag_write.tag) && tag_read.tag  && tag_read.valid );

//
    if(f_past_valid &&  ((rstate) ==  cache_state_type'( compare_tag )) &&  (cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag )
     && (tag_read.valid==1)  && ( $past(!rst)) )  //  cache hit 
      begin 
      a2: assert (rstate == cache_state_type'(compare_tag)  );
    //  a2_1: assert (rstate != cache_state_type'(compare_tag)  );
      a3: cover (rstate == cache_state_type'(compare_tag) );
     end  

// if cache controller is in compare state and requested cache is miss and cache entry is clean i.e we can skip  writing cache contents to lower level memory  
// we can move to allocate state for Reading new block from memory

if( (f_past_valid &&  $past((rstate) ==  cache_state_type'( compare_tag )) &&   $past(!cache_hit) && $past(!tag_read.dirty))  &&  $past(!rst)  )
   a5: assert(rstate ==  cache_state_type'( allocate ));



// if cache controller is in 'compare_tag' state and requested cache is miss, drity and not valid 
// we should move to allocte state and it state shoulnt move to write back because dirty and 'invalid' stste
if( (f_past_valid &&  $past((rstate) ==  cache_state_type'( compare_tag )) &&  $past(!tag_read.valid) &&   $past(!cache_hit) && $past(tag_read.dirty))  &&  $past(!rst) )begin
   a6: assert((rstate) !=  cache_state_type'( write_back ));
   a6_2: assert((rstate) ==  cache_state_type'(allocate ));

end 

// if cache controller is in 'compare_tag' state and requested cache is miss, drity and  valid
// we should move to write_back state for writing cache contents to lower level menory 

if( (f_past_valid &&  $past((rstate) ==  cache_state_type'( compare_tag )) &&  $past(tag_read.valid) &&   $past(!cache_hit) && $past(tag_read.dirty))  &&  $past(!rst) )
   a6_1: assert((rstate) ==  cache_state_type'( write_back ));


// if cache controller is in 'compare_tag' state and requested cache is miss, drity and  valid
// write the cache contents to lower level memory

if( (f_past_valid &&  ((rstate) ==  cache_state_type'( compare_tag )) &&  (tag_read.valid)  && (tag_read.dirty)    && (!cache_hit) &&  $past(!rst) )) begin

    a7:  assert(   mem_req.data ==   data_read);
    a8 : assert(mem_req.valid == 1'b1 );
    a9 : assert(mem_req.addr == {tag_read.tag, cpu_req.addr[TAGLSB-1:0]}  ); // write different addr from cpu request based on the addr contained in cache 
    a10 : assert(mem_req.rw == 1'b1);


    a7_c:  cover(   mem_req.data ==   data_read && data_read != 0 );
    a8_c : cover(mem_req.valid == 1'b1 );
    a9_c : cover(mem_req.addr == {tag_read.tag, cpu_req.addr[TAGLSB-1:0]}  ); // write different addr from cpu request based on the addr contained in cache 
    a10_c : cover(mem_req.rw == 1'b1);
end 


// if cache controller is in 'compare_tag' state and requested cache is miss, clean and  valid---? is valid necessary
// issue read request to lower level memory

if( (f_past_valid &&  ((rstate) ==  cache_state_type'( compare_tag )) &&  (tag_read.valid)  && (!tag_read.dirty)  && (!cache_hit) &&  $past(!rst) )) begin
   	 a11 : assert(mem_req.valid == 1'b1 );
  	 a12 : assert(mem_req.addr ==  cpu_req.addr );
   	 a13 : assert(mem_req.rw == 1'b0);
end 

// if cache controller is in 'compare_tag' state and  cpu_write, requested cache is hit, clean and  valid
//cache controller response data should be equal to data write provided by cpu request

if( (f_past_valid && $past(!rst) &&  ((rstate) ==  cache_state_type'( compare_tag )) && $past(cpu_req.rw) && (tag_read.valid)  && (!tag_read.dirty)  && (cache_hit) ) ) begin
	  a14: assert(cpu_res.ready == 1'b1);
	  a15: assert(  data_req.we && data_write[ ((cpu_req.addr[3:2]+1'b1) *32)-1 -: 32    ] ==  cpu_req.data  );

	  a14_c: cover(cpu_res.ready == 1'b1);
	  a15_c: cover(  data_req.we && data_write[ ((cpu_req.addr[3:2]+1'b1) *32)-1 -: 32    ] ==  cpu_req.data  );
end 

// if cache controller is in 'compare_tag' state and cpu_read, requested cache is hit and  valid
//cache controller response data should be equal to data read memory output

if( (f_past_valid && $past(!rst) &&  ((rstate) ==  cache_state_type'( compare_tag )) && $past(!cpu_req.rw) && (tag_read.valid)  && (cache_hit) ) ) begin
 	 a16: assert(cpu_res.ready == 1'b1);
 	 a17 :assert(  data_read[ ((cpu_req.addr[3:2]+1'b1) *32)-1 -: 32    ] ==  cpu_res.data  );

         a16_c: cover(cpu_res.ready == 1'b1);
 	 a17_c :cover(  data_read[ ((cpu_req.addr[3:2]+1'b1) *32)-1 -: 32    ] ==  cpu_res.data  );

end 

// dummy 
if( (f_past_valid &&  ((rstate) ==  cache_state_type'( compare_tag )) &&  (tag_read.valid)  && (tag_read.dirty)    && (!cache_hit) &&  $past(!rst) )) begin

	a18 : assert(mem_req.addr == {tag_read.tag, cpu_req.addr[TAGLSB-1:0]}  );
	a19 : assert(mem_req.data ==  data_read     );
end 

// / if cache controller is in 'write_back' state and issue the read request to lower level memory based on cpu request
if( (f_past_valid &&  ((rstate) ==  cache_state_type'( write_back )) && mem_data.ready &&  $past(!rst) )) begin

	a20 : assert(mem_req.rw == 1'b0 );
	a21: assert(mem_req.addr == cpu_req.addr );
	a22:  assert(mem_req.valid == 1'b1 );

end 

// if cache controller is in 'allocate' state  write  the contents to data memory read from lower level memory 
if( (f_past_valid &&  ((rstate) ==  cache_state_type'( allocate )) && mem_data.ready &&  $past(!rst) )) begin

	a23: assert ( data_write == mem_data.data );
	a24: assert (data_req.we ==1'b1 );
end 


// if cache controller is in 'allocate' state, the cache controller response data equal to data came from lower level memory
if( (f_past_valid &&  $past((rstate) ==  cache_state_type'( allocate )) && $past( mem_data.ready) && cpu_req.valid &&  $past(!rst) )) begin
  	a25: assert( cpu_res.data == data_read[ ((cpu_req.addr[3:2]+1'b1) *32)-1 -: 32    ] );
  	a25_c : cover(cpu_res.data != 0);
 	a26: assert(cpu_res.ready == 1'b1);
end 


////////////////////////////////
//Invariants for the K- induction engine
// k- induction strenghthed the a26 assertion by including cpu_req.valid, when k-induction started from the write back state and cpu_req.valid ==0 -checker bug 

end 

(* anyconst *) logic [9:0] f_index;  // symbolic constant 

always @(posedge clk) begin
// assume(data_req.index == sym_index);
if( f_past_valid && $past(data_req.we) && $past(data_req.index) == f_index  ) 
	if(!data_req.we  && data_req.index == f_index )
              a4:assert ((data_read == $past(data_write)));



 if (f_past_valid && $past(!rst) &&  $past(tag_req.we) && $past(tag_req.index) == f_index)
	 if(!tag_req.we && tag_req.index== f_index)
    begin

  a11_:   assert (  tag_read == $past(tag_write));
  ca11:   cover (  tag_read == $past(tag_write));

end
end 


