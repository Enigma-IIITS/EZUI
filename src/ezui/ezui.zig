const std = @import("std");
const glfw = @import("mach-glfw");

const ez_renderer = @import("renderer.zig");
const Renderer = ez_renderer.Renderer;

pub const EZUI = struct {
    renderer: Renderer,

    pub fn init(window: glfw.Window) EZUI {
        var renderer = Renderer.init(window);

        return EZUI{ .renderer = renderer };
    }

    pub fn resize(ezui: *EZUI, width: u32, height: u32) void {
        ezui.renderer.resizeSwapchain(width, height);
    }

    pub fn render(ezui: *EZUI) void {
        ezui.renderer.render();
    }

    pub fn deinit(ezui: *EZUI) void {
        ezui.renderer.deinit();
    }
};
