
`include "../base/defs.v"

module map_212 
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
	ss_addr[7:0] == 2 ? {bank_16, mirror_mode} : 
	ss_addr[7:0] == 127 ? map_idx : 8'hff;
	//*************************************************************

	assign ram_we = 0;
	assign chr_we = 0;
	assign ram_ce = 0;
	assign rom_ce = !cpu_ce;
	assign chr_ce = ciram_ce;
	
	assign ciram_a10 = !mirror_mode ? ppu_addr[10] : ppu_addr[11];
	assign ciram_ce = !ppu_addr[13];
	
	assign prg_addr[13:0] = cpu_addr[13:0];
	assign prg_addr[16:14] = bank_16 ? prg[2:0] : {prg[1:0], cpu_addr[14]};
	
	
	assign chr_addr[12:0] = ppu_addr[12:0];
	assign chr_addr[15:13] = chr[2:0];
	
	reg bank_16;
	reg mirror_mode;
	reg [3:0]prg;
	reg [2:0]chr;
	

	always @(negedge m2)
	if(ss_act)
	begin
		if(ss_we & ss_addr[7:0] == 0)prg <= cpu_dat;
		if(ss_we & ss_addr[7:0] == 1)chr <= cpu_dat;
		if(ss_we & ss_addr[7:0] == 2){bank_16, mirror_mode} <= cpu_dat;
	end
		else
	begin
		
		if(map_rst)
		begin
			prg[2:0] <= 3'b111;
			bank_16 <= 0;
		end
			else
		if(!cpu_ce & !cpu_rw)
		begin
		
			if(cpu_addr[14] == 0)
			begin
				prg[2:0] <= cpu_addr[2:0];
				bank_16 <= 1;
			end
				else
			begin
				prg[1:0] <= cpu_addr[2:1];
				bank_16 <= 0;
			end
			
			chr <= cpu_addr[2:0];
			mirror_mode <= cpu_addr[3];
			
		end
		
	end
	
	

	
endmodule




