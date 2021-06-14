module umbrella_animate(
    input wire reset, clk,
    input wire video_on,
    input wire [7:0] btn,
    input wire [9:0] pix_x, pix_y,
    output reg [11:0] graph_rgb,
    output wire audioOut
   );
   // constant and signal declaration
   // x, y coordinates (0,0) to (639,479) (NOTE: The values have been swapped)
   localparam MAX_X = 480;
   localparam MAX_Y = 640;
   wire refr_tick;
   //--------------------------------------------
   // vertical stripe as a wall (modified to horizontal in Y coords)
   //--------------------------------------------
   // wall left, right boundary
   localparam WALL_X_L1 = 0;
   localparam WALL_X_R1 = 35;
   localparam WALL_X_L2 = 450;
   localparam WALL_X_R2 = 479;
   //--------------------------------------------
   // right vertical bar (Now umbrella, modified to bottom horizontal bar in Y coords)
   //--------------------------------------------
   // bar left, right boundary (was 600 and 603)
   localparam BAR_X_L = 340;
   localparam BAR_X_R = 371;
   // bar top, bottom boundary (modified to horizontal)
   wire [9:0] bar_y_t, bar_y_b;
   localparam BAR_Y_SIZE = 32; //now horizontal size
   // register to track top boundary  (x position is fixed)
   reg [9:0] bar_y_reg, bar_y_next, bar_x_reg, bar_x_next;
   // bar moving velocity when a button is pressed
   localparam BAR_V = 4;
   wire [4:0] rom_addr_umb, rom_col_umb;
   reg [31:0] rom_data_umb;
   wire rom_bit_umb;
   //--------------------------------------------
   // square ball
   //--------------------------------------------
   localparam BALL_SIZE = 8;
   // ball left, right boundary
   wire [9:0] ball_x_l_1, ball_x_r_1, ball_x_l_2, ball_x_r_2;
   // ball top, bottom boundary
   wire [9:0] ball_y_t_1, ball_y_b_1, ball_y_t_2, ball_y_b_2;
   // reg to track left, top position
   reg [9:0] ball_x_reg_1, ball_y_reg_1, ball_x_reg_2, ball_y_reg_2;
   wire [9:0] ball_x_next_1, ball_y_next_1, ball_x_next_2, ball_y_next_2;
   // reg to track ball speed
   reg [9:0] x_delta_reg_1, x_delta_next_1, x_delta_reg_2, x_delta_next_2;
   reg [9:0] y_delta_reg_1, y_delta_next_1, y_delta_reg_2, y_delta_next_2;
   // ball velocity can be pos or neg)
   localparam BALL_V_P = 2;
   localparam BALL_V_N = -2;
   //--------------------------------------------
   // round ball
   //--------------------------------------------
   wire [2:0] rom_addr_ball_1, rom_col_ball_1, rom_addr_ball_2, rom_col_ball_2;
   reg [7:0] rom_data_ball_1, rom_data_ball_2;
   wire rom_bit_ball_1, rom_bit_ball_2;
   
   //--------------------------------------------
   // Person
   //--------------------------------------------
   wire [3:0] rom_addr_p, rom_col_p;
   reg [15:0] rom_data_p;
   wire rom_bit_p;
   localparam person_X_L = 400;
   localparam person_X_R = 415;
   localparam person_SIZE = 16;
   wire [9:0] person_y_t, person_y_b;
   reg [9:0] person_y_reg, person_y_next;
   localparam person_V = 4;
   
   //--------------------------------------------
   // object output signals
   //--------------------------------------------
   wire wall_on1, wall_on2, bar_on, sq_ball_on_1, rd_ball_on_1, person_on, rd_umb_on, rd_person_on, sq_ball_on_2, rd_ball_on_2;
   wire [11:0] wall_rgb1, wall_rgb2, bar_rgb, ball_rgb, digit_rgb, person_rgb;

   //--------------------------------------------
   //score tracking
   //--------------------------------------------
   //reg ball_miss;
   reg ball_miss1, ball_miss2;
   wire isOn1, isOn2, isOn3, isOn4, isOn5, isOn6, add10_1, add100_1, add10_2, add100_2;
   wire p1Pon, p1Lon, p1Aon, p1Yon, p1Eon, p1Ron, p1Non, p2Pon, p2Lon, p2Aon, p2Yon, p2Eon, p2Ron, p2Non;
   reg [6:0] char_addr_s;
   // body
   //--------------------------------------------
   // round ball image ROM
   //--------------------------------------------
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
   
   always @*
      case (rom_addr_ball_2)
         3'h0: rom_data_ball_2 = 8'b00000000; //    **
         3'h1: rom_data_ball_2 = 8'b00001000; //    **
         3'h2: rom_data_ball_2 = 8'b00011110; //   ****
         3'h3: rom_data_ball_2 = 8'b11111111; //  ******
         3'h4: rom_data_ball_2 = 8'b11111111; // ********
         3'h5: rom_data_ball_2 = 8'b00011110; // ********
         3'h6: rom_data_ball_2 = 8'b00001100; //  ******
         3'h7: rom_data_ball_2 = 8'b00000000; //   ****
      endcase
   
   //umbrella ROM
   always @*
   case (rom_addr_umb)
      5'h0:  rom_data_umb = 32'b00000000000000001000000000000000; //    **
      5'h1:  rom_data_umb = 32'b00000000000000001100000000000000; //    **
      5'h2:  rom_data_umb = 32'b00000000000000001110000000000000; //   ****
      5'h3:  rom_data_umb = 32'b00000000000000001111000000000000; //  ******
      5'h4:  rom_data_umb = 32'b00000000000000001111100000000000; // ********
      5'h5:  rom_data_umb = 32'b00000000000000001111110000000000; // ********
      5'h6:  rom_data_umb = 32'b00000000000000001111111000000000; //  ******
      5'h7:  rom_data_umb = 32'b00000000000000001111111100000000; //   ****
      5'h8:  rom_data_umb = 32'b00000000000000001111111110000000; //    **
      5'h9:  rom_data_umb = 32'b00000000000000001111111111000000; //    **
      5'hA:  rom_data_umb = 32'b00000000000000001111111111100000; //   ****
      5'hB:  rom_data_umb = 32'b00000000000000001111111111110000; //  ******
      5'hC:  rom_data_umb = 32'b00000000000000001111111111111000; // ********
      5'hD:  rom_data_umb = 32'b00000000000000001111111111111100; // ********
      5'hE:  rom_data_umb = 32'b00000000000000001111111111111110; //  ******
      5'hF:  rom_data_umb = 32'b11111111111111111111111111111111; //   ****
      5'h10: rom_data_umb = 32'b11111111111111111111111111111111;
      5'h11: rom_data_umb = 32'b00000000000000001111111111111110;
      5'h12: rom_data_umb = 32'b00000000000000001111111111111100;
      5'h13: rom_data_umb = 32'b00000000000000001111111111111000;
      5'h14: rom_data_umb = 32'b00000000000000001111111111110000;
      5'h15: rom_data_umb = 32'b00000000000000001111111111100000;
      5'h16: rom_data_umb = 32'b00000000000000001111111111000000;
      5'h17: rom_data_umb = 32'b00000000000000001111111110000000;
      5'h18: rom_data_umb = 32'b00000000000000001111111100000000;
      5'h19: rom_data_umb = 32'b00000000000000001111111000000000;
      5'h1A: rom_data_umb = 32'b00000000000000001111110000000000;
      5'h1B: rom_data_umb = 32'b00000000000000001111100000000000;
      5'h1C: rom_data_umb = 32'b00000000000000001111000000000000;
      5'h1D: rom_data_umb = 32'b00000000000000001110000000000000;
      5'h1E: rom_data_umb = 32'b00000000000000001100000000000000;
      5'h1F: rom_data_umb = 32'b00000000000000001000000000000000;
   endcase
   
   always @*
   case (rom_addr_p)
   // person ROM
   /*5'h0:  rom_data_p = 32'b10000000000000000000000000000000; //    **
   5'h1:  rom_data_p = 32'b01000000000000000000000000000000; //    **
   5'h2:  rom_data_p = 32'b00100000000000000000000000000000; //   ****
   5'h3:  rom_data_p = 32'b00010000000000000000000000000000; //  ******
   5'h4:  rom_data_p = 32'b00001000000000000000000000000000; // ********
   5'h5:  rom_data_p = 32'b00000100000000000000000000000000; // ********
   5'h6:  rom_data_p = 32'b00000010000000000000000000000000; //  ******
   5'h7:  rom_data_p = 32'b00000001000000000000000000000000; //   ****
   5'h8:  rom_data_p = 32'b00000000100000000000000000000000; //    **
   5'h9:  rom_data_p = 32'b00000000010000000001100000000000; //    **
   5'hA:  rom_data_p = 32'b00000000001000000001100000000000; //   ****
   5'hB:  rom_data_p = 32'b00000000000100000001100000001000; //  ******
   5'hC:  rom_data_p = 32'b00000000000010000001100000011100; // ********
   5'hD:  rom_data_p = 32'b00000000000001000001100000111110; // ********
   5'hE:  rom_data_p = 32'b00000000000000100001100001111111; //  ******
   5'hF:  rom_data_p = 32'b00000000000000011111111111111111; //   ****
   5'h10: rom_data_p = 32'b00000000000000011111111111111111;
   5'h11: rom_data_p = 32'b00000000000000100001100001111111;
   5'h12: rom_data_p = 32'b00000000000001000001100000111110;
   5'h13: rom_data_p = 32'b00000000000010000001100000011100;
   5'h14: rom_data_p = 32'b00000000000100000001100000001000;
   5'h15: rom_data_p = 32'b00000000001000000001100000000000;
   5'h16: rom_data_p = 32'b00000000010000000001100000000000;
   5'h17: rom_data_p = 32'b00000000100000000000000000000000;
   5'h18: rom_data_p = 32'b00000001000000000000000000000000;
   5'h19: rom_data_p = 32'b00000010000000000000000000000000;
   5'h1A: rom_data_p = 32'b00000100000000000000000000000000;
   5'h1B: rom_data_p = 32'b00001000000000000000000000000000;
   5'h1C: rom_data_p = 32'b00010000000000000000000000000000;
   5'h1D: rom_data_p = 32'b00100000000000000000000000000000;
   5'h1E: rom_data_p = 32'b01000000000000000000000000000000;
   5'h1F: rom_data_p = 32'b10000000000000000000000000000000;
   */
   
   4'h0:  rom_data_p = 16'b1000000000000000; //    **
   4'h1:  rom_data_p = 16'b0100000000000000; //    **
   4'h2:  rom_data_p = 16'b0100000000000000; //   ****
   4'h3:  rom_data_p = 16'b0010001000001000; //  ******
   4'h4:  rom_data_p = 16'b0010001000011100; // ********
   4'h5:  rom_data_p = 16'b0001001000111110; // ********
   4'h6:  rom_data_p = 16'b0001001001111111; //  ******
   4'h7:  rom_data_p = 16'b0000111111111111; //   ****
   4'h8:  rom_data_p = 16'b0000111111111111; //    **
   4'h9:  rom_data_p = 16'b0001001001111111; //    **
   4'hA:  rom_data_p = 16'b0001001000111110; //   ****
   4'hB:  rom_data_p = 16'b0010001000011100; //  ******
   4'hC:  rom_data_p = 16'b0010001000001000; // ********
   4'hD:  rom_data_p = 16'b0100000000000000; // ********
   4'hE:  rom_data_p = 16'b0100000000000000; //  ******
   4'hF:  rom_data_p = 16'b1000000000000000; //   ****
   
   endcase
   // registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            bar_y_reg <= 0;
            person_y_reg <= 0;
           // bar_x_reg <= 0;
            ball_x_reg_1 <= 0;
            ball_y_reg_1 <= 0;
            ball_x_reg_2 <= 0;
            ball_y_reg_2 <= 0;
            x_delta_reg_1 <= 10'h004;
            y_delta_reg_1 <= 10'h004;
            //ball_miss <= 0;
         end
      else
         begin
            bar_y_reg <= bar_y_next;
            person_y_reg <= person_y_next;
            //bar_x_reg <= bar_x_next;
            ball_x_reg_1 <= ball_x_next_1;
            ball_y_reg_1 <= ball_y_next_1;
            ball_x_reg_2 <= ball_x_next_2;
            ball_y_reg_2 <= ball_y_next_2;
            x_delta_reg_1 <= x_delta_next_1;
            y_delta_reg_1 <= y_delta_next_1;
         end

   // refr_tick: 1-clock tick asserted at start of v-sync
   //            i.e., when the screen is refreshed (60 Hz)
   assign refr_tick = (pix_y==481) && (pix_x==0);

   //--------------------------------------------
   // (wall) left vertical strip
   //--------------------------------------------
   // pixel within wall
   assign wall_on1 = (WALL_X_L1<=pix_y) && (pix_y<=WALL_X_R1); //replaced pix_x with pix_y for horizontal top wall
   assign wall_on2 = (WALL_X_L2<=pix_y) && (pix_y<=WALL_X_R2);
   // wall rgb output
   assign wall_rgb1 = 12'b1000_1000_1000; // blue
   assign wall_rgb2 = 12'b0000_1001_0000;
   //--------------------------------------------
   // right vertical bar (umbrella)
   //--------------------------------------------
   // boundary
   assign bar_y_t = bar_y_reg;
   //assign bar_x_l = bar_x_reg;
   //assign bar_x_r = bar_x_l + BAR_Y_SIZE - 1;
   assign bar_y_b = bar_y_t + BAR_Y_SIZE - 1;
   // pixel within bar
   assign bar_on = (BAR_X_L<=pix_y) && (pix_y<=BAR_X_R) &&
                   (bar_y_t<=pix_x) && (pix_x<=bar_y_b);
   assign rom_addr_umb = pix_x[4:0] - BAR_X_L[4:0]; 
   assign rom_col_umb = pix_y[4:0] - bar_y_t[4:0];
   assign rom_bit_umb = rom_data_umb[rom_col_umb];
   assign rd_umb_on = bar_on & rom_bit_umb;
   // bar rgb output
   assign bar_rgb = 12'b1111_1000_1001; // green
   // new bar y-position
   always @*
   begin
      bar_y_next = bar_y_reg; // no move
      if (refr_tick)
         if ((btn == 8'h23) & (bar_y_b < (MAX_Y-1-BAR_V)))
            begin
                bar_y_next = bar_y_reg + BAR_V; // move down
            end
         else if ((btn == 8'h1C) & (bar_y_t > BAR_V))
            begin
                bar_y_next = bar_y_reg - BAR_V; // move up
            end
   end

   //--------------------------------------------
   // square ball
   //--------------------------------------------
   // boundary
   assign ball_x_l_1 = ball_x_reg_1;
   assign ball_y_t_1 = ball_y_reg_1;
   assign ball_x_r_1 = ball_x_l_1 + BALL_SIZE - 1;
   assign ball_y_b_1 = ball_y_t_1 + BALL_SIZE - 1;
   // pixel within ball
   assign sq_ball_on_1 =
            (ball_x_l_1<=pix_y) && (pix_y<=ball_x_r_1) &&
            (ball_y_t_1<=pix_x) && (pix_x<=ball_y_b_1);
   // map current pixel location to ROM addr/col
   assign rom_addr_ball_1 = pix_x[2:0] - ball_x_l_1[2:0];
   assign rom_col_ball_1 = pix_y[2:0] - ball_y_t_1[2:0];
   assign rom_bit_ball_1 = rom_data_ball_1[rom_col_ball_1];
   // pixel within ball
   assign rd_ball_on_1 = sq_ball_on_1 & rom_bit_ball_1;
   // ball rgb output
   assign ball_rgb = 12'b0000_0000_1001;   // blue, was red
   // new ball position
   assign ball_x_next_1 = (refr_tick) ? ball_x_reg_1+x_delta_reg_1 :
                        ball_x_reg_1 ;
   assign ball_y_next_1 = (refr_tick) ? ball_y_reg_1+y_delta_reg_1 :
                        ball_y_reg_1;
   // new ball velocity
   always @*
   begin
      x_delta_next_1 = x_delta_reg_1;
      y_delta_next_1 = y_delta_reg_1;
      if (ball_y_t_1 < 1) // reach left (was top)
         y_delta_next_1 = BALL_V_P;
      else if (ball_y_b_1 > (MAX_Y-1)) // reach right (was bottom)
         y_delta_next_1 = BALL_V_N;
      else if (ball_x_l_1 <= WALL_X_R1) // reach wall
         x_delta_next_1 = BALL_V_P;    // bounce back
      else if ((BAR_X_L<=ball_x_r_1) && (ball_x_r_1<=BAR_X_R) &&
               (bar_y_t<=ball_y_b_1) && (ball_y_t_1<=bar_y_b))
         // reach x of right bar and hit, ball bounce back
         x_delta_next_1 = BALL_V_N; 
   end
   
    assign ball_x_l_2 = ball_x_reg_2;
     assign ball_y_t_2 = ball_y_reg_2;
     assign ball_x_r_2 = ball_x_l_2 + BALL_SIZE - 1;
     assign ball_y_b_2 = ball_y_t_2 + BALL_SIZE - 1;
     // pixel within ball
     assign sq_ball_on_2 =
              (ball_x_l_2<=pix_y) && (pix_y<=ball_x_r_2) &&
              (ball_y_t_2<=pix_x) && (pix_x<=ball_y_b_2);
     // map current pixel location to ROM addr/col
     assign rom_addr_ball_2 = pix_x[2:0] - ball_x_l_2[2:0];
     assign rom_col_ball_2 = pix_y[2:0] - ball_y_t_2[2:0];
     assign rom_bit_ball_2 = rom_data_ball_2[rom_col_ball_2];
     // pixel within ball
     assign rd_ball_on_2 = sq_ball_on_2 & rom_bit_ball_2;
     // ball rgb output
     // new ball position
     assign ball_x_next_2 = (refr_tick) ? ball_x_reg_2+x_delta_reg_2 :
                          ball_x_reg_2 ;
     assign ball_y_next_2 = (refr_tick) ? ball_y_reg_2+y_delta_reg_2 :
                          ball_y_reg_2;
     // new ball velocity
     always @*
     begin
        x_delta_next_2 = x_delta_reg_2;
        y_delta_next_2 = y_delta_reg_2;
        if (ball_y_t_1 < 2) // reach left (was top)
           y_delta_next_2 = BALL_V_P*2;
        else if (ball_y_b_2 > (MAX_Y-1)) // reach right (was bottom)
           y_delta_next_2 = BALL_V_N*2;
        else if (ball_x_l_2 <= WALL_X_R1) // reach wall
           x_delta_next_2 = BALL_V_P*2;    // bounce back
        else if ((BAR_X_L<=ball_x_r_2) && (ball_x_r_2<=BAR_X_R) &&
                 (bar_y_t<=ball_y_b_2) && (ball_y_t_2<=bar_y_b))
           // reach x of right bar and hit, ball bounce back
           x_delta_next_2 = BALL_V_P*2; //was BALL_V_N 
     end
  
   //person
      assign person_y_t = person_y_reg;
      assign person_y_b = person_y_t + person_SIZE - 1;
      // pixel within bar
      assign person_on = (person_X_L<=pix_y) && (pix_y<=person_X_R) &&
                      (person_y_t<=pix_x) && (pix_x<=person_y_b);
      assign rom_addr_p = pix_x[4:0] - person_X_L[4:0];
      assign rom_col_p = pix_y[4:0] - person_y_t[4:0];
      assign rom_bit_p = rom_data_p[rom_col_p];
      assign rd_person_on = person_on & rom_bit_p;
      // bar rgb output
      assign person_rgb = 12'b1111_0010_0000; // green
      // new bar y-position
      always @*
      begin
         person_y_next = person_y_reg; // no move
         if (refr_tick)
            if ((btn == 8'h4C) & (person_y_b < (MAX_Y-1-person_V)))
               begin
                   person_y_next = person_y_reg + person_V; // move down
               end
            else if ((btn == 8'h42) & (person_y_t > person_V))
               begin
                   person_y_next = person_y_reg - person_V; // move up
               end
      end
   
   //sound
   SongPlayer sound_gen(
    .clock(clk), .reset(reset), .audioOut(audioOut));
   
   //scoreboard
   text_scoreboard player1_P(
    .clk(clk), .reset(reset), .isOn(p1Pon), .pix_x(pix_x), .pix_y(pix_y), .posx1(0), .posx2(7));
   text_scoreboardL player1_L(
    .clk(clk), .reset(reset), .isOn(p1Lon), .pix_x(pix_x), .pix_y(pix_y), .posx1(8), .posx2(15));
   text_scoreboardA player1_A(
    .clk(clk), .reset(reset), .isOn(p1Aon), .pix_x(pix_x), .pix_y(pix_y), .posx1(16), .posx2(23));
   text_scoreboardY player1_Y(
    .clk(clk), .reset(reset), .isOn(p1Yon), .pix_x(pix_x), .pix_y(pix_y), .posx1(24), .posx2(31));
   text_scoreboardE player1_E(
    .clk(clk), .reset(reset), .isOn(p1Eon), .pix_x(pix_x), .pix_y(pix_y), .posx1(32), .posx2(39));
   text_scoreboardR player1_R(
    .clk(clk), .reset(reset), .isOn(p1Ron), .pix_x(pix_x), .pix_y(pix_y), .posx1(40), .posx2(47));
   text_scoreboardnum player1_N(
    .clk(clk), .reset(reset), .isOn(p1Non), .pix_x(pix_x), .pix_y(pix_y), .posx1(48), .posx2(55), .playerNum(1));
   m100_counter score1_0( 
    .clk(clk), .reset(reset), .d_inc(ball_miss1), .isOn(isOn1), .pix_x(pix_x), .pix_y(pix_y), .posx1(76), .posx2(83), .add10(add10_1));
   m100_counter2 score1_1( 
    .clk(clk), .reset(reset), .d_inc(ball_miss1), .isOn(isOn2), .pix_x(pix_x), .pix_y(pix_y), .posx1(68), .posx2(75), .add10(add10_1), .add100(add100_1));
   m100_counter3 score1_2( 
    .clk(clk), .reset(reset), .d_inc(ball_miss1), .isOn(isOn3), .pix_x(pix_x), .pix_y(pix_y), .posx1(60), .posx2(67), .add100(add100_1), .add10(add10_1));
   
   text_scoreboard player2_P(
    .clk(clk), .reset(reset), .isOn(p2Pon), .pix_x(pix_x), .pix_y(pix_y), .posx1(556), .posx2(563));
   text_scoreboardL player2_L(
    .clk(clk), .reset(reset), .isOn(p2Lon), .pix_x(pix_x), .pix_y(pix_y), .posx1(564), .posx2(571));
   text_scoreboardA player2_A(
    .clk(clk), .reset(reset), .isOn(p2Aon), .pix_x(pix_x), .pix_y(pix_y), .posx1(572), .posx2(579));    
   text_scoreboardY player2_Y(
    .clk(clk), .reset(reset), .isOn(p2Yon), .pix_x(pix_x), .pix_y(pix_y), .posx1(580), .posx2(587));
   text_scoreboardE player2_E(
    .clk(clk), .reset(reset), .isOn(p2Eon), .pix_x(pix_x), .pix_y(pix_y), .posx1(588), .posx2(595));
   text_scoreboardR player2_R(
    .clk(clk), .reset(reset), .isOn(p2Ron), .pix_x(pix_x), .pix_y(pix_y), .posx1(596), .posx2(603));
   text_scoreboardnum player2_N(
    .clk(clk), .reset(reset), .isOn(p2Non), .pix_x(pix_x), .pix_y(pix_y), .posx1(604), .posx2(611), .playerNum(2));
   m100_counter score2_0( 
    .clk(clk), .reset(reset), .d_inc(ball_miss1), .isOn(isOn4), .pix_x(pix_x), .pix_y(pix_y), .posx1(632), .posx2(639), .add10(add10_2));
   m100_counter2 score2_1( 
    .clk(clk), .reset(reset), .d_inc(ball_miss1), .isOn(isOn5), .pix_x(pix_x), .pix_y(pix_y), .posx1(624), .posx2(631), .add10(add10_2), .add100(add100_2));
   m100_counter3 score2_2( 
    .clk(clk), .reset(reset), .d_inc(ball_miss1), .isOn(isOn6), .pix_x(pix_x), .pix_y(pix_y), .posx1(616), .posx2(623), .add100(add100_2), .add10(add10_2));
   
   assign digit_rgb = 12'b0000_0000_0000;
    
   always @*
   begin
      if ((ball_x_l_1 > 480) || ((BAR_X_L<=ball_x_r_1) && (ball_x_r_1<=BAR_X_R) &&
                  (bar_y_t<=ball_y_b_1) && (ball_y_t_1<=bar_y_b)))
        begin
         ball_miss1 = 1'b1;
         ball_miss2 = 1'b1;
        end
        
      else if (((person_X_L<=ball_x_r_1) && (ball_x_r_1<=person_X_R) && (person_y_t<=ball_y_b_1) && (ball_y_t_1<=person_y_b)))
        begin
          ball_miss1 = 1'b1;
          ball_miss2 = 1'b0;
        end
      else
        ball_miss1 = 1'b0;
        ball_miss2 = 1'b0;   
   end
   
   //--------------------------------------------
   // rgb multiplexing circuit
   //--------------------------------------------
   always @*
      if (~video_on)
         graph_rgb = 12'b0000_0000_0000; // blank
      else
         if (wall_on1)
            graph_rgb = wall_rgb1;
         else if (wall_on2)
            graph_rgb = wall_rgb2;
         else if (rd_person_on)
            graph_rgb = person_rgb;
         else if (rd_umb_on)
            graph_rgb = bar_rgb;
         else if (rd_ball_on_1 || rd_ball_on_2)
            graph_rgb = ball_rgb;
         else if (isOn1 || isOn2 || isOn3 || isOn4 || isOn5 || isOn6)
            graph_rgb = digit_rgb;
         else if (p1Pon || p1Lon || p1Aon || p1Yon || p1Eon || p1Ron || p1Non || p2Pon || p2Lon || p2Aon || p2Yon || p2Eon || p2Ron || p2Non)
            graph_rgb = digit_rgb; //reuse black color
         else
            graph_rgb = 12'b1000_1000_1000; // now gray. yellow background would be 1111_1111_0000

endmodule
