`ifndef ASSERT_L
`define ASSERT_L 1'b0
`define DEASSERT_L 1'b1
`endif
`ifndef ASSERT_H
`define ASSERT_H 1'b1
`define DEASSERT_H 1'b0
`endif

`timescale 1 ps / 1 ps

module ram_int #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 29,
                  MEM_DEPTH = 1 << ADDR_WIDTH, BE = 4'h7)
  (
    input [ADDR_WIDTH - 1:0] wr_addr, rd_addr,
    input [DATA_WIDTH - 1:0] wr_data,
    input CLOCK_125_p, wr_en, rd_en, reset,
    output reg [DATA_WIDTH - 1:0] rd_data
		output wire [9:0]  mem_ca,                   //       memory.mem_ca
		output wire [0:0]  mem_ck,                   //             .mem_ck
		output wire [0:0]  mem_ck_n,                 //             .mem_ck_n
		output wire [0:0]  mem_cke,                  //             .mem_cke
		output wire [0:0]  mem_cs_n,                 //             .mem_cs_n
		output wire [3:0]  mem_dm,                   //             .mem_dm
		inout  wire [31:0] mem_dq,                   //             .mem_dq
		inout  wire [3:0]  mem_dqs,                  //             .mem_dqs
		inout  wire [3:0]  mem_dqs_n,                //             .mem_dqs_n
		input  wire        oct_rzqin,                //          oct.rzqin
  );
  
  /* Define the required states. */
  parameter INIT = 2'h0, IDLE = 2'h1, WRITE = 2'h2, READ = 2'h3;

  /* These wires are necessary for the hard memory controller IP. */
  wire         pll_locked_ddr, pll_locked_int;
  wire         pll0_pll_clk_clk;
	wire         avl_burstbegin_0;
	wire         avl_ready_0;
	wire  [28:0] avl_addr_0;
	wire         avl_read_req_0;
	wire   [3:0] avl_be_0;
	wire         avl_rdata_valid_0;
	wire         avl_write_req_0;
	wire   [2:0] avl_size_0;
	wire         rst_controller_reset_out_reset;
	wire         pll0_reset_out_reset;
	wire         rst_controller_001_reset_out_reset;
	wire         rst_controller_002_reset_out_reset;
  
  wire local_cal_fail, local_cal_success, local_init_done;
  reg global_reset_n, soft_reset_n, rst_cnt;
  reg [1:0] curr_state, next_state;
  //reg [31:0] cnt;
    
  /*
  always @(posedge CLOCK_125_p)
    if (rst_cnt == `ASSERT_L || reset == `ASSERT_L)
      cnt <= 32'h0;
    else
      cnt <= cnt + 32'h1;
  */
      
  always @(posedge CLOCK_125_p) begin
    if (reset == `ASSERT_L) begin
      global_reset_n <= `ASSERT_L;
      soft_reset_n <= `ASSERT_L;
      curr_state <= INIT;
    end else
      curr_state <= next_state;
      
    case (curr_state)
      INIT:   begin
                global_reset_n <= `DEASSERT_L;
                if (pll_locked_ddr == `ASSERT_H && pll_locked_int == `ASSERT_H) begin
                  soft_reset_n <= `DEASSERT_L;
                  next_state <= INIT;
                end else
                  next_state <= INIT;
                if (local_cal_success == `ASSERT_H && soft_reset_n == `DEASSERT_L)
                  next_state <= IDLE;
                else
                  next_state <= INIT;
              end
            
      IDLE:   begin
                if (avl_ready_0 == `ASSERT_H && wr_en == `ASSERT_L)
                  next_state <= WRITE;
                else if (avl_ready_0 == `ASSERT_H && rd_en == `ASSERT_L)
                  next_state <= READ;
                else
                  next_state <= IDLE;
              end
      
      WRITE:  begin
      
              end
      
      READ:   begin
      
              end
    endcase
  end
  
	LPDDR2x32 lpddr2x32_inst (
		.pll_ref_clk                (CLOCK_125_p),                                    //        pll_ref_clk.clk
		.global_reset_n             (global_reset_n),                                 //       global_reset.reset_n
		.soft_reset_n               (soft_reset_n),                                   //         soft_reset.reset_n
		.afi_clk                    (),                                               //            afi_clk.clk
		.afi_half_clk               (),                                               //       afi_half_clk.clk
		.afi_reset_n                (),                                               //          afi_reset.reset_n
		.afi_reset_export_n         (),                                               //   afi_reset_export.reset_n
		.mem_ca                     (mem_ca),                                         //             memory.mem_ca
		.mem_ck                     (mem_ck),                                         //                   .mem_ck
		.mem_ck_n                   (mem_ck_n),                                       //                   .mem_ck_n
		.mem_cke                    (mem_cke),                                        //                   .mem_cke
		.mem_cs_n                   (mem_cs_n),                                       //                   .mem_cs_n
		.mem_dm                     (mem_dm),                                         //                   .mem_dm
		.mem_dq                     (mem_dq),                                         //                   .mem_dq
		.mem_dqs                    (mem_dqs),                                        //                   .mem_dqs
		.mem_dqs_n                  (mem_dqs_n),                                      //                   .mem_dqs_n
		.avl_ready_0                (avl_ready_0),                                    //              avl_0.waitrequest_n
		.avl_burstbegin_0           (avl_burstbegin_0),                               //                   .beginbursttransfer
		.avl_addr_0                 (avl_addr_0),                                     //                   .address
		.avl_rdata_valid_0          (avl_rdata_valid_0),                              //                   .readdatavalid
		.avl_rdata_0                (rd_data),                                        //                   .readdata
		.avl_wdata_0                (wr_data),                                        //                   .writedata
		.avl_be_0                   (avl_be_0),                                       //                   .byteenable
		.avl_read_req_0             (avl_read_req_0),                                 //                   .read
		.avl_write_req_0            (avl_write_req_0),                                //                   .write
		.avl_size_0                 (avl_size_0),                                     //                   .burstcount
		.mp_cmd_clk_0_clk           (pll0_pll_clk_clk),                               //       mp_cmd_clk_0.clk
		.mp_cmd_reset_n_0_reset_n   (~rst_controller_reset_out_reset),                //   mp_cmd_reset_n_0.reset_n
		.mp_rfifo_clk_0_clk         (pll0_pll_clk_clk),                               //     mp_rfifo_clk_0.clk
		.mp_rfifo_reset_n_0_reset_n (~rst_controller_001_reset_out_reset),            // mp_rfifo_reset_n_0.reset_n
		.mp_wfifo_clk_0_clk         (pll0_pll_clk_clk),                               //     mp_wfifo_clk_0.clk
		.mp_wfifo_reset_n_0_reset_n (~rst_controller_002_reset_out_reset),            // mp_wfifo_reset_n_0.reset_n
		.local_init_done            (local_init_done),                                //             status.local_init_done
		.local_cal_success          (local_cal_success),                              //                   .local_cal_success
		.local_cal_fail             (local_cal_fail),                                 //                   .local_cal_fail
		.oct_rzqin                  (oct_rzqin),                                      //                oct.rzqin
		.pll_mem_clk                (),                                               //        pll_sharing.pll_mem_clk
		.pll_write_clk              (),                                               //                   .pll_write_clk
		.pll_locked                 (pll_locked_ddr),                                 //                   .pll_locked
		.pll_write_clk_pre_phy_clk  (),                                               //                   .pll_write_clk_pre_phy_clk
		.pll_addr_cmd_clk           (),                                               //                   .pll_addr_cmd_clk
		.pll_avl_clk                (),                                               //                   .pll_avl_clk
		.pll_config_clk             (),                                               //                   .pll_config_clk
		.pll_mem_phy_clk            (),                                               //                   .pll_mem_phy_clk
		.afi_phy_clk                (),                                               //                   .afi_phy_clk
		.pll_avl_phy_clk            ()                                                //                   .pll_avl_phy_clk
	);
  
	altera_mem_if_single_clock_pll #(
		.DEVICE_FAMILY    ("Cyclone V"),
		.REF_CLK_FREQ_STR ("125.0 MHz"),
		.REF_CLK_PS       ("8000.0"),
		.PLL_CLK_FREQ_STR ("125.0 MHz"),
		.PLL_CLK_PHASE_PS (0),
		.PLL_CLK_MULT     (0),
		.PLL_CLK_DIV      (0),
		.USE_GENERIC_PLL  (1)
	) pll0 (
		.pll_ref_clk    (CLOCK_125_p),          //    pll_ref_clk.clk
		.pll_clk        (pll0_pll_clk_clk),     //        pll_clk.clk
		.global_reset_n (global_reset_n),       // global_reset_n.reset_n
		.pll_locked     (pll_locked_int),       //     pll_locked.pll_locked
		.reset_out_n    (pll0_reset_out_reset)  //      reset_out.reset_n
	);
  
	altera_reset_controller #(
		.NUM_RESET_INPUTS          (3),
		.OUTPUT_RESET_SYNC_EDGES   ("none"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~pll0_reset_out_reset),          // reset_in0.reset
		.reset_in1      (~global_reset_n),                // reset_in1.reset
		.reset_in2      (~soft_reset_n),                  // reset_in2.reset
		.clk            (),                               //       clk.clk
		.reset_out      (rst_controller_reset_out_reset), // reset_out.reset
		.reset_req      (),                               // (terminated)
		.reset_req_in0  (1'b0),                           // (terminated)
		.reset_req_in1  (1'b0),                           // (terminated)
		.reset_req_in2  (1'b0),                           // (terminated)
		.reset_in3      (1'b0),                           // (terminated)
		.reset_req_in3  (1'b0),                           // (terminated)
		.reset_in4      (1'b0),                           // (terminated)
		.reset_req_in4  (1'b0),                           // (terminated)
		.reset_in5      (1'b0),                           // (terminated)
		.reset_req_in5  (1'b0),                           // (terminated)
		.reset_in6      (1'b0),                           // (terminated)
		.reset_req_in6  (1'b0),                           // (terminated)
		.reset_in7      (1'b0),                           // (terminated)
		.reset_req_in7  (1'b0),                           // (terminated)
		.reset_in8      (1'b0),                           // (terminated)
		.reset_req_in8  (1'b0),                           // (terminated)
		.reset_in9      (1'b0),                           // (terminated)
		.reset_req_in9  (1'b0),                           // (terminated)
		.reset_in10     (1'b0),                           // (terminated)
		.reset_req_in10 (1'b0),                           // (terminated)
		.reset_in11     (1'b0),                           // (terminated)
		.reset_req_in11 (1'b0),                           // (terminated)
		.reset_in12     (1'b0),                           // (terminated)
		.reset_req_in12 (1'b0),                           // (terminated)
		.reset_in13     (1'b0),                           // (terminated)
		.reset_req_in13 (1'b0),                           // (terminated)
		.reset_in14     (1'b0),                           // (terminated)
		.reset_req_in14 (1'b0),                           // (terminated)
		.reset_in15     (1'b0),                           // (terminated)
		.reset_req_in15 (1'b0)                            // (terminated)
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (3),
		.OUTPUT_RESET_SYNC_EDGES   ("none"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller_001 (
		.reset_in0      (~pll0_reset_out_reset),              // reset_in0.reset
		.reset_in1      (~global_reset_n),                    // reset_in1.reset
		.reset_in2      (~soft_reset_n),                      // reset_in2.reset
		.clk            (),                                   //       clk.clk
		.reset_out      (rst_controller_001_reset_out_reset), // reset_out.reset
		.reset_req      (),                                   // (terminated)
		.reset_req_in0  (1'b0),                               // (terminated)
		.reset_req_in1  (1'b0),                               // (terminated)
		.reset_req_in2  (1'b0),                               // (terminated)
		.reset_in3      (1'b0),                               // (terminated)
		.reset_req_in3  (1'b0),                               // (terminated)
		.reset_in4      (1'b0),                               // (terminated)
		.reset_req_in4  (1'b0),                               // (terminated)
		.reset_in5      (1'b0),                               // (terminated)
		.reset_req_in5  (1'b0),                               // (terminated)
		.reset_in6      (1'b0),                               // (terminated)
		.reset_req_in6  (1'b0),                               // (terminated)
		.reset_in7      (1'b0),                               // (terminated)
		.reset_req_in7  (1'b0),                               // (terminated)
		.reset_in8      (1'b0),                               // (terminated)
		.reset_req_in8  (1'b0),                               // (terminated)
		.reset_in9      (1'b0),                               // (terminated)
		.reset_req_in9  (1'b0),                               // (terminated)
		.reset_in10     (1'b0),                               // (terminated)
		.reset_req_in10 (1'b0),                               // (terminated)
		.reset_in11     (1'b0),                               // (terminated)
		.reset_req_in11 (1'b0),                               // (terminated)
		.reset_in12     (1'b0),                               // (terminated)
		.reset_req_in12 (1'b0),                               // (terminated)
		.reset_in13     (1'b0),                               // (terminated)
		.reset_req_in13 (1'b0),                               // (terminated)
		.reset_in14     (1'b0),                               // (terminated)
		.reset_req_in14 (1'b0),                               // (terminated)
		.reset_in15     (1'b0),                               // (terminated)
		.reset_req_in15 (1'b0)                                // (terminated)
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (3),
		.OUTPUT_RESET_SYNC_EDGES   ("none"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller_002 (
		.reset_in0      (~pll0_reset_out_reset),              // reset_in0.reset
		.reset_in1      (~global_reset_n),                    // reset_in1.reset
		.reset_in2      (~soft_reset_n),                      // reset_in2.reset
		.clk            (),                                   //       clk.clk
		.reset_out      (rst_controller_002_reset_out_reset), // reset_out.reset
		.reset_req      (),                                   // (terminated)
		.reset_req_in0  (1'b0),                               // (terminated)
		.reset_req_in1  (1'b0),                               // (terminated)
		.reset_req_in2  (1'b0),                               // (terminated)
		.reset_in3      (1'b0),                               // (terminated)
		.reset_req_in3  (1'b0),                               // (terminated)
		.reset_in4      (1'b0),                               // (terminated)
		.reset_req_in4  (1'b0),                               // (terminated)
		.reset_in5      (1'b0),                               // (terminated)
		.reset_req_in5  (1'b0),                               // (terminated)
		.reset_in6      (1'b0),                               // (terminated)
		.reset_req_in6  (1'b0),                               // (terminated)
		.reset_in7      (1'b0),                               // (terminated)
		.reset_req_in7  (1'b0),                               // (terminated)
		.reset_in8      (1'b0),                               // (terminated)
		.reset_req_in8  (1'b0),                               // (terminated)
		.reset_in9      (1'b0),                               // (terminated)
		.reset_req_in9  (1'b0),                               // (terminated)
		.reset_in10     (1'b0),                               // (terminated)
		.reset_req_in10 (1'b0),                               // (terminated)
		.reset_in11     (1'b0),                               // (terminated)
		.reset_req_in11 (1'b0),                               // (terminated)
		.reset_in12     (1'b0),                               // (terminated)
		.reset_req_in12 (1'b0),                               // (terminated)
		.reset_in13     (1'b0),                               // (terminated)
		.reset_req_in13 (1'b0),                               // (terminated)
		.reset_in14     (1'b0),                               // (terminated)
		.reset_req_in14 (1'b0),                               // (terminated)
		.reset_in15     (1'b0),                               // (terminated)
		.reset_req_in15 (1'b0)                                // (terminated)
	);

endmodule