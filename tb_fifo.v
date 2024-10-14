module tb_fifo;
    parameter DATA_WIDTH    = 32;
    parameter DEPTH         = 3;

    reg clk, rst_n;
    wire fifo_full, fifo_empty;
    wire w_valid;
    wire r_ready;
    wire[DATA_WIDTH-1 : 0] data_in, data_out;
 
    fifo
    #(  .WIDTH      (DATA_WIDTH),
        .DEPTH      (DEPTH)
    )   inst_fifo
    (
        clk         (clk),
        reset       (rst_n),
        fifo_full   (fifo_full),
        fifo_empty  (fifo_empty),
        w_valid     (w_valid),
        r_ready     (r_ready),
        data_in     (data_in),
        data_out    (data_out)
    );

    always #50 clk = ~clk;

    // *******************************************************************************************
    // 
    // 
    // 
    // 
    // 
    // 
    // 
    // 
    // *******************************************************************************************   
    task generate_data;
        input[DATA_WIDTH-1 : 0] data;
        begin
            
        end
    endtask

    // *******************************************************************************************
    // - TB Need test case
    //  - 1. check fifo empty (no w_valid)
    //  - 2. check fifo full (control r_ready)
    //  - 3. basic auto check compare data : 
    //      - TB has a fifo and sram (behavior)
    //      - when data is generated, push to TB fifo and push to design fifo. 
    //      - design fifo and TB fifo have the same depth fifo layer.
    //  - 4. random test
    // *******************************************************************************************   
    initial 
    begin
    $dumpfile ("./tb_fir.vcd");
    $dumpvars (0, tb_fifo);
    // ---------------------------------------
    // - reset
    rst_n       = 0;
    w_valid     = 0;
    r_ready     = 0;
    data_in     = 0;
    // ---------------------------------------
    repeat(5) @(posedge clk)
    if(!fifo_empty)
        begin
        $display ("ERROR : fifo_empty is not working.");
        $stop;
        end
    
    end

endmodule