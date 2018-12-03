/*
 * Black-and-white VGA Framebuffer
 *
 * Stephen A. Edwards, Columbia University
 */

module VGA_framebuffer(
 input logic 	    clk50, reset,
 input logic [10:0] x, y, // Pixel coordinates
 input logic [7:0] pixel_GS,
 input logic pixel_write,
		       
 output logic [7:0] VGA_R, VGA_G, VGA_B,
 output logic 	    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);

/*
 * 640 X 480 VGA timing for a 50 MHz clock: one pixel every other cycle
 * 
 *HCOUNT 1599 0             1279       1599 0
 *            _______________              ________
 * __________|    Video      |____________|  Video
 * 
 * 
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 */

   parameter HACTIVE      = 11'd 1280,
             HFRONT_PORCH = 11'd 32,
             HSYNC        = 11'd 192,
             HBACK_PORCH  = 11'd 96,   
             HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC + HBACK_PORCH; //1600

   parameter VACTIVE      = 10'd 480,
             VFRONT_PORCH = 10'd 10,
             VSYNC        = 10'd 2,
             VBACK_PORCH  = 10'd 33,
             VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC + VBACK_PORCH; //525

   logic [10:0]			     hcount; // Horizontal counter
   logic 			     endOfLine;
   
   always_ff @(posedge clk50 or posedge reset)
     if (reset)          hcount <= 0;
     else
	  if (endOfLine) hcount <= 0;
     else  	         hcount <= hcount + 11'd 1;

   assign endOfLine = hcount == HTOTAL - 1;

   // Vertical counter
   logic [9:0] 			     vcount;
   logic 			     endOfField;
   
   always_ff @(posedge clk50 or posedge reset)
     if (reset)          vcount <= 0;
     else if (endOfLine)
       if (endOfField)   vcount <= 0;
       else              vcount <= vcount + 10'd 1;

   assign endOfField = vcount == VTOTAL - 1;

   // Horizontal sync: from 0x520 to 0x57F
   // 101 0010 0000 to 101 0111 1111
   assign VGA_HS = !( (hcount[10:7] == 4'b1010) & (hcount[6] | hcount[5]));
   assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);

   assign VGA_SYNC_n = 1; // For adding sync to video signals; not used for VGA
   
   // Horizontal active: 0 to 1279     Vertical active: 0 to 479
   // 101 0000 0000  1280	       01 1110 0000  480	       
   // 110 0011 1111  1599	       10 0000 1100  524
   logic 			     blank;
   assign blank = ( hcount[10] & (hcount[9] | hcount[8]) ) |
		  ( vcount[9] | (vcount[8:5] == 4'b1111) );

   // Framebuffer memory: 640 x 480 = 307200 bits

   logic [7:0]  framebuffer[307199:0];
   logic [18:0] 		     read_address, write_address;

   assign write_address = x + (y << 9) + (y << 7) ; // x + y * 640
   assign read_address = (hcount >> 1) + (vcount << 9) + (vcount << 7);

	logic 		 activebuffer;
   logic [7:0] pixel_read;
   
   always_ff @(posedge clk50) begin
		if (pixel_write) framebuffer[write_address] <= pixel_GS;
      if (hcount[0]) begin
        pixel_read <= framebuffer[read_address];
        VGA_BLANK_n <= ~blank; // Keep blank in sync with pixel data
      end
   end
	
	always_ff @(posedge clk50)
		if(reset)
			activebuffer <= 0;
		else if (VGA_VS) // On vertical sync, switch buffers
			activebuffer <= ~activebuffer;
   
   assign VGA_CLK = hcount[0]; // 25 MHz clock: pixel latched on rising edge

   assign VGA_R = pixel_read;
	assign VGA_G = pixel_read;
	assign VGA_B = pixel_read;
   
endmodule

module VGA_framebuffer_testbench();
logic 	    clk50, reset;
logic [10:0] x, y; // Pixel coordinates
logic [7:0]  pixel_GS;
logic			 pixel_write;
		       
logic [7:0]  VGA_R, VGA_G, VGA_B;
logic 	    VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n;

VGA_framebuffer dut (.*);

parameter CLOCK_PERIOD = 20000;
initial begin
	clk50 <= 0;
	forever #(CLOCK_PERIOD/2) clk50 <= ~clk50;
end

initial begin
pixel_write = 0; x = 4; y = 0; reset = 1;
pixel_GS = 8'd127; @(posedge clk50);
pixel_write = 1; reset = 0; @(posedge clk50);
#1000000;
$stop;
end

endmodule