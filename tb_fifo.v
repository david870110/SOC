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
    // Create TB FIFO for check : 
    // *******************************************************************************************   
    localparam PTR_NUM_BITS = $clog2(DEPTH);
    
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    reg [PTR_NUM_BITS:0] wrp, rdp;
    reg [PTR_NUM_BITS:0] drp;  

    task reset_tb_fifo;
        begin
            drp = 0;
            rdp = 0;
            wrp = 0;
        end
    endtask

    task push_tb_fifo;
        input[DATA_WIDTH-1 : 0] data;
        begin
            if(drp < DEPTH)
            begin
                fifo_mem[wrp] <= data;
                wrp = wrp + 1;
                drp = drp + 1;
            end
        end
    endtask

    task pop_tb_fifo;
        output [DATA_WIDTH-1 : 0] data;
        begin
            if(drp > 0)
            begin
                data <= fifo_mem[rdp];
                rdp = rdp + 1;
                drp = drp - 1;
            end
        end
    endtask



    // *******************************************************************************************
    // task generate_data : 
    //  - input data and notify to fifo full
    //  - it will reset valid at next clock if push to fifo.
    //  - it will also to push in TB FIFO.
    // *******************************************************************************************   
    task generate_data;
        input[DATA_WIDTH-1 : 0] data;
        begin
            if(!fifo_full) 
            begin
                w_valid <= 1;
                data_in <= data;
                push_tb_fifo(data);
                @(posedge clk);
                w_valid <= 0;
            end
            else
            begin
                $display("FIFO FULL : data %h is not input fifo." , data);
            end
        end
    endtask

    // *******************************************************************************************
    // task write_mem : 
    //  - create a exp memory and design memory for check.
    //  - pop data and notify to fifo empty.
    //  - it will reset ready at next clock if push to fifo.
    //  - it will also to pop in TB FIFO.
    // *******************************************************************************************   
    reg [DATA_WIDTH-1:0] exp_mem    [0:1023];
    reg [DATA_WIDTH-1:0] design_mem [0:1023];
    reg [9:0] mem_addr;
    task reset_mem;
        begin
            mem_addr = 0;
        end
    endtask
    
    task write_mem;
        begin
            if(!fifo_empty) 
            begin
                r_ready                 <= 1;
                design_mem[mem_addr]    <= data_out;       // ---!!! maybe have clock problem.
                pop_tb_fifo(exp_mem[mem_addr]);
                @(posedge clk);
                r_ready                 <= 0;
                mem_addr                <= mem_addr + 1;
            end
            else
            begin
                $display("FIFO Empty: no data in fifo.");
            end
        end
    endtask
    // *******************************************************************************************
    // task auto_check : 
    //  - compare exp and design mem result
    //  - use mem_addr pointer to know the mem data nums.
    // *******************************************************************************************   
    task auto_check;
        begin
            for(i = 0 ; i < mem_addr; i = i+1)
            begin
                if(design_mem[i] == exp_mem[i])
                    $display("  Correct : in memory address : %d." , i);
                else
                begin
                    $display("    ERROR : auto check compare result is failed, in memory address : %d." , i);
                    $stop;
                end
            end
        end
    endtask

    // *******************************************************************************************
    // task random_data_generate : 
    //  - double layer for loop
    //      - total_loop for : total generate and pop to mem data cycle.
    //          - ramdom for generate   : total generate data.
    //          - ramdom for pop to mem : total pop data. 
    // *******************************************************************************************   
    integer i,j;

    task random_data_generate;
        input [9:0]total_loop;
        begin
            for(i = 0 ; i < total_loop ; i = i+1)
            begin
                for(j = 0 ; j < ({$random} % (2 * DEPTH)) ; j = j+1) 
                    generate_data({$random} % 32'hFFFFFFFF);
                for(j = 0 ; j < ({$random} % (2 * DEPTH)) ; j = j+1) 
                    write_mem;
            end
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
    initial 
    begin
    $dumpfile ("./tb_fir.vcd");
    $dumpvars (0, tb_fifo);
    // reset --------------------------------------------------------
    clk     = 0;
    rst_n   = 1;
    data_in = 0;
    r_ready = 0;
    w_valid = 0;
    reset_tb_fifo;
    reset_mem;
    repeat(1) @(posedge clk)
    rst_n   = 0;
    repeat(1) @(posedge clk)
    rst_n   = 1;

    //  1. fifo empty testing ---------------------------------------
    if(!fifo_empty)
    begin
        $display ("ERROR : fifo_empty is not working.");
        $stop;
    end

    //  2. fifo full testing ---------------------------------------
    for(i = 0; i < DEPTH ; i = i+1)
    begin
        if(fifo_full) 
        begin
            $display("    ERROR : fifo_full is not match to depth.");
            $stop;
        end
        generate_data(i);
    end
    generate_data(i);
    if(!fifo_full) 
        begin
        $display("    ERROR : fifo_full is not working.");
        $stop;
        end

    //  3. basic auto check ----------------------------------------
    write_mem;
    write_mem;
    write_mem;
    for(i = 0; i < 4 ; i= i+1)  
    begin
        for(j = 0; j < DEPTH; j = j+1)
            write_mem;
        for(j = 0; j < DEPTH; j = j+1)
            generate_data(j+i*DEPTH);
    end

    auto_check;

    //  4. random task ---------------------------------------------
    /*
    random_data_generate(50);
    auto_check;
    */

    // finish ------------------------------------------------------
    repeat(5) @(posedge clk);
    $display ("CORRECT : Not have any error.");
    $finish;
    end

endmodule
/*
("    ERROR : fifo_empty is not working.");
("  CORRECT : Not have any error.");
("FIFO FULL : data %h is not input fifo." , data);
("    ERROR : fifo_full is not match to depth.");
("    ERROR : fifo_full is not working.");
("FIFO Empty: no data in fifo.")

("    ERROR : auto check compare result is failed, in memory address : %d." , i);
*/