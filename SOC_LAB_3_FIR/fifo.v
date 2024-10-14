////////////////////////////////////////////////////
// Function Description : 
// AXI-Lite : 
// AXI-Stream : 
// FIR Control :
// 
////////////////////////////////////////////////////
module fifo
#(
   parameter WIDTH = 32,
   parameter DEPTH = 3
)
(
    input               clk ,
    input               reset ,

    // fifo status
    output              fifo_full,
    output              fifo_empty,

    // data protocol
    input               w_valid,
    input               r_ready,
    input  [WIDTH-1:0]  data_in,
    output [WIDTH-1:0]  data_out
);
    localparam PTR_NUM_BITS = $clog2(DEPTH);

    //*******************************************************************************************
    // - FIFO Status & ptr control
    //*******************************************************************************************    
    reg [PTR_NUM_BITS-1 : 0] drp, wrp, rdp;
    wire fifo_pop,fifo_push;
    
    assign fifo_pop = !fifo_empty & r_ready;
    assign fifo_push = !fifo_full & w_valid;
    assign fifo_full  = (drp == DEPTH );
    assign fifo_empty = (drp == 0); 

    always @(posedge clk or negedge reset) 
    begin
        if (!reset)
        begin
            wrp <= 'd0;
            rdp <= 'd0;
        end
        else 
        begin
            if(fifo_push)
            begin
                if(wrp < DEPTH-1)
                    wrp <= wrp + 1'b1;
                else
                    wrp <= 0;
            end
            if(fifo_pop)
            begin
                if(rdp < DEPTH-1)
                    rdp <= rdp + 1;
                else
                    rdp <= 0;
            end
        end
    end 
    always @(posedge clk or negedge reset) 
    begin
        if (!reset)
        begin
            drp <= 'd0;
        end
        else 
        begin
            if(fifo_push & !fifo_pop)
                drp <= drp + 1'b1;
            else if(!fifo_push & fifo_pop)
                drp <= drp - 1'b1;
        end
    end 

    //*******************************************************************************************
    // - FIFO data output
    //*******************************************************************************************   
    reg [WIDTH-1:0] fifo_reg [0:DEPTH-1];
    integer i ;
    assign data_out = fifo_reg[rdp];
    
    always @(posedge clk or negedge reset) 
    begin
        if (!reset)
            for(i = 0;i<DEPTH;i=i+1)
                fifo_reg[i] <= 'd0;
        else 
        begin
            if(fifo_push)
                fifo_reg[wrp] <= data_in;
            /*if(fifo_pop)                  // - ring fifo will write at cycle, can't reset  -- JIANG
                fifo_reg[rdp] <= 'bz;*/
        end
    end 
endmodule