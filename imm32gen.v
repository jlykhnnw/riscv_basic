
`include "RV32I.h"
module imm32gen(
	input wire [`INSTWIDTH-1:0]ir,
	output reg [`DATAWIDTH-1:0]imm_out
);

always@(*)begin
	case(ir[6:0])
		`LUI	:imm_out = {ir[31:12], 12'h000};//U
		`AUIPC	:imm_out = {ir[31:12], 12'h000};//U
		`JAL	:imm_out = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};//J
		`STORE	:imm_out = {{21{ir[31]}}, ir[30:25], ir[11:08], ir[07]};//S
		`BRANCH	:imm_out = {{20{ir[31]}}, ir[07], ir[30:25], ir[11:08], 1'b0};//B
		`JALR	:imm_out = {{21{ir[31]}}, ir[30:20]};//I
		`LOAD	:imm_out = {{21{ir[31]}}, ir[30:20]};//I
		`OPRI	:imm_out = {{21{ir[31]}}, ir[30:20]};//I
		default	:imm_out = {`DATAWIDTH{1'b0}};
	endcase
end



endmodule