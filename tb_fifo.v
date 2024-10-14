module tb_fifo;
    parameter DATA_WIDTH    = 32;
    parameter DEPTH         = 3;

    reg clk, rst_n;
    reg w_valid;
    reg r_ready;
    reg [DATA_WIDTH-1 : 0]  data_in;
    wire[DATA_WIDTH-1 : 0]  data_out;
    wire fifo_full, fifo_empty;
 
    fifo
    #(  .WIDTH      (DATA_WIDTH),
        .DEPTH      (DEPTH)
    )   inst_fifo
    (
        .clk         (clk),
        .reset       (rst_n),
        .fifo_full   (fifo_full),
        .fifo_empty  (fifo_empty),
        .w_valid     (w_valid),
        .r_ready     (r_ready),
        .data_in     (data_in),
        .data_out    (data_out)
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
            if(!fifo_full) 
            begin
                w_valid <= 1;
                data_in <= data;
                @(posedge clk);
                w_valid <= 0;
            end
            else
                $display("FIFO FULL : data %h is not input fifo." , data);
        end
    endtask

    // *******************************************************************************************
    // - TB Need test case
    //  - 1. check fifo empty (no w_valid) (OK)
    //  - 2. check fifo full (control r_ready) 
    //  - 3. basic auto check compare data : 
    //      - TB has a fifo and sram (behavior)
    //      - when data is generated, push to TB fifo and push to design fifo. 
    //      - design fifo and TB fifo have the same depth fifo layer.
    //  - 4. random test
    // *******************************************************************************************  
    integer i ; 

    initial 
    begin
    $dumpfile ("./tb_fir.vcd");
    $dumpvars (0, tb_fifo);
    // ---------------------------------------
    // - reset
    clk     = 0;
    rst_n   = 1;
    // ---------------------------------------
    repeat(1) @(posedge clk)
    rst_n   = 0;
    repeat(1) @(posedge clk)
    rst_n   = 1;
    if(!fifo_empty)
    begin
        $display ("ERROR : fifo_empty is not working.");
        $stop;
    end
    for(i = 0; i<10 ; i = i+1)
    begin
        generate_data(i);
    end




    // ---------------------------------------
    repeat(5) @(posedge clk)
    $display ("CORRECT : Not have any error.");
    $finish;
    end

endmodule
/*
("    ERROR : fifo_empty is not working.");
("  CORRECT : Not have any error.");
("FIFO FULL : data %h is not input fifo." , data)
*/