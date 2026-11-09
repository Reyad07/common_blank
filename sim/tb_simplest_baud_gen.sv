module tb_simplest_baud_gen;

  logic clk=0;
  logic tx_en;
  logic rx_en;

  baud_gen u_dut(.*);

  always #10 clk = ~clk;    // 50MHz

  initial begin
    #10000000;  // otherwise the tx_en wont be captured
    $finish;
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;
  end

endmodule
