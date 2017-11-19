// ------------------------------------------------------------------------------
// PROJECT NAME: 	LIBRA
// FILE NAME: 		l1_addr_decoder.sv
// AUTHOR: 			Maksim Kobzar
// AUTHOR`S MAIL: 	maksim.s.kobzar@gmail.com
// DESCRIPTION:  	Block where address decode to understand it`s hit or miss.
// ------------------------------------------------------------------------------


`ifndef INC_L1_ADDR_DECODER_SV
`define INC_L1_ADDR_DECODER_SV


module l1_addr_decoder
#(
	parameter SET_NUMBER	= 8,
	parameter BLOCK_NUMBER	= 128,
	parameter BLOCK_SIZE	= 32,
	parameter L1_CACHE_ADDR_WIDTH = 32
)
(
	input	logic						clk,

	input	logic						core_req_val,
	input	logic	[ADDR_WIDTH-1:0]	core_req_addr,

	input	logic						tag_wr_val,
	input	logic	[ADDR_WIDTH-1:0]	tag_wr_addr,
	input	logic	[TAG_WIDTH-1:0]		tag_wr_data,

	output	logic	[ADDR_WIDTH-1:0]	data_addr,
	output	logic						hit
);
	
	localparam SET_NUMBER_WIDTH		= $clog2(SET_NUMBER);
	localparam BLOCK_NUMBER_WIDTH	= $clog2(BLOCK_NUMBER);
	localparam BLOCK_SIZE_WIDTH		= $clog2(BLOCK_SIZE);
	localparam BLOCK_NUMBER_LSB		= BLOCK_SIZE_WIDTH + 2;
	localparam SET_NUMBER_LSB		= BLOCK_NUMBER_LSB + BLOCK_NUMBER_WIDTH - SET_NUMBER_WIDTH;
	localparam TAG_LSB				= SET_NUMBER_LSB + BLOCK_NUMBER_WIDTH;
	localparam TAG_WIDTH			= ADDR_WIDTH - TAG_LSB;

	`define TAG_BITS	ADDR_WIDTH-1	 : TAG_LSB
	`define SET_BITS	TAG_LSB-1		 : SET_NUMBER_LSB
	`define BLOCK_BITS	TAG_LSB-1		 : BLOCK_NUMBER_LSB
	
	logic [BLOCK_NUMBER-1:0]		val_bit_vec;
	logic [SET_NUMBER-1:0]			hit_set;
	logic [SET_NUMBER_WIDTH-1:0]	hit_set_num;

	genvar tag_bank_index;
	generate
		for (tag_bank_index = 0; tag_bank_index < SET_NUMBER; tag_bank_index++) begin : gen_tag_mem
			ram_model
			#(
				.ADDR_WIDTH (BLOCK_NUMBER_WIDTH - SET_NUMBER_WIDTH),
				.DATA_WIDTH (L1_CACHE_ADDR_WIDTH -  - 2),
			)
			mem_tag
			(
				.clk	(clk),
				.ren	(core_req_val),
				.raddr	(core_req_addr[`BLOCK_BITS]),
				.rdata	(tag_rd_data[tag_bank_index]),
				.wen	(tag_wr_val_vec[tag_bank_index]),
				.waddr	(tag_wr_addr),
				.wdata	(tag_wr_data),
			);

		end
		assign tag_wr_val_vec[tag_bank_index] = tag_wr_val && tag_wr_addr[`SET_BITS] == tag_bank_index;
		assign hit_set[tag_bank_index] = 	tag_rd_data[tag_bank_index] == addr[`TAG_BITS] && val_bit_vec[TAG_LSB - 1: BLOCK_NUMBER_LSB];
	endgenerate

	always_comb begin
		for (tag_bank_index = 0; tag_bank_index < SET_NUMBER; tag_bank_index++) begin : decode_hit_set_num
			if(hit_set[tag_bank_index]) hit_set_num = tag_bank_index;
		end
	end

	// ------------------------------------------------------------------------
	// Outputs
	// ------------------------------------------------------------------------
	assign hit = |hit_set;
	assign data_addr = {core_req_addr[`TAG_BITS], hit_set_num, core_req_addr[TAG_LSB-1: 0]};

endmodule

`endif // INC_l1_ADDR_DECODER_SV
