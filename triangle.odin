package main

// stores vertex index
face_t :: struct {
    a : int,
    b : int,
    c : int,
}

triangle_t :: struct {
    points : [3]vec2_t
}