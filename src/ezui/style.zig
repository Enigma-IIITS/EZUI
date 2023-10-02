const std = @import("std");
const Color = @import("../utils/math.zig").Color;

pub const Style = struct {
    window_color: Color,
    button_color: Color,
    button_hover_color: Color,
    button_click_color: Color,
    indent_width: f32,
    height_between_elements: f32,
    element_height: f32,
};
