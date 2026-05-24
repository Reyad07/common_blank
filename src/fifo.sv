module fifo(
    input logic         clk_i,
    input logic         arst_ni,
    input logic [7:0]   data_i,
    input logic         push_i,
    input logic         pop_i,
    output logic [7:0]  data_o,
    output logic        full_o,
    output logic        empty_o
);
    logic [7:0] fifo_mem [4];
    logic [1:0] count;      // counter to keep track of the number of elements in the FIFO
    logic [1:0] rd_ptr;     // read pointer
    logic [1:0] wr_ptr;     // write pointer
    logic       full;       // fifo full status
    logic       empty;      // fifo empty status


    // ================================================================================================
    // counter update based on wr_ptr and rd_ptr
    //    R W | T
    //    0 0 | T       no read no write
    //    0 1 | T + 1   Write but no read
    //    1 0 | T - 1   Read but no write
    //    1 1 | T       read and write both
    // ================================================================================================
    always_comb begin
        count = '0;
        case({rd_ptr, wr_ptr})
            2'b00: count = count;
            2'b01: count = count + 1;
            2'b10: count = count - 1;
            2'b11: count = count;
            default: begin end
        endcase
    end

    // ================================================================================================
    // full and empty condition implementation
    // ================================================================================================
    always_comb begin
        // fifo_mem will be full when count value reaches to 2'b11 or 3; meaning 4 elements
        full  = (count == 2'b11) ? 1'b1 : 0;
        // fifo will be empty if both read and write pointer are 0
        empty = (rd_ptr == '0 && wr_ptr == '0) ? 1'b1 : 1'b0;
    end

    // ================================================================================================
    // connecting the internal logic to the IO ports of the module
    // ================================================================================================
    always_comb begin
        full_o = full;
        empty_o = empty;
    end

    // ================================================================================================
    // fifo memroy (fifo_mem) update
    // ================================================================================================
    always_ff @(posedge clk_i or negedge arst_ni) begin
        if (arst_ni == 0) begin
            rd_ptr <= '0;
            wr_ptr <= '0;
        end
        else begin
            if (push_i == 1 && full != 1 ) begin    // push_i should be set and fifo cannot be full
                fifo_mem[wr_ptr] <= data_i;
                wr_ptr++;                           // increment the write pointer after each write
            end
            else if (pop_i == 1 && empty != 1) begin    // read from fifo_mem only when pop_i is set and empty is not set
                data_o <= fifo_mem[rd_ptr];
                rd_ptr++;
            end
        end
    end

endmodule
