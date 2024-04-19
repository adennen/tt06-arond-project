/*
 * Copyright (c) 2024 Aron Dennen 
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_7seg_animated (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg reset;
  
  // *** Clock divider vars

  wire clkPwm;
  wire clk60;

  clock_divider clk_divider (
    .clk(clk),
    .reset(reset),
    .clkPwm(clkPwm),
    .clk60(clk60)
    );

  // *** PWM module vars

  reg pwmOut;

  pwm pwm (
    .enable(ena),
    .clk(clkPwm),
    .reset(reset),
    .pwmValue( { uio_in[6:0], 1'b0 } ),
    .pwmOut(pwmOut)
  );

  // *** Segment animator vars

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

  // *** Main program

  reg [7:0] out;
  assign uo_out = out;
  
  always @(posedge clk) begin
    reset <= ~rst_n;
    charInput <= ui_in[6:0];

    if (uio_in[7]) begin
      out[6:0] <= (pwmOut) ? displayOut : 7'b0000000;
    end
    else out[6:0] <= displayOut;

    out[7] <= ui_in[7];
  end

  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

endmodule
