module tb_fir;
    localparam pADDR_WIDTH = 12;
    localparam pDATA_WIDTH = 32;
    localparam Tape_Num    = 4'd11;
    reg axis_clk;
    reg axis_rst_n;

    // Axi-lite write 
    reg awvalid;
    reg [(pADDR_WIDTH-1):0] awaddr;
    reg wvalid;
    reg [(pDATA_WIDTH-1):0] wdata;
    wire awready;
    wire wready;

    // Axi-lite read 
    reg arvalid;
    reg [(pADDR_WIDTH-1):0] araddr;
    reg rready;
    wire arready;
    wire rvalid;
    wire [(pDATA_WIDTH-1):0] rdata;

// -------------------------------------------------
    // Axi-stream write 
    reg ss_tvalid;
    reg [(pDATA_WIDTH-1):0] ss_tdata;
    reg ss_tlast;
    wire ss_tready;

    // Axi-stream read 
    reg sm_tready;
    wire sm_tvalid;
    wire [(pDATA_WIDTH-1):0] sm_tdata;
    wire sm_tlast;

    // bram for tap RAM 
    wire [3:0] tap_WE;
    wire tap_EN;
    wire [(pDATA_WIDTH-1):0] tap_Di;
    wire [(pADDR_WIDTH-1):0] tap_A;
    reg [(pDATA_WIDTH-1):0] tap_Do;

    // bram for data RAM 
    wire [3:0] data_WE;
    wire data_EN;
    wire [(pDATA_WIDTH-1):0] data_Di;
    wire [(pADDR_WIDTH-1):0] data_A;
    reg [(pDATA_WIDTH-1):0] data_Do;


    fir #(
        .pADDR_WIDTH(pADDR_WIDTH),
        .pDATA_WIDTH(pDATA_WIDTH),
        .Tape_Num(Tape_Num)
    ) uut (
        // Axi-lite write
        .awready(awready),
        .wready(wready),
        .awvalid(awvalid),
        .awaddr(awaddr),
        .wvalid(wvalid),
        .wdata(wdata),

        // Axi-lite read
        .arready(arready),
        .rready(rready),
        .arvalid(arvalid),
        .araddr(araddr),
        .rvalid(rvalid),
        .rdata(rdata),

        // Axi-stream write 
        .ss_tvalid(ss_tvalid),
        .ss_tdata(ss_tdata),
        .ss_tlast(ss_tlast),
        .ss_tready(ss_tready),

        // Axi-stream read
        .sm_tready(sm_tready),
        .sm_tvalid(sm_tvalid),
        .sm_tdata(sm_tdata),
        .sm_tlast(sm_tlast),

        // bram for tap RAM
        .tap_WE(tap_WE),
        .tap_EN(tap_EN),
        .tap_Di(tap_Di),
        .tap_A(tap_A),
        .tap_Do(tap_Do),

        // bram for data RAM
        .data_WE(data_WE),
        .data_EN(data_EN),
        .data_Di(data_Di),
        .data_A(data_A),
        .data_Do(data_Do),

        .axis_clk(axis_clk),
        .axis_rst_n(axis_rst_n)
    );
    always #50 axis_clk = ~axis_clk;
    initial
        axis_clk = 0;
//*******************************************************************************************
// - Axi-lite Protocol Control
//*******************************************************************************************
/*    always @(posedge axis_clk or negedge axis_rst_n)
    begin
        if(!axis_rst_n)
        begin
            awvalid <= 0;
            wvalid  <= 0;
            arvalid <= 0;
        end
        else
        begin
            if(awready)
            begin
                awvalid <= 0;
                awaddr <= 0;
            end
            if(wready)
            begin
                wvalid <= 0;
                wdata <= 0;
            end
            
            if(arready)
                arvalid <= 0;
            if(rvalid)
                rready <= 1;
        end
    end
*/


//*******************************************************************************************
// - configuration write / read task
//*******************************************************************************************
    // configuration write 
    task configure_write;
        input [pADDR_WIDTH-1:0] addr;
        input [pDATA_WIDTH-1:0] data;
    begin
        @(posedge axis_clk);
        awvalid <= 1;
        wvalid  <= 1;
        wdata   <= data;
        awaddr  <= addr;
        fork
            begin
                while( !awready) @(posedge axis_clk);
                awvalid <= 0;
                awaddr  <= 0;
            end 
            begin
                while( !awready) @(posedge axis_clk)
                wvalid  <= 0;
                wdata   <= 0;
            end
        join
    end
    endtask
//*******************************************************************************************
// - configuration write / read task
//*******************************************************************************************
    initial 
    begin
        axis_rst_n = 1;
        @(posedge axis_clk);
        axis_rst_n = 0;
        @(posedge axis_clk);
        axis_rst_n = 1;
        configure_write('h10,'h30);
        configure_write('h0,'b111);
    end

endmodule