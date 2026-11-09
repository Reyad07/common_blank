module simplest_baud_gen (
  input logic clk,
  output logic tx_en,
  output logic rx_en
);

  logic [12:0] tx_cnt;
  logic [9:0] rx_cnt;

  always_ff @(posedge clk) begin
     if (tx_cnt <5208) begin
      tx_cnt <= tx_cnt + 1;
     end
     else begin
       tx_cnt <= '0;
     end
   end

   always_ff @(posedge clk) begin
     if (rx_cnt <325) begin
      rx_cnt <= rx_cnt + 1;
     end
     else begin
       rx_cnt <= '0;
     end
   end

  assign tx_en = (tx_cnt == 0) ? 1'b1:'0;
  assign rx_en = (rx_cnt == 0) ? 1'b1:'0;

endmodule
