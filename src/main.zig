const std = @import("std");
const testing = std.testing;

const glfw = @import("mach-glfw");
const gpu = @import("mach-gpu");
const util = @import("util.zig");
const EZUI = @import("ezui/ezui.zig").EZUI;
const Style = @import("ezui/style.zig").Style;
const math = @import("utils/math.zig");
const Vec2 = math.Vec2;
const Color = math.Color;

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
    const window = glfw.Window.create(1080, 720, "EZUI!", null, null, hints) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();

    var style = Style{
        .window_color = Color{ .r = 0.2, .g = 0.2, .b = 0.2 },
        .button_color = Color{ .r = 1.0, .g = 0.0, .b = 0.0 },
        .button_hover_color = Color{ .r = 0.9, .g = 0.0, .b = 0.0 },
        .button_click_color = Color{ .r = 0.8, .g = 0.0, .b = 0.0 },
        .indent_width = 5.0,
        .height_between_elements = 5.0,
        .element_height = 20.0,
    };

    var ezui = EZUI.init(window, &style);
    defer ezui.deinit();

    window.setUserPointer(&ezui);
    window.setFramebufferSizeCallback((struct {
        fn callback(window_: glfw.Window, width_: u32, height_: u32) void {
            const pl = window_.getUserPointer(EZUI);
            pl.?.resize(width_, height_);
        }
    }).callback);

    window.setMouseButtonCallback((struct {
        fn callback(window_: glfw.Window, button_: glfw.MouseButton, action: glfw.Action, mods: glfw.Mods) void {
            _ = mods;
            const pl = window_.getUserPointer(EZUI);
            if (button_ == .left and action == .press) {
                pl.?.mousePressed();
            } else if (button_ == .left and action == .release) {
                pl.?.mouseReleased();
            }
        }
    }).callback);

    while (!window.shouldClose()) {
        glfw.pollEvents();
        const mouse_pos = window.getCursorPos();
        ezui.setCursorPos(@floatCast(mouse_pos.xpos), @floatCast(mouse_pos.ypos));

        ezui.window(Vec2{ .x = 50, .y = 50 }, 200, 500);

        if (ezui.button().hover) {
            std.log.info("Button 1 hovered!", .{});
        }

        ezui.window(Vec2{ .x = 400, .y = 50 }, 200, 500);

        if (ezui.button().click) {
            std.log.info("Button 2 clicked!", .{});
        }

        ezui.render();
    }
}
