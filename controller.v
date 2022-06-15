
`include "RV32I.h"
module controller(
	input wire clk,
	input wire rst_n,
	input wire [`DATAWIDTH-1:0] aluout,
	input wire [`OPCODEWIDTH-1:0]IF2ID_IR_OPCODE,
	input wire [`OPCODEWIDTH-1:0]ID2EX_OPCODE,
	input wire [`OPCODEWIDTH-1:0]EX2MEM_OPCODE,
	output reg pc_stuck,
	output reg [2:0]pc_sel,
	output reg regfile_we,
	output reg [2:0]regfile_rd_wdata_sel,
	output reg dmem_we,
	output reg aluin1_sel,
	output reg aluin2_sel
);

//aluin1_sel
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)
		aluin1_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `AUIPC)
		aluin1_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `JAL)
		aluin1_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `JALR)
		aluin1_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `BRANCH)
		aluin1_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `LOAD)
		aluin1_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `STORE)
		aluin1_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `OPRI)
		aluin1_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `OPRR)
		aluin1_sel <= 1'b0;
	else
		aluin1_sel <= 1'b0;
end

//aluin2_sel
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)
		aluin2_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `AUIPC)
		aluin2_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `JAL)
		aluin2_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `JALR)
		aluin2_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `BRANCH)
		aluin2_sel <= 1'b0;
	else if(IF2ID_IR_OPCODE == `LOAD)
		aluin2_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `STORE)
		aluin2_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `OPRI)
		aluin2_sel <= 1'b1;
	else if(IF2ID_IR_OPCODE == `OPRR)
		aluin2_sel <= 1'b0;
	else
		aluin2_sel <= 1'b0;
end

//regfile_we
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)
		regfile_we <= 1'b0;
	else if(IF2ID_IR_OPCODE == `LUI)
		regfile_we <= 1'b1;
	else if(ID2EX_OPCODE == `AUIPC)
		regfile_we <= 1'b1;
	else if(ID2EX_OPCODE == `JAL)
		regfile_we <= 1'b1;
	else if(ID2EX_OPCODE == `JALR)
		regfile_we <= 1'b1;
	else if(EX2MEM_OPCODE == `LOAD)
		regfile_we <= 1'b1;
	else if(ID2EX_OPCODE == `OPRI)
		regfile_we <= 1'b1;
	else if(ID2EX_OPCODE == `OPRR)
		regfile_we <= 1'b1;
	else
		regfile_we <= 1'b0;
end

//regfile_rd_wdata_sel
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)
		regfile_rd_wdata_sel <= 3'b000;
	else if(IF2ID_IR_OPCODE == `LUI)
		regfile_rd_wdata_sel <= 3'b001;//ID2EX_IMM32
	else if(ID2EX_OPCODE == `AUIPC)
		regfile_rd_wdata_sel <= 3'b010;//aluout
	else if(ID2EX_OPCODE == `JAL)
		regfile_rd_wdata_sel <= 3'b011;//ID2EX_PC + 4
	else if(ID2EX_OPCODE == `JALR)
		regfile_rd_wdata_sel <= 3'b011;//ID2EX_PC + 4
	else if(EX2MEM_OPCODE == `LOAD)
		regfile_rd_wdata_sel <= 3'b000;//MEM2WB_MDOUT_TRIM
	else if(ID2EX_OPCODE == `OPRI)
		regfile_rd_wdata_sel <= 3'b010;//aluout
	else if(ID2EX_OPCODE == `OPRR)
		regfile_rd_wdata_sel <= 3'b010;//aluout
	else
		regfile_rd_wdata_sel <= 3'b000;
end

//dmem_we
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)
		dmem_we <= 1'b0;
	else if(ID2EX_OPCODE == `STORE)
		dmem_we <= 1'b1;
	else
		dmem_we <= 1'b0;
end

//pc_sel
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)
		pc_sel <= 3'b000;
	else if(ID2EX_OPCODE == `JAL)
		pc_sel <= 3'b001;//aluout
	else if(ID2EX_OPCODE == `JALR)
		pc_sel <= 3'b001;//aluout
	else if((ID2EX_OPCODE == `BRANCH) && aluout == 32'h1)
		pc_sel <= 3'b010;//EX2MEM_PC_IMM
	else
		pc_sel <= 3'b000;
end

//pc_stuck
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)
		pc_stuck <= 1'b0;
	else
		pc_stuck <= 1'b0;
end

endmodule