module dsp_unit_tb();
reg [17:0] A, B, D, BCIN;
reg [47:0] C, PCIN;
reg [7:0] OPMODE;
reg CLK, CARRYIN, RSTA, RSTB, RSTC, RSTM, RSTP, RSTD, RSTCARRYIN, RSTOPMODE;
reg CEA, CEB, CEC, CEM, CEP, CED, CECARRYIN, CEOPMODE;
wire [17:0] BCOUT;
wire [47:0] PCOUT, P;
wire [35:0] M;
wire CARRYOUT, CARRYOUTF;

DSP48A1 dut(A, B, D, C, CLK, CARRYIN, OPMODE, BCIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD,
               RSTCARRYIN, RSTOPMODE, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE, PCIN, 
               PCOUT, BCOUT, P, M, CARRYOUT, CARRYOUTF);
initial begin
    CLK = 0;
   forever #1 CLK = ~CLK;
end

initial begin
    RSTA = 1; RSTB = 1; RSTC = 1; RSTCARRYIN = 1; RSTM = 1; RSTP = 1; RSTD = 1; RSTOPMODE = 1;
    A = $random; B = $random; D = $random; BCIN = $random; 
    C = $random; PCIN = $random;
    OPMODE = $random;
    CEA = $random; CEB = $random; CEC = $random; CEM = $random; CEP = $random; CED = $random;
    CECARRYIN = $random; CEOPMODE = $random; CARRYIN = $random;
    @(negedge CLK);
    // path1 test
    RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0; RSTM = 0; RSTP = 0; RSTD = 0; RSTOPMODE = 0;
    CEA = 1; CEB = 1; CEC = 1; CEM = 1; CEP = 1; CED = 1; CECARRYIN = 1; CEOPMODE = 1;
    OPMODE = 8'b11011101;
    A = 20; B = 10; C = 350; D = 25;
    BCIN = $random; PCIN = $random; CARRYIN = $random;
    repeat(4) @(negedge CLK);
    if((BCOUT != 18'hf) || (M != 36'h12c) || (P != 48'h32) || (CARRYOUT != 0)) begin
      $display("Error");
      $stop;
    end
    //path2 test
    OPMODE = 8'b00010000;
    repeat(3) @(negedge CLK);
    if((BCOUT != 18'h23) || (M != 36'h2bc) || (P != 0) || (CARRYOUT != 0)) begin
      $display("Error");
      $stop;
    end
    //path3 test
    OPMODE = 8'b00001010;
    repeat(3) @(negedge CLK);
    if((BCOUT != 18'ha) || (M != 36'hc8) || (P != PCOUT) || (CARRYOUT != CARRYOUTF)) begin
      $display("Error");
      $stop;
    end
    //path4 test
    OPMODE = 8'b10100111;
    A = 5; B = 6; C = 350; D = 25; PCIN = 3000;
    repeat(3) @(negedge CLK);
    if((BCOUT != 18'h6) || (M != 36'h1e) || (P != 48'hfe6fffec0bb1) || (CARRYOUT != 1)) begin
      $display("Error");
      $stop;
    end
    $stop;
    end
endmodule 