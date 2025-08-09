vlib work
vlog RAM.v SPI_SLAVE.v SPI_WRAPPER.v SPI_WRAPPER_tb.v
vsim -voptargs=+acc work.SPI_WRAPPER_tb
add wave -position insertpoint  \
sim:/SPI_WRAPPER_tb/clk \
sim:/SPI_WRAPPER_tb/rst_n \
sim:/SPI_WRAPPER_tb/SS_n \
sim:/SPI_WRAPPER_tb/MOSI \
sim:/SPI_WRAPPER_tb/MISO \
sim:/SPI_WRAPPER_tb/uut/spi_slave_inst/tx_valid \
sim:/SPI_WRAPPER_tb/uut/spi_slave_inst/rx_valid \
sim:/SPI_WRAPPER_tb/uut/spi_slave_inst/rx_data \
sim:/SPI_WRAPPER_tb/uut/spi_slave_inst/tx_data
run -all