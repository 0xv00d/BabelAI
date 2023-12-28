const std = @import("std");

pub const   ASSETS_FOLDER =    "assets/latin";
pub const      TESTS_JSON =      "tests.json";
pub const EXCLUSIONS_JSON = "exclusions.json";

pub const TestsFileData = struct { grammar: [][]u8, vocabulary: [][]u8, qna: [][]u8 };
pub const ExclusionsFileData = [][]u8;

const BabelError = error{JsonReadError};
fn readJsonFromFile(
    file: *const std.fs.File,
    buffer: *const []u8
) !void {
    const read_size = try file.*.readAll(buffer.*);

    const file_stats = try file.*.stat();
    if (read_size != file_stats.size) return BabelError.JsonReadError;

    return;
}

// Use generics for this.
pub fn getExclusionsFileData(
    file: *const std.fs.File,
    allocator: std.mem.Allocator
) !std.json.Parsed(ExclusionsFileData) {
    const file_stats = try file.*.stat();

    const json = try allocator.alloc(u8, file_stats.size);
    defer allocator.free(json);

    try readJsonFromFile(file, &json);

    const exclusions = try std.json.parseFromSlice(ExclusionsFileData, allocator, json, .{});
    return exclusions;
}

pub fn getTestsFileData(
    file: *const std.fs.File,
    allocator: std.mem.Allocator
) !std.json.Parsed(TestsFileData) {
    const file_stats = try file.*.stat();

    const json = try allocator.alloc(u8, file_stats.size);
    defer allocator.free(json);

    try readJsonFromFile(file, &json);

    const tests = try std.json.parseFromSlice(TestsFileData, allocator, json, .{});
    return tests;
}
