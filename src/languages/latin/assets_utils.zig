const std = @import("std");

pub const   ASSETS_FOLDER =    "assets/latin";
pub const      TESTS_JSON =      "tests.json";
pub const EXCLUSIONS_JSON = "exclusions.json";

pub const TestsFileData = struct { grammar: [][]u8, vocabulary: [][]u8, qna: [][]u8 };
pub const ExclusionsFileData = [][]u8;

const BabelJsonError = error{ ReadError, ParseError };

fn readJsonFromFile(
    file: *const std.fs.File,
    buffer: *const []u8
) BabelJsonError!usize {
    const read_size = file.*.readAll(buffer.*)
        catch |err| {
            std.debug.print("[LATIN ASSET UTILS] @readJsonFromFile v\n", .{});
            switch (err) {
                std.os.ReadError.AccessDenied    => { std.debug.print("Insufficient file permissions.", .{}); },
                std.os.ReadError.SystemResources => { std.debug.print("Insufficient system resources.", .{}); },
                else => { std.debug.print("Error {d}.", .{@errorName(err)}); }
            }
            return BabelJsonError.ReadError;
        };

    return read_size;
}

pub fn parseJsonFromFile(
    comptime T: type,
    file: *const std.fs.File,
    allocator: std.mem.Allocator
) BabelJsonError!std.json.Parsed(T) {
    const file_stats = file.*.stat()
        catch |err| {
            std.debug.print("[LATIN ASSET UTILS] @parseJsonFromFile v\n", .{});
            switch (err) {
                std.os.FStatError.AccessDenied    => { std.debug.print("Insufficient file permissions.", .{}); },
                std.os.FStatError.SystemResources => { std.debug.print("Insufficient system resources.", .{}); },
                else => { std.debug.print("Error {d}.", .{@errorName(err)}); }
            }
            return BabelJsonError.ReadError;
        };

    const json = allocator.alloc(u8, file_stats.size)
        catch |err| {
            std.debug.print("[LATIN ASSET UTILS] @parseJsonFromFile ${s}.\n", .{@errorName(err)});
            return BabelJsonError.ReadError;
        };
    defer allocator.free(json);

    if (try readJsonFromFile(file, &json) != file_stats.size) return BabelJsonError.ReadError;

    const parsed = std.json.parseFromSlice(T, allocator, json, .{})
        catch |err| {
            std.debug.print("[LATIN ASSET UTILS] @parseJsonFromFile: ${s}.\n", .{@errorName(err)});
            return BabelJsonError.ParseError;
        };

    return parsed;
}