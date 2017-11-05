// ------------------------------------------------------------------------------
// PROJECT NAME: 	LIBRA
// FILE NAME: 		ram_model.sv
// AUTHOR: 			Maksim Kobzar
// AUTHOR`S MAIL: 	maksim.s.kobzar@gmail.com
// DESCRIPTION:  	Behavioral 2 port RAM model.
// ------------------------------------------------------------------------------


`ifndef INC_RAM_MODEL_SV
`define INC_RAM_MODEL_SV

module ram_model
#(
	parameter ADDR_WIDTH = 16,
	parameter DATA_WIDTH = 32
)
(
	input	logic						clk,
	input	logic						ren,
	input	logic	[ADDR_WIDTH-1:0]	raddr,
	output	logic	[DATA_WIDTH-1:0]	rdata,
	input	logic						wen,
	input	logic	[ADDR_WIDTH-1:0]	waddr,
	input	logic	[DATA_WIDTH-1:0]	wdata
);

	logic [DATA_WIDTH-1:0] mem [$clog(ADDR_WIDTH)];

	always_ff @(posedge clk)
		if(we) mem[waddr] <= wdata;

	assign rdata = ren ? mem[raddr] : {DATA_WIDTH{1'bz}};

endmodule

`endif // INC_RAM_MODEL_SV
