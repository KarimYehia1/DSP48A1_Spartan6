module reg_mux(clk, clk_enable, s, d, rst, out);
parameter N = 1, RSTTYPE = "SYNC";
input clk, clk_enable, rst, s;
input [N-1:0] d;
output [N-1:0] out;

reg [N-1:0] out_reg;

generate
    if(RSTTYPE == "SYNC") begin
        always @(posedge clk) begin
            if(rst)
                out_reg <= 0;
            else if(clk_enable)
                out_reg <= d;
            end
    end

    else if(RSTTYPE == "ASYNC") begin
      always @(posedge clk or posedge rst) begin
            if(rst)
                out_reg <= 0;
            else if(clk_enable)
                out_reg <= d;
        end
    end     
endgenerate

assign out = s ? out_reg : d;
endmodule