package verifPkg;
    bit clk; bit nrst;
    int count = 100;

    //memory operation type
    typedef enum bit {
        READ,
        WRITE
    } m_op_e;

    //transactions to move between TB components
    typedef struct {
        bit [sparceMemPkg::ADDR_WIDTH-1 : 0] address;
        bit [sparceMemPkg::DATA_WIDTH-1 : 0] data;
        m_op_e opcode;
        sparceMemPkg::mem_op_e size;
    } packet_t;

    //mailboxes between TB components
    typedef mailbox #(packet_t) pkt_mbx;

    pkt_mbx seq_drv_mbx;
    pkt_mbx moni_chk_mbx;
    pkt_mbx mono_chk_mbx;

    initial begin
        forever #10 clk = ~clk;
    end

    sparceMemif bus_if(clk, nrst);

    function automatic build();
        seq_drv_mbx  = new(1);
        moni_chk_mbx = new(1);
        mono_chk_mbx = new(1);
    endfunction

    task automatic reset();
        bus_if.TB.cs <= 0;
        but_if.TB.we <= sparceMemPkg::NOP;
        but_if.TB.re <= sparceMemPkg::NOP;
        bur_if.TB.write_address <= '0;
        bur_if.TB.read_address  <= '0;
        bur_if.TB.write_data    <= '0;
        #10 nrst <= 0;
        #10 nrst <= 1;
    endtask

    // task to generate instruction sequences to the memory
    task automatic sequencer (int count);
        packet_t seq_pkt;

        bit [sparceMemPkg::ADDR_WIDTH-1 : 0] address_q [$];

        for (int i = 0; i <= count; i++) begin
            //if this is the first iteration, make a write operation
            if (i == 0) begin
                seq_pkt.opcode  = WRITE;
                seq_pkt.size    = sparceMemPkg::WORD_OP;
            end else begin
                seq_pkt.opcode  = $urandom();
                seq_pkt.size    = $urandom();
            end
            if (seq_pkt.opcode == WRITE) begin
                seq_pkt.address = $urandom();
                seq_pkt.data    = $urandom();

                address_q.push_back(seq_pkt.address);
            end else begin //if operation is READ
                address_q.shuffle();
                seq_pkt.address = address_q[$];
            end

            seq_drv_mbx.put(seq_pkt);
        end
    endtask

    //task to drive 
    task automatic driver();
        packet_t drv_pkt;

        forever begin
            seq_drv_mbx.get(drv_pkt);
            @(negedge clk);
            bus_if.TB.cs <= 1;
            if (drv_pkt.opcode == WRITE) begin
                bus_if.TB.we <= drv_pkt.size;
                bus_if.TB.re <= sparceMemPkg::NOP;
                bus_if.TB.write_address <= drv_pkt.address;
                bus_if.TB.write_data <= drv_pkt.data;
            end else if (drv_pkt.opcode == READ) begin
                bus_if.TB.re <= drv_pkt.size;
                bus_if.TB.we <= sparceMemPkg::NOP;
                bus_if.TB.read_address <= drv_pkt.address;
            end
        end
    endtask

    task automatic monitorOut();
        packet_t mono_pkt;

        forever begin
            @(posedge clk); #1;
            mono_pk.data <= bus_if.TB.read_data;
            mono_chk_mbx.put(mono_pkt);
        end
    endtask

    task automatic monitorIn();
        packet_t moni_pkt;

        forever begin
            @(posedge clk);
            if (bus_if.cs == 1) begin
                if (bus_if.we != sparceMemPkg::NOP) begin
                    moni_pkt.opcode  <= WRITE;
                    moni_pkt.address <= bus_if.write_address;
                    moni_pkt.data    <= bus_if.write_data;
                    moni_pkt.size    <= bus_if.we;
                end else if (bus_if.we != sparceMemPkg::NOP) begin
                    moni_pkt.opcode  <= WRITE;
                    moni_pkt.address <= bus_if.write_address;
                    moni_pkt.data    <= bus_if.write_data;
                    moni_pkt.size    <= bus_if.we;
                end else begin
                    if (nrst == 1) begin
                        $error("%m: [TB-ERR] Undefined Operation!");
                    end
                end
                if (nrst == 1) begin
                    moni_chk_mbx.put(moni_pkt);
                end
            end
        end
    endtask

    task automatic check();
        //logic [7: 0] MEM [*];
        packet_t in_pkt;
        packet_t out_pkt;
        packet_t chk_pkt;

        forever begin
            moni_chk_mbx.get(in_pkt);
            monp_chk_mbx.get(out_pkt);

            /*
            Checker logic here
            */
        end
    endtask

    task automatic finish();
        $display("%m: [TB-INFO] Test Complete!");
    endtask
    task automatic run_test();
        build();
        reset();
        fork
            sequencer();
            driver();
            monitorOut();
            monitorIn();
            check();
        join_any
        finish();
    endtask

endpackage
