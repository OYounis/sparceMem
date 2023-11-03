`define ADDR_WIDTH_32
//`define ADDR_WIDTH_64
//`define DATA_WIDTH_32
`define DATA_WIDTH_64
`define DATA_WIDTH_128

`ifdef ADDR_WIDTH_64
    `define ADDR_WIDTH 64
`else
    `define ADDR_WIDTH 32
`endif

`ifdef DATA_WIDTH_64
    `define DATA_WIDTH 64
`else
    `define DATA_WIDTH 32
`endif
