/*
 * Copyright (c) 2024 Aron Dennen 
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

`include "clock_divider.v"
`include "segment_animator.v"

module tt_um_7seghex_animated (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign reset = ~rst_n;

  
  // *** Clock divider vars

  wire clk480;
  wire clk60;

  clock_divider clk_divider (
    .clk(clk),
    .reset(reset),
    .clk480(clk480),
    .clk60(clk60)
    );


  // *** Segment animator vars

  reg charAvailable;
  reg [6:0] charInput;
  wire [6:0] displayOut;

  segment_animator animator (
    .enable(ena),
    .clk(clk),
    .clk60(clk60),
    .reset(reset),
    .charAvailable(ui_in[7]),
    .charInput(charInput),
    .out(displayOut)
    );

  assign uo_out = { displayOut, 1'b0 };



  // *** Main program

  always @(posedge reset) begin
    // Dummy info
    charInput = ui_in[6:0];
  end

  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

endmodule

