module SPI_WRAPPER (
    input  logic clk,
    input  logic rst_n,
    input  logic SS_n,
    input  logic MOSI,
    output logic MISO
);

    // Internal signals
    logic [9:0] rx_data;
    logic       rx_valid;
    logic [7:0] tx_data;
    logic       tx_valid;

    // SPI_SLAVE instantiation
    SPI_SLAVE spi_slave_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .SS_n     (SS_n),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .tx_data  (tx_data),
        .tx_valid (tx_valid),
        .MOSI     (MOSI),
        .MISO     (MISO)
    );

    // RAM instantiation
    RAM ram_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .rx_valid (rx_valid),
        .din      (rx_data),
        .tx_valid (tx_valid),
        .dout     (tx_data)
    );

endmodule
