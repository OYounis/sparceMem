module sparceMemTB;
    bit clk; bit nrst;

    sparceMemif bus_if(clk, nrst);

    typedef struct {
        bit [sparceMemPkg::ADDR_WIDTH-1 : 0] address;
        bit [sparceMemPkg::DATA_WIDTH-1 : 0] data;
        sparceMemPkg::mem_op_e opcode;
    } packet_t;

    
    task automatic reset();
        #10 nrst = 0;
        #10 nrst = 1;
    endtask

    // task to generate instruction sequences to the memory
    task sequencer (int count);
        bit [sparceMemPkg::ADDR_WIDTH-1 : 0] address_q [$];
        bit [sparceMemPkg::DATA_WIDTH-1 : 0] data_q [$];
        sparceMemPkg::mem_op_e opcode_q[];

		repeat(count) begin
            
		end
	endtask

	task monitor_output();
		forever begin

		end
	endtask 

	task monitor_input();
		forever begin

		end
	endtask 

	task check_output();
		forever begin
			
		end
	endtask


    sparceMemTop(bus_if.DUT);

    initial begin
        forever #10 clk = ~clk;
    end

    initial begin
        reset();
        run();
        fin();
    end
endmodule
