@tool
class_name Road
extends Node2D
# Carretera de 4 carriles que avanza hacia abajo. Se dibuja con código (también en el editor, por @tool).
# El mundo mide 180 x 320; la Camera2D de cada escena lo centra en cualquier pantalla.

const W := 180.0
const H := 320.0
const LEFT := 30.0
const RIGHT := 150.0
const LANE_W := 30.0
const LANES := 4

@export var auto_speed := 0.0  ## Si es > 0 avanza sola (fondo del menú).

var scroll := 0.0:
	set(v):
		scroll = v
		queue_redraw()
var _trees := []

static func lane_x(lane: int) -> float:
	return LEFT + LANE_W * (lane + 0.5)

func _ready() -> void:
	for i in 40:  # cubre el pasto hasta pantallas 21:9
		_trees.append(Vector2(randf_range(-300, 22) if i % 2 == 0 else randf_range(158, 480), randf() * (H + 40)))

func _process(delta: float) -> void:
	if auto_speed > 0 and not Engine.is_editor_hint():
		scroll += auto_speed * delta

func _draw() -> void:
	draw_rect(Rect2(-400, 0, W + 800, H), Color("5a9e3a"))
	draw_rect(Rect2(LEFT, 0, RIGHT - LEFT, H), Color("6b6b6b"))
	var off := fmod(scroll, 20.0)
	for i in range(-2, int(H / 10) + 2):  # bordillos
		var c := Color("c62828") if i % 2 == 0 else Color("eeeeee")
		draw_rect(Rect2(LEFT - 4, i * 10 + off, 4, 10), c)
		draw_rect(Rect2(RIGHT, i * 10 + off, 4, 10), c)
	for l in range(1, LANES):  # líneas de carril
		for i in range(-1, int(H / 20) + 2):
			draw_rect(Rect2(LEFT + LANE_W * l - 1, i * 20 + off, 2, 10), Color("dddddd"))
	for tr in _trees:
		var x: float = tr.x
		var y := fposmod(tr.y + scroll, H + 40) - 20  # los árboles bajan con la carretera
		draw_rect(Rect2(x - 1, y + 3, 2, 4), Color("5d4037"))
		draw_rect(Rect2(x - 5, y - 5, 10, 9), Color("2e6b22"))
		draw_rect(Rect2(x - 3, y - 7, 6, 2), Color("3d8a2e"))
