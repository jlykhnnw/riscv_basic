//wk2022/02/21/22:21
`include "RV32I.h"
module RV32I(
	input  wire pad_clk	,
	input  wire pad_rst_n
);

//IF
(* KEEP = "TRUE" *)reg [`PCWIDTH-1:0]		IF_PC;

//IF2ID
(* KEEP = "TRUE" *)reg [`PCWIDTH-1:0]		IF2ID_PC;
(* KEEP = "TRUE" *)wire [`INSTWIDTH-1:0]	IF2ID_IR;

//ID2EX
(* KEEP = "TRUE" *)reg [`PCWIDTH-1:0]		ID2EX_PC;
(* KEEP = "TRUE" *)reg [`INSTWIDTH-1:0]		ID2EX_IR;
(* KEEP = "TRUE" *)reg [`FUNCT7WIDTH-1:0]	ID2EX_FUNCT7;
(* KEEP = "TRUE" *)reg [`FUNCT3WIDTH-1:0]	ID2EX_FUNCT3;
(* KEEP = "TRUE" *)reg [`OPADDRWIDTH-1:0]	ID2EX_RD;
(* KEEP = "TRUE" *)reg [`OPCODEWIDTH-1:0]	ID2EX_OPCODE;
(* KEEP = "TRUE" *)reg [`DATAWIDTH-1:0]		ID2EX_RS1_DATA;
(* KEEP = "TRUE" *)reg [`DATAWIDTH-1:0]		ID2EX_RS2_DATA;
(* KEEP = "TRUE" *)reg [`DATAWIDTH-1:0]		ID2EX_IMM32;

//EX2MEM
(* KEEP = "TRUE" *)reg [`PCWIDTH-1:0]		EX2MEM_PC;
(* KEEP = "TRUE" *)reg [`INSTWIDTH-1:0]		EX2MEM_IR;
(* KEEP = "TRUE" *)reg [`FUNCT3WIDTH-1:0]	EX2MEM_FUNCT3;
(* KEEP = "TRUE" *)reg [`OPADDRWIDTH-1:0]	EX2MEM_RD;
(* KEEP = "TRUE" *)reg [`OPCODEWIDTH-1:0]	EX2MEM_OPCODE;
(* KEEP = "TRUE" *)reg [`PCWIDTH-1:0]		EX2MEM_NPC;
(* KEEP = "TRUE" *)reg [`PCWIDTH-1:0]		EX2MEM_PC_IMM;
(* KEEP = "TRUE" *)reg [`DATAWIDTH-1:0]		EX2MEM_ALU_OUT;
(* KEEP = "TRUE" *)reg [`DATAWIDTH-1:0]		EX2MEM_RS2_DATA;

//MEM2WB
(* KEEP = "TRUE" *)reg [`PCWIDTH-1:0]		MEM2WB_PC;
(* KEEP = "TRUE" *)reg [`INSTWIDTH-1:0]		MEM2WB_IR;
(* KEEP = "TRUE" *)reg [`FUNCT3WIDTH-1:0]	MEM2WB_FUNCT3;
(* KEEP = "TRUE" *)reg [`OPADDRWIDTH-1:0]	MEM2WB_RD;
(* KEEP = "TRUE" *)reg [`OPCODEWIDTH-1:0]	MEM2WB_OPCODE;
(* KEEP = "TRUE" *)reg [`DATAWIDTH-1:0]		MEM2WB_MDOUT;

//wires
(* KEEP = "TRUE" *)wire	pc_stuck;
(* KEEP = "TRUE" *)wire [2:0]pc_sel;
(* KEEP = "TRUE" *)wire [`PCWIDTH-1:0]IF_PC_NEXT;
(* KEEP = "TRUE" *)wire [`INSTWIDTH-1:0]imem_rdata;

(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0]	ImmSignEX_out;
(* KEEP = "TRUE" *)wire 					regfile_we;
(* KEEP = "TRUE" *)wire [2:0]				regfile_rd_wdata_sel;
(* KEEP = "TRUE" *)wire [`OPADDRWIDTH-1:0]	regfile_rd;
(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0]	regfile_rd_wdata;
(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0]	regfile_rs1_rdata;
(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0]	regfile_rs2_rdata;
(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0] 	regfile_rs2_rdata_trim;

(* KEEP = "TRUE" *)wire [`DATAWIDTH - 1 : 0]aluin1;
(* KEEP = "TRUE" *)wire [`DATAWIDTH - 1 : 0]aluin2;
(* KEEP = "TRUE" *)wire [`DATAWIDTH - 1 : 0]aluout;
(* KEEP = "TRUE" *)wire aluin1_sel;
(* KEEP = "TRUE" *)wire aluin2_sel;

