module ALU #(
    parameter DATA_W = 32
)
(
    input                       i_clk,   // clock
    input                       i_rst_n, // reset

    input                       i_valid, // input valid signal
    input [DATA_W - 1 : 0]      i_A,     // input operand A
    input [DATA_W - 1 : 0]      i_B,     // input operand B
    input [         2 : 0]      i_inst,  // instruction

    output [2*DATA_W-1  : 0]   o_data,  // output value
    output                      o_done   // output valid signal
);
// Do not Modify the above part !!!

// Parameters
    // ======== choose your FSM style ==========
    // 1. FSM based on operation cycles
    //parameter S_IDLE           = 2'd0;
    //parameter S_ONE_CYCLE_OP   = 2'd1;
    //parameter S_MULTI_CYCLE_OP = 2'd2;
    // 2. FSM based on operation modes
     parameter S_IDLE = 4'd0;
     parameter S_ADD  = 4'd1;
     parameter S_SUB  = 4'd2;
     parameter S_AND  = 4'd3;
     parameter S_OR   = 4'd4;
     parameter S_SLT  = 4'd5;
     parameter S_SRA  = 4'd6;
     parameter S_MUL  = 4'd7;
     parameter S_DIV  = 4'd8;
     parameter S_OUT  = 4'd9;

// Wires & Regs
    // Todo
    // state
    reg  [         4: 0] state, state_nxt; // remember to expand the bit width if you want to add more states!
    // load input
    reg  [  DATA_W-1: 0] operand_a, operand_a_nxt;
    reg  [  DATA_W-1: 0] operand_b, operand_b_nxt;
    reg  [         2: 0] inst, inst_nxt;
    reg [64:0] outp;  
    reg [6: 0] counter;
    reg done;
    reg [32:0]add1;
    reg [32:0]sub1;
    reg [64:0] mul1,mul2, mul3;
    reg [64:0] div1,div2,div3,div4,div5,div6;

    parameter ADD = 3'd0;
    parameter SUB = 3'd1;
    parameter AND = 3'd2;
    parameter OR = 3'd3;
    parameter SLT = 3'd4;
    parameter SRA = 3'd5;
    parameter MUL = 3'd6;
    parameter DIV = 3'd7;
    
// Wire Assignments
    // Todo
    
