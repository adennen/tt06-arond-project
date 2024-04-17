// Clock divider module, Aron Dennen 2024

// Inputs a 12.5 MHz signal and outputs a 480 Hz and 60 Hz clock signals
// Outputs toggle at twice the output frequency to maintin N rising edges per second

// 12.5 MHz / 26042 = 479.99 hz
// toggle every 13021 clocks

module clock_divider (
  // Inputs
  input wire clk,
  input wire reset,
  
  // Outputs
  output wire clk480,
  output wire clk60
);

  reg [13:0] count; // 14-bit counter for 12.5 MHz -> 480 Hz signal
  reg [2:0] count2; // 3-bit counter for 480 Hz -> 60 Hz signal

  reg out480;
  reg out60;

  assign clk480 = out480;
  assign clk60 = out60;

  initial begin
    count = 0;
    count2 = 0;

    out480 = 0;
    out60 = 0;
  end

  always @(posedge clk, posedge reset) begin
    if (reset) begin
      count <= 0;
      out480 <= 0;
    end
    else begin
      count <= count + 1;
      if (count == 13021) begin // 13021
        // reset the main counter
        count <= 0; 
        out480 <= ~out480;
      end
    end
  end

  always @(posedge out480, posedge reset) begin
    if (reset) begin
      count2 <= 0;
      out60 <= 0;
    end
    else begin
      count2 <= count2 + 1;
      // counter2 self-resets because it's 3 bits counting to 8
      if (count2 == 3'b000) out60 <= ~out60;
    end
  end

endmodule
