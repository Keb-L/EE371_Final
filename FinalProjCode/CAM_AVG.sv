module CAM_AVG (
	input VGA_CLK,
	input V_SYNC, 
	input RST_N,
	input [7:0] pixel,
	output [7:0] color,
	output upd
);

reg [31:0] r_acc, r_counter;
reg [7:0] r_color;
reg [7:0] r_frame; 
reg [31:0] r_time;
reg r_upd;

assign upd = r_upd;
assign color = r_color;

always_ff @(negedge V_SYNC) begin
	if(r_frame + 1  == 8'd1) begin
		r_frame <= 0;
		r_color <= r_acc / (r_counter - 1);  
	end
	else begin
		r_frame <= r_frame + 1;
	end
	r_upd <= ~r_upd;
end

always_ff @(posedge VGA_CLK) begin
	if(~RST_N) begin
		r_acc <= 0;
		r_counter <= 1;
//		r_frame <= 0;
//		r_color <= 0;
//		r_upd <= 0;
		r_time <= 0;
	end
	else if(~V_SYNC) begin
		r_acc <= 0;
		r_counter <= 1;	
		
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
	end
	else begin
		r_acc <= r_acc + pixel;
		r_counter <= r_counter + 1;
//		r_color <= r_color;
//		r_frame <= r_frame;
		r_time <= r_time + 1;
	end
end
endmodule

module CAM_AVG_testbench();
logic VGA_CLK;
logic RST_N, V_SYNC;
logic [7:0] pixel;
logic [7:0] color;
logic upd;

CAM_AVG dut (.*);

parameter CLOCK_PERIOD = 20000;
initial begin
	VGA_CLK <= 0;
	forever #(CLOCK_PERIOD/2) VGA_CLK <= ~VGA_CLK;
end

int i;
initial begin
	RST_N = 0; @(posedge VGA_CLK);
	RST_N = 1; @(posedge VGA_CLK);
	V_SYNC = 1; pixel = 0; 		@(posedge VGA_CLK);
	V_SYNC = 0; pixel = 200; 	@(posedge VGA_CLK);
	V_SYNC = 1;  					@(posedge VGA_CLK);
	#(CLOCK_PERIOD*100);		@(posedge VGA_CLK);
	V_SYNC = 0;					 	@(posedge VGA_CLK);
	V_SYNC = 1; 
	for(i = 0; i < 100; i++) begin
		pixel = i + 200; @(posedge VGA_CLK);
	end	
	
	V_SYNC = 0;					 	@(posedge VGA_CLK);
	V_SYNC = 1; 
	for(i = 0; i < 100; i++) begin
		pixel = i; @(posedge VGA_CLK);
	end	
	
	V_SYNC = 0;					 	@(posedge VGA_CLK);
	V_SYNC = 1;						@(posedge VGA_CLK);
	$stop;
end

endmodule