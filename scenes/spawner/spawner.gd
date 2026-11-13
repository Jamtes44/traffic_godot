class_name Spawner
extends Node
# Crea obstáculos y power-ups delante de la moto. Las listas se editan en el Inspector:
# repetir una escena en la lista la hace salir más seguido.

@export var obstacles: Array[PackedScene] = []
@export var power_ups: Array[PackedScene] = []
@export var target: Node2D  ## Nodo donde se agregan (los mueve el juego).
@export var active := true

var _obstacle_t := 1.0
var _item_t := 2.0

func tick(delta: float, speed: float) -> void:
	if not active:
		return
	_obstacle_t -= delta
	if _obstacle_t <= 0:
		_obstacle_t = randf_range(0.5, 1.1) * clamp(150.0 / speed, 0.4, 1.0)  # más rápido = más obstáculos
		spawn(obstacles.pick_random())
	_item_t -= delta
	if _item_t <= 0:
		_item_t = randf_range(2.0, 4.0)
		spawn(power_ups.pick_random())

func spawn(scene: PackedScene) -> RoadObject:
	var o: RoadObject = scene.instantiate()
	match o.placement:
		1:  # sobre una línea: tapa medio carril a cada lado
			o.position = Vector2(Road.LEFT + Road.LANE_W * (randi() % (Road.LANES - 1) + 1), -25)
		2:  # entra por una orilla y cruza
			o.dir = 1.0 if randf() < 0.5 else -1.0
			o.rotation = o.dir * PI / 2  # los sprites miran hacia arriba: girar hacia donde cruza
			o.position = Vector2(Road.LEFT - 10 if o.dir > 0 else Road.RIGHT + 10, randf_range(-10, 40))
		_:
			o.position = Vector2(Road.lane_x(randi() % Road.LANES), -25)
	target.add_child(o)
	return o
