const std = @import("std");
const aus = @import("assets_utils.zig");

fn read(file: *const std.fs.File) !void {
    var buf_reader = std.io.bufferedReader(file.*.reader());
    var in_stream = buf_reader.reader();

    const stdout_file = std.io.getStdOut().writer();
    var buf_writer = std.io.bufferedWriter(stdout_file);
    const stdout = buf_writer.writer();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try stdout.print("{s}\n", .{line});
        try buf_writer.flush();
    }
}

fn containsText(haystack: [][]const u8, needle: []const u8) bool {
    for (haystack) |thing| if (std.mem.eql(u8, thing, needle)) return true;
    return false;
}

fn extractTextFiles(
    collection: *std.fs.Dir,
    exclusions: *const aus.ExclusionsFileData,
    allocator : *const std.mem.Allocator
) !std.ArrayList(std.fs.File) {
    var text_files = std.ArrayList(std.fs.File).init(allocator.*);

    var it = collection.*.iterateAssumeFirstIteration();
    while (it.next()) |entry| {
        if (entry == null) break;
        if (entry.?.kind != .file
        or !std.mem.endsWith(u8, entry.?.name, ".txt")
        or  containsText(exclusions.*, entry.?.name)) continue;

        const file = try collection.openFile(entry.?.name, .{});
        try text_files.append(file);
    } else |_| {
        // Later, when a full on cmd or desktop application, bubble up to user.
        std.log.err("[LATIN_ROOT] @extractTextFiles v", .{});
    }

    return text_files;
}

fn processCollection(collection: *std.fs.Dir) !void {
    var   gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const exclusions_file = try collection.*.openFile(aus.EXCLUSIONS_JSON, .{});
    defer exclusions_file.close();
    const exclusions = try aus.parseJsonFromFile(aus.ExclusionsFileData, &exclusions_file, gpa.allocator());
    defer exclusions.deinit();

    const tests_file = try collection.*.openFile(aus.TESTS_JSON, .{});
    defer tests_file.close();
    const tests = try aus.parseJsonFromFile(aus.TestsFileData, &tests_file, gpa.allocator());
    defer tests.deinit();

    var   arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var text_files = try extractTextFiles(collection, &exclusions.value, &allocator);
    defer text_files.deinit();

    for (text_files.items) |text_file| {
        defer text_file.close();
        try read(&text_file);
    }
}

pub fn instantiateLatinModule() !void {
    var assets_dir = try std.fs.cwd().openDir(aus.ASSETS_FOLDER, .{ .iterate = true });
    defer assets_dir.close();

    var it = assets_dir.iterateAssumeFirstIteration();
    while (it.next()) |entry| {
        if (entry == null) break;
        if (entry.?.kind != .directory) {
            continue;
        }

        var collection = try assets_dir.openDir(entry.?.name, .{ .iterate = true });
        defer collection.close();

        try processCollection(&collection);
    } else |_| {
        // Later, when a full on cmd or desktop application, bubble up to user.
        std.log.err("[LATIN_ROOT] @instantiateLatinModule v", .{});
    }

    //TODO:
    //2. WRAP UP RULES
    //3. START DOING NLP INSTEAD OF PRINTING
}
