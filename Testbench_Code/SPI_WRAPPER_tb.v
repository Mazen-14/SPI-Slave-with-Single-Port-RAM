module SPI_WRAPPER_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg SS_n;
    reg MOSI;
    wire MISO;


    // Instantiate SPI_WRAPPER
    SPI_WRAPPER uut (
        .clk(clk),
        .rst_n(rst_n),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .MISO(MISO)
    );


    // Internal signals for self checking
    reg [7:0] address;
    reg [7:0] data;
    reg [7:0] read_data;


    // Clock generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end


    integer i;
    initial begin
        $readmemh("mem.dat",uut.ram_inst.mem);

        repeat(1000)begin
            // rst check
            rst_n = 0;
            MOSI = 0;
            address = 0;
            data = 0;
            read_data = 0;
            @(negedge clk);
            if (MISO!=0) begin
                $display("rst check failed");
                $stop;
            end 
            else 
                $display("rst check passed");

            rst_n = 1;
            //Write Address check
            SS_n = 0;
            @(negedge clk);
            // CHK_CMD
            MOSI = 0;
            repeat(3)@(negedge clk);
            // receive wr_address
            for(i=7;i>=0;i=i-1)begin
                MOSI = $random;
                address[i] = MOSI;
                @(negedge clk);
            end
            SS_n = 1;
            @(negedge clk);
            // IDLE
            if (uut.ram_inst.addr != address) begin
                $display("write address check failed");
                $stop;
            end 
            else 
                $display("write address check passed");


            //Write Data check
            SS_n = 0;
            @(negedge clk);
            // CHK_CMD
            MOSI = 0;
            repeat(2)@(negedge clk);
            MOSI = 1;
            @(negedge clk);
            // Receive wr_data
            for(i=7;i>=0;i=i-1)begin
                MOSI = $random;
                data[i] = MOSI;
                @(negedge clk);
            end
            SS_n = 1;
            @(negedge clk);
            // IDLE
            if (uut.ram_inst.mem[address] != data) begin
                $display("write data check failed");
                $stop;
            end 
            else 
                $display("write data check passed");


        //Read Address check
            SS_n = 0;
            @(negedge clk);
            // CHK_CMD
            MOSI = 1;
            repeat(2)@(negedge clk);
            MOSI = 0;
            @(negedge clk);
            // send rd_address
            for(i=7;i>=0;i=i-1)begin
                MOSI = address[i];
                @(negedge clk);
            end
            SS_n = 1;
            @(negedge clk);
            // IDLE
            if (uut.ram_inst.addr != address) begin
                $display("read address check failed");
                $stop;
            end 
            else 
                $display("read address check passed");


            //Read Data check
            SS_n = 0;
            @(negedge clk);
            // CHK_CMD
            MOSI = 1;
            repeat(3)@(negedge clk);
            // read dumy 8 bits 
            repeat(8)begin
                @(negedge clk);
            end
            // read rd_data
            repeat(2)@(negedge clk);
            for(i=7;i>=0;i=i-1)begin
                read_data[i] = MISO;
                @(negedge clk);
            end
            SS_n = 1;
            @(negedge clk);
            // IDLE
            if (read_data != uut.ram_inst.mem[address]) begin
                $display("read data check failed");
                $stop;
            end 
            else 
                $display("read data check passed");

        end
        $stop;
    end

endmodule