module spi_ctrl
(
    //
    input wire i_clk,
    input wire i_rst,
    input wire i_en,
    input wire i_miso,
    //
    output wire o_spi_clk,
    output wire o_spi_cs_n,
    output wire [15:0] o_data,
    output wire o_status

);

// parameter declaration
localparam N = 5; // No of bits for shift register
localparam K = 16;
//localparam CLK_DIV = 11;

// state declaration
localparam [1:0] START   = 2'b00,
                 RECEIVE = 2'b01,
                 STOP    = 2'b10;

                 
// signal declaration
reg [N-1:0] bit_count_r, bit_count_n;
reg [1:0] state_r, state_n;
reg sts_n, sts_r;
reg [K-1:0] data_r, data_n;
reg [K-1:0] clk_cnt_r;
reg [K-1:0] clk_cnt_n;
reg data_latch_n, data_latch_r;
reg spi_cs_n,spi_cs_r;


always @(posedge i_clk, posedge i_rst)
    if (i_rst)
        begin
            state_r     <= START;
            bit_count_r <= 0;
            data_r      <= 0;
            clk_cnt_r   <= 0;
            sts_r       <= 1'b0;
            data_latch_r <= 1'b0;
            spi_cs_r   <= 1'b0;
        end
    else
        begin
            state_r     <= state_n;
            bit_count_r <= bit_count_n;
            data_r      <= data_n;
            clk_cnt_r   <= clk_cnt_n;
            sts_r       <= sts_n;
            data_latch_r <= data_latch_n;
            spi_cs_r <= spi_cs_n;
        end
/*    
always @*
    begin
        if(clk_cnt_r < 128) begin
            clk_cnt_n <= 0;
        end
        else begin
            clk_cnt_n <= clk_cnt_r + 1;
        end
        
        if(clk_cnt_r < 11) begin
            clk_cnt_n <= clk_cnt_r + 1;
        end
        else begin
            clk_cnt_n <= clk_cnt_r;
        end
        
        
    end
*/
always @*
     if(i_en == 1'b1) begin
        clk_cnt_n = clk_cnt_r + 1;
     end
     else
        clk_cnt_n = 0;
        
//assign data_latch_cnt = {clk_cnt_r[6:0]};

always @*
    if((clk_cnt_r > 63) && (clk_cnt_r[6:0] == 7'b0001010))
        data_latch_n <= 1'b1;
    else
        data_latch_n <= 1'b0;    

    
always @*
    begin
        sts_n       = sts_r;
        state_n     = state_r;
        bit_count_n = bit_count_r;
        data_n      = data_r;
        spi_cs_n <= spi_cs_r;
        
        case (state_r)
            START : begin
                sts_n = 1'b0;
                bit_count_n = 0;
                
                if(i_en == 1'b1) begin
                    state_n = RECEIVE;
                    spi_cs_n = 1'b1;
                  end  
                else begin
                    state_n = START;
                    spi_cs_n = 1'b0;
                  end  
            end
            
            RECEIVE : begin
               
                if(bit_count_r == 15) begin
                    state_n = STOP;
                    sts_n   = 1'b1;
                    spi_cs_n = 1'b0;
                end
                else begin
                    state_n = RECEIVE;
                    sts_n   = 1'b0;
                    spi_cs_n = 1'b1;
                end
    
                if(data_latch_r == 1'b1) begin
                    bit_count_n = bit_count_r + 1;
                    data_n      = {data_r[K-2:0], i_miso};
                    
                end
                else begin
                    bit_count_n = bit_count_r;
                    data_n      = data_r;
                end
                
            end
            
            STOP : begin
            
                sts_n   = 1'b1;
                state_n = START;
            
            end
            
            default : state_n = START;
        
        endcase
    end

// output    
assign o_spi_clk = {clk_cnt_r[6]};
assign o_status = sts_r;
assign o_data = data_r;
assign o_spi_cs_n = ~(spi_cs_r);
endmodule


    
    
    
    
    
    
    
    
    
    
