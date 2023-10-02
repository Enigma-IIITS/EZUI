const std = @import("std");

// TODO: Maybe don't pack struct here

pub const Color = packed struct {
    r: f32,
    g: f32,
    b: f32,
};

pub const Rect = packed struct {
    pos: Vec2,
    width: f32,
    height: f32,
    color: Color,

    pub fn initZero() Rect {
        return Rect{ .pos = Vec2{ .x = 0, .y = 0 }, .width = 0, .height = 0, .color = Color{ .r = 0.0, .g = 0.0, .b = 0.0 } };
    }
};

pub const Vec2 = packed struct {
    x: f32,
    y: f32,

    pub fn initZero() Vec2 {
        return Vec2{ .x = 0, .y = 0 };
    }

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
