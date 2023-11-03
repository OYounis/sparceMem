import verifPkg::*;

module sparceMemTB;

    sparceMemTop DUT(bus_if.DUT);

    initial begin
        run_test();
    end
endmodule
