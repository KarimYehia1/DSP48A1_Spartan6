module DSP48A1(A, B, D, C, CLK, CARRYIN, OPMODE, BCIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD,
               RSTCARRYIN, RSTOPMODE, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE, PCIN, 
               PCOUT, BCOUT, P, M, CARRYOUT, CARRYOUTF);
parameter A0REG = 0, B0REG = 0;
parameter A1REG = 1, B1REG = 1, CREG = 1, DREG = 1, MREG = 1, PREG = 1, CARRYINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1;
parameter CARRYINSEL = "OPMODE5"; //valid values are "OPMODE5" & "CARRYIN"
parameter B_INPUT = "DIRECT"; // valid values are "DIRECT" & "CASCADE"
parameter RSTTYPE = "SYNC"; // valid values are "SYNC" & "ASYNC"
input [17:0] A, B, D, BCIN;
input [47:0] C, PCIN;
input [7:0] OPMODE;
input CLK, CARRYIN, RSTA, RSTB, RSTC, RSTM, RSTP, RSTD, RSTCARRYIN, RSTOPMODE;
input CEA, CEB, CEC, CEM, CEP, CED, CECARRYIN, CEOPMODE;
output [17:0] BCOUT;
output [47:0] PCOUT, P;
output [35:0] M;
output CARRYOUT, CARRYOUTF;

// First Stage 
wire [17:0] d_reg_out;
reg_mux #(.N(18), .RSTTYPE(RSTTYPE)) D_REGISTER(CLK, CED, DREG, D, RSTD, d_reg_out);

wire [17:0] b0_reg_in;
wire [17:0] b0_reg_out;
assign b0_reg_in = (B_INPUT == "DIRECT") ? B : BCIN;
reg_mux #(.N(18), .RSTTYPE(RSTTYPE)) B0_REGISTER(CLK, CEB, B0REG, b0_reg_in, RSTB, b0_reg_out);

wire [17:0] a0_reg_out;
reg_mux #(.N(18), .RSTTYPE(RSTTYPE)) A0_REGISTER(CLK, CEA, A0REG, A, RSTA, a0_reg_out);

wire [47:0] c_reg_out;
reg_mux #(.N(48), .RSTTYPE(RSTTYPE)) C_REGISTER(CLK, CEC, CREG, C, RSTC, c_reg_out);

// opcode stages 
wire op6_out;
reg_mux #(.N(1), .RSTTYPE(RSTTYPE)) OP6_REGISTER(CLK, CEOPMODE, OPMODEREG, OPMODE[6], RSTOPMODE, op6_out);

wire op4_out;
reg_mux #(.N(1), .RSTTYPE(RSTTYPE)) OP4_REGISTER(CLK, CEOPMODE, OPMODEREG, OPMODE[4], RSTOPMODE, op4_out);

wire op5_out;
reg_mux #(.N(1), .RSTTYPE(RSTTYPE)) OP5_REGISTER(CLK, CEOPMODE, OPMODEREG, OPMODE[5], RSTOPMODE, op5_out);

wire op7_out;
reg_mux #(.N(1), .RSTTYPE(RSTTYPE)) OP7_REGISTER(CLK, CEOPMODE, OPMODEREG, OPMODE[7], RSTOPMODE, op7_out);

wire [1:0] op1to0_out;
reg_mux #(.N(2), .RSTTYPE(RSTTYPE)) OP1TO0_REGISTER(CLK, CEOPMODE, OPMODEREG, OPMODE[1:0], RSTOPMODE, op1to0_out);

wire [1:0] op3to2_out;
reg_mux #(.N(2), .RSTTYPE(RSTTYPE)) OP3TO2_REGISTER(CLK, CEOPMODE, OPMODEREG, OPMODE[3:2], RSTOPMODE, op3to2_out);

// second stage
wire [17:0] pre_add_substract;
assign pre_add_substract = (op6_out) ? (d_reg_out - b0_reg_out) : (d_reg_out + b0_reg_out);

wire [17:0] b1_reg_in;
assign b1_reg_in = (op4_out) ? (pre_add_substract) : (b0_reg_out);

wire [17:0] b1_reg_out;
reg_mux #(.N(18), .RSTTYPE(RSTTYPE)) B1_REGISTER(CLK, CEB, B1REG, b1_reg_in, RSTB, b1_reg_out);

wire [17:0] a1_reg_out;
reg_mux #(.N(18), .RSTTYPE(RSTTYPE)) A1_REGISTER(CLK, CEA, A1REG, a0_reg_out, RSTA, a1_reg_out);

assign BCOUT = b1_reg_out;

wire [35:0] m_reg_in, m_reg_out;
assign m_reg_in = a1_reg_out * b1_reg_out;
reg_mux #(.N(36), .RSTTYPE(RSTTYPE)) M_REGISTER(CLK, CEM, MREG, m_reg_in, RSTM, m_reg_out);
assign M = m_reg_out;

wire cyi_in, CIN;
assign cyi_in = (CARRYINSEL == "OPMODE5") ? op5_out : CARRYIN;
reg_mux #(.N(1), .RSTTYPE(RSTTYPE)) CYI_REGISTER(CLK, CECARRYIN, CARRYINREG, cyi_in, RSTCARRYIN, CIN);

// X & Z multiplexers
// X mux
wire [47:0] X, Z;
assign X = (op1to0_out == 3) ? ({d_reg_out[11:0], a1_reg_out, b1_reg_out}) :
                        (op1to0_out == 2) ? (P) :
                        (op1to0_out == 1) ? ({{12{1'b0}}, m_reg_out}) : 
                        0;
assign Z = (op3to2_out == 3) ? (c_reg_out) :
           (op3to2_out == 2) ? (P) :
           (op3to2_out == 1) ? (PCIN) : 
             0;   
wire [47:0] post_add_sub_out;
wire cyo_in;
assign {cyo_in, post_add_sub_out} = (op7_out) ? (Z - (X + CIN)) : (Z + X + CIN);

reg_mux #(.N(48), .RSTTYPE(RSTTYPE)) P_REGISTER(CLK, CEP, PREG, post_add_sub_out, RSTP, P);
assign PCOUT = P;

reg_mux #(.N(1), .RSTTYPE(RSTTYPE)) CYO_REGISTER(CLK, CECARRYIN, CARRYOUTREG, cyo_in, RSTCARRYIN, CARRYOUT);
assign CARRYOUTF = CARRYOUT;

endmodule