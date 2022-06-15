`timescale 1ns/1ps

`include "C:/Users/WK/Desktop/Riscv32I/src/RV32I.h"

`define HALF_T 10//50MHZ
`define RF x_RV32I.x_regfile.regfile
`define PC x_RV32I.IF_PC
`define IMEM x_RV32I.x_imem.mem_array
`define DMEM x_RV32I.x_dmem.mem_array

module RV32I_TB();

bit pad_clk;
bit pad_rst_n;

RV32I x_RV32I(
	.pad_clk	(pad_clk	),
    .pad_rst_n	(pad_rst_n	)
);

//pad_clk
initial begin
	pad_clk = 1'b0;
	forever #(`HALF_T) pad_clk = ~pad_clk;
end

//pad_clk
initial begin
	pad_rst_n = 1'b1;
end

//reset_n
task reset_n();
	pad_rst_n = 1'b0;
	#(7*`HALF_T + 2.7);
	pad_rst_n = 1'b1;
endtask

task udelay(input [31:0] n);
	#(n*100*`HALF_T);
endtask

task Tdelay(input [31:0] n);
	#(n*2*`HALF_T);
endtask

//main process
initial begin
	mem_initial();
	//transfer_jump_link();
	//transfer_branch();
	//transfer_mem_access();
	//transfer_opri();
	transfer_oprr();
	$finish;
end
/***************************test cases*************************************************************/
task mem_initial();
	int i;
	for(i=0;i<2048;i = i+1) begin
		`IMEM[i] = 32'h0000_0000;
		`DMEM[i] = 32'h0000_0000;
	end
endtask

