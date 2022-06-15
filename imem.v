`include "RV32I.h"
//little endian
module imem(
	//write port
	input  wire 				clka	,
	input  wire 				ena		,
	input  wire					wea		,
	input  wire [`PCWIDTH-1:0]	addra	,
	input  wire [`INSTWIDTH-1:0]dia		,
	//read port
	input  wire 				clkb	,
	input  wire 				enb		,
	input  wire [`PCWIDTH-1:0]	addrb	,
	output  reg [`INSTWIDTH-1:0]dob
);

(*ram_style = "block"*)reg [`INSTWIDTH-1:0]mem_array[`IMEM_DEPTH-1:0];

//write
always@(posedge clka)begin
	if(ena & wea) begin
		mem_array[addra] <= dia;
	end else;
end

//read
always@(posedge clkb)begin
	if(enb) begin
		dob <= mem_array[addrb];
	end else;
end

endmodule