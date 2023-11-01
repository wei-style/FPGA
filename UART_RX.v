//module uart_recv(input sys_clk,input sys_rst_n,input uart_rxd,output reg[7:0] uart_data,output reg uart_done);

//parameter CLK_FREQ=50_000_000;
//parameter UART_BPS=115200;
//parameter BPS_CNT=CLK_FREQ/UART_BPS;

//reg uart_rxd_d0;
//reg uart_rxd_d1;
//wire start_flag;
//reg rx_flag;
//reg[3:0] rx_cnt;
//reg[15:0]	clk_cnt;
//reg[7:0] rx_data;

//assign start_flag=uart_rxd_d1&(~uart_rxd_d0);
//always@(posedge sys_clk,negedge sys_rst_n)
//begin if(!sys_rst_n)
//	begin 	
//		uart_rxd_d0<=1'b1;
//		uart_rxd_d1<=1'b1;
//	end
//else 
//	begin 
//		uart_rxd_d0<=uart_rxd;
//		uart_rxd_d1<=uart_rxd_d0;
//		end
//end

//always@(posedge sys_clk,negedge sys_rst_n)begin
//if(!sys_rst_n)
//	rx_flag<=1'b0;
//else if(start_flag)
//	rx_flag<=1'b1;
//else if((rx_cnt==4'd9)&&(clk_cnt==BPS_CNT/2-1'b1))
//	rx_flag<=1'b0;
//end

//always@(posedge sys_clk,negedge sys_rst_n)begin
//if(!sys_rst_n)
//	clk_cnt<=16'd0;
//else if(rx_flag) begin
//	       if(clk_cnt<BPS_CNT-1'b1)
//	       clk_cnt<=clk_cnt+1'b1;
//	 else 
//	clk_cnt<=16'd0;
//    end
//end

//always@(posedge sys_clk,negedge sys_rst_n)begin
//if(!sys_rst_n)
//	rx_cnt<=4'b0;
//else if(rx_flag) begin
//	  if(clk_cnt==BPS_CNT-1'b1)
//	         rx_cnt<=rx_cnt+1'b1;
//	 else rx_cnt<=rx_cnt;
//	end
//else rx_cnt<=4'd0;
//end

//always@(posedge sys_clk,negedge sys_rst_n)begin
//if(!sys_rst_n)
//	rx_data<=8'd0;
//else if(rx_flag&&clk_cnt==BPS_CNT/2)begin
//case(rx_cnt)
//    4'd1:rx_data[0]<=uart_rxd_d1;
//    4'd2:rx_data[1]<=uart_rxd_d1;
//    4'd3:rx_data[2]<=uart_rxd_d1;
//    4'd4:rx_data[3]<=uart_rxd_d1;
//    4'd5:rx_data[4]<=uart_rxd_d1;
//    4'd6:rx_data[5]<=uart_rxd_d1;
//    4'd7:rx_data[6]<=uart_rxd_d1;
//    4'd8:rx_data[7]<=uart_rxd_d1;
//    endcase
//    end
//end


//always@(posedge sys_clk,negedge sys_rst_n)begin
//if(!sys_rst_n) begin
//	uart_done<=1'b0;
//	uart_data<=8'd0;
//	end
//else if(rx_cnt==4'd9) begin
//	uart_done<=1'b1;
//	uart_data<=rx_data;
//	end
//else begin
//	uart_done<=1'b0;
//	uart_data<=8'd0;
//	end
//end	

//endmodule






module UART_RX(input clk,rst_n,rxd,output[7:0] uart_data,output  rx_done);
parameter Bit_rate='d115200;
parameter F_clk='d50_000_000;
parameter Number_cnt=F_clk/Bit_rate;

//检测rxd下降沿
reg[1:0] uart_rx_store;
always@(posedge clk)
uart_rx_store<={uart_rx_store[0],rxd};

assign rxd_down=uart_rx_store[1]&(!uart_rx_store[0]);

reg tx_flag;
always@(posedge clk,negedge rst_n)
if(!rst_n||read_done)//接收完成后不再计数
tx_flag<=0;
else if(rxd_down)
tx_flag<=1;


//计数波特率周期
reg[15:0] cnt_clk;
assign add_cnt_clk=tx_flag;
assign end_cnt_clk=(cnt_clk==Number_cnt-1)&&add_cnt_clk;
always@(posedge clk,negedge rst_n)
if(~rst_n|end_cnt_clk|!tx_flag)
cnt_clk<=0;
else if(add_cnt_clk)
cnt_clk<=cnt_clk+1;

//计数传输的位数
reg[3:0] cnt_bit;
assign add_cnt_bit=end_cnt_clk;
assign end_cnt_bit=(cnt_bit==10-1)&&add_cnt_bit;//1位起始位，8位数据位，1位结束位，一共10位
always@(posedge clk,negedge rst_n)
if(~rst_n|end_cnt_bit|!tx_flag)
cnt_bit<=0;
else if(add_cnt_bit)
cnt_bit<=cnt_bit+1;

//定义接受结束标志read_done
assign read_done=(cnt_bit==9)&(cnt_clk==Number_cnt/2);//停止位的中间，产生传输结束信号
assign rx_done=(cnt_bit==9)&&(cnt_clk<Number_cnt/2);
//assign rx_done=read_done;

//接收数据
reg[7:0] datastore;
always@(posedge clk,negedge rst_n)
if(!rst_n)
begin datastore<=0;
end
else if(tx_flag&(cnt_clk==Number_cnt/2))
case(cnt_bit)
0:datastore<=0;
1:datastore[7]<=rxd;
2:datastore[6]<=rxd;
3:datastore[5]<=rxd;
4:datastore[4]<=rxd;
5:datastore[3]<=rxd;
6:datastore[2]<=rxd;
7:datastore[1]<=rxd;
8:datastore[0]<=rxd;
9:datastore<=0;
endcase

assign uart_data=(cnt_bit==9)&&(cnt_clk<Number_cnt/2)?datastore[7:0]:0;


endmodule 