extends Control
# Fin del recorrido: pide el nombre (teclado en pantalla o físico) y muestra la tabla de puntajes.

signal retry
signal menu

var dist := 0
var rank := -1

func open(reason: String, distance: int) -> void:
	dist = distance
	%Razon.text = reason
	%Distancia.text = "Distancia: %d m" % dist
	%NuevoRecord.visible = dist > Save.best()
	if %NuevoRecord.visible:
		Audio.play("record")
	%Nombre.show()
	%Puntajes.hide()
	show()
	%Teclado.focus_first()

func type_char(ch: String) -> void:
	if %NombreCampo.text.length() < %NombreCampo.max_length:
		%NombreCampo.text += ch

func backspace() -> void:
	%NombreCampo.text = %NombreCampo.text.left(-1)

func _unhandled_key_input(event: InputEvent) -> void:  # teclado físico
	if not %Nombre.is_visible_in_tree() or not event.pressed:
		return
	if event.keycode == KEY_BACKSPACE:
		backspace()
	elif event.unicode > 32:
		type_char(char(event.unicode).to_upper())
		%OK.grab_focus()  # así Enter guarda en vez de escribir la letra enfocada
	else:
		return
	get_viewport().set_input_as_handled()

func save_name() -> void:
	var player: String = %NombreCampo.text.strip_edges()
	rank = Save.add_score(player if player != "" else "Anónimo", dist)
	Save.save()
	for h in ["#", "Nombre", "Metros"]:
		_cell(h, Color("888888"))
	for i in Save.scores.size():
		var c := Color("ffd600") if i == rank else Color.WHITE  # tu puntaje resaltado
		_cell(str(i + 1), c)
		_cell(Save.scores[i].name, c)
		_cell("%d m" % Save.scores[i].dist, c)
	%FueraTop.visible = rank == -1
	%Nombre.hide()
	%Puntajes.show()
	%OtraVez.grab_focus()

func _cell(s: String, c: Color) -> void:
	var l := Label.new()
	l.text = s
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_color", c)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	%Tabla.add_child(l)

func _on_otra_vez() -> void:
	retry.emit()

func _on_menu() -> void:
	menu.emit()