task transfer_jump_link();
	`IMEM[00] = lui(20'h12345, 5'h01);
	`IMEM[01] = auipc(20'h00018, 5'h02);
	`IMEM[02] = jal(20'h000c0, 5'h03);
	`IMEM[98] = jalr(12'h000e0, 5'h04, 5'h03);
	reset_n();
	Tdelay(4.5);
	$display("The first instruction was fetched!");
	Tdelay(2.1);
	$display("The value of x1 is %h", `RF[5'h01]);
	Tdelay(2);
	$display("The value of x2 is %h", `RF[5'h02]);
	Tdelay(1);
	$display("The value of x3 is %h", `RF[5'h03]);
	$display("The value of PC is %h", `PC);
	udelay(1);
endtask

task transfer_branch();
	`IMEM[00] = lui(20'h12345, 5'h01);
	`IMEM[01] = lui(20'h12345, 5'h02);
	`IMEM[02] = 32'h0000_0000;
	`IMEM[03] = branch(12'h1f0, 5'h02, 5'h01, `BEQ);
	reset_n();
	udelay(1);
	
	`IMEM[00] = lui(20'h12345, 5'h01);
	`IMEM[01] = lui(20'h12344, 5'h02);
	`IMEM[02] = 32'h0000_0000;
	`IMEM[03] = branch(12'h1f0, 5'h02, 5'h01, `BNE);
	reset_n();
	udelay(1);
	
	`IMEM[00] = lui(20'hf2345, 5'h01);
	`IMEM[01] = lui(20'hff345, 5'h02);
	`IMEM[02] = 32'h0000_0000;
	`IMEM[03] = branch(12'h1f0, 5'h02, 5'h01, `BLT);
	reset_n();
	udelay(1);
	
	`IMEM[00] = lui(20'hfff45, 5'h01);
	`IMEM[01] = lui(20'hf2345, 5'h02);
	`IMEM[02] = 32'h0000_0000;
	`IMEM[03] = branch(12'h1f0, 5'h02, 5'h01, `BGE);
	reset_n();
	udelay(1);
	
	`IMEM[00] = lui(20'h02345, 5'h01);
	`IMEM[01] = lui(20'h12345, 5'h02);
	`IMEM[02] = 32'h0000_0000;
	`IMEM[03] = branch(12'h1f0, 5'h02, 5'h01, `BLTU);
	reset_n();
	udelay(1);
	
	`IMEM[00] = lui(20'h22345, 5'h01);
	`IMEM[01] = lui(20'h12345, 5'h02);
	`IMEM[02] = 32'h0000_0000;
	`IMEM[03] = branch(12'h1f0, 5'h02, 5'h01, `BGEU);
	reset_n();
	udelay(1);
endtask

task transfer_mem_access();
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = load(12'h004, 5'h01, `BYTE, 5'h02);
	`DMEM[((20'h0<<12) + 12'h4)>>2] = 32'hf123_f4f6;
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = load(12'h004, 5'h01, `HALF, 5'h02);
	`DMEM[((20'h0<<12) + 12'h4)>>2] = 32'hf123_f4f6;
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = load(12'h004, 5'h01, `WORD, 5'h02);
	`DMEM[((20'h0<<12) + 12'h4)>>2] = 32'hf123_f4f6;
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = load(12'h004, 5'h01, `BYTEU, 5'h02);
	`DMEM[((20'h0<<12) + 12'h4)>>2] = 32'hf123_f4f6;
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = load(12'h004, 5'h01, `HALFU, 5'h02);
	`DMEM[((20'h0<<12) + 12'h4)>>2] = 32'hf123_f4f6;
	reset_n();
	udelay(1);
	//store
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'hABCDE, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = store(12'h008, 5'h02, 5'h01, `WORD);
	reset_n();
	udelay(0.5);
	$display("%h",`DMEM[((20'h0<<12) + 12'h008)>>2]);
	udelay(0.5);
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'hABCDE, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = store(12'h00C, 5'h02, 5'h01, `BYTE);
	reset_n();
	udelay(0.5);
	$display("%h",`DMEM[((20'h0<<12) + 12'h00C)>>2]);
	udelay(0.5);
	`IMEM[00] = lui(20'h00000, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'hABCDE, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = store(12'h010, 5'h02, 5'h01, `HALF);
	reset_n();
	udelay(0.5);
	$display("%h",`DMEM[((20'h0<<12) + 12'h010)>>2]);
	udelay(0.5);
endtask

task transfer_opri();
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri(12'h001, 5'h01, `ADDI, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri(12'h001, 5'h01, `SLTI, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri(12'h001, 5'h01, `SLTIU, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri(12'h001, 5'h01, `XORI, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri(12'h001, 5'h01, `ORI, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri(12'h001, 5'h01, `ANDI, 5'h03);
	reset_n();
	udelay(1);
	//
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri({`F700, 5'h04}, 5'h01, `SLLI, 5'h03);
	reset_n();
	udelay(1);	
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri({`F700, 5'h04}, 5'h01, `SRLI, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = opri({`F720, 5'h04}, 5'h01, `SRAI, 5'h03);
	reset_n();
	udelay(1);
endtask

task transfer_oprr();
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `ADD, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F720, 5'h02, 5'h01, `SUB, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `SLL, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `SLT, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `SLTU, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `XOR, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `SRL, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F720, 5'h02, 5'h01, `SRA, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `OR, 5'h03);
	reset_n();
	udelay(1);
	`IMEM[00] = lui(20'hf1234, 5'h01);
	`IMEM[01] = 32'h0000_0000;
	`IMEM[02] = lui(20'h00001, 5'h02);
	`IMEM[03] = 32'h0000_0000;
	`IMEM[04] = oprr(`F700, 5'h02, 5'h01, `AND, 5'h03);
	reset_n();
	udelay(1);
endtask

/*****************instruction encode***************************************************************/
function [31:0]lui(input [19:0]imm, input [4:0]rd);
	lui = {imm, rd, `LUI};
endfunction

function [31:0]auipc(input [19:0]imm, input [4:0]rd);
	auipc = {imm, rd, `AUIPC};
endfunction

function [31:0]jal(input [19:0]imm, input [4:0]rd);
	reg [19:0] imm_temp;
	imm_temp = {imm[19], imm[9:0], imm[10], imm[18:11]};
	jal = {imm_temp, rd, `JAL};
endfunction

function [31:0]jalr(input [11:0]imm, input [4:0]rs1, input [4:0]rd);
	jalr = {imm, rs1, 3'b000, rd, `JALR};
endfunction

function [31:0]branch(input [11:0]imm, input [4:0]rs2, input [4:0]rs1, input [2:0]funct3);
	branch = {imm[11], imm[9:4], rs2, rs1, funct3, imm[3:0], imm[10], `BRANCH};
endfunction

function [31:0]load(input [11:0]imm, input [4:0]rs1, input [2:0]funct3,  input [4:0]rd);
	load = {imm[11:0], rs1, funct3, rd, `LOAD};
endfunction

function [31:0]store(input [11:0]imm, input [4:0]rs2, input [4:0]rs1, input [2:0]funct3);
	store = {imm[11:5], rs2, rs1, funct3, imm[4:0], `STORE};
endfunction

function [31:0]opri(input [11:0]imm, input [4:0]rs1, input [2:0]funct3, input [4:0]rd);
	opri = {imm[11:0], rs1, funct3, rd, `OPRI};
endfunction

function [31:0]oprr(input [6:0]funct7, input [4:0]rs2, input [4:0]rs1, input [2:0]funct3, input [4:0]rd);
	oprr = {funct7, rs2, rs1, funct3, rd, `OPRR};
endfunction


endmodule