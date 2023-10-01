const std = @import("std");

pub const Style = struct {
    window_color: [3]f32,
    button_color: [3]f32,
    button_hover_color: [3]f32,
    indent_width: f32,
    height_between_elements: f32,
    element_height: f32,
};
