const std = @import("std");
const builtin = @import("builtin");

const Allocator = std.mem.Allocator;
const File = std.fs.File;

const program_name = "yes";

fn usage(status: u8) noreturn {
    if (status != 0) {
        std.debug.print("Try '{s} --help' for more information.", .{program_name});
    } else {
        const help_message =
            \\Usage: {s} [STRING]...
            \\  or:  {s} OPTION
            \\Repeatedly output a line with all specified STRING(s), or 'y'.
            \\
            \\  --help     display this help and exit
            \\  --version  output version information and exit
            \\
        ;
        std.debug.print(help_message, .{ program_name, program_name });
    }
    std.process.exit(status);
}

fn version() noreturn {
    std.debug.print("{s} (zig port) 1.0\nCopyright (C) 2025 Free Software Foundation, Inc.", .{program_name});
    std.debug.print("License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.", .{});
    std.debug.print("This is free software: you are free to change and redistribute it.", .{});
    std.debug.print("There is NO WARRANTY, to the extent permitted by law.", .{});
    std.debug.print("\nWritten by David MacKenzie (original), ported to Zig.", .{});
    std.process.exit(0);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1) {
        const first_arg = args[1];
        if (std.mem.eql(u8, first_arg, "--help")) {
            usage(0);
        } else if (std.mem.eql(u8, first_arg, "--version")) {
            version();
        }
    }

    const output = if (args.len > 1) blk: {
        var buf = std.ArrayList(u8).init(allocator);
        defer buf.deinit();

        for (args[1..], 0..) |arg, i| {
            try buf.appendSlice(arg);
            if (i < args.len - 2) {
                try buf.append(' ');
            }
        }
        try buf.append('\n');
        break :blk try buf.toOwnedSlice();
    } else blk: {
        break :blk try allocator.dupe(u8, "y\n");
    };

    const stdout = std.io.getStdOut();
    const writer = stdout.writer();

    const buffer_size = @max(output.len, 4096);
    var buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(buffer);

    var bytes_written: usize = 0;
    while (bytes_written < buffer_size) {
        const copy_size = @min(output.len, buffer_size - bytes_written);
        @memcpy(buffer[bytes_written..][0..copy_size], output);
        bytes_written += copy_size;
    }

    while (true) {
        try writer.writeAll(buffer);
    }
}
