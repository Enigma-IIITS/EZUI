const std = @import("std");

// TODO: Maybe don't pack struct here

pub const Color = packed struct {
    r: f32 = 0.0,
    g: f32 = 0.0,
    b: f32 = 0.0,
};

pub const Rect = packed struct {
    pos: Vec2 = .{},
    width: f32 = 0.0,
    height: f32 = 0.0,
    color: Color = .{},
};

pub const Vec2 = packed struct {
    x: f32 = 0.0,
    y: f32 = 0.0,

    pub fn add(a: *Vec2, b: Vec2) void {
        return Vec2{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn sub(a: *Vec2, b: Vec2) void {
        return Vec2{ .x = a.x - b.x, .y = a.y - b.y };
    }

    // pub fn getRectFromBound(a: Vec2, b: Vec2) struct { pos: Vec2, width: f32, height: f32 } {
    //     const width = b.x - a.x;
    //     const height = b.y - a.y;
    //     return struct { .pos = a, .width = width, .height = height };
    // }

    // pub fn scale(a: *Vec2U, factor: u32) void {
    //     return Vec2U{.x = a.x * factor, .y = a.y * factor};
    // }
};
