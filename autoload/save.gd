extends Node
# Autoload "Save": tabla de puntajes y ajustes (brillo, volumen, música, motor) guardados en user://record.cfg.
#   Windows: %APPDATA%/Godot/app_userdata/Gamedev - Traffic Runner/record.cfg
#   Android: almacenamiento interno de la app (se borra al desinstalar).

const PATH := "user://record.cfg"
const OLD_DIR := "Moto Runner"  # nombre anterior del juego: su carpeta de datos se migra una vez
const TOP := 10
const MUSIC_BUS := "Musica"  # buses propios: música y motor se ajustan sin tocar los demás sonidos
const ENGINE_BUS := "Motor"

var brightness := 1.0
var volume := 0.8
var music_volume := 0.6
var music_on := true
var engine_volume := 0.8
var scores := []  # [{name, dist}] de mayor a menor
var _dimmer := CanvasModulate.new()  # brillo: multiplica el color del mundo en todas las escenas

func _ready() -> void:
	add_child(_dimmer)
	for bus in [MUSIC_BUS, ENGINE_BUS]:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	var old_file := OS.get_user_data_dir().get_base_dir().path_join(OLD_DIR).path_join("record.cfg")
	if not FileAccess.file_exists(PATH) and FileAccess.file_exists(old_file):
		DirAccess.copy_absolute(old_file, ProjectSettings.globalize_path(PATH))
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		brightness = cfg.get_value("juego", "brillo", 1.0)
		volume = cfg.get_value("juego", "volumen", 0.8)
		music_volume = cfg.get_value("juego", "musica", 0.6)
		music_on = cfg.get_value("juego", "musica_on", true)
		engine_volume = cfg.get_value("juego", "motor", 0.8)
		scores = cfg.get_value("juego", "puntajes", [])
		var old: int = cfg.get_value("juego", "record", 0)  # récord guardado antes de existir la tabla
		if scores.is_empty() and old > 0:
			scores = [{name = "---", dist = old}]
	set_brightness(brightness)
	set_volume(volume)
	set_music_volume(music_volume)
	set_music_on(music_on)
	set_engine_volume(engine_volume)

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("juego", "brillo", brightness)
	cfg.set_value("juego", "volumen", volume)
	cfg.set_value("juego", "musica", music_volume)
	cfg.set_value("juego", "musica_on", music_on)
	cfg.set_value("juego", "motor", engine_volume)
	cfg.set_value("juego", "puntajes", scores)
	cfg.save(PATH)

func best() -> int:
	return scores[0].dist if scores.size() > 0 else 0

## Agrega el puntaje y devuelve su puesto (0 = primero) o -1 si no entró al top.
func add_score(player: String, dist: int) -> int:
	var entry := {name = player, dist = dist}
	scores.append(entry)
	scores.sort_custom(func(a, b): return a.dist > b.dist)
	scores.resize(min(scores.size(), TOP))
	return scores.find(entry)

func set_brightness(v: float) -> void:
	brightness = v
	_dimmer.color = Color(v, v, v)

func set_volume(v: float) -> void:
	volume = v
	AudioServer.set_bus_volume_db(0, linear_to_db(v))

func set_music_volume(v: float) -> void:
	music_volume = v
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(v))

func set_music_on(on: bool) -> void:
	music_on = on
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MUSIC_BUS), not on)

func set_engine_volume(v: float) -> void:
	engine_volume = v
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(ENGINE_BUS), linear_to_db(v))
