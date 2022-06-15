`include "RV32I.h"
//little endian
module regfile(
	input  wire clk,	
	input  wire rst_n,
	input  wire [`OPADDRWIDTH-1:0]rs1,
	input  wire	[`OPADDRWIDTH-1:0]rs2,
	output wire	[`DATAWIDTH-1:0]rs1_rdata,
	output wire	[`DATAWIDTH-1:0]rs2_rdata,
	input  wire we,			
	input  wire [`OPADDRWIDTH-1:0]rd,
	input  wire [`DATAWIDTH-1:0]rd_wdata	
);

(* KEEP = "TRUE" *)reg [`DATAWIDTH-1:0]regfile[31:0];

//read
assign rs1_rdata = rst_n? regfile[rs1] : 32'h0;
assign rs2_rdata = rst_n? regfile[rs2] : 32'h0;

//write
always@(posedge clk or negedge rst_n)begin
	if(~rst_n) begin
		regfile[00] <= {`DATAWIDTH{1'b0}};
		regfile[01] <= {`DATAWIDTH{1'b0}};
		regfile[02] <= {`DATAWIDTH{1'b0}};
		regfile[03] <= {`DATAWIDTH{1'b0}};
		regfile[04] <= {`DATAWIDTH{1'b0}};
		regfile[05] <= {`DATAWIDTH{1'b0}};
		regfile[06] <= {`DATAWIDTH{1'b0}};
		regfile[07] <= {`DATAWIDTH{1'b0}};
		regfile[08] <= {`DATAWIDTH{1'b0}};
		regfile[09] <= {`DATAWIDTH{1'b0}};
		regfile[10] <= {`DATAWIDTH{1'b0}};
		regfile[11] <= {`DATAWIDTH{1'b0}};
		regfile[12] <= {`DATAWIDTH{1'b0}};
		regfile[13] <= {`DATAWIDTH{1'b0}};
		regfile[14] <= {`DATAWIDTH{1'b0}};
		regfile[15] <= {`DATAWIDTH{1'b0}};
		regfile[16] <= {`DATAWIDTH{1'b0}};
		regfile[17] <= {`DATAWIDTH{1'b0}};
		regfile[18] <= {`DATAWIDTH{1'b0}};
		regfile[19] <= {`DATAWIDTH{1'b0}};
		regfile[20] <= {`DATAWIDTH{1'b0}};
		regfile[21] <= {`DATAWIDTH{1'b0}};
		regfile[22] <= {`DATAWIDTH{1'b0}};
		regfile[23] <= {`DATAWIDTH{1'b0}};
		regfile[24] <= {`DATAWIDTH{1'b0}};
		regfile[25] <= {`DATAWIDTH{1'b0}};
		regfile[26] <= {`DATAWIDTH{1'b0}};
		regfile[27] <= {`DATAWIDTH{1'b0}};
		regfile[28] <= {`DATAWIDTH{1'b0}};
		regfile[29] <= {`DATAWIDTH{1'b0}};
		regfile[30] <= {`DATAWIDTH{1'b0}};
		regfile[31] <= {`DATAWIDTH{1'b0}};
	end else if(we)
		regfile[rd] <= rd_wdata;
	else;
end

endmodule