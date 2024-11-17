module tb_fir;
    localparam pADDR_WIDTH = 12;
    localparam pDATA_WIDTH = 32;
    localparam Tape_Num    = 4'd11;
    localparam Data_Num    = 600;
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
    wire [(pDATA_WIDTH-1):0] tap_Do;

    // bram for data RAM 
    wire [3:0] data_WE;
    wire data_EN;
    wire [(pDATA_WIDTH-1):0] data_Di;
    wire [(pADDR_WIDTH-1):0] data_A;
    wire [(pDATA_WIDTH-1):0] data_Do;


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
        .tap_A (tap_A),
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

    
    always #5 axis_clk = ~axis_clk;

//*******************************************************************************************
// - Axi-lite Protocol Control
//*******************************************************************************************
always @(posedge axis_clk or negedge axis_rst_n)
    begin
        if(!axis_rst_n)
        begin
            awvalid <= 0;
            wvalid  <= 0;
            arvalid <= 0;

            ss_tvalid <= 0;
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
            if(ss_tready)
                ss_tvalid <= 0;
            /*
            if(arready)
                arvalid <= 0;
            if(rvalid)
                rready <= 1;*/
        end
    end



// *******************************************************************************************
// - axi-lite write / read task
// *******************************************************************************************
    // configuration write 
    task configure_write_addr;
    input [pADDR_WIDTH-1:0] addr;
    begin
        @(posedge axis_clk);
        awvalid <= 1;
        awaddr  <= addr;
        while( !awready) @(posedge axis_clk);
            awaddr  <= 0;
    end
    endtask

    task configure_write_data;
    input [pDATA_WIDTH-1:0] data;
    begin
        @(posedge axis_clk);
        wvalid <= 1;
        wdata  <= data;
        while( !wready) @(posedge axis_clk);
            wdata  <= 0;
    end
    endtask

    task configurae_write;
    input [pADDR_WIDTH-1:0] addr;
    input [pDATA_WIDTH-1:0] data;
    input [6:0] random_cycle_mode;
    fork
        if(random_cycle_mode > 0)
        begin
            repeat({$random} % random_cycle_mode) @(posedge axis_clk);
            configure_write_addr(addr);
        end
        else
            configure_write_addr(addr);
        if(random_cycle_mode > 0)
        begin
            repeat({$random} % random_cycle_mode) @(posedge axis_clk);
            configure_write_data(data); 
        end
        else
            configure_write_data(data); 
    join
    endtask

    task configure_read;
        input  [31:0] addr;
        output [31:0] data;
        begin
            @(posedge axis_clk);
            arvalid <= 1;
            araddr  <= addr;
            fork
                begin   
                    while(!arready) @(posedge axis_clk);
                    arvalid <= 0;
                    araddr  <= 0;
                end
                begin  
                    // wait for rvalid, rdata
                    rready  <= 1;
                    while(!rvalid) @(posedge axis_clk);
                    rready  <= 0;
                    data    <= rdata;
                end
            join
        end
    endtask
//*******************************************************************************************
// - data preprocess
//*******************************************************************************************
// tap-------------------
    reg signed [31:0] coef [0:Tape_Num-1]; // fill in coef 
    initial
    begin
        coef[0]  =  32'd0;       
        coef[1]  = -32'd10;      
        coef[2]  = -32'd9;
        coef[3]  =  32'd23;
        coef[4]  =  32'd56;
        coef[5]  =  32'd63;
        coef[6]  =  32'd56;
        coef[7]  =  32'd23;
        coef[8]  = -32'd9;
        coef[9]  = -32'd10;     
        coef[10] =  32'd0;            
    end                        

// data------------------
    reg         [(pDATA_WIDTH-1):0] data_length;
    reg signed  [(pDATA_WIDTH-1):0] Din_list    [0:(Data_Num-1)];
    reg signed  [(pDATA_WIDTH-1):0] golden_list [0:(Data_Num-1)];

    integer Din, golden, input_data, golden_data, m;
    initial begin
        data_length = 0;
        Din = $fopen("./input.dat","r");
        golden = $fopen("./out_gold.dat","r");
        for(m=0; m<Data_Num; m=m+1) begin
            input_data = $fscanf(Din,"%d", Din_list[m]);
            golden_data = $fscanf(golden,"%d", golden_list[m]);
            data_length = data_length + 1;
        end
    end

//*******************************************************************************************
// - axi-stream write / read task
//*******************************************************************************************
    task stream_write;
    input [pDATA_WIDTH-1:0] data;
    input last;
    begin
        @(posedge axis_clk);
        ss_tvalid <= 1;
        ss_tdata  <= data;
        while( !ss_tready) @(posedge axis_clk);
            ss_tdata  <= 0;
    end
    endtask

//*******************************************************************************************
// - auto check
//*******************************************************************************************
    reg [9 : 0] golden_index;
    always @(posedge axis_clk or negedge axis_rst_n)
    begin
        if(!axis_rst_n)
            golden_index <= 0;
        else
            if(sm_tvalid)
            begin
                golden_index <= golden_index + 1;
                if(golden_list[golden_index] !== sm_tdata)
                begin
                    $display("ERROR : index[%d] compare error." , golden_index);
                    $stop;
                end
                else if(sm_tlast)
                begin
                    $display("All Correct");
                    golden_index <= 0;
                    //$finish;
                end
            end
    end

//*******************************************************************************************
// - Testing start
//*******************************************************************************************
    reg[31:0] axi_data_read;
    wire ap_done;
    assign ap_done = axi_data_read[1];

    integer i,j;
    initial 
    begin
        // reset ------------------------------
        sm_tready = 1;
        axis_clk = 0;
        axis_rst_n = 1;
        @(posedge axis_clk);
        axis_rst_n = 0;
        @(posedge axis_clk);
        axis_rst_n = 1;
        // axi-lite write ------------------------------


        configurae_write(0,'b111, 0);
        configurae_write('h10,'d600, 0);
        for(i = 0; i<Tape_Num; i = i+1)
            configurae_write('h20+(i<<2),coef[i],0);

        for(i = 0; i<Data_Num; i = i+1)
        begin

            if(i == (Data_Num - 1))
                stream_write(Din_list[i],1);
            else
                stream_write(Din_list[i],0);
        end

        configure_read(0,axi_data_read);

           

        configurae_write(0,'b111, 0);
        configurae_write('h10,'d600, 0);
        for(i = 0; i<Tape_Num; i = i+1)
            configurae_write('h20+(i<<2),coef[i],0);

        for(i = 0; i<Data_Num; i = i+1)
        begin

            if(i == (Data_Num - 1))
                stream_write(Din_list[i],1);
            else
                stream_write(Din_list[i],0);
        end

    end
//*******************************************************************************************
// - Testing start
//*******************************************************************************************
    bram #(11) tap_ram
    (
        .CLK        (axis_clk),
        .WE         (tap_WE),
        .EN         (tap_EN),
        .Di         (tap_Di),
        .Do         (tap_Do),
        .A          (tap_A)
    );
    bram #(10) data_ram
    (
        .CLK        (axis_clk),
        .WE         (data_WE),
        .EN         (data_EN),
        .Di         (data_Di),
        .Do         (data_Do),
        .A          (data_A)
    );
endmodule