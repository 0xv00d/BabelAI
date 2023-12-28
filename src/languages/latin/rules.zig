const std = @import("std");

const modifiers = [_][]const u8{"in"};
const suffixes = [_][]const u8{"a", "ā", "us", "ī", "ae", "um", "ō"};

var singular_to_plural = getSingularToPluralHashMap();

fn getSingularToPluralHashMap() std.StringHashMap([]const u8) {
    var hashmap = std.StringHashMap([]const u8).init(allocator);
    try hashmap.put("us", "ī");
    try hashmap.put("a", "ae");
    try hashmap.put("um", "a");

    return hashmap;
}

var whatever_to_location = getWhateverToLocationHashMap();

fn getWhateverToLocationHashMap() std.StringHashMap([]const u8) {
    var hashmap = std.StringHashMap([]const u8).init(allocator);
    try hashmap.put("a", "ā");
    try hashmap.put("um", "ō");

    return hashmap;
}

fn findPluralBlocks() usize {

}

// S est, S + S sunt
// Estne, ne suffix = ?
// adjective conjug follows noun conjug
// Num = est-ne
// num? -> nōn
