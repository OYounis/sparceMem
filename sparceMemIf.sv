interface sparceMemif(
    input logic clk,
    input logic nrst);

    logic cs;     // Memory Chip Select, Active low
    mem_op_e we;  // Memory Write Enable
    mem_op_e re;  // Memory Read Enable

    logic [sparceMemPkg::ADDR_WIDTH-1 : 0] write_address;
    logic [sparceMemPkg::ADDR_WIDTH-1 : 0] read_address;

    logic [sparceMemPkg::BC - 1: 0][7:0] write_data;
    logic [sparceMemPkg::BC - 1: 0][7:0] read_data;

    modport DUT (
    input clk,
    input nrst,
    input cs,
    input we,
    input re,
    input write_address,
    input read_address,
    input write_data,
    output read_data
    );

    modport TB (
    output clk,
    output nrst,
    output cs,
    output we,
    output re,
    output write_address,
    output read_address,
    output write_data,
    input read_data
    );
endinterface : sparceMemif
