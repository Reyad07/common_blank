class packet;

  rand bit [7:0] payload [];
  rand bit [3:0] priority_level;
  bit [7:0] checksum;
  int packet_id;

  constraint payload_c {payload.size inside {[8'h4:8'hF]}; }
  constraint priority_lvl_c {
    priority_level dist {[0:7] := 80, [8:15] := 20};
  }

  static int count = 0;

function void pre_randomize();
    count ++;
    packet_id = count;
    $display("Pre_Randomize: packet_id = %0d", packet_id);
endfunction

function void post_randomize();
  checksum = payload.xor();
    if (priority_level > 10) begin
        checksum =~ checksum;
    end
endfunction

endclass

class generator;

    mailbox #(packet) gen2drv_mbx;
    event drv_done; // Handle to shared synchroniztion event
    bit [7:0] num_pkts;   // target transaction count 5

    function new (mailbox #(packet) gen2drv_mbx, event drv_done);
        this.gen2drv_mbx = gen2drv_mbx;
        this.drv_done = drv_done;
    endfunction

    task run();
        foreach (num_pkts[i]) begin
            packet pkt = new();

            if (!pkt.randomize()) $fatal(1,"Randomization Failed!");
            gen2drv_mbx.put(pkt);
            @(drv_done);    // block execution until driver finish
        end
    endtask

endclass

class driver;

    mailbox #(packet) gen2drv_mbx;  // handle to shared mailbox
    event drv_done;     // handle to shared synchronization event
    packet pkt;         // temporary container for received handle
    bit [7:0] exp_parity;

    function new(mailbox #(packet) gen2drv_mbx, event drv_done);
        this.gen2drv_mbx = gen2drv_mbx;
        this.drv_done = drv_done;
    endfunction

    task run();
        forever begin
            gen2drv_mbx.get(pkt);
            #10;
          exp_parity = pkt.payload.xor();
          if (pkt.priority_level >10) exp_parity = ~exp_parity;
          if (pkt.checksum != exp_parity) $display("parity did not match for pkt_id: %0d expected: 0b%0b, got: 0b%0b", pkt.packet_id, exp_parity, pkt.checksum);
            -> drv_done;
        end
    endtask

endclass

module tb;
    mailbox #(packet) gen2drv_mbx = new();
    event drv_done;

    generator gen = new(gen2drv_mbx, drv_done);
    driver drv = new (gen2drv_mbx, drv_done);

    initial begin
        fork
            gen.run();
            drv.run();
        join_any
        #20;
        $finish;
    end

endmodule
