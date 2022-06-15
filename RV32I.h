//addr width constant
`define PCWIDTH		32
`define OPADDRWIDTH 05
`define DMADDRWIDTH 32
`define IMEM_DEPTH	2048
`define DMEM_DEPTH	2048
//data width constant
`define INSTWIDTH 	32
`define DATAWIDTH 	32
`define IMMWIDTH12	12
`define IMMWIDTH20	20
`define OPCODEWIDTH 07
`define FUNCT7WIDTH	07
`define FUNCT3WIDTH 03
//opcode
`define LUI			7'h37//U1
`define AUIPC		7'h17//U1
`define JAL			7'h6f//J1
`define JALR		7'h67//I1
`define	BRANCH		7'h63//B6
`define LOAD		7'h03//I5
`define STORE		7'h23//S3
`define OPRI		7'h13//I9
`define OPRR		7'h33//R10
`define MISC_MEM	7'h0f//I2
`define SYSTEM		7'h73//I8

//OPRI func3
`define	ADDI		3'b000
`define SLLI		3'b001
`define SLTI 		3'b010
`define SLTIU 		3'b011
`define XORI		3'b100
`define SRLI		3'b101
`define SRAI		3'b101
`define ORI			3'b110
`define ANDI		3'b111

//OPRI and OPRR func7
`define F700		7'h00
`define F720		7'h20

//OPRR func3
`define ADD			3'b000
`define SUB     	3'b000
`define SLL     	3'b001
`define	SLT     	3'b010
`define SLTU     	3'b011
`define XOR     	3'b100
`define SRL     	3'b101
`define SRA     	3'b101
`define OR      	3'b110
`define AND     	3'b111

//BRANCH func3
`define BEQ			3'b000
`define BNE		    3'b001
`define BLT		    3'b010
`define BGE		    3'b110
`define BLTU		3'b011
`define BGEU		3'b111

//LOAD and STORE
`define BYTE		3'b000
`define HALF		3'b001
`define WORD		3'b010
`define BYTEU		3'b100
`define HALFU		3'b101

//MISC-MEM
`define FENCE		3'b000
`define FENCEI		3'b001

//SYSTEM
`define	ECALL		3'b000
`define	EBREAK		3'b000
`define	CSR_RW		3'b001
`define	CSR_RS		3'b010
`define	CSR_RC		3'b011
`define	CSR_RWI		3'b101
`define	CSR_RSI		3'b110
`define	CSR_RCI		3'b111