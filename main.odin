package main

import "core:fmt"
import "core:os"
import sdl "vendor:sdl2"

N_POINTS :: 9 * 9 * 9
cube_points : [N_POINTS]vec3_t
projected_points : [N_POINTS]vec2_t
fov_factor : f32 = 640
camera_position : vec3_t = {0, 0, -5}
cube_rotaion : vec3_t = {0, 0, 0}

is_running              : bool
previous_frame_time : u32

setup :: proc() {
    color_buffer = make([]u32, window_width * window_height)

    color_buffer_texture = sdl.CreateTexture(
        renderer,
        .ARGB8888,
        .STREAMING,
        window_width,
        window_height
    )

    point_count : int

    for x: f32 = -1; x <= 1; x += 0.25 {
        for y: f32 = -1; y <= 1; y += 0.25 {
            for z: f32 = -1; z <= 1; z += 0.25 {
                new_point : vec3_t = {x, y, z}
                cube_points[point_count] = new_point
                point_count += 1
            }
        }
    }

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

    for i in 0..<N_POINTS {
        point := cube_points[i]

        transform_point := vec3_rotate_x(point, cube_rotaion.x)
        transform_point = vec3_rotate_y(transform_point, cube_rotaion.y)
        transform_point = vec3_rotate_z(transform_point, cube_rotaion.z)

        // move point away from the camera
        transform_point.z -= camera_position.z

        projected_point := project(transform_point)

        projected_points[i] = projected_point
    }
}

render :: proc() {

    clear_color_buffer(0xFF000000)

    draw_grid(0xFF222222, 10)

    for i in 0..<N_POINTS {
        projected_point := projected_points[i]
        color : u32 = 0xFFFFFF00
        if i == 0 {
            color = 0xFFFF0000
        }
        draw_rect(
            cast(i32)projected_point.x + window_width / 2,
            cast(i32)projected_point.y + window_height / 2,
            4,
            4,
            color
        )
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