const std = @import("std");

pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const jigoko = builder.addExecutable(.{
        .name = "jigoko",
        .target = target,
        .optimize = optimize,
    });

    jigoko.linkLibC();
    jigoko.addCSourceFiles(&.{
        "src/main.c",
    }, &.{
        "-std=c99",
        "-pedantic",
        "-Wall",
        "-Wextra",
        "-Wl,--subsystem,windows"
    });

    builder.installArtifact(jigoko);
}
