import gg
import gx

import math

// import spytheman.vperlin as perlin
import spytheman.vperlin.stb as perlin

import lib

/* Debugging */
// import time
// import arrays

const (
	inc = 0.1
	scale = 100
	width = 500
	height = 500
	size = height * width
	interpolation_scale = 2

	win_width = 800
	win_height = 600
	padding_top = (win_height - height) / 2
	padding_left = (win_width - width) / 2

	vcols = int(math.floor(width / scale))
	vrows = int(math.floor(height / scale))

	noise_min = 0
	noise_max = 2
)

struct DrawnVector {
	pos lib.Vector
	vec lib.Vector
}

struct AppState {
mut:
	pixels_array [][]f32 = [][]f32{len: height, init: []f32{len: width, init: 0}}
	draw_array [][]int = [][]int{len: height, init: []int{len: width, init: 0}}
	vectors_array []DrawnVector
	frame int
}

fn (mut aps AppState) update_noise() {
	mut xoff := 0.0
	mut yoff := 0.0
	mut zoff := f32(aps.frame) / 100.0

	for y in 0..height {
		xoff = 0
		for x in 0..width {
			noise_val := ((perlin.turbulence_noise3(
				f32(xoff / scale), // x
				f32(yoff / scale), // y
				f32(zoff),         // z
				f32(2),            // lacunarity
				f32(0.7),          // gain
 				6                  // octaves
			) - noise_min) / (noise_max - noise_min)) * 255
			aps.pixels_array[y][x] = noise_val
			aps.draw_array[y][x] = gx.rgb(u8(noise_val), u8(0), u8(0)).rgba8()

			xoff += inc
		}

		yoff += inc
	}

	aps.frame++
}

fn (aps AppState) interpolate() {
	unsafe {
		mut mat := &aps.pixels_array

		for y := 1; y < mat.len - 1; y += interpolation_scale {
			for x := 1; x < mat[0].len - 1; x += interpolation_scale {
				mat[y][x+1] = (mat[y][x] + mat[y][x+2]) / 2
			}
		}
	}
}

fn (mut aps AppState) update() {
	mut xoff := 0.0
	mut yoff := 0.0
	mut zoff := f32(aps.frame) / 100.0

	for y in 0..vrows {
		xoff = 0
		for x in 0..vcols {
			noise_val := ((perlin.turbulence_noise3(
				f32(xoff / scale), // x
				f32(yoff / scale), // y
				f32(zoff),         // z
				f32(2),            // lacunarity
				f32(0.7),          // gain
 				6                  // octaves
			) - noise_min) / (noise_max - noise_min))

			angle := int(noise_val * math.pi_2 * 4)
			mut vec := lib.vector_from_angle(angle)
			vec.set_mag(1)

			dvec := DrawnVector{pos: lib.Vector{x: x, y: y}, vec: vec}
			aps.vectors_array << dvec

			xoff += inc
		}

		yoff += inc
	}

	aps.frame++
}

struct App {
mut:
	gg 			&gg.Context = 0
	aps         AppState
	istream_idx int
}

fn (mut app App) draw() {
	mut istream_image := app.gg.get_cached_image_by_idx(app.istream_idx)
	app.aps.update_noise()
	istream_image.update_pixel_data(&app.aps.draw_array)
	app.gg.draw_image(padding_left, padding_top, width, height, istream_image)
}

fn graphics_init(mut app App) {
	app.istream_idx = app.gg.new_streaming_image(width, height, 4, pixel_format: .rgba8)
}

fn graphics_frame(mut app App) {
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn main() {
	mut app := &App{}
	app.gg = gg.new_context(
		bg_color: gx.white
		width: win_width
		height: win_height
		create_window: true
		window_title: 'Flowfield'
		init_fn: graphics_init
		frame_fn: graphics_frame
		user_data: app
	)

	app.aps.update()
	app.gg.run()

	/* Debugging */
	// mut aps := &AppState{}
	// aps.update()
	// start := time.now().microsecond
	// aps.interpolate()
	// end := time.now().microsecond
	// println(end-start)
}
