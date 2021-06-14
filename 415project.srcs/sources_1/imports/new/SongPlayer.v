`timescale 1ns / 1ps

module SongPlayer( input clock, input reset, output wire audioOut);
reg [19:0] counter;
reg [29:0] time1, noteTime;
reg [9:0] msec, number;	//millisecond counter, and sequence number of musical note.
wire [19:0] notePeriod;
reg audioOutReg;
parameter clockFrequency = 6_250_000;	//Nexys 100 MHz
wire [4:0] duration;
 MusicSheet PongSound(	number, notePeriod, duration	);
always @ (posedge clock) begin
    if(reset) begin counter <=0;  time1<=0;  number <=0;  audioOutReg <=1;	end
    else begin
        counter <= counter + 1; time1<= time1+1;
        if( counter >= notePeriod) begin
            counter <=0;  
            audioOutReg <= ~audioOutReg ; end	//toggle audio output 
        if( time1 >= noteTime) begin	
            time1 <=0;  number <= number + 1; end  //play next note
    end
end	
always @(duration) noteTime = duration * clockFrequency; //number of FPGA clock periods in one note.

assign audioOut = audioOutReg;
endmodule 