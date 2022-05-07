module lib

import math
import rand

// Basic data types start

// Vector start
pub struct Vector {
pub mut:
	x f64
	y f64
}

pub fn (v Vector) repr__() string {
	return '$v.x.str() $v.y.str()'
}

pub fn (v Vector) copy() Vector {
	return Vector{...v}
}

pub fn (mut v Vector) add(w Vector) Vector {
	v.x += w.x
	v.y += w.y

	return v
}

pub fn (mut v Vector) mult(f f64) Vector {
	v.x *= f
	v.y *= f

	return v
}

pub fn (mut v Vector) set_mag(m int) {
	cmag := math.sqrt(v.x * v.x + v.y * v.y)
	v.x = v.x * m / cmag
	v.y = v.x * m / cmag
}

pub fn vector_from_angle(a int) &Vector {
	return &Vector{x: int(math.cos(a)), y: int(math.sin(a))}
} // Vector end
// Basic data types end

// Particle start
pub struct Particle {
pub mut:
	pos Vector
	prev_pos Vector
	vel Vector
	acc Vector
	path []Vector
}

pub fn (p Particle) repr__() string {
	return 'Position: $p.pos.repr__() Velocity: $p.vel.repr__() Acceleration: $p.acc.repr__()'
} 

pub fn (mut p Particle) update() Particle {
	p.vel.add(p.acc)
	p.pos.add(p.vel)
	p.acc.mult(0)

	return p
}

pub fn (mut p Particle) apply_force(v Vector) Particle {
	p.acc.add(v)

	return p
}

pub fn new_particle() Particle {
	mut p := Particle{ pos: Vector{x: rand.int_in_range(0, 100) or {0}, y: rand.int_in_range(0, 100) or {0}} }
	p.prev_pos = p.pos.copy()
	return p
} // Particle end

// Particles start
struct Particles {
	ps []Particle
}

pub fn (mut ps Particles) new_particles(len int) {
	
}

pub fn (mut ps Particles) update() {
	for mut p in ps.ps {
		p.update()
	}
} // Particles end