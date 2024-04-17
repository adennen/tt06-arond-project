// 7-Segment animator module, Aron Dennen 2024

// Iterates over the bits of a 7-segment character, sets the output segments individually with a delay period

module segment_animator (

  // Inputs
  input wire reset,
  input wire enable,
  input wire clk,
  input wire clk60, // 60Hz clock input for timing
  input wire charAvailable, // A character is available to be read
  input wire [6:0] charInput, // The next character to read

  // Outputs
  output wire [6:0] out // 7-segment out
);

  reg [7:0] segsOut;
  
  reg [6:0] currentChar; // Current 7-segment character to be displayed
  reg [6:0] segChecked; // Flags whether the segment has been evaluated for display
  reg [2:0] segIndex; // Debug for displaying segments sequentially

  reg [5:0] timerCount; // 6-bit segment animation timer (64 ticks)

  // States
  reg [1:0] state;
  localparam idle_state = 2'b00;
  localparam getChar_state = 2'b01;
  localparam getSeg_state = 2'b10;


  assign out = segsOut;

  initial begin
    segsOut = 0;

    currentChar = 0;
    segChecked = 0;
    segIndex = 0;

    timerCount = 0;

    state = idle_state; 
  end

  // When a new character becomes available, interrupt everything and load the new character
  always @(posedge charAvailable) begin
    if (enable) state <= getChar_state;
  end

  // Time to wait before finding the next displayable segment
  always @(posedge clk60) begin
    if (enable) begin

      if (timerCount > 0) begin
        timerCount <= timerCount - 1;
        if (timerCount == 1) state <= getSeg_state; // Get the next segment after the timer expires
      end

    end
  end


  always @(posedge clk, posedge reset) begin

    if (reset) begin
      segsOut = 0;

      currentChar = 0;
      segChecked = 0;
      segIndex = 0;

      timerCount = 0;

      state <= idle_state;
    end
    else if (enable) begin

      case(state)
        getSeg_state: begin
          // Find the next valid segment, one clock at a time

          // If the current segment index is a valid segment,
          // display it and start the timer
          if (currentChar[segIndex] == 1) begin
            segsOut[segIndex] <= 1;

            // Start the timer and move to idle state
            timerCount <= 8; // delay for 8 timer ticks = 0.13 seconds
            state <= idle_state;
          end
          
          // Mark that the segment has been checked
          segChecked[segIndex] <= 1;
          
          // Move to the next segment to check (debug)
          segIndex <= segIndex + 1;
          
          // 3. If all the segments have been checked, idle
          if (segChecked == 7'b1111111) begin
            state <= idle_state;
          end
        end

        getChar_state: begin
          // *** Reset variables ***
          segsOut <= 0;  // Reset the display

          currentChar <= charInput; // Get the next input character here
          segChecked <= 0;
          segIndex <= 0;

          timerCount <= 0;

          // Done getting the new character
          // Start displaying the segments
          state <= getSeg_state;
        end

      endcase
    end

  end /* end always block */
  
endmodule
