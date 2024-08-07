module pwm_ctrl(
    input wire clk, 
    input wire rst, 
    input wire En, 
    input wire [31:0] Ton, 
    input wire [31:0] Tp, 
    output wire  op, 
    output wire [31:0] cnt_val,
    output wire [31:0] milli_cnt
);


reg [31:0] q_reg, q_next;
reg [31:0] q1_reg, q1_next;
reg [31:0] q2_reg, q2_next;
reg op_r, op_n;

always @(posedge clk, posedge rst)
	if(rst)
		begin
			q_reg <= 0;
			q1_reg <= 0;
			q2_reg <= 0;
			op_r <= 1'b0;
		end
	else
		begin
			q_reg <= q_next;
			q1_reg <= q1_next;
			q2_reg <= q2_next;
			op_r <= op_n;
		end

always @*
begin
    if( (En == 1'b1) && (q_reg < Tp))
        q_next = q_reg + 1;
    else
        q_next = 0;
        
    if(q_reg < Ton && (En == 1'b1))
          op_n <= 1'b1;
    else
          op_n <= 1'b0;
    
    if( q1_reg == 100000)
       q1_next = 0;
    else
       q1_next = q1_reg + 1;
           
    if( q1_reg == 100000)
        q2_next = q2_reg + 1;
    else
        q2_next = q2_reg;      
                       
end

assign op = op_r;
assign cnt_val = q_reg;
assign milli_cnt = q2_reg;


endmodule
