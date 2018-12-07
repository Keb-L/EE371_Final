
module	VGA_Controller(	
      input	    		   iCLK,
      input	    	   	iRST_N,
      input	    [7:0]	iGray,
		input 	 [10:0]	iX, iY,
		input					wr_en,
      output      		oRequest,
      output		[7:0]	oVGA_R,
      output		[7:0]	oVGA_G,
      output		[7:0]	oVGA_B,
      output				oVGA_H_SYNC,
      output				oVGA_V_SYNC,
      output				oVGA_SYNC,
      output				oVGA_BLANK,
      output	reg		[12:0]		H_Cont,
      output	reg		[12:0]		V_Cont,
		output		[9:0] VGA_X, VGA_Y
		);

//=======================================================
// REG/WIRE declarations
//=======================================================
parameter H_MARK   = 17;//MAX 17
parameter H_MARK1  = 10;//MAX 10
parameter V_MARK   = 9; //MAX 9
`include "VGA_Param.h"

//=======================================================
// Structural coding
//=======================================================

																  
//---h 								  
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
	end
	else
	begin
		if (H_Cont < H_SYNC_TOTAL)
			H_Cont	<=	H_Cont+1;
		else
			H_Cont	<=	0;
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
	end
	else
	begin
		if (H_Cont == 0)
		begin
			if( V_Cont < V_SYNC_TOTAL )
				V_Cont	 <=	V_Cont+1;
			else
				V_Cont	<=	0;
		end
	end
end

//reg [7:0] framebuffer[0];
logic [7:0]  framebuffer[307199:0];
wire [18:0] 		     read_address, write_address;
wire [12:0] h_ptr, y_ptr;

assign h_ptr = (H_Cont >= H_BLANK) ? H_Cont - H_BLANK : '0;
assign v_ptr = (V_Cont >= V_BLANK) ? V_Cont - V_BLANK : '0;

assign VGA_X = h_ptr;
assign VGA_Y = v_ptr;

assign write_address = iX + (iY << 9) + (iY << 7) ; // x + y * 640
assign read_address = h_ptr + (v_ptr << 9) + (v_ptr << 7);

logic [7:0] pixel_read;
   
always @(posedge iCLK) begin
	if (wr_en) framebuffer[write_address] <= iGray;
	pixel_read <= framebuffer[read_address];
end


//---output 
assign oVGA_BLANK	=   ~((H_Cont < H_BLANK ) || ( V_Cont < V_BLANK ));
assign oVGA_H_SYNC =	( ( H_Cont > (H_SYNC_FRONT-H_MARK1 ) )  &&  ( H_Cont <= (H_SYNC_CYC + H_SYNC_FRONT-H_MARK1)))?0 :1 ; 
assign oVGA_V_SYNC =	( ( V_Cont > (V_SYNC_FRONT ) )  &&  ( V_Cont <= (V_SYNC_CYC + V_SYNC_FRONT)))?0 :1 ; 
//assign oVGA_H_SYNC =	( ( H_Cont > (H_SYNC_BACK ) )  &&  ( H_Cont <= (H_SYNC_CYC + H_SYNC_BACK)))?0 :1 ; 
//assign oVGA_V_SYNC =	( ( V_Cont > (V_SYNC_BACK ) )  &&  ( V_Cont <= (V_SYNC_CYC + V_SYNC_BACK)))?0 :1 ; 




assign oRequest    = (  H_Cont >=  X_START+H_MARK  &&  H_Cont< X_START+H_SYNC_ACT +H_MARK 
							  &&
							   V_Cont >=  Y_START+V_MARK && V_Cont< Y_START + V_SYNC_ACT + V_MARK)?1:0 ; 
								  
                  
assign	oVGA_SYNC =	 1'b0   ;
assign	oVGA_R	 =	 oVGA_BLANK ?	iGray	   :	0;
assign	oVGA_G	 =	 oVGA_BLANK ?	iGray		:	0;
assign	oVGA_B	 =	 oVGA_BLANK ?	iGray	   :	0;
								  								  
endmodule


