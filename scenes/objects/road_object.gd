class_name RoadObject
extends Area2D
# Base de todo lo que va sobre la vía (obstáculos y power-ups). El juego lo mueve con advance().

## Dónde lo pone el Spawner al aparecer.
@export_enum("Carril", "Entre carriles", "Cruza la vía") var placement := 0
## Velocidad de lado a lado (solo para "Cruza la vía").
@export var cross_speed := 0.0

var dir := 1.0  # hacia dónde cruza; lo elige el Spawner

func advance(v: float, delta: float) -> void:
	position += Vector2(dir * cross_speed, v) * delta
	if position.y > Road.H + 50 or position.x < -30 or position.x > Road.W + 30:
		queue_free()  # salió de la pantalla
