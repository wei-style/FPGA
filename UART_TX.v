//module uart_send(input sys_clk,input sys_rst_n,input uart_en,input[7:0] uart_din,output reg uart_txd);
//parameter CLK_FREQ=50_000_000;
//parameter UART_BPS=115200;
//parameter BPS_CNT=CLK_FREQ/UART_BPS;

//reg uart_en_d0;
//reg uart_en_d1;
//wire en_flag;
//reg tx_flag;
//reg[3:0] tx_cnt;
//reg[15:0]	clk_cnt;
//reg[7:0] tx_data;

//assign en_flag=uart_en_d0&(~uart_en_d1);
//always@(posedge sys_clk,negedge sys_rst_n)
//if(!sys_rst_n)
//	begin 	
//		uart_en_d0<=1'b0;
//		uart_en_d1<=1'b0;
//	end
//else 
//	begin 
//		uart_en_d0<=uart_en;
//		uart_en_d1<=uart_en_d0;
//		end

//always@(posedge sys_clk,negedge sys_rst_n)
//if(!sys_rst_n) begin
//	tx_data<=8'b0;
//	end
//else if(en_flag) begin
//	tx_data<=uart_din;
//	end
//else begin
//	tx_data<=tx_data;
//	end


//always@(posedge sys_clk,negedge sys_rst_n)
//if(!sys_rst_n)
//	tx_flag<=1'b0;
//else if(en_flag)
//	tx_flag<=1'b1;
//else if((tx_cnt==4'd9)&&(clk_cnt==BPS_CNT/2-1'b1))
//	tx_flag<=1'b0;

//always@(posedge sys_clk,negedge sys_rst_n)
//if(!sys_rst_n)
//	clk_cnt<=16'd0;
//else if(tx_flag) begin
//	if(clk_cnt<BPS_CNT-1'b1)
//	clk_cnt<=clk_cnt+1'b1;
//	else 
//	clk_cnt<=16'd0;
//end

//always@(posedge sys_clk,negedge sys_rst_n)
//if(!sys_rst_n)
//	tx_cnt<=4'd0;
//else if(tx_flag) begin
//	if(clk_cnt==BPS_CNT-1'b1)
//	tx_cnt<=tx_cnt+1'b1;
//	else tx_cnt<=tx_cnt;
//	               end
//else tx_cnt<=4'd0;


//always@(posedge sys_clk,negedge sys_rst_n)
//if(!sys_rst_n)
//	uart_txd<=1'b1;
//else if(tx_flag&&clk_cnt==16'd0)
//case(tx_cnt)
//4'd0:uart_txd<=1'b0;
//4'd1:uart_txd<=tx_data[0];
//4'd2:uart_txd<=tx_data[1];
//4'd3:uart_txd<=tx_data[2];
//4'd4:uart_txd<=tx_data[3];
//4'd5:uart_txd<=tx_data[4];
//4'd6:uart_txd<=tx_data[5];
//4'd7:uart_txd<=tx_data[6];
//4'd8:uart_txd<=tx_data[7];
//4'd9:uart_txd<=1'b1;
//endcase


//endmodule




 module UART_TX(input clk,rst_n,uart_en,input [7:0] data,output reg uart_tx_data);

parameter Bit_rate='d115200;
parameter F_clk='d50_000_000;
parameter Number_cnt=F_clk/Bit_rate;

//uart_en上升沿检测
reg[1:0] uart_en_store;
always@(posedge clk)
uart_en_store<={uart_en_store[0],uart_en};

assign uart_en_up=uart_en_store[0]&(!uart_en_store[1]);
 
//上升沿到来后将数据寄存起来
reg[7:0] data_temp;
always@(posedge clk,negedge rst_n)
if(!rst_n)
data_temp<=0;
else if(uart_en_up)
data_temp<=data;
else data_temp<=data_temp;


reg tx_flag;
always@(posedge clk,negedge rst_n)
if(!rst_n||send_done)//发送完成后不再计数
tx_flag<=0;
else if(uart_en_up)
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
 
//定义传输结束标志send_done
assign send_done=(cnt_bit==9)&(cnt_clk==Number_cnt/2);//停止位的中间，产生传输结束信号


//接收数据
reg[7:0] datastore;
always@(posedge clk,negedge rst_n)
if(!rst_n)
begin uart_tx_data<=1;
end
else if(tx_flag&(cnt_clk==0))//发送完一个数据后立刻发送下一个数据，不用等待稳定
case(cnt_bit)
0:uart_tx_data<=0;
1:uart_tx_data<=data_temp[7];
2:uart_tx_data<=data_temp[6];
3:uart_tx_data<=data_temp[5];
4:uart_tx_data<=data_temp[4];
5:uart_tx_data<=data_temp[3];
6:uart_tx_data<=data_temp[2];
7:uart_tx_data<=data_temp[1];
8:uart_tx_data<=data_temp[0];
9:uart_tx_data<=1;
endcase


 
endmodule 