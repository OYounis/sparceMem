/*
    Module: Sparce Memory Top Module
*/
module sparceMemTop (interface mem_if);
    logic [BC - 1: 0][7: 0] MEM [*];

    logic [BADDR-1 : 0] baddr_wr;
    logic [BADDR-1 : 0] baddr_rd;

    assign baddr_rd = read_address[BADDR-1:0];
    assign baddr_wr = write_address[BADDR-1:0];

    always_ff @(mem_if.clk, mem_if.nrst) begin : read_block
        if (!mem_if.nrst) begin
            mem_if.read_data <= '0;
        end else if (mem_if.cs) begin
            if (mem_if.re != sparceMemPkg::NOP && MEM.exists(mem_if.read_address)) begin
                case (mem_if.re)
                    sparceMemPkg::BYTE_OP : begin
                        mem_if.read_data[baddr_rd] <= MEM[read_address][baddr_rd];
                    end sparceMemPkg::HALF_OP : begin
                        for(int i = 0; i < 2;i++) begin
                            mem_if.read_data[baddr_rd+i] <= MEM[read_address][baddr_rd+i];
                        end
                    end sparceMemPkg::WORD_OP : begin
                        for(int i = 0; i < 4;i++) begin
                            mem_if.read_data[baddr_rd+i] <= MEM[read_address][baddr_rd+i];
                        end
                    end
                    `ifndef  DATA_WIDTH_32
                    sparceMemPkg::DWORD_OP: begin
                        for(int i = 0; i < 8;i++) begin
                            mem_if.read_data[baddr_rd+i] <= MEM[read_address][baddr_rd+i];
                        end
                    end
                    `endif
                    default: $error("%m: [RD-ERR] Illegal read Operation!");
                endcase
            end else if (!MEM.exists(mem_if.read_address)) begin
                $error("%m: [RD-ERR] Element does not exist!");
            end
        end
    end

    always_ff @(mem_if.clk, mem_if.nrst) begin : write_block
        if (!mem_if.nrst) begin
            MEM.delete(); //delete memory contents
        end else if (mem_if.cs) begin
            if (mem_if.we != sparceMemPkg::NOP) begin
                case (mem_if.we)
                    sparceMemPkg::BYTE_OP : begin
                        MEM[write_address][baddr_wr] <= mem_if.write_data[baddr_wr];
                    end sparceMemPkg::HALF_OP : begin
                        for(int i = 0; i < 2;i++) begin
                            MEM[write_address][baddr_wr+i] <= mem_if.write_data[baddr_wr+i];
                        end
                    end sparceMemPkg::WORD_OP : begin
                        for(int i = 0; i < 4;i++) begin
                            MEM[write_address][baddr_wr+i] <= mem_if.write_data[baddr_wr+i];
                        end
                    end
                    `ifndef  DATA_WIDTH_32
                    sparceMemPkg::DWORD_OP: begin
                        for(int i = 0; i < 8;i++) begin
                            MEM[write_address][baddr_wr+i] <= mem_if.write_data[baddr_wr+i];
                        end
                    end
                    `endif
                    default: $error("%m: [WR-ERR] Illegal write Operation");
                endcase
            end
        end
    end
endmodule
