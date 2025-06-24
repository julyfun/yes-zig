pub fn main() !void {
    const std = @import("std");
    var args = std.process.args();
    _ = args.skip();
    const arg = args.next();
    const out = std.io.getStdOut().writer();
    if (arg == null) {
        while (true) {
            try out.print("y\n", .{});
        }
    } else {
        while (true) {
            try out.print("{s}\n", .{arg.?});
        }
    }
}
