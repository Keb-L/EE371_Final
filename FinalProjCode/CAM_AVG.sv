module CAM_AVG 
#(parameter frame_max = 30,
			pixel_max = 307200)
(
	input VGA_CLK, 
	input RST_N,
	input [7:0] pixel,
	output [7:0] color,
	output upd
);

reg [31:0] r_acc, r_counter;
reg [7:0] r_color;
reg [7:0] r_frame; 
reg r_upd;

assign upd = r_upd;
assign color = r_color;

wire [31:0] avg;
assign avg = (r_acc + pixel) / (r_counter + 1);

always_ff @(posedge VGA_CLK) begin
	if(~RST_N) begin
		r_acc <= 0;
		r_counter <= 0;
		r_frame <= 0;
		r_color <= 0;
		r_upd <= 0;
	end

	else begin
		if(r_counter + 1 == pixel_max) begin
			r_acc <= 0;
			r_counter <= 0;
			
			if(r_frame + 1 == frame_max) begin
				r_color <= avg;
				r_upd <= ~r_upd;
				r_frame <= 0;
			end
			else begin
				r_frame <= r_frame + 1;
			end
		end 
		else begin
			r_acc <= r_acc + pixel;
			r_counter <= r_counter + 1;
		end
	end
end
endmodule

module CAM_AVG_testbench();
logic VGA_CLK;
logic RST_N;
logic [7:0] pixel;
logic [7:0] color;
logic upd;

CAM_AVG #(2, 10) dut (.*);

parameter CLOCK_PERIOD = 20000;
initial begin
	VGA_CLK <= 0;
	forever #(CLOCK_PERIOD/2) VGA_CLK <= ~VGA_CLK;
end

int i;
initial begin
	RST_N = 0; @(posedge VGA_CLK);
	RST_N = 1; @(posedge VGA_CLK);

	for(i = 0; i < 1000; i++) begin
		pixel = i + 200; @(posedge VGA_CLK);
	end	
 
	#(CLOCK_PERIOD * 10);
	$stop;
end

endmodule

//	else if(~V_SYNC) begin
//		r_acc <= 0;
//		r_counter <= 1;	
//		
//		if(r_time > (32'h017D_7840 >> 2) ) begin
//			r_time <= 0;
//			r_color <= r_acc / (r_counter - 1);
//			r_upd <= ~r_upd;
//		end
//		else begin
//			r_time <= r_time + 1;
//		end
//		// once every 30 frames
//		if (r_frame + 1 == 8'd60) begin
//			r_color <= r_acc / (r_counter - 1);
//			r_frame <= 0;
//			r_upd <= ~r_upd;
//		end
//		else begin
//			r_frame <= r_frame + 1;
//		end
//	end