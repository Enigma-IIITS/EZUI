const std = @import("std");
const glfw = @import("mach-glfw");

const ez_renderer = @import("renderer.zig");
const Renderer = ez_renderer.Renderer;
const math = @import("../utils/math.zig");
const Vec2 = math.Vec2;
const Rect = math.Rect;

const MaxElements = 500;

pub const EZUI = struct {
    renderer: Renderer,
    elements: [MaxElements]Rect,
    element_idx: u32,
    cursor_pos: Vec2,

    pub fn init(window: glfw.Window) EZUI {
        var renderer = Renderer.init(window);

        return EZUI{ .renderer = renderer, .elements = [_]Rect{Rect{ .pos = Vec2{ .x = 0, .y = 0 }, .width = 0, .height = 0, .color = [_]f32{0.0} ** 4 }} ** MaxElements, .element_idx = 0, .cursor_pos = Vec2{ .x = 0.0, .y = 0.0 } };
    }

    pub fn deinit(ezui: *EZUI) void {
        ezui.renderer.deinit();
    }

    pub fn render(ezui: *EZUI) void {
        ezui.renderer.render(ezui.elements[0..ezui.element_idx]);
        ezui.element_idx = 0;
    }

    pub fn setCursorPos(ezui: *EZUI, x: f32, y: f32) void {
        ezui.cursor_pos.x = x;
        ezui.cursor_pos.y = y;
    }

    fn cursorRectIntersection(ezui: *EZUI, pos: Vec2, width: f32, height: f32) bool {
        // TODO: Make it easier to read, by using const for ezui.cursor_pos.*
        return ezui.cursor_pos.x >= pos.x and ezui.cursor_pos.x <= pos.x + width and ezui.cursor_pos.y >= pos.y and ezui.cursor_pos.y <= pos.y + height;
    }

    pub fn button(ezui: *EZUI, pos: Vec2, width: f32, height: f32) bool {
        const isHover = ezui.cursorRectIntersection(pos, width, height);

        ezui.elements[ezui.element_idx].color = .{ 1.0, 0.0, 0.0, 1.0 };
        ezui.elements[ezui.element_idx].pos = pos;
        ezui.elements[ezui.element_idx].width = width;
        ezui.elements[ezui.element_idx].height = height;
        if (isHover) {
            ezui.elements[ezui.element_idx].color = .{ 0.0, 1.0, 0.0, 1.0 };
        }
        ezui.element_idx += 1;
        return isHover;
    }

    pub fn resize(ezui: *EZUI, width: u32, height: u32) void {
        ezui.renderer.resizeSwapchain(width, height);
    }
};
