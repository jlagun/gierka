class_name DemonData
extends Resource
## The numbers that make a demon. A new kind of demon is mostly a new .tres file
## with different values. They have no defaults here, because Godot doesn't save
## a value that equals its default, and the numbers would then slip out of the
## .tres and back into code.

## Hit points of a fresh demon.
@export_range(1, 1000, 1, "or_greater") var health: int
## How fast it chases players, in meters per second.
@export_range(0.5, 20.0, 0.1, "or_greater") var speed: float
## Damage done by each attack that lands.
@export_range(0, 100, 1, "or_greater") var damage: int
## How close a player must be for an attack, in meters from the demon's center.
@export_range(0.5, 10.0, 0.1, "or_greater") var attack_range: float
## Seconds between two attacks, at least.
@export_range(0.1, 10.0, 0.1, "or_greater") var attack_cooldown: float
