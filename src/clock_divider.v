/*
 * Copyright (c) 2024 Aron Dennen 
 * SPDX-License-Identifier: Apache-2.0
 */

// Inputs a 12.5 MHz signal and outputs a 122400 Hz (480Hz * 255 Pwm periods/clock) and 60 Hz clock signal
// Outputs toggle at twice the output frequency to maintin N rising edges per second

module clock_divider (
  // Inputs
  input wire clk,
  input wire reset,
  
  // Outputs
  output wire clkPwm,
  output wire clk60
);

  reg [5:0] count; // 6-bit counter for 12.5 MHz -> 122,400 Hz signal (51 counts per transition)
  reg [9:0] count2; // 10-bit counter for 122,400 Hz -> 60 Hz signal (1020 counts per transition)

  reg outPwm;
  reg out60;

  assign clkPwm = outPwm;
  assign clk60 = out60;

  always @(posedge clk) begin
    if (reset) begin
      count <= 0;
      outPwm <= 0;
    end
    else begin
      count <= count + 1;
      if (count == 51) begin
        // reset the main counter
        count <= 0; 
        outPwm <= ~outPwm;
      end
    end
  end

  always @(posedge outPwm) begin
    if (reset) begin
      count2 <= 0;
      out60 <= 0;
    end
    else begin
      count2 <= count2 + 1;

      if (count2 == 1020) begin
        count2 <= 0; 
        out60 <= ~out60;
      end
    end
  end

endmodule