// Always Combination
    // load input
    always @(*) begin
        if (i_valid) begin
            operand_a_nxt = i_A;
            operand_b_nxt = i_B;
            inst_nxt      = i_inst;
        end
        else begin
            operand_a_nxt = operand_a;
            operand_b_nxt = operand_b;
            inst_nxt      = inst;
        end
    end
    // Todo: FSM
    always @(*) begin
        state_nxt = state;
        case(state)
            S_IDLE  :
                if (i_valid) begin
                    case(i_inst)    
                        ADD : state_nxt = S_ADD;
                        SUB : state_nxt = S_SUB;
                        AND : state_nxt = S_AND;
                        OR : state_nxt = S_OR;
                        SLT : state_nxt = S_SLT;
                        SRA : state_nxt = S_SRA;
                        MUL : state_nxt = S_MUL;
                        DIV : state_nxt = S_DIV;
                        default : state_nxt = state;
                    endcase
                end
            S_ADD  : state_nxt = S_OUT;
            S_SUB  : state_nxt = S_OUT;
            S_AND  : state_nxt = S_OUT;
            S_OR   : state_nxt = S_OUT;
            S_SLT  : state_nxt = S_OUT;
            S_SRA  : state_nxt = S_OUT;
            S_MUL  : if (counter == 32) 
                        state_nxt = S_OUT;
            S_DIV  : if (counter == 32)
                        state_nxt = S_OUT;
            S_OUT  : state_nxt = S_IDLE;
            default : state_nxt = state;
        endcase
    end
    // Todo: Counter
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            counter <= 0;
            end
        else begin
            if (state_nxt == S_MUL || state_nxt == S_DIV || state_nxt ==S_OUT) begin
                if(counter <33) begin
                    counter <= counter + 1;
                    if(counter==32) done <= 1;
                end 
                else counter <= 0;
            end
            else counter <= 0;
        end
    end
    // Todo: ALU output
    assign o_data = outp;
    assign o_done = done;
    

    always @(*) begin               
        mul1 = outp >> 1;       
    end
    
    always @(*) begin
        mul2 = {(outp[64:32]+operand_a),outp[31:0]};
        mul3 = mul2 >> 1;
    end

    always @(*) begin
        div1 = outp << 1;
        div2 = {div1[64: 33], div1[31: 0]};
    end

    always @(*) begin
        div3 = {outp[64:32] - operand_b, outp[31:0]};
        div4 = div3 << 1;
        div5 = {div4[64:1],1'b1};
        div6 = {div5[64:33],div5[31:0]};
    end

    always @(*) begin
        add1 = operand_a + operand_b;
    end

    always @(*) begin
        sub1 = operand_a - operand_b;
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            outp <= 0;
            done <= 0;
            end
        else begin
            if(state_nxt==S_IDLE) outp <= 0;
            
            if(state==S_IDLE) begin
                // done <=0;
                if(inst_nxt==MUL && counter==0) begin
                    outp[31:0] <= operand_b_nxt;
                    outp[64:32] <= 33'h0;
                end
                if(inst_nxt==DIV && counter==0) outp <= operand_a_nxt << 1;
            end
            else if(state==S_OUT) done <= 0;
            else if(state_nxt==S_MUL && counter==0) outp <= operand_b_nxt;
            else if(state==S_MUL) begin
                if (counter < 33) begin
                    if(outp[0] == 0) 
                        outp <= mul1;
                    else outp <= mul3;    
                end
                
            end
            // else if(state==S_DIV) begin

            // end
            else begin
                case (state)
                    S_ADD : begin
                        if (operand_a[31] == 1'd1 && operand_b[31] == 1'd1 && add1[31] == 0) 
                            outp <= 64'h80000000;
                        else if (operand_a[31] == 0 && operand_b[31] == 0 && add1[31] == 1'd1)
                            outp <= 64'h7fffffff; 
                        else
                            outp <= add1[31:0];
                        done <= 1;
                    end
                    S_SUB : begin
                        if (operand_a[31] == 1 && operand_b[31] == 0 && sub1[31] == 0) 
                            outp <= 64'h80000000;
                        else if (operand_a[31] == 0 && operand_b[31] == 1 && sub1[31] == 1)
                            outp <= 64'h7fffffff; 
                        else 
                            outp <= sub1[31:0];
                        done <= 1;
                    end

                    S_AND : begin 
                        outp <= operand_a & operand_b; 
                        done <= 1;
                    end

                    S_OR : begin
                        outp <= operand_a | operand_b; 
                        done <= 1; 
                    end

                    S_SLT : begin
                        if (operand_a[31] == 1 && operand_b[31] == 0)
                            outp <= 32'b1;
                        else if (operand_a[31] == 0 && operand_b[31] == 1)
                            outp <= 32'b0;
                        else
                            outp <= (operand_a < operand_b) ? 32'b1 : 32'b0; 
                        done <= 1;
                    end
                    S_SRA : begin
                        if (operand_a[31] == 1) begin
                            outp <= $signed(operand_a)>>>operand_b;
                            outp[64:32] <= 33'h0;
                            end
                        else 
                            outp <= $signed(operand_a)>>>operand_b;
                        done <= 1;
                    end
                    S_MUL : begin
                        if (counter < 33) begin
                            if(outp[0] == 0) 
                                outp <= mul1;
                            else outp <= mul3;    
                        end
                    end

                    S_DIV : begin
                        if (counter == 32) begin
                            if(outp[64:32] < operand_b) 
                                outp <= div2;
                            else outp <= div6;    
                        end
                        else begin
                            if(outp[64:32] < operand_b) 
                                outp <= div1;
                            else outp <= div5;
                        end

                    end
                    

                endcase
                    // done <= 1;
                end
            end
    end
    // Todo: output valid signal

    // Todo: Sequential always block
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state       <= S_IDLE;
            operand_a   <= 0;
            operand_b   <= 0;
            inst        <= 0;
        end
        else begin
            state       <= state_nxt;
            operand_a   <= operand_a_nxt;
            operand_b   <= operand_b_nxt;
            inst        <= inst_nxt;
        end
    end

endmodule
