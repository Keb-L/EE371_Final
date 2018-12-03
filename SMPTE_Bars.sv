module SMPTE_Bars(x, y, R, G, B);
input logic [10:0] x, y;
output logic [7:0] R, G, B;

assign R = x < 180 | (x >= 360 & x < 420) ? '1 : '0;
assign G = x < 60  | (x >= 120 & x < 300) ? '1 : '0;
assign B = x < 60  | (x >= 240 & x < 420) ? '1 : '0;

endmodule