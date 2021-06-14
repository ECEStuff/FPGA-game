`timescale 1ns / 1ps


module text_scoreboardnum(
    input wire clk, reset,
    input wire [9:0] posx1, posx2,
    input wire [9:0] pix_x, pix_y,
    input wire [1:0] playerNum,
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
     case (playerNum)
     1: case (rom_addr1)
            3'h0: rom_data1 = 8'b00011100; //   ****
            3'h1: rom_data1 = 8'b00011110; //  **  **
            3'h2: rom_data1 = 8'b00011011; // **   ***
            3'h3: rom_data1 = 8'b00011000; // **  * **
            3'h4: rom_data1 = 8'b00011000; // ** *  **
            3'h5: rom_data1 = 8'b00011000; // ***   **
            3'h6: rom_data1 = 8'b00011000; //  **  **
            3'h7: rom_data1 = 8'b01111110; //   ****
         endcase
      
     2: case (rom_addr1)
            3'h0: rom_data1 = 8'b00111100; //   ****
            3'h1: rom_data1 = 8'b01100110; //  **  **
            3'h2: rom_data1 = 8'b11000011; // **   ***
            3'h3: rom_data1 = 8'b01100001; // **  * **
            3'h4: rom_data1 = 8'b00110000; // ** *  **
            3'h5: rom_data1 = 8'b00001100; // ***   **
            3'h6: rom_data1 = 8'b00000011; //  **  **
            3'h7: rom_data1 = 8'b01111111; //   ****
      endcase
     endcase
    end
            
     //output
      assign rom_addr1 = pix_y[2:0] - posy1[2:0];
      assign rom_bit1 = rom_data1[rom_col1];
      assign rom_col1 = pix_x[2:0] - posx1[2:0];
      assign isOn = (posy1<=pix_y) && (pix_y<=posy2) && (posx1<=pix_x) && (pix_x<=posx2) && rom_bit1;
endmodule