const std = @import("std");

//Build and install into the standard loc.
fn buildExecutable(b: *std.Build, target: *const std.zig.CrossTarget, optimize: *const std.builtin.OptimizeMode) *std.Build.Step.Compile {
    const generated_test_lib = b.addStaticLibrary(.{
        .name = "BabelAI",
        .root_source_file = .{ .path = "src/root.zig" }, // In more complicated build scripts, could be generated file.
        .target = target.*,
        .optimize = optimize.*,
    });
    b.installArtifact(generated_test_lib);

    const  core_module = b.addModule( "core", .{ .source_file = .{ .path = "src/core/root.zig" } });
    const latin_module = b.addModule("latin", .{
        .source_file = .{ .path = "src/languages/latin/root.zig" },
        .dependencies = &[1]std.Build.ModuleDependency{
            .{ .name = "core", .module = core_module }
        }
    });
    
    const exe = b.addExecutable(.{
        .name = "BabelAI",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target.*,
        .optimize = optimize.*,
    });
    exe.addModule("latin", latin_module);
    b.installArtifact(exe);

    return exe;
}

fn setupApplication(b: *std.Build, target: *const std.zig.CrossTarget, optimize: *const std.builtin.OptimizeMode) void {
    const exe = buildExecutable(b, target, optimize);

    // This *creates* a Run step in the build graph, to be executed when another step is evaluated that depends on it.
    const run_cmd = b.addRunArtifact(exe);

    // If application depends on other installed files, ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep()); // Depend on zig-out instead of zig-cache

    if (b.args) |args| {
        run_cmd.addArgs(args); // `zig build run -- arg1 arg2 etc`
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn setupUnitTests(b: *std.Build, target: *const std.zig.CrossTarget, optimize: *const std.builtin.OptimizeMode) void {
    // Creates a step for unit testing. This only builds the test executable but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target.*,
        .optimize = optimize.*,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target.*,
        .optimize = optimize.*,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

// Declaratively constructs a build graph. Declares "zig build" modifs first.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{}); // arch
    const optimize = b.standardOptimizeOption(.{}); // release

    setupApplication(b, &target, &optimize);
    setupUnitTests(b, &target, &optimize);
}
