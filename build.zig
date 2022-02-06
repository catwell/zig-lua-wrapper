const std = @import("std");
var builder: *std.build.Builder = undefined;

pub fn build(b: *std.build.Builder) void {
    builder = b;
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("wrapper", "wrapper.zig");

    const lua_src_dir = "lua-5.3.4/src";
    const luasocket_src_dir = "luasocket/src";

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibC();
    exe.addIncludeDir(lua_src_dir);
    exe.addIncludeDir(luasocket_src_dir);

    const lua_c_files = [_][]const u8{
        "lapi.c",
        "lauxlib.c",
        "lbaselib.c",
        "lbitlib.c",
        "lcode.c",
        "lcorolib.c",
        "lctype.c",
        "ldblib.c",
        "ldebug.c",
        "ldo.c",
        "ldump.c",
        "lfunc.c",
        "lgc.c",
        "linit.c",
        "liolib.c",
        "llex.c",
        "lmathlib.c",
        "lmem.c",
        "loadlib.c",
        "lobject.c",
        "lopcodes.c",
        "loslib.c",
        "lparser.c",
        "lstate.c",
        "lstring.c",
        "lstrlib.c",
        "ltable.c",
        "ltablib.c",
        "ltm.c",
        "lundump.c",
        "lutf8lib.c",
        "lvm.c",
        "lzio.c",
    };

    const luasocket_c_files = [_][]const u8{
        "auxiliar.c",
        "buffer.c",
        "compat.c",
        "except.c",
        "inet.c",
        "io.c",
        "luasocket.c",
        "mime.c",
        "options.c",
        "select.c",
        "serial.c",
        "tcp.c",
        "timeout.c",
        "udp.c",
        "unix.c",
        "unixdgram.c",
        "unixstream.c",
        "usocket.c",
    };

    if (target.os_tag == std.Target.Os.Tag.windows) {
        const c_flags = [_][]const u8{ "-std=c99", "-O2", "-DLUA_USE_WINDOWS" };
        inline for (lua_c_files) |c_file| {
            exe.addCSourceFile(lua_src_dir ++ "/" ++ c_file, &c_flags);
        }
    } else {
        const c_flags = [_][]const u8{
            "-O2",
            "-DLUA_USE_POSIX",
        };
        inline for (lua_c_files) |c_file| {
            exe.addCSourceFile(lua_src_dir ++ "/" ++ c_file, &c_flags);
        }
        inline for (luasocket_c_files) |c_file| {
            exe.addCSourceFile(luasocket_src_dir ++ "/" ++ c_file, &c_flags);
        }
    }

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
