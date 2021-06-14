`timescale 1ns / 1ps

module text_scoreboard(
    input wire clk, reset,
    input wire [9:0] posx1, posx2,
    input wire [9:0] pix_x, pix_y,
    output wire isOn
    );
    
    localparam posy1 = 36;
    localparam posy2 = 43;
    //signal declaration
    wire [2:0] rom_addr1, rom_col1;
    reg [55:0] rom_data1;
    wire rom_bit1;
     
     always @*
     begin
     case (rom_addr1)
            //3'h0: rom_data1 = 56'b00111111_00000011_00111100_11000011_11111111_00111111_00011100_; //   ****
            //3'h1: rom_data1 = 56'b01100011_00000011_01100110_11000011_00000011_01100011_00011110_; //  **  **
            //3'h2: rom_data1 = 56'b11000011_00000011_11000011_01100110_00000011_11000011_00011011_; // **   ***
            //3'h3: rom_data1 = 56'b01100011_00000011_11111111_00111100_11111111_01100011_00011000_; // **  * **
            //3'h4: rom_data1 = 56'b00111111_00000011_11000011_00011000_11111111_00111111_00011000_; // ** *  **
            //3'h5: rom_data1 = 56'b00000011_00000011_11000011_00011000_00000011_01100011_00011000_; // ***   **
            //3'h6: rom_data1 = 56'b00000011_00000011_11000011_00011000_00000011_11000011_00011000_; //  **  **
            //3'h7: rom_data1 = 56'b00000011_11111111_11000011_00011000_11111111_10000011_01111110_; //   ****
            3'h0: rom_data1 = 8'b00111111; //   ****
            3'h1: rom_data1 = 8'b01100011; //  **  **
            3'h2: rom_data1 = 8'b11000011; // **   ***
            3'h3: rom_data1 = 8'b01100011; // **  * **
            3'h4: rom_data1 = 8'b00111111; // ** *  **
            3'h5: rom_data1 = 8'b00000011; // ***   **
            3'h6: rom_data1 = 8'b00000011; //  **  **
            3'h7: rom_data1 = 8'b00000011; //   ****
            
      endcase
     end
            
     //output
      assign rom_addr1 = pix_y[2:0] - posy1[2:0];
      assign rom_bit1 = rom_data1[rom_col1];
      assign rom_col1 = pix_x[2:0] - posx1[2:0];
      assign isOn = (posy1<=pix_y) && (pix_y<=posy2) && (posx1<=pix_x) && (pix_x<=posx2) && rom_bit1;
endmodule