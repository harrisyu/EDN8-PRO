
`include "../base/defs.v"

module map_078
(map_out, bus, sys_cfg, ss_ctrl);

	`include "../base/bus_in.v"
	`include "../base/map_out.v"
	`include "../base/sys_cfg_in.v"
	`include "../base/ss_ctrl_in.v"
	
	output [`BW_MAP_OUT-1:0]map_out;
	input [`BW_SYS_CFG-1:0]sys_cfg;
	
	
	assign sync_m2 = 1;
	assign mir_4sc = 0;//enable support for 4-screen mirroring. for activation should be ensabled in sys_cfg also
	assign srm_addr[12:0] = cpu_addr[12:0];
	assign prg_oe = cpu_rw;
	assign chr_oe = !ppu_oe;
	//*************************************************************  save state setup
	assign ss_rdat[7:0] = 
	ss_addr[7:0] == 0 ? prg : 
	ss_addr[7:0] == 1 ? chr : 
	ss_addr[7:0] == 2 ? {mirror_mode, mir, we_latch} : 
	ss_addr[7:0] == 127 ? map_idx : 8'hff;
	//*************************************************************
	assign ram_ce = {cpu_addr[15:13], 13'd0} == 16'h6000;
	assign ram_we = 0;
	assign rom_ce = !cpu_ce;
	assign chr_ce = ciram_ce;
	assign chr_we = 0;
	
	//A10-Vmir, A11-Hmir
	assign ciram_a10 = mir ? mirror_mode : mirror_mode ? ppu_addr[10] : ppu_addr[11];
	assign ciram_ce = !ppu_addr[13];
	
	assign prg_addr[13:0] = cpu_addr[13:0];
	assign prg_addr[16:14] = !cpu_addr[14] ? prg[2:0] : 3'b111;
	
	assign chr_addr[12:0] = ppu_addr[12:0];
	assign chr_addr[16:13] = chr[3:0];
	
	
	reg [2:0]prg;
	reg [3:0]chr;
	reg we_latch;
	reg mir;
	reg mirror_mode;
	
	always @(negedge m2)
	if(ss_act)
	begin
		if(ss_we & ss_addr[7:0] == 0)prg <= cpu_dat;
		if(ss_we & ss_addr[7:0] == 1)chr <= cpu_dat;
		if(ss_we & ss_addr[7:0] == 2){mirror_mode, mir, we_latch} <= cpu_dat;
	end
		else
	if(map_rst)
	begin
		we_latch <= 0;
	end
		else
	if(!cpu_rw & !cpu_ce)
	begin
		prg[2:0] <= cpu_dat[2:0];
		mirror_mode <= cpu_dat[3];
		chr[3:0] <= cpu_dat[7:4];
		we_latch <= 1;
		if(!we_latch)mir <= cpu_dat[7:0] == 8'h03;
	end
	
endmodule