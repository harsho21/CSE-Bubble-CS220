`timescale 1ns / 1ps

//module for addition
module func_add(input [31:0] op1,
           input [31:0] op2,
           output [31:0] result);
assign result = op1+op2;
endmodule

//module for subtraction
module func_sub(input [31:0] op1,
           input [31:0] op2,
           output [31:0] result);
assign result = op1 - op2;
endmodule

//module for and operation
module func_and(input [31:0] op1,
           input [31:0] op2,
           output [31:0] result);
assign result = op1&b;
endmodule

//module for or operation
module func_or(input [31:0] op1,
           input [31:0] op2,
           output [31:0] result);
assign result = op1|b;
endmodule

//module for shift left operation
module func_sll(input [31:0] op1,
           input [4:0] op2,
           output [31:0] result);
assign result = op1>>op2;
endmodule

//module for shift right operation
module func_srl(input [31:0] op1,
           input [4:0] op2,
           output [31:0] result);
assign result = op1<<op2;
endmodule

// whole CSE BUBBLE is covered in this module, it includes memory, fetching data from memory, alu with braching operation, decoding instruction
module CSE_BUBBLE(clk);
input clk;

//program counter
reg [9:0] pc;

//variables to store different fields of instruction
reg [5:0] op;
reg [5:0] fun;
reg [4:0] rs;
reg [4:0] rd;
reg [4:0] rt;
reg [15:0] imm;
reg [4:0] shamt;
reg [25:0] tar_add;

//instruction
reg [31:0] instruction;

//regi is set of 32 required registers
reg [31:0] regi [31:0];
//memory_veda is required memory
reg [31:0] memory_veda [1023:0];

//this are the variables which will store result of above operations in above mentioned modules
wire [31:0] out_add;
wire [31:0] out_sub;
wire [31:0] out_and;
wire [31:0] out_or;
wire [31:0] out_sll;
wire [31:0] out_srl;

// storing machine code in memory
initial begin
    memory_veda[0]=00000010100100011010000000100000;
    memory_veda[1]=00101000001000100000000000000000;
    memory_veda[2]=10001101001000010000000000001000;
    memory_veda[3]=10001101001100010000000000000000;
    memory_veda[4]=00100001000000100001000000100000;
    memory_veda[5]=00010001100010100000000000000001;
    memory_veda[6]=00100001000001010001000000100000;
    memory_veda[7]=10001101010010010000000000000000;
    memory_veda[8]=00010010010010100000000000000001;
    memory_veda[9]=00100001000001100010000000100000;
    memory_veda[10]=00010001100101010000000000000000;
    memory_veda[11]=10001101011000100000000000001000;
    memory_veda[12]=00010001100101000000000000000001;
    memory_veda[13]=10001101011010010000000000000000;
    memory_veda[14]=00100001000010010010000000100000;
    memory_veda[15]=00010001100111000000000000000001;
    memory_veda[16]=10001101011100100000000000001000;
    memory_veda[17]=00100001000011000010000000100000;
    memory_veda[18]=00000010100100001001000000100000;
    memory_veda[19]=10001101010011000000000000001000;
    memory_veda[20]=00010010010010010000000000000001;
    memory_veda[21]=00100001000100100010000000100000;
    memory_veda[22]=00010001101000000000000000000010;
    memory_veda[23]=00100001000101000100000000100000;
    memory_veda[24]=00010001100101000000000000000001;
    memory_veda[25]=00100001000101001010000000100000;
    memory_veda[26]=00010001100101010000000000000001;
    memory_veda[27]=10001101011000100000000000001000;
    memory_veda[28]=00010001100101000000000000000001;
    memory_veda[29]=10001101011010010000000000000000;
    memory_veda[30]=00100001000010010010000000100000;
    memory_veda[31]=00010001100111000000000000000001;
    memory_veda[32]=10001101011100100000000000001000;
    memory_veda[33]=00100001000011000010000000100000;

end

//this always block fetch instruction from memory
always @(posedge clk) begin
        instruction = memory_veda[pc];
        $display($time, "ins=%b\n",instruction);
end

//initializing all 32 registers
initial begin
    pc = 0;
    regi[0] = 32'd0;
    regi[1] = 32'd0;
    regi[2] = 32'd0;
    regi[3] = 32'd0;
    regi[4] = 32'd0;
    regi[5] = 32'd0;
    regi[6] = 32'd0;
    regi[7] = 32'd0;
    regi[8] = 32'd0;
    regi[9] = 32'd0;
    regi[10] = 32'd0;
    regi[11] = 32'd0;
    regi[12] = 32'd0;
    regi[13] = 32'd0;
    regi[14] = 32'd0;
    regi[15] = 32'd0;
    regi[16] = 32'd0;
    regi[17] = 32'd0;
    regi[18] = 32'd0;
    regi[19] = 32'd0;
    regi[20] = 32'd0;
    regi[21] = 32'd0;
    regi[22] = 32'd0;
    regi[23] = 32'd0;
    regi[24] = 32'd0;
    regi[25] = 32'd0;
    regi[26] = 32'd0;
    regi[27] = 32'd0;
    regi[28] = 32'd0;
    regi[29] = 32'd0;
    regi[30] = 32'd0;
    regi[31] = 32'd0;
end
output reg [31:0] out;

//following instantiation of above modules
func_add uut1(regi[rs],regi[rt],out_add);
func_and uut2(regi[rs],regi[rt],out_and);
func_sub uut3(regi[rs],regi[rt],out_sub);
func_sll uut4(regi[rt],shamt,out_sll);
func_srl uut5(regi[rt],shamt,out_srl);
func_or uut6(regi[rs],regi[rt],out_or);

//this always block do decoding of instruction and alu operations
always @(negedge clk)
begin

    op=instruction[31:26];  
    rs = instruction[25:21];
    rt = instruction[20:16];
    rd = instruction[15:11];
    shamt = instruction[10:6];
    fun = instruction[5:0];
    tar_add[25:0] = instruction[25:0];
    imm[15:0] = instruction[15:0];
    
// case statement is used to perfrom different operations in alu 
    case(op)
        6'b000000: case(fun)
// if opcode is 000000 then it checks for fun field
                     6'b100000: begin                                
                                regi[rd] = out_add;
                                pc = pc + 1;
                                end

                    6'b100010: begin                              
                               regi[rd] = out_sub;
                               pc = pc + 1;
                               end

                    6'b100001: begin                                
                                regi[rd] = out_add;
                                pc = pc + 1;
                                end

                    6'b100011: begin                              
                               regi[rd] = out_sub;
                               pc = pc + 1;
                               end

                    6'b100100: begin
                               regi[rd] = out_and;
                               pc = pc + 1;

                               end

                    6'b100101: begin                               
                               regi[rd] = out_or;
                               pc = pc + 1;
                               end

                    6'b000000: begin                              
                               regi[rd] = out_sll;
                               pc = pc + 1;
                               end

                    6'b000010: begin                              
                               regi[rd] = out_srl;
                               pc = pc + 1;
                               end

                    6'b001000: pc = regi[rs];

                    6'b101010: begin
                               if(regi[rs] < regi[rt]) regi[rd] = 1;
                               else regi[rd] = 0;
                               pc = pc + 1;
                               end
                   endcase

        6'b001000 : begin
                        regi[rt] = regi[rs] + imm[15:0];
                        pc = pc + 1;
                    end

        6'b001001 : begin  
                        regi[rt] = regi[rs] + imm[15:0];
                        pc = pc + 1;
                    end

        6'b001100 : begin
                        regi[rt] = regi[rs] & imm[15:0];
                        pc = pc + 1;
                    end

        6'b001101 : begin
                        regi[rt] = regi[rs] | imm[15:0];
                        pc = pc + 1;
                    end

        6'b100011 : begin
                        regi[rt] = memory_veda[regi[rs] +  imm];
                        out = regi[rt];
                        pc = pc + 1;
                    end

        6'b101011 : begin
                        memory_veda[regi[rs] +  imm] = regi[rt];
                        pc = pc + 1;
                    end

        6'b000100 : if(regi[rt] == regi[rs]) begin
                                                 pc = pc + 1 + imm[5:0];
                                             end
        
        6'b000101 : if(regi[rt] != regi[rs]) pc = pc + 1 + imm[9:0];
        6'b000111 : if(regi[rs] > regi[rt]) pc = pc + 1 + imm[9:0];
        6'b001111 : if(regi[rs] >= regi[rt]) pc = pc + 1 + imm[9:0];
        6'b000110 : if(regi[rs] < regi[rt]) pc = pc + 1 + imm[9:0];
        6'b011111 : if(regi[rs] <= regi[rt]) pc = pc + 1 + imm[9:0];
        6'b000010 : pc = tar_add[9:0];
        
        6'b000011 : begin  
                        $display("Jump and link "); 
                        regi[5'b11111] = pc + 1;
                        pc = tar_add[9:0];
                    end

        6'b001010 : begin
                        $display("Set on less than immediate");
                        if(regi[rt] < imm) regi[rs] = 1;
                        else regi[rs] = 0;
                        pc = pc + 1;
                    end
    endcase
end

endmodule

// testbench to simulate CSE BUBBLE
module tb;

reg clk;
CSE_BUBBLE uut (clk);

initial begin
clk = 0;
forever #10 clk = ~clk;
end

initial begin
    #400 $finish;
end

endmodule


