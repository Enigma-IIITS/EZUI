const std = @import("std");
const glfw = @import("mach-glfw");

const ez_renderer = @import("renderer.zig");
const Renderer = ez_renderer.Renderer;
const Style = @import("style.zig").Style;
const math = @import("../utils/math.zig");
const Vec2 = math.Vec2;
const Rect = math.Rect;

pub const MaxElements = 500;

pub const EZUI = struct {
    renderer: Renderer,
    elements: [MaxElements]Rect,
    element_idx: u32,
    window_rect: Rect,
    cursor_pos: Vec2,
    style: *Style,

    pub fn init(glfw_window: glfw.Window, style: *Style) EZUI {
        var renderer = Renderer.init(glfw_window);

        return EZUI{
            .renderer = renderer,
            .elements = [_]Rect{Rect.initZero()} ** MaxElements,
            .element_idx = 0,
            .cursor_pos = Vec2{ .x = 0.0, .y = 0.0 },
            .window_rect = Rect.initZero(),
            .style = style,
        };
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
        const c_x = ezui.cursor_pos.x;
        const c_y = ezui.cursor_pos.y;
        return c_x >= pos.x and c_x <= pos.x + width and c_y >= pos.y and c_y <= pos.y + height;
    }

    pub fn window(ezui: *EZUI, pos: Vec2, width: f32, height: f32) void {
        ezui.elements[ezui.element_idx].color = ezui.style.window_color;
        ezui.elements[ezui.element_idx].pos = pos;
        ezui.elements[ezui.element_idx].width = width;
        ezui.elements[ezui.element_idx].height = height;
        ezui.element_idx += 1;

        ezui.window_rect.pos = pos;
        ezui.window_rect.width = width;
        ezui.window_rect.height = height;
    }

    pub fn button(ezui: *EZUI) bool {
        const window_rect_x = ezui.window_rect.pos.x;
        const window_rect_y = ezui.window_rect.pos.y;
        const window_rect_width = ezui.window_rect.width;

        const pos = Vec2{ .x = window_rect_x + ezui.style.indent_width, .y = window_rect_y + ezui.style.height_between_elements };
        const width = window_rect_width - ezui.style.indent_width * 2;
        const height = ezui.style.element_height;

        const isHover = ezui.cursorRectIntersection(pos, width, height);

        ezui.elements[ezui.element_idx].color = ezui.style.button_color;
        ezui.elements[ezui.element_idx].pos = pos;
        ezui.elements[ezui.element_idx].width = width;
        ezui.elements[ezui.element_idx].height = height;
        if (isHover) {
            ezui.elements[ezui.element_idx].color = ezui.style.button_hover_color;
        }
        ezui.element_idx += 1;
        ezui.window_rect.pos.y = pos.y + height;
        return isHover;
    }

    pub fn resize(ezui: *EZUI, width: u32, height: u32) void {
        ezui.renderer.resizeSwapchain(width, height);
    }
};
