@tool
extends Control
# Logo de Traffic Runner al estilo GameDev: llaves { } turquesa, la moto al centro entre
# líneas de carril naranjas y el nombre abajo. Se dibuja con código para verse nítido a
# cualquier tamaño; el mismo nodo se usa en el menú y para generar art/logo.png y art/icon.png.

const TEAL := Color("117a81")
const ORANGE := Color("f0911f")
const CARD := Color("fbfaf6")
const MOTO := preload("res://art/moto.png")

@export var show_text := true:  ## false = versión cuadrada para el ícono
	set(v):
		show_text = v
		queue_redraw()
@export var card := true:  ## fondo blanco redondeado
	set(v):
		card = v
		queue_redraw()
@export var animate := false  ## las líneas del carril avanzan (menú)

var _t := 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # la moto es pixel art

func _process(delta: float) -> void:
	if animate and not Engine.is_editor_hint():
		_t += delta
		queue_redraw()

func _draw() -> void:
	# Espacio de diseño fijo; se escala para llenar el tamaño del nodo.
	var design := Vector2(150, 84) if show_text else Vector2(60, 60)
	var k: float = min(size.x / design.x, size.y / design.y)
	draw_set_transform((size - design * k) / 2, 0, Vector2(k, k))
	if card:
		var sb := StyleBoxFlat.new()
		sb.bg_color = CARD
		sb.set_corner_radius_all(10)
		draw_style_box(sb, Rect2(Vector2.ZERO, design))

	var cx := design.x / 2
	var top := 6.0 if show_text else 8.0
	var bottom := 46.0 if show_text else 52.0
	var spread := 32.0 if show_text else 25.0
	var lane := 13.0 if show_text else 11.0
	_brace(cx - spread, top, bottom, -1)
	_brace(cx + spread, top, bottom, 1)

	var mid := (top + bottom) / 2
	var off := fmod(_t * 24.0, 12.0)
	for side in [-1, 1]:  # líneas de carril naranjas a los lados de la moto
		for i in range(-1, 4):
			var y := top + 2 + i * 12 + off
			if y >= top and y + 6 <= bottom:
				draw_rect(Rect2(cx + side * lane - 1.5, y, 3, 6), ORANGE)
	draw_texture_rect(MOTO, Rect2(cx - 8, mid - 16, 16, 32), false)

	if show_text:
		var font := ThemeDB.fallback_font
		_bold_text(font, "TRAFFIC", 64, 17, TEAL, design.x)
		_bold_text(font, "RUNNER", 78, 11, ORANGE, design.x)

## Llave "{" (side = -1) o "}" (side = 1) con la punta en x = tip.
func _brace(tip: float, top: float, bottom: float, side: int) -> void:
	var mid := (top + bottom) / 2
	var c := Curve2D.new()
	var s := -side  # el cuerpo queda hacia adentro
	c.add_point(Vector2(tip + s * 9, top), Vector2.ZERO, Vector2(-s * 5, 0))
	c.add_point(Vector2(tip + s * 4, top + 6), Vector2(0, -4), Vector2.ZERO)
	c.add_point(Vector2(tip + s * 4, mid - 6), Vector2.ZERO, Vector2(0, 4))
	c.add_point(Vector2(tip, mid), Vector2(s * 2, -1.5), Vector2(s * 2, 1.5))
	c.add_point(Vector2(tip + s * 4, mid + 6), Vector2(0, -4), Vector2.ZERO)
	c.add_point(Vector2(tip + s * 4, bottom - 6), Vector2.ZERO, Vector2(0, 4))
	c.add_point(Vector2(tip + s * 9, bottom), Vector2(-s * 5, 0), Vector2.ZERO)
	var pts := c.tessellate(5, 3)
	for i in pts.size():  # tramos + círculos = trazo con uniones y puntas redondeadas
		if i > 0:
			draw_line(pts[i - 1], pts[i], TEAL, 4.5)
		draw_circle(pts[i], 2.25, TEAL)

func _bold_text(font: Font, s: String, y: float, fs: int, c: Color, w: float) -> void:
	draw_string_outline(font, Vector2(0, y), s, HORIZONTAL_ALIGNMENT_CENTER, w, fs, 2, c)
	draw_string(font, Vector2(0, y), s, HORIZONTAL_ALIGNMENT_CENTER, w, fs, c)
