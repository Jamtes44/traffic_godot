extends Node2D
# Menú principal: Iniciar / Configuración / Salir. La carretera avanza de fondo.

const GAME := "res://scenes/game/game.tscn"

func _ready() -> void:
	%Salir.visible = not OS.has_feature("web")  # en el navegador se cierra la pestaña, no el juego
	%Record.text = "Récord: %d m" % Save.best()
	%Brillo.value = Save.brightness
	%Volumen.value = Save.volume
	_update_labels()
	show_config(false)

func start() -> void:
	get_tree().change_scene_to_file(GAME)

func quit_game() -> void:
	get_tree().quit()

func open_config() -> void:
	show_config(true)

func close_config() -> void:
	show_config(false)

func show_config(on: bool) -> void:
	if %Config.visible and not on:
		Save.save()  # al salir de configuración
	%Inicio.visible = not on
	%Config.visible = on
	(%Brillo if on else %Iniciar).grab_focus()  # para usarlo con el control remoto

func _on_brillo_changed(v: float) -> void:
	Save.set_brightness(v)
	_update_labels()

func _on_volumen_changed(v: float) -> void:
	Save.set_volume(v)
	_update_labels()

func _update_labels() -> void:
	%BrilloLabel.text = "Brillo: %d%%" % round(%Brillo.value * 100)
	%VolumenLabel.text = "Volumen: %d%%" % round(%Volumen.value * 100)

func _unhandled_input(event: InputEvent) -> void:
	if %Config.visible and event.is_action_pressed("ui_cancel"):
		close_config()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # botón Atrás del control de Android
		if %Config.visible:
			close_config()
		else:
			quit_game()
