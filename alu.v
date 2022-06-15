`include "RV32I.h"
module alu(
	input  wire [`OPCODEWIDTH-1:0]opcode,
	input  wire [`FUNCT7WIDTH-1:0]funct7,
	input  wire [`FUNCT3WIDTH-1:0]funct3,
	input  wire [`DATAWIDTH-1:0]aluin1,
	input  wire [`DATAWIDTH-1:0]aluin2,
	output wire [`DATAWIDTH-1:0]aluout
);

wire lui_en		;
wire auipc_en   ;
wire jal_en     ;
wire jalr_en    ;
wire load_en	;
wire branch_en  ;
wire store_en   ;
wire opri_en    ;
wire oprr_en    ;
wire misc_mem_en;
wire system_en  ;

wire [`DATAWIDTH-1:0]aluout_lui	    ;
wire [`DATAWIDTH-1:0]aluout_auipc   ;
wire [`DATAWIDTH-1:0]aluout_jal     ;
wire [`DATAWIDTH-1:0]aluout_jalr    ;
wire [`DATAWIDTH-1:0]aluout_branch  ;
wire [`DATAWIDTH-1:0]aluout_load	;
wire [`DATAWIDTH-1:0]aluout_store   ;
wire [`DATAWIDTH-1:0]aluout_opri    ;
wire [`DATAWIDTH-1:0]aluout_oprr    ;
wire [`DATAWIDTH-1:0]aluout_misc_mem;
wire [`DATAWIDTH-1:0]aluout_system  ;

assign lui_en		= (opcode == `LUI		);
assign auipc_en   	= (opcode == `AUIPC		);
assign jal_en     	= (opcode == `JAL		);
assign jalr_en    	= (opcode == `JALR		);
assign branch_en  	= (opcode == `BRANCH	);
assign load_en		= (opcode == `LOAD		);
assign store_en   	= (opcode == `STORE		);
assign opri_en    	= (opcode == `OPRI		);
assign oprr_en    	= (opcode == `OPRR		);
assign misc_mem_en	= (opcode == `MISC_MEM	);
assign system_en  	= (opcode == `SYSTEM	);


assign aluout_lui 		= 32'h0;
assign aluout_misc_mem  = 32'h0;
assign aluout_system    = 32'h0;
assign aluout_auipc     = auipc_en 		? ($signed(aluin1) + $signed(aluin2)) : 32'h0;
assign aluout_jal       = jal_en     	? ($signed(aluin1) + $signed(aluin2)) : 32'h0;
assign aluout_jalr      = jalr_en       ? (($signed(aluin1) + $signed(aluin2))&~(32'h1)) : 32'h0;
assign aluout_branch    = branch_en     ? ((funct3 == `BEQ) ? (aluin1 == aluin2):
										   (funct3 == `BNE) ? (aluin1 != aluin2):
										   (funct3 == `BLT) ? ($signed(aluin1) < $signed(aluin2)):
										   (funct3 == `BGE) ? ($signed(aluin1) >= $signed(aluin2)):
										   (funct3 == `BLTU) ? (aluin1 < aluin2):
										   (funct3 == `BGEU) ? (aluin1 >= aluin2):32'h0
										   ) : 32'h0;
assign aluout_load	    = load_en	    ? ($signed(aluin1) + $signed(aluin2)) : 32'h0;
assign aluout_store     = store_en      ? ($signed(aluin1) + $signed(aluin2)) : 32'h0;
assign aluout_opri      = opri_en       ? ((funct3 == `ADDI ) ? ($signed(aluin1) + $signed(aluin2)):
										   (funct3 == `SLLI	) ? (aluin1 << aluin2[4:0]):
										   (funct3 == `SLTI ) ? ($signed(aluin1) < $signed(aluin2)):
										   (funct3 == `SLTIU) ? (aluin1 < aluin2):
										   (funct3 == `XORI	) ? (aluin1 ^ aluin2):
										   ((aluin2[10] == 1'b0)&&(funct3 == `SRLI)) ? (aluin1 >> aluin2[4:0]):
										   ((aluin2[10] == 1'b1)&&(funct3 == `SRAI)) ? (({32{aluin1[31]}} << {32 - aluin2[4:0]}) |  (aluin1 >> aluin2[4:0]) ):
										   (funct3 == `ORI	) ? (aluin1 | aluin2):
										   (funct3 == `ANDI	) ? (aluin1 & aluin2):32'h0
										   ) : 32'h0;
assign aluout_oprr      = oprr_en     ?  ( ((funct7 == 7'h00)&&(funct3 == `ADD)) ? ($signed(aluin1) + $signed(aluin2)):
										   ((funct7 == 7'h20)&&(funct3 == `SUB)) ? ($signed(aluin1) - $signed(aluin2)):
										   (funct3 == `SLL ) ? (aluin1 << aluin2[4:0]):
										   (funct3 == `SLT ) ? ($signed(aluin1) < $signed(aluin2)):
										   (funct3 == `SLTU) ? (aluin1 < aluin2):
										   (funct3 == `XOR ) ? (aluin1 ^ aluin2):
										   ((funct7 == 7'h00)&&(funct3 == `SRL)) ? (aluin1 >> aluin2[4:0]):
										   ((funct7 == 7'h20)&&(funct3 == `SRA)) ? (({32{aluin1[31]}} << {32 - aluin2[4:0]}) |  (aluin1>> aluin2[4:0]) ):
										   (funct3 == `OR  ) ? (aluin1 | aluin2):
										   (funct3 == `AND ) ? (aluin1 & aluin2): 32'h0
										   ):32'h0;


assign aluout = aluout_lui | aluout_auipc | aluout_jal | aluout_jalr |
				aluout_load | aluout_branch | aluout_store | aluout_opri |
				aluout_oprr | aluout_misc_mem | aluout_system;

endmodule