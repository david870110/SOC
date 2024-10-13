////////////////////////////////////////////////////
// Function Description : 
// AXI-Lite : 
// AXI-Stream : 
// FIR Control :
// 
////////////////////////////////////////////////////

module fir 
#(  
    parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)
(
    // Axi-lite write
    output  wire                     awready,
    output  wire                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,

    // Axi-lite read
    output  wire                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  wire                     rvalid,
    output  wire [(pDATA_WIDTH-1):0] rdata,    

    // Axi-stream write 
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  wire                     ss_tready, 
    
    // Axi-stream read
    input   wire                     sm_tready, 
    output  wire                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  wire                     sm_tlast, 
    
    // bram for tap RAM
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  wire [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    // bram for data RAM
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);
//*******************************************************************************************
// - axi-lite write
//  - awready   : when awvalid is asserted , awready will check fifo status , if not full is ready.
//  - wready    : when wvalid is asserted , awready will check fifo status , if not full is ready.     
//  - fifo_push : fifo not full & data valid.
//  - fifo_pop  : aw_fifo and w_fifo both not empty will pop to SRAM. (pop_axi_fifo)         
//*******************************************************************************************
    localparam AXI_FIFO_DEPTH = 3;

    wire w_fifo_full,w_fifo_empty,aw_fifo_full,aw_fifo_empty;
    wire pop_axi_fifo;
    wire [pADDR_WIDTH-1 : 0] aw_fifo_out;
    wire [pDATA_WIDTH-1 : 0] w_fifo_out;

    assign awready       = awvalid & !aw_fifo_full; // valid can remove ? -JIANG
    assign wready        = wvalid  & !w_fifo_full;
    assign pop_axi_fifo  = !w_fifo_empty & !aw_fifo_empty; 

    fifo
    #(  .WIDTH      (pADDR_WIDTH),
        .DEPTH      (AXI_FIFO_DEPTH)
    )   aw_fifo
    (
        clk         (axis_clk),
        reset       (axis_rst_n),
        fifo_full   (aw_fifo_full),
        fifo_empty  (aw_fifo_empty),
        w_valid     (awvalid),
        r_ready     (pop_axi_fifo),
        data_in     (awaddr),
        data_out    (aw_fifo_out)
    );
    fifo
    #(  .WIDTH      (pDATA_WIDTH),
        .DEPTH      (AXI_FIFO_DEPTH)
    )   w_fifo
    (
        clk         (axis_clk),
        reset       (axis_rst_n),
        fifo_full   (w_fifo_full),
        fifo_empty  (w_fifo_empty),
        w_valid     (wvalid),
        r_ready     (pop_axi_fifo),
        data_in     (wdata),
        data_out    (w_fifo_out)
    );


