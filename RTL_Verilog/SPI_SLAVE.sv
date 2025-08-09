module SPI_SLAVE (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        SS_n,
    input  logic        MOSI,
    input  logic        tx_valid,
    input  logic [7:0]  tx_data,
    output logic        MISO,
    output logic        rx_valid,
    output logic [9:0]  rx_data
);
    typedef enum logic [2:0] {
        IDLE       = 3'b000,
        CHK_CMD    = 3'b001,
        WRITE      = 3'b010,
        READ_ADD   = 3'b011,
        READ_DATA  = 3'b100
    } state_t;

    logic [9:0]   data;
    state_t       cs, ns;
    logic         read_state;
    logic [4:0]   counter;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            cs         <= IDLE;
            read_state <= 1'b0;
        end 
        else begin
            cs <= ns;
            if ((cs == READ_ADD || cs == READ_DATA) && SS_n)
                read_state <= ~read_state;
        end
    end

    always_comb begin
        ns = cs; 
        unique case (cs)
            IDLE:      ns = SS_n ? IDLE : CHK_CMD;
            CHK_CMD:   if (SS_n) ns = IDLE;
                       else if (!MOSI)        ns = WRITE;
                       else if (!read_state)  ns = READ_ADD;
                       else                   ns = READ_DATA;
            WRITE:     ns = SS_n ? IDLE : WRITE;
            READ_ADD:  ns = SS_n ? IDLE : READ_ADD;
            READ_DATA: ns = SS_n ? IDLE : READ_DATA;
            default:   ns = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            rx_valid <= 1'b0;
            counter  <= '0;
            MISO     <= 1'b0;
            data     <= '0;
        end 
        else begin
            case (cs)
                IDLE: begin
                    rx_valid <= 1'b0;
                    counter  <= '0;
                end

                WRITE: begin
                    counter            <= counter + 1;
                    data[9-counter]    <= MOSI;
                    rx_valid           <= (counter == 9);
                end

                READ_ADD: begin
                    counter            <= counter + 1;
                    data[9-counter]    <= MOSI;
                    rx_valid           <= (counter == 9);
                end

                READ_DATA: begin
                    if (!tx_valid) begin
                        if (counter == 10) counter <= '0;
                        else if (counter < 10 && !rx_valid) begin
                            counter         <= counter + 1;
                            data[9-counter] <= MOSI;
                            rx_valid        <= (counter == 9);
                        end
                    end
                    else begin 
                        if (counter == 8) counter <= '0;
                        else if (counter < 8) begin
                            counter <= counter + 1;
                            MISO    <= tx_data[7-counter];
                            rx_valid <= 1'b0;
                        end
                    end
                end
            endcase
        end
    end
    assign rx_data = (rx_valid) ? data : rx_data;

endmodule
