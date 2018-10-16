/**
 * Module: arbiter
 *
 * Description:
 *  A look ahead, round-robing parametrized arbiter.
 *
 * <> request
 *  each bit is controlled by an actor and each actor can 'request' ownership
 *  of the shared resource by bring high its request bit.
 *
 * <> grant
 *  when an actor has been given ownership of shared resource its 'grant' bit
 *  is driven high
 *
 * <> select
 *  binary representation of the grant signal (optional use)
 *
 * <> active
 *  is brought high by the arbiter when (any) actor has been given ownership
 *  of shared resource.
 *
 *
 * Created: Sat Jun  1 20:26:44 EDT 2013
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 */
`ifndef _arbiter_ `define _arbiter_

module arbiter #(
   parameter NUM_PORTS = 6)
(
   input                               clk,
   input                               rst,
   input      [NUM_PORTS-1:0]          request,
   output reg [NUM_PORTS-1:0]          grant,
   output reg [clog2(NUM_PORTS)-1:0]   select,
   output reg                          active
);

   `include "verilog_utils.vh"

   localparam WRAP_LENGTH = 2*NUM_PORTS;

   // Find First 1 - Start from MSB and count downwards,
   // returns 0 when no bit set or bit0 is set
   function [clog2(NUM_PORTS)-1:0] ff1;
      input [NUM_PORTS-1:0] in;
      integer i;
      begin
         ff1 = 0;
         for (i = NUM_PORTS-1; i >= 0; i = i-1) begin
            if (in[i]) ff1 = i;
         end
      end
   endfunction

`ifdef VERBOSE
   initial $display("Bus arbiter with %d units", NUM_PORTS);
`endif

   wire                    next;
   wire [NUM_PORTS-1:0]    order;

   // only one bit in token is 1, the first check bit for request
   reg  [NUM_PORTS-1:0]    token;
   // if token is 0001
   //   token_lookahead[0]: 0001
   //   token_lookahead[1]: 1000
   //   token_lookahead[2]: 0100
   //   token_lookahead[3]: 0010
   // if token is 0010
   //   token_lookahead[0]: 0010
   //   token_lookahead[1]: 0001
   //   token_lookahead[2]: 1000
   //   token_lookahead[3]: 0100
   // if token is 0100
   //   token_lookahead[0]: 0100
   //   token_lookahead[1]: 0010
   //   token_lookahead[2]: 0001
   //   token_lookahead[3]: 1000
   // if token is 1000
   //   token_lookahead[0]: 1000
   //   token_lookahead[1]: 0100
   //   token_lookahead[2]: 0010
   //   token_lookahead[3]: 0001
   wire [NUM_PORTS-1:0]    token_lookahead [NUM_PORTS-1:0];
   wire [WRAP_LENGTH-1:0]  token_wrap;

   assign token_wrap   = {token, token};

   // next == 1 when (token & request) == 0
   // (token bit & request bit) == 0
   // means no request match this token, will trigger finding new token
   assign next = ~|(token & request);

   always @(posedge clk)
      grant <= token & request;

   always @(posedge clk)
      select <= ff1(token & request);

   always @(posedge clk)
      active <= |(token & request);

   // for NUM_PORTS = 4
   // initial token is 0001
   integer yy;
   always @(posedge clk)
      if (rst) token <= 'b1;
      else if (next) begin // no request match this token, choose new token
         for (yy = 0; yy < NUM_PORTS; yy = yy+1) begin : TOKEN_
            // token is changed only when find active request
            if (order[yy]) begin
               token <= token_lookahead[yy];
            end
         end
      end

   // for NUM_PORTS = 4
   // initial token is 0001, initial token_wrap is 00010001
   // so
   // token_lookahead[0] is 0001
   // token_lookahead[1] is 1000
   // token_lookahead[2] is 0100
   // token_lookahead[3] is 0010
   genvar xx;
   generate
      for (xx = 0; xx < NUM_PORTS; xx = xx+1) begin : ORDER_
         // token_lookahead[0] = token_wrap[3:0]
         // token_lookahead[1] = token_wrap[4:1]
         // token_lookahead[2] = token_wrap[5:2]
         // token_lookahead[3] = token_wrap[6:3]
         assign token_lookahead[xx]  = token_wrap[xx+:NUM_PORTS];
         // order[xx] == 1 if token bit and request bit is matched
         assign order[xx]            = |(token_lookahead[xx] & request);
      end
   endgenerate

endmodule

`endif //  `ifndef _arbiter_
