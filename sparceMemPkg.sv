package sparceMemPkg;
    parameter int ADDR_WIDTH = `ADDR_WIDTH; //minimum is 32bits
    parameter int DATA_WIDTH = `DATA_WIDTH; //minimum is 32bits

    //byte count parameter
    //The number of bytes in a dataword
    parameter int BC = sparceMemPkg::DATA_WIDTH / 8;
    //byte address parameter
    //The address size required to represent the bytes
    parameter int BADDR = $clog2(BC);

    typedef enum logic[1:0] {
        BYTE_OP,
        HALF_OP,
        WORD_OP,
        `ifndef DATA_WIDTH_32
        DWORD_OP,
        `endif
        NOP
    } mem_op_e;
endpackage
