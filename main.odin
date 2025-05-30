package main

import "core:fmt"
import "core:os"
import sdl "vendor:sdl2"

triangles_to_render : [N_MESH_FACES]triangle_t

camera_position : vec3_t = {0, 0, -5}
cube_rotaion : vec3_t = {0, 0, 0}

fov_factor : f32 = 640

is_running              : bool
previous_frame_time : u32

setup :: proc() {
    color_buffer = make([]u32, window_width * window_height)

    color_buffer_texture = sdl.CreateTexture(
        renderer,
        .ARGB8888,
        .STREAMING,
        window_width,
        window_height,
    )
}

process_input :: proc() {
    event : sdl.Event
    sdl.PollEvent(&event)

    #partial switch event.type {
        case .QUIT:
            is_running = false
        case .KEYDOWN:
            if event.key.keysym.sym == .ESCAPE {
                is_running = false
            }
    }
}

project :: proc(point: vec3_t) -> vec2_t {
    return {
        fov_factor * point.x / point.z, 
        fov_factor * point.y / point.z,
    }
}

update :: proc() {
    // simple wating while loop
    // for !sdl.TICKS_PASSED(
    //     sdl.GetTicks(), 
    //     previous_frame_time + FRAME_TARGET_TIME){}

    // better for sharing cpu resources
    time_to_wait := FRAME_TARGET_TIME - (sdl.GetTicks() - previous_frame_time)
    if time_to_wait > 0 && time_to_wait <= FRAME_TARGET_TIME {
        sdl.Delay(time_to_wait)
    }
    
    previous_frame_time = sdl.GetTicks()

    cube_rotaion.y += 0.01
    cube_rotaion.x += 0.01
    cube_rotaion.z += 0.01

    // loop all triangle faces
    for i := 0; i < N_MESH_FACES; i += 1 {
        mesh_face := mesh_faces[i]
        
        face_vertices : [3]vec3_t;
        face_vertices[0] = mesh_vertices[mesh_face.a - 1]
        face_vertices[1] = mesh_vertices[mesh_face.b - 1]
        face_vertices[2] = mesh_vertices[mesh_face.c - 1]

        projected_triangle : triangle_t

        // loop all three verticies and apply transformation
        for j := 0; j < 3; j += 1{
            transformed_vertex : vec3_t = face_vertices[j]

            transformed_vertex = vec3_rotate_x(transformed_vertex, cube_rotaion.x)
            transformed_vertex = vec3_rotate_y(transformed_vertex, cube_rotaion.y)
            transformed_vertex = vec3_rotate_z(transformed_vertex, cube_rotaion.z)

            // translate vertex away from camera
            transformed_vertex.z += camera_position.z

            projected_point : vec2_t = project(transformed_vertex)

            // scale and project to center of screen
            projected_point.x += cast(f32) window_width / 2
            projected_point.y += cast(f32) window_height / 2

            projected_triangle.points[j] = projected_point
        }

        triangles_to_render[i] = projected_triangle
    }

    // for i in 0..<N_POINTS {
    //     point := cube_points[i]

    //     transform_point := vec3_rotate_x(point, cube_rotaion.x)
    //     transform_point = vec3_rotate_y(transform_point, cube_rotaion.y)
    //     transform_point = vec3_rotate_z(transform_point, cube_rotaion.z)

    //     // move point away from the camera
    //     transform_point.z -= camera_position.z

    //     projected_point := project(transform_point)

    //     projected_points[i] = projected_point
    // }
}

render :: proc() {

    clear_color_buffer(0xFF000000)

    draw_grid(0xFF222222, 10)

    for i in 6..<8 {
        triangle := triangles_to_render[i]
        draw_rect(cast(i32)triangle.points[0].x, cast(i32)triangle.points[0].y, 3, 3, 0xFFFFFF00)
        draw_rect(cast(i32)triangle.points[1].x, cast(i32)triangle.points[1].y, 3, 3, 0xFFFFFF00)
        draw_rect(cast(i32)triangle.points[2].x, cast(i32)triangle.points[2].y, 3, 3, 0xFFFFFF00)

        // draw triangle lines
        draw_line(triangle.points[0], triangle.points[1], 0xFF00FF00)
        draw_line(triangle.points[1], triangle.points[2], 0xFF00FF00)
        draw_line(triangle.points[0], triangle.points[2], 0xFF00FF00)
    }

    render_color_buffer()

    sdl.RenderPresent(renderer)
}

main :: proc() {
    is_running = initialize_window()

    setup()

    for is_running {
        process_input()
        update()
        render()
    }

    destroy_window()
}