`timescale 1ns / 1ps

module MusicSheet( input [9:0] number,
output reg [19:0] note, //max 32 different musical notes
output reg [4:0] duration);

parameter HALF = 5'b00100;
parameter ONE = 2* HALF;
parameter TWO = 2* ONE;
parameter FOUR = 2* TWO;
parameter C4 = 25_000_000/262, D4 = 25_000_000/294, E4 = 25_000_000/330;
parameter F4 = 25_000_000/349, G4 = 25_000_000/392, A4 = 25_000_000/440; //number of FPGA clock periods.

always @ (number) begin
case(number) //It's Raining, It's Pouring
    0: begin note = 0; duration = ONE; end  
    1: begin note = 0; duration = TWO; end //hold 3 counts
    
    2: begin note = G4; duration = ONE; end //It's
    3: begin note = G4; duration = TWO; end //rain
    4: begin note = E4; duration = ONE; end //ing
    5: begin note = A4; duration = ONE; end //It's
    6: begin note = G4; duration = TWO; end //pour
    7: begin note = E4; duration = ONE; end //ing.
    8: begin note = E4; duration = ONE; end //The
    9: begin note = G4; duration = TWO; end //old
    10: begin note = E4; duration = ONE; end //man
    11: begin note = A4; duration = ONE; end //is
    12: begin note = G4; duration = TWO; end //snor
    13: begin note = E4; duration = TWO; end //ing.
    
    14: begin note = G4; duration = ONE; end //Went
    15: begin note = G4; duration = ONE; end //to
    16: begin note = E4; duration = ONE; end //bed
    17: begin note = E4; duration = HALF; end //and
    18: begin note = A4; duration = HALF; end //he
    19: begin note = G4; duration = ONE; end //bumped
    20: begin note = G4; duration = ONE; end //his
    21: begin note = E4; duration = ONE; end //head
    22: begin note = E4; duration = HALF; end //and
    23: begin note = A4; duration = HALF; end //he
    24: begin note = G4; duration = HALF; end //could
    25: begin note = G4; duration = HALF; end //n't
    26: begin note = A4; duration = ONE; end //get
    27: begin note = E4; duration = ONE; end //up
    28: begin note = E4; duration = HALF; end //in
    29: begin note = A4; duration = HALF; end //the
    30: begin note = G4; duration = TWO; end //morn
    31: begin note = E4; duration = TWO; end //ing
    default: begin note = C4; duration = FOUR; end
endcase
end
endmodule
