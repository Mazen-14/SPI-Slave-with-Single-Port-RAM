module RAM #(
    parameter int MEM_WIDTH = 8,
    parameter int MEM_DEPTH = 256,
    parameter int ADDR_SIZE = 8
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   rx_valid,
    input  logic [9:0]              din,
    output logic                   tx_valid,
    output logic [MEM_WIDTH-1:0]   dout
);

    logic [ADDR_SIZE-1:0] addr;
    logic [MEM_WIDTH-1:0] mem [MEM_DEPTH];
    typedef enum logic [1:0] {
        SET_ADDR  = 2'b00,
        WRITE     = 2'b01,
        LOAD_ADDR = 2'b10,
        READ      = 2'b11
    } cmd_t;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            dout     <= '0;
            tx_valid <= 1'b0;
            addr     <= '0;
        end 
        else if (rx_valid) begin
            case (cmd_t'(din[9:8]))
                SET_ADDR: begin
                    addr     <= din[7:0];
                    tx_valid <= 1'b0;
                end
                WRITE: begin
                    mem[addr] <= din[7:0];
                    tx_valid  <= 1'b0;
                end
                LOAD_ADDR: begin
                    addr     <= din[7:0];
                    tx_valid <= 1'b0;
                end
                READ: begin
                    dout     <= mem[addr];
                    tx_valid <= 1'b1;
                end
                default: begin
                    addr       <= '0;
                    mem[addr]  <= '0;
                    tx_valid   <= 1'b0;
                end
            endcase
        end
    end

endmodule
