extends VBoxContainer
# Volumen general, música y motor. El mismo bloque va en Configuración (menú) y en la pausa (juego).

func _ready() -> void:
	%Volumen.value = Save.volume
	%Motor.value = Save.engine_volume
	%Musica.value = Save.music_volume
	%MusicaOn.button_pressed = Save.music_on
	_update()

func focus_first() -> void:
	%MusicaOn.grab_focus()

func _on_volumen_changed(v: float) -> void:
	Save.set_volume(v)
	_update()

func _on_motor_changed(v: float) -> void:
	Save.set_engine_volume(v)
	_update()

func _on_musica_changed(v: float) -> void:
	Save.set_music_volume(v)
	_update()

func _on_musica_on_toggled(on: bool) -> void:
	Save.set_music_on(on)
	_update()

func _update() -> void:
	%VolumenLabel.text = "Volumen %d%%" % round(Save.volume * 100)
	%MusicaLabel.text = "Música %d%%" % round(Save.music_volume * 100) if Save.music_on else "Música off"
	%MotorLabel.text = "Motor %d%%" % round(Save.engine_volume * 100)
	%Musica.editable = Save.music_on
