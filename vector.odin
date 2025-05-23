package main

import m "core:math"

vec2_t :: struct {
    x: f32,
    y: f32,
}

vec3_t :: struct {
    x: f32,
    y: f32,
    z: f32,
}

vec3_rotate_x :: proc(v: vec3_t, angle: f32) -> vec3_t {
    return {
        v.x,
        v.y * m.cos(angle) - v.z * m.sin(angle),
        v.y * m.sin(angle) + v.z * m.cos(angle),
    }
}
vec3_rotate_y :: proc(v: vec3_t, angle: f32) -> vec3_t {
    return {
        v.z * m.sin(angle) + v.x * m.cos(angle),
        v.y,
        v.z * m.cos(angle) - v.x * m.sin(angle),
    }
}
vec3_rotate_z :: proc(v: vec3_t, angle: f32) -> vec3_t {
    return {
        v.x * m.cos(angle) - v.y * m.sin(angle),
        v.x * m.sin(angle) + v.y * m.cos(angle),
        v.z
    }
}