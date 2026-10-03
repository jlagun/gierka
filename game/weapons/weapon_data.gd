class_name WeaponData
extends Resource
## The numbers that make a weapon. A new weapon is mostly a new .tres file with
## different values, plus a model.

## Damage done by each pellet that hits.
@export var damage: int = 10
## Shots per second, at most.
@export_range(0.1, 20.0, 0.1, "or_greater") var fire_rate: float = 2.0
## How far a shot reaches, in meters.
@export var max_range: float = 50.0
## How far a pellet can stray from where you aim, in degrees.
@export_range(0.0, 45.0, 0.1) var spread: float = 0.0
## Rays per shot: 1 for a pistol, several for a shotgun.
@export_range(1, 32) var pellets: int = 1
@export_range(1, 100, 1, "or_greater") var magazine_size: int = 10
## Seconds a reload takes.
@export_range(0.1, 10.0, 0.1, "or_greater") var reload_time: float = 1.0
## What the player holds. Shot effects start at its "Muzzle" marker.
@export var model: PackedScene

@export_group("Effects")
## Shown at the muzzle with each shot.
@export var muzzle_flash: PackedScene
## Drawn from the muzzle to where each pellet went. Its root needs the Tracer script.
@export var tracer: PackedScene
## Shown where a pellet hits something. Its root is a CPUParticles3D.
@export var impact: PackedScene
## Played with each shot.
@export var shot_sound: AudioStream
