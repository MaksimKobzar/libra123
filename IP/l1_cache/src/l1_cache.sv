// ------------------------------------------------------------------------------
// PROJECT NAME: 	LIBRA
// FILE NAME: 		l1_cache.sv
// AUTHOR: 			Maksim Kobzar
// AUTHOR`S MAIL: 	maksim.s.kobzar@gmail.com
// DESCRIPTION:  	Top level of the 1st level cache controller.
// ------------------------------------------------------------------------------


`ifndef INC_L1_CACHE_SV
`define INC_L1_CACHE_SV


`ifndef `RESET_NAME
	`define RESET_NAME rst_n
`endif

`ifndef `RESET_TYPE(reset)
	!reset
`endif



//-------------------------------------------------------------------------------
// Memory command enum
//-------------------------------------------------------------------------------
typedef enum logic {
    SCR1_MEM_CMD_RD     = 1'b0,
    SCR1_MEM_CMD_WR     = 1'b1,
    SCR1_MEM_CMD_ERROR  = 'x
} type_scr1_mem_cmd_e;

//-------------------------------------------------------------------------------
// Memory data width enum
//-------------------------------------------------------------------------------
typedef enum logic[1:0] {
    SCR1_MEM_WIDTH_BYTE     = 2'b00,
    SCR1_MEM_WIDTH_HWORD    = 2'b01,
    SCR1_MEM_WIDTH_WORD     = 2'b10,
    SCR1_MEM_WIDTH_ERROR    = 'x
} type_scr1_mem_width_e;

//-------------------------------------------------------------------------------
// Memory response enum
//-------------------------------------------------------------------------------
typedef enum logic[1:0] {
    SCR1_MEM_RESP_NOTRDY    = 2'b00,
    SCR1_MEM_RESP_RDY_OK    = 2'b01,
    SCR1_MEM_RESP_RDY_ER    = 2'b10,
    SCR1_MEM_RESP_ERROR     = 'x
} type_scr1_mem_resp_e;



module l1_cache
#(
	parameter SET_NUMBER		= 4,
	parameter SET_SIZE_KB		= 4,
	parameter CORE_CMND_WIDTH	= 2,
	parameter CORE_WDTH_WIDTH	= 2,
	parameter CORE_ADDR_WIDTH	= 16,
	parameter CORE_DATA_WIDTH	= 32,
	parameter CORE_RESP_WIDTH	= 2,
	parameter L2_CMND_WIDTH		= 2,
	parameter L2_SIZE_WIDTH		= 3,
	parameter L2_ADDR_WIDTH		= 16,
	parameter L2_DATA_WIDTH		= 32,
	parameter L2_STRB_WIDTH		= L2_DATA_WIDTH/8
)
(
	input	logic							clk,
	input	logic							`RESET_NAME,
	// Core interface
	input	logic							core_req,
	input	logic	[CORE_CMND_WIDTH-1:0]	core_cmd,
	input	logic	[CORE_WDTH_WIDTH-1:0]	core_width,
	input	logic	[CORE_ADDR_WIDTH-1:0]	core_addr,
	input	logic	[CORE_DATA_WIDTH-1:0]	core_wdata,
	output	logic							core_req_ack,
	output	logic	[CORE_DATA_WIDTH-1:0]	core_rdata,
	output	logic	[CORE_RESP_WIDTH-1:0]	core_resp
	// The second cache controller interface
	output	logic							req_val,
	output	logic							req_nc,
	output	logic	[L2_CMND_WIDTH-1:0]		req_cmd,
	output	logic	[L2_SIZE_WIDTH-1:0]		req_size,
	output	logic	[L2_ADDR_WIDTH-1:0]		req_addr,
	output	logic							req_wdata_val,
	output	logic	[L2_DATA_WIDTH-1:0]		req_wdata,
	output	logic	[L2_STRB_WIDTH-1:0]		req_wstrb,
	input	logic							resp_val,
	input	logic							resp_err,
	input	logic							resp_rdata_val,
	input	logic	[L2_DATA_WIDTH-1:0]		resp_rdata
);

parameter CACHE_INDEX_WIDTH = $clog(SET_NUMBER);
parameter CACHE_INDEX_MSB 	= $clog((SET_SIZE_KB*2**10)/2**2);

core_if_engine i_core_if_engine
(
	.req			(core_req),
	.cmd			(core_cmd),
	.addr			(core_addr),
	.req_ack		(core_req_ack),
	.resp			(core_resp),

	.cache_dcd		(cache_dcd),
	.hit_not_miss 	(hit_not_miss)
);

cache_address_decoder i_cache_address_decoder
(
	.cache_tag		(core_addr[CACHE_INDEX_MSB +: CACHE_INDEX_WIDTH]),
	.cache_index	(core_addr[CACHE_INDEX_MSB-1:0]),
	.cache_dcd		(cache_dcd),
	.hit_not_miss 	(hit_not_miss),
);

assign mem_ren = hit_not_miss && core_cmd == SCR1_MEM_CMD_RD;
assign mem_wen = hit_not_miss && core_cmd == SCR1_MEM_CMD_WR;

`ifndef SYNTHESIS
	ram_model mem
	(
		.ren 	(mem_ren),
		.wen 	(mem_wen),
		.addr 	(core_addr),
		.wdata 	(core_wdata),
		.rdata 	(core_rdata),
	);
`elif
	// Compiled SRAM with SET_SIZE_KB size
`endif

endmodule

`ednif // INC_L1_CACHE_SV