//*******************************************************************************************
// - pop data check address condition
//  - 0x00          :
//      - wire name : pop_cfg 
//      - [0] : ap_start    --- set 1 in axi write 0x00 ; reset at first axis data transfer & ap_idle = 1; 
//      - [1] : ap_done     --- set 1 at Y data is transfered finish , reset in axi-read address 0x00.
//      - [2] : ap_idle     --- when ap_start = 1 , set 1 ; reset at Y data is calculated finish.
//  - 0x10 ~ 0x14   : 
//      - wire name : pop_datalength
//      - data length     
//  - 0x20 ~ 0xFF   :  
//      - wire name : pop_tap
//      - tap data       
//*******************************************************************************************
    reg ap_start,ap_done,ap_idle;
    reg [pDATA_WIDTH-1 : 0] data_length;
    wire pop_cfg,pop_datalength,pop_tap;

    assign pop_cfg         = pop_axi_fifo & (aw_fifo_out[pADDR_WIDTH-1 : 0] == 12'h0);
    assign pop_datalength   = pop_axi_fifo & (aw_fifo_out[pADDR_WIDTH-1 : 0] >= 'h20) & (aw_fifo_out[pADDR_WIDTH-1 : 0] <= 'hFF);
    assign pop_tap          = pop_axi_fifo & (aw_fifo_out[pADDR_WIDTH-1 : 0] >= 'h10) & (aw_fifo_out[pADDR_WIDTH-1 : 0] <= 'h14);

    always@(posedge axis_clk or negedge axis_rst_n)
    begin
        if(!axis_rst_n)
        begin
            ap_start    <= 0;
            ap_done     <= 0;
            ap_idle     <= 1; //reset is 1; 
            data_length <= 0;
        end
        else
        begin
            // --- resetting
            /*
            if(first axis data transfer & ap_idle == 0) 
                ap_start <= 0;
            if(last Y data is calculated) ap_idle <= 1;
            */
            if((araddr[pADDR_WIDTH-1 : 0] == 12'h0) & arvalid)
                ap_done <= 0;

            // --- setting
            // if(last Y data is transfered) ap_done <= 1
            if(ap_start)
                ap_idle <= 0;
            if(pop_cfg)
                ap_start <= w_fifo_out[0];
            else if(pop_datalength)
                data_length <= w_fifo_out;
        end
    end

//*******************************************************************************************
// - tap_ram control
//  - tap_ram address generation : tap_wr_addr
//      - it will plus one after pop_tap until to Tape_Num.
//  - .EN is connect to pop_tap, when pop_tap high, it will write w_fifo_out data.
//*******************************************************************************************
    localparam TAPE_NUM_BIT = $clog2(Tape_Num);
    reg [TAPE_NUM_BIT-1 : 0] tap_wr_addr;
    wire [TAPE_NUM_BIT-1 : 0] tap_addr_sel;

    // for PE-transfer-----------------------------------
    reg [TAPE_NUM_BIT-1 : 0] pe_req_addr;     // ??? wait axis flow finished
    // --------------------------------------------------

    assign tap_addr_sel[TAPE_NUM_BIT-1 : 2] = (pop_tap) ? tap_wr_addr : pe_req_addr;// --!!! if tap data transfer finish, but still transfer tap when ap_idle = 1, it maybe will have problem.  - JIANG


    always@(posedge axis_clk or negedge axis_rst_n)
    begin
        if(!axis_rst_n)
            tap_wr_addr  <= 0;
        else if((tap_wr_addr < Tape_Num) & pop_tap)
            tap_wr_addr  <= tap_wr_addr + 1;
    end


    bram #(11) tap_ram
    (
        .CLK        (axis_clk),
        .WE         (4'b1111),
        .EN         (pop_tap),
        .Di         (w_fifo_out),
        .Do         (),
        .A          (tap_addr_sel)
    );

//*******************************************************************************************
// - axi-lite read
//  - rvalid    : when address is asserted , data is valid.
//  - arready   : when arready is asserted , TB will reset arvalid and araddr in next cycle. 
//*******************************************************************************************
    assign rvalid   = arvalid;
    assign arready  = arvalid;
    // ??? need read axi-lite?

    

//*******************************************************************************************
// - axi-stream write
//*******************************************************************************************
    localparam AXIS_FIFO_DEPTH = 3;

    wire ss_fifo_full,ss_fifo_empty;
    wire pop_ss_fifo;
    wire [pDATA_WIDTH-1 : 0] ss_fifo_out;

    // for PE-transfer-----------------------------------
    wire[pDATA_WIDTH-1 : 0] x_data;
    wire pe_ready;
    // --------------------------------------------------

    assign ss_tready        = ss_tvalid  & !ss_fifo_full;
    assign pop_ss_fifo     = pe_ready; //unit calculate end can pop next data.

    fifo
    #(  .WIDTH      (pDATA_WIDTH),
        .DEPTH      (AXIS_FIFO_DEPTH)
    )   ss_fifo
    (
        clk         (axis_clk),
        reset       (axis_rst_n),
        fifo_full   (ss_fifo_full),
        fifo_empty  (ss_fifo_empty),
        w_valid     (ss_tvalid),
        r_ready     (pop_ss_fifo),
        data_in     (ss_tdata),
        data_out    (x_data)
    );


//*******************************************************************************************
// - PE-Transfer  systolic array convolution
//*******************************************************************************************
    reg [pDATA_WIDTH-1 : 0] x_input,tap_input;
    reg [pDATA_WIDTH-1 : 0] PE_output [0 : Tape_Num-1];
    localparam [1:0] IDLE = 2'b00; // pop > calculate; calculate one cycle to datatransfer; pop 
//*******************************************************************************************
// - axi-stream read
//*******************************************************************************************
endmodule