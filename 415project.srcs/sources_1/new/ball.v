module ball(
    input wire clk, reset,
    input wire [9:0] pix_x, pix_y,
    input wire refr_tick,
    input wire [9:0] BAR_X_L, BAR_X_R, bar_y_b, bar_y_t, MAX_Y, WALL_X_R1,
    output rd_ball_on
    );
   //--------------------------------------------
   // square ball
   //--------------------------------------------
   
   wire sq_ball_on;
   localparam BALL_SIZE = 8;
   // ball left, right boundary
   wire [9:0] ball_x_l, ball_x_r;
   // ball top, bottom boundary
   wire [9:0] ball_y_t, ball_y_b;
   // reg to track left, top position
   reg [9:0] ball_x_reg, ball_y_reg;
   wire [9:0] ball_x_next, ball_y_next;
   // reg to track ball speed
   reg [9:0] x_delta_reg, x_delta_next;
   reg [9:0] y_delta_reg, y_delta_next;
   // ball velocity can be pos or neg)
   localparam BALL_V_P = 2;
   localparam BALL_V_N = -2;
   //--------------------------------------------
   // round ball
   //--------------------------------------------
   wire [2:0] rom_addr_ball_1, rom_col_ball_1, rom_addr_ball_2, rom_col_ball_2;
   reg [7:0] rom_data_ball_1, rom_data_ball_2;
   wire rom_bit_ball_1, rom_bit_ball_2;
   
   always @*
      case (rom_addr_ball_1)
         3'h0: rom_data_ball_1 = 8'b00000000; //    **
         3'h1: rom_data_ball_1 = 8'b00001000; //    **
         3'h2: rom_data_ball_1 = 8'b00011110; //   ****
         3'h3: rom_data_ball_1 = 8'b11111111; //  ******
         3'h4: rom_data_ball_1 = 8'b11111111; // ********
         3'h5: rom_data_ball_1 = 8'b00011110; // ********
         3'h6: rom_data_ball_1 = 8'b00001100; //  ******
         3'h7: rom_data_ball_1 = 8'b00000000; //   ****
      endcase
   
   //--------------------------------------------
   // square ball
   //--------------------------------------------
   // boundary
   assign ball_x_l = ball_x_reg;
   assign ball_y_t = ball_y_reg;
   assign ball_x_r = ball_x_l + BALL_SIZE - 1;
   assign ball_y_b = ball_y_t + BALL_SIZE - 1;
   // pixel within ball
   assign sq_ball_on =
            (ball_x_l<=pix_y) && (pix_y<=ball_x_r) &&
            (ball_y_t<=pix_x) && (pix_x<=ball_y_b);
   // map current pixel location to ROM addr/col
   assign rom_addr_ball_1 = pix_x[2:0] - ball_x_l[2:0];
   assign rom_col_ball_1 = pix_y[2:0] - ball_y_t[2:0];
   assign rom_bit_ball_1 = rom_data_ball_1[rom_col_ball_1];
   // pixel within ball
   assign rd_ball_on = sq_ball_on & rom_bit_ball_1;
   // ball rgb output
   // new ball position
   assign ball_x_next = (refr_tick) ? ball_x_reg+x_delta_reg :
                        ball_x_reg ;
   assign ball_y_next = (refr_tick) ? ball_y_reg+y_delta_reg :
                        ball_y_reg ;
   // new ball velocity
   always @*
   begin
      x_delta_next = x_delta_reg;
      y_delta_next = y_delta_reg;
      if (ball_y_t < 1) // reach left (was top)
         y_delta_next = BALL_V_P;
      else if (ball_y_b > (MAX_Y-1)) // reach right (was bottom)
         y_delta_next = BALL_V_N;
      else if (ball_x_l <= WALL_X_R1) // reach wall
         x_delta_next = BALL_V_P;    // bounce back
      else if ((BAR_X_L<=ball_x_r) && (ball_x_r<=BAR_X_R) &&
               (bar_y_t<=ball_y_b) && (ball_y_t<=bar_y_b))
         // reach x of right bar and hit, ball bounce back
         x_delta_next = BALL_V_N; 
   end

endmodule
