pub const WordType = enum { noun, verb };

pub const Word = struct { token: []u8, type: WordType, appears: u32 = 0 };
