/*
 * Copyright (c) 2024 Aron Dennen 
 * SPDX-License-Identifier: Apache-2.0
 */

// 8-bit pwm, pwmValue 0 = fully off, pwmValue 255 = fully on
// rolls the count over at 254 to prevent the off-by-one error
// which prevents 255 from being fully on

module pwm (
  // Inputs
  input wire enable,
  input wire clk,
  input wire reset,
  input wire [7:0] pwmValue,
 
  // Outputs
  output wire pwmOut
);

  reg [7:0] pwmCount;
  reg out;
  
  assign pwmOut = out;
  
  always @(posedge clk) begin
    if (enable) begin

      if (reset) begin
        pwmCount <= 0;
        out <= 0;
      end
      else if (enable) begin
        out <= (pwmCount < pwmValue) ? 1 : 0;
        pwmCount <= pwmCount + 1;
        if (pwmCount == 254) pwmCount <= 0; // Off-by-one error fix
      end

    end
  end

endmodule
