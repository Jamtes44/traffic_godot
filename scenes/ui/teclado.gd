extends GridContainer
# Teclado en pantalla para el control remoto del TV (flechas + OK). Las teclas se generan
# desde LETTERS para no repetir 28 botones a mano en la escena.

signal letter(ch: String)
signal erase

const LETTERS := "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ"

func _ready() -> void:
	for ch in LETTERS:
		_key(ch, letter.emit.bind(ch))
	_key("←", erase.emit)  # 28 teclas = 4 filas exactas de 7

func focus_first() -> void:
	get_child(0).grab_focus()

func _key(label: String, on_press: Callable) -> void:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size.y = 14
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 8)
	b.pressed.connect(on_press)
	add_child(b)
