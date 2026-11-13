extends Control
# Menú de pausa: congela el juego (get_tree().paused) y deja ajustar música y volumen.
# Corre con process_mode = Siempre para seguir recibiendo teclas mientras todo está en pausa.

signal menu

func open() -> void:
	show()
	get_tree().paused = true
	%Continuar.grab_focus()

func close() -> void:
	hide()
	get_tree().paused = false
	Save.save()

func _on_menu() -> void:
	close()
	menu.emit()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
