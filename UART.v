module UART(input clk,rst_n,input uart_rxd,output uart_txd);
wire[7:0] uart_data;
wire uart_done;
//uart_recv U_receive(.sys_clk(clk),.sys_rst_n(rst_n),.uart_rxd(uart_rxd),.uart_data(uart_data),.uart_done(uart_done));
    UART_RX U_RX(.clk(clk),.rst_n(rst_n),.rxd(uart_rxd),.uart_data(uart_data),.rx_done(rx_done));
//uart_send U_send(.sys_clk(clk),.sys_rst_n(rst_n),.uart_en(uart_done),.uart_din(uart_data),.uart_txd(uart_txd));
    UART_TX U_TX(.clk(clk),.rst_n(rst_n),.uart_en(rx_done),.data(uart_data),.uart_tx_data(uart_txd));
	
endmodule 