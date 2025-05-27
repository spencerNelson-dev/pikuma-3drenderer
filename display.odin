package main

import "core:fmt"
import "core:os"
import sdl "vendor:sdl2"

Color :: u32

FPS :: 30
FRAME_TARGET_TIME ::(1000 / FPS)

color_buffer            : []u32
color_buffer_texture    : ^sdl.Texture

window_width    : i32 = 800
window_height   : i32 = 600
window                  : ^sdl.Window
renderer                : ^sdl.Renderer


initialize_window :: proc() -> bool {
    sdl.Init(sdl.INIT_EVERYTHING)
    if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
        fmt.fprintf(os.stderr, "Error initializing SDL.\n")
        return false
    }

    display_mode : sdl.DisplayMode
    sdl.GetCurrentDisplayMode(
        0,
        &display_mode
    )

    window_width = display_mode.w
    window_height = display_mode.h

    window = sdl.CreateWindow(
        nil,
        sdl.WINDOWPOS_CENTERED,
        sdl.WINDOWPOS_CENTERED,
        window_width,
        window_height,
        sdl.WINDOW_BORDERLESS
    )
    if window == nil {
        fmt.fprintf(os.stderr, "Error creating SDL window.\n")
        return false
    }

    // Create sdl renderer
    renderer = sdl.CreateRenderer(
        window,
        -1,
        {}
    )
    if renderer == nil {
        fmt.fprint(os.stderr, "Error creating SDL renderer")
        return false
    }

    sdl.SetWindowFullscreen(window, sdl.WINDOW_FULLSCREEN)

    return true
}

destroy_window :: proc() {
    delete(color_buffer)
    sdl.DestroyTexture(color_buffer_texture)
    sdl.DestroyRenderer(renderer)
    sdl.DestroyWindow(window)
    sdl.Quit()
}

render_color_buffer :: proc() {
    sdl.UpdateTexture(
        color_buffer_texture,
        nil,
        raw_data(color_buffer),
        window_width * size_of(u32)
    )

    sdl.RenderCopy(
        renderer,
        color_buffer_texture,
        nil,
        nil
    )
}

clear_color_buffer :: proc(color: u32) {
    for &c in color_buffer {
        c = color
    }
    
}

draw_grid :: proc(color : u32, width : i32) {
    grid_color := color
    grid_width := width

    // dots
    for j : i32 = 0; j < window_height * window_width; j += window_width * grid_width {
        color_buffer[j] = grid_color

        for i : i32 = j; i < window_width + j; i += 1 {
            if i % grid_width == 0 {
                color_buffer[i] = grid_color
            }
        }
    }

    // Horizontal Lines
    // for y : i32 = 0; y < window_height * window_width; y += window_width * grid_width {
    //     for x : i32 = y; x < window_width + y; x += 1 {
    //         color_buffer[x] = grid_color
    //         count += 1
    //     }
    // }

    // // vertical Lines
    // for j : i32 = 0; j < window_height; j += 1 {
    //     for i : i32 = j * window_width; i < (j + 1) * window_width; i += grid_width {
    //         color_buffer[i] = grid_color
    //         count += 1
    //     }
    // }
}

draw_rect :: proc(x: i32, y: i32, w: i32, h: i32, color: u32) {

    for i:i32 = y; i <= y + h; i += 1 {
        for j:i32 = x; j <= x + w; j += 1 {
            draw_pixel(j, i, color)
            // color_buffer[(window_width * i) + j] = color
        }
    }

}

draw_pixel :: proc(x : i32, y: i32, color: Color){
    if x >= 0 && x < window_width && y >=0 && y < window_height {
        color_buffer[(window_width * y) + x] = color
    }
}
