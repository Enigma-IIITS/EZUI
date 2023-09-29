const std = @import("std");
const testing = std.testing;

const glfw = @import("mach-glfw");
const gpu = @import("mach-gpu");
const util = @import("util.zig");
const EZUI = @import("ezui/ezui.zig").EZUI;
const math = @import("utils/math.zig");
const Vec2 = math.Vec2;

pub const GPUInterface = gpu.dawn.Interface;

fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

pub fn detectBackendType() gpu.BackendType {
    const target = @import("builtin").target;
    if (target.isDarwin()) return .metal;
    if (target.os.tag == .windows) return .d3d12;
    return .vulkan;
}

pub fn main() !void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    const backend_type = detectBackendType();
    var hints = util.glfwWindowHintsForBackend(backend_type);
    hints.cocoa_retina_framebuffer = true;
    const window = glfw.Window.create(500, 500, "EZUI!", null, null, hints) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();

    var ezui = EZUI.init(window);
    defer ezui.deinit();

    window.setUserPointer(&ezui);
    window.setFramebufferSizeCallback((struct {
        fn callback(window_: glfw.Window, width_: u32, height_: u32) void {
            const pl = window_.getUserPointer(EZUI);
            pl.?.resize(width_, height_);
        }
    }).callback);

    while (!window.shouldClose()) {
        glfw.pollEvents();
        const mouse_pos = window.getCursorPos();
        ezui.setCursorPos(@floatCast(mouse_pos.xpos), @floatCast(mouse_pos.ypos));

        if (ezui.button(Vec2{ .x = 100, .y = 100 }, 50, 50)) {
            std.log.info("mouse is over button 1", .{});
        }
        if (ezui.button(Vec2{ .x = 100, .y = 200 }, 50, 50)) {
            std.log.info("mouse is over button 2", .{});
        }
        if (ezui.button(Vec2{ .x = 200, .y = 100 }, 50, 50)) {
            std.log.info("mouse is over button 3", .{});
        }
        if (ezui.button(Vec2{ .x = 200, .y = 200 }, 50, 50)) {
            std.log.info("mouse is over button 4", .{});
        }
        ezui.render();
    }
}