(* KEEP = "TRUE" *)wire 					dmem_addr_sel;
(* KEEP = "TRUE" *)wire  				  	dmem_we;
(* KEEP = "TRUE" *)wire [`DMADDRWIDTH-1:0]  dmem_addr;
(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0] 	dmem_wdata;
(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0] 	dmem_rdata;
(* KEEP = "TRUE" *)wire [`DATAWIDTH-1:0] 	MEM2WB_MDOUT_TRIM;

(* KEEP = "TRUE" *)wire con_temp 	;
(* KEEP = "TRUE" *)wire con0 		;
(* KEEP = "TRUE" *)wire con1 		;
(* KEEP = "TRUE" *)wire con2 		;
(* KEEP = "TRUE" *)wire con3 		;
(* KEEP = "TRUE" *)wire con4 		;
(* KEEP = "TRUE" *)wire con5		; 		

/******************************IF**************************************/
always@(posedge pad_clk or negedge pad_rst_n)begin
	if(~pad_rst_n)
		IF_PC <= {`PCWIDTH{1'b0}};
	else if(pc_stuck)
		IF_PC <= IF_PC;
	else
		IF_PC <= IF_PC_NEXT;
end

imem x_imem(
	.clka	(1'b0),
    .ena	(1'b0),
    .wea	(1'b0),
    .addra	(32'h0),
    .dia    (32'h0),
    .clkb	(pad_clk),
    .enb	(1'b1),
    .addrb	(IF_PC>>2),
    .dob    (imem_rdata)
);

assign IF2ID_IR = imem_rdata;

/********************************ID************************************/
always@(posedge pad_clk or negedge pad_rst_n)begin
	if(~pad_rst_n) begin
		IF2ID_PC <= {`PCWIDTH{1'b0}};
	end else begin
		IF2ID_PC <= IF_PC;
	end
end

regfile x_regfile(
	.clk		(pad_clk),
	.rst_n		(pad_rst_n),
	.rs1		(IF2ID_IR[19:15]),
	.rs2		(IF2ID_IR[24:20]),
	.rs1_rdata	(regfile_rs1_rdata),
	.rs2_rdata	(regfile_rs2_rdata),
	.we			(regfile_we),
	.rd			(regfile_rd),
	.rd_wdata	(regfile_rd_wdata)
);

imm32gen x_imm32gen(
	.ir			(IF2ID_IR),
	.imm_out	(ImmSignEX_out)
);

/*******************************EX*************************************/
always@(posedge pad_clk or negedge pad_rst_n)begin
	if(~pad_rst_n) begin
		ID2EX_PC 		<= {`PCWIDTH{1'b0}};
		ID2EX_IR		<= {`INSTWIDTH{1'b0}};
		ID2EX_FUNCT7	<= {`FUNCT7WIDTH{1'b0}};
		ID2EX_FUNCT3 	<= {`FUNCT3WIDTH{1'b0}};
		ID2EX_RD		<= {`OPADDRWIDTH{1'b0}};
		ID2EX_OPCODE	<= {`OPCODEWIDTH{1'b0}};
		ID2EX_RS1_DATA 	<= {`DATAWIDTH{1'b0}};
		ID2EX_RS2_DATA 	<= {`DATAWIDTH{1'b0}};
		ID2EX_IMM32 	<= {`DATAWIDTH{1'b0}};
	end else begin
		ID2EX_PC 		<= IF2ID_PC;
		ID2EX_IR		<= IF2ID_IR;
		ID2EX_FUNCT7	<= IF2ID_IR[31:25];
		ID2EX_FUNCT3 	<= IF2ID_IR[14:12];
		ID2EX_RD		<= IF2ID_IR[11:07];
		ID2EX_OPCODE	<= IF2ID_IR[06:00];
		ID2EX_RS1_DATA 	<= regfile_rs1_rdata;
		ID2EX_RS2_DATA 	<= regfile_rs2_rdata;
		ID2EX_IMM32 	<= ImmSignEX_out;
	end
end



assign regfile_rs2_rdata_trim = (ID2EX_OPCODE == `STORE)?(
								(ID2EX_FUNCT3 == `BYTE)? ID2EX_RS2_DATA[7:0]:
								(ID2EX_FUNCT3 == `HALF)? ID2EX_RS2_DATA[15:0]:
								(ID2EX_FUNCT3 == `WORD)? ID2EX_RS2_DATA:ID2EX_RS2_DATA
								):ID2EX_RS2_DATA;

assign aluin1 = con4? MEM2WB_MDOUT : ((con0||con2)? EX2MEM_ALU_OUT : (aluin1_sel? ID2EX_PC : ID2EX_RS1_DATA));
assign aluin2 = con5? MEM2WB_MDOUT : ((con1||con3)? EX2MEM_ALU_OUT : (aluin2_sel? ID2EX_IMM32 : regfile_rs2_rdata_trim));

alu x_alu(
	.opcode		(ID2EX_OPCODE),
	.funct7		(ID2EX_FUNCT7),
	.funct3		(ID2EX_FUNCT3),
	.aluin1		(aluin1),
	.aluin2		(aluin2),
	.aluout		(aluout)
);

/*******************************by_pass_logic*****************************/

assign con_temp = (ID2EX_IR[6:0] == `OPRR) || (ID2EX_IR[6:0] == `OPRI) || (ID2EX_IR[6:0] == `LOAD) || (ID2EX_IR[6:0] == `STORE) || (ID2EX_IR[6:0] == `BRANCH) || (ID2EX_IR[6:0] == `JALR);
assign con0 	= (EX2MEM_IR[6:0] == `OPRR) && (con_temp) && (EX2MEM_IR[11:7]==ID2EX_IR[19:15]);
assign con1 	= (EX2MEM_IR[6:0] == `OPRR) && (ID2EX_IR[6:0] == `OPRR) && (EX2MEM_IR[11:7]==ID2EX_IR[24:20]);
assign con2 	= (EX2MEM_IR[6:0] == `OPRI) && (con_temp) && (EX2MEM_IR[11:7]==ID2EX_IR[19:15]);
assign con3 	= (EX2MEM_IR[6:0] == `OPRI) && (ID2EX_IR[6:0] == `OPRR) && (EX2MEM_IR[11:7]==ID2EX_IR[24:20]);
assign con4 	= (MEM2WB_IR[6:0] == `LOAD) && (con_temp) && (MEM2WB_IR[11:7]==ID2EX_IR[19:15]);
assign con5 	= (MEM2WB_IR[6:0] == `LOAD) && (ID2EX_IR[6:0] == `OPRR) && (MEM2WB_IR[11:7]==ID2EX_IR[24:20]);



/*******************************MEM*************************************/
always@(posedge pad_clk or negedge pad_rst_n)begin
	if(~pad_rst_n) begin
		EX2MEM_PC		<= {`PCWIDTH{1'b0}};
		EX2MEM_IR		<= {`INSTWIDTH{1'b0}};
		EX2MEM_FUNCT3   <= {`FUNCT3WIDTH{1'b0}};
		EX2MEM_RD		<= {`OPADDRWIDTH{1'b0}};
		EX2MEM_OPCODE	<= {`OPCODEWIDTH{1'b0}};
		EX2MEM_NPC		<= {`PCWIDTH{1'b0}};
		EX2MEM_PC_IMM	<= {`PCWIDTH{1'b0}};
		EX2MEM_ALU_OUT	<= {`DATAWIDTH{1'b0}};
		EX2MEM_RS2_DATA	<= {`DATAWIDTH{1'b0}};
	end else begin
		EX2MEM_PC		<=  ID2EX_PC;
		EX2MEM_IR		<=  ID2EX_IR;
		EX2MEM_FUNCT3   <=  ID2EX_FUNCT3;
		EX2MEM_RD		<=  ID2EX_RD;
		EX2MEM_OPCODE	<=  ID2EX_OPCODE;
		EX2MEM_NPC		<=  ID2EX_PC + 4;
		EX2MEM_PC_IMM	<=  ID2EX_PC + ID2EX_IMM32;
		EX2MEM_ALU_OUT	<=  aluout;
		EX2MEM_RS2_DATA	<=  regfile_rs2_rdata_trim;
	end
end

assign dmem_addr  = EX2MEM_ALU_OUT;
assign dmem_wdata = EX2MEM_RS2_DATA;

dmem x_dmem(
	.clka	(pad_clk),
    .ena	(1'b1),
    .wea	(dmem_we),
    .addra	(dmem_addr>>2),
    .dia    (dmem_wdata),
    .clkb	(pad_clk),
    .enb	(1'b1),
    .addrb	(dmem_addr>>2),
    .dob    (dmem_rdata)
);

/*******************************WB*************************************/
always@(posedge pad_clk or negedge pad_rst_n)begin
	if(~pad_rst_n) begin
		MEM2WB_PC		<= {`PCWIDTH{1'b0}};
		MEM2WB_IR		<= {`INSTWIDTH{1'b0}};
		MEM2WB_FUNCT3   <= {`FUNCT3WIDTH{1'b0}};
		MEM2WB_RD		<= {`OPADDRWIDTH{1'b0}};
		MEM2WB_OPCODE	<= {`OPCODEWIDTH{1'b0}};
		//MEM2WB_MDOUT	<= {`DATAWIDTH{1'b0}};
	end else begin
		MEM2WB_PC		<= EX2MEM_PC;
		MEM2WB_IR		<= EX2MEM_IR;
		MEM2WB_FUNCT3   <= EX2MEM_FUNCT3;
		MEM2WB_RD		<= EX2MEM_RD;
		MEM2WB_OPCODE	<= EX2MEM_OPCODE;
		//MEM2WB_MDOUT	<= dmem_rdata;
	end
end



assign MEM2WB_MDOUT_TRIM = (MEM2WB_OPCODE == `LOAD)? (
						   (MEM2WB_FUNCT3 == `BYTE)?{{24{dmem_rdata[7]}}, dmem_rdata[7:0]}:
						   (MEM2WB_FUNCT3 == `HALF)?{{16{dmem_rdata[15]}}, dmem_rdata[15:0]}:
						   (MEM2WB_FUNCT3 == `WORD)? dmem_rdata[31:0]:
						   (MEM2WB_FUNCT3 == `BYTEU)?{{24{1'b0}}, dmem_rdata[7:0]}:
						   (MEM2WB_FUNCT3 == `HALFU)?{{16{1'b0}}, dmem_rdata[15:0]}:dmem_rdata[31:0]
							):dmem_rdata[31:0];

assign regfile_rd 		=  (regfile_rd_wdata_sel == 3'b001) ?	ID2EX_RD :
                           (regfile_rd_wdata_sel == 3'b010) ? 	EX2MEM_RD :
                           (regfile_rd_wdata_sel == 3'b011) ? 	EX2MEM_RD:
																MEM2WB_RD;
assign regfile_rd_wdata = (regfile_rd_wdata_sel == 3'b001) ?  	ID2EX_IMM32 	:
						  (regfile_rd_wdata_sel == 3'b010) ? 	EX2MEM_ALU_OUT 	:
                          (regfile_rd_wdata_sel == 3'b011) ? 	EX2MEM_PC + 4	:
																MEM2WB_MDOUT_TRIM;//可能出不定态

assign IF_PC_NEXT = (pc_sel == 3'b001) ? 	EX2MEM_ALU_OUT:
					(pc_sel == 3'b010) ? 	EX2MEM_PC_IMM:
											(IF_PC + 4);
/*******************************controller*************************************/
controller x_controller(
	.clk					(pad_clk),
	.rst_n					(pad_rst_n),
	.aluout					(aluout),
	.IF2ID_IR_OPCODE   		(IF2ID_IR[06:00]),
	.ID2EX_OPCODE  			(ID2EX_OPCODE  ),
	.EX2MEM_OPCODE  		(EX2MEM_OPCODE  ),
	.pc_stuck				(pc_stuck		),
	.regfile_we				(regfile_we		),
	.dmem_we        		(dmem_we   		),
	.pc_sel					(pc_sel					),
	.regfile_rd_wdata_sel	(regfile_rd_wdata_sel	),
	.aluin1_sel				(aluin1_sel				),
	.aluin2_sel				(aluin2_sel				)
);

endmodule