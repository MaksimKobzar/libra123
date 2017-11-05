// ------------------------------------------------------------------------------
// PROJECT NAME: 	LIBRA
// FILE NAME: 		l1_core_if_engine.sv
// AUTHOR: 			Maksim Kobzar
// AUTHOR`S MAIL: 	maksim.s.kobzar@gmail.com
// DESCRIPTION:  	Top level of the 1st level cache controller.
// ------------------------------------------------------------------------------


`ifndef INC_L1_CORE_IF_ENGINE_SV
`define INC_L1_CORE_IF_ENGINE_SV


module l1_core_if_engine
(
input	logic							req,
input	logic	[CORE_CMND_WIDTH-1:0]	cmd,
output	logic							req_ack,
output	logic							resp,

output	logic							cache_dcd,
input	logic							hit_not_miss
);
		
	state_e state, next_state;

	always_ff @(posedge clk, `RESET_TYPE(`RESET_NAME)) begin : fsm_switching
		if(`RESET_TYPE) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

	always_comb begin : 
		if(state == IDLE) begin
			if(hit_not_miss) 	next_state = TRAN;
			else 				next_state = state;
		end else if(state == TRAN) begin
			
		end
	end

	typedef enum logic [1:0] {
		IDLE = 2'b00, TRAN = 2'b01
	} state_e;

	assign cache_dcd = req;

	assign next_state = ;

endmodule

`endif // INC_L1_CORE_IF_ENGINE_SV