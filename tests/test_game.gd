extends SceneTree
# Correr: Godot_console.exe --headless --path juego -s res://tests/test_game.gd
# Carga la escena de juego real y prueba las reglas. No guarda nada en disco.

var g  # escena de juego
var moto

func _initialize() -> void:
	change_scene_to_file("res://scenes/game/game.tscn")
	for i in 3:
		await process_frame
	g = current_scene
	moto = g.moto
	g.spawner.active = false  # solo los objetos que pone el test

	# instrucciones: el juego espera una tecla
	check(g.get_node("%Instrucciones").visible and not g.playing, "instrucciones antes de arrancar")
	var key := InputEventKey.new(); key.keycode = KEY_SPACE; key.pressed = true
	root.push_input(key)
	await process_frame
	check(not g.get_node("%Instrucciones").visible and g.playing, "cualquier tecla arranca")

	# música y pausa (sin Save.save(): el test no escribe en disco)
	check(root.get_node("Audio").music.playing and root.get_node("Audio").music.bus == "Musica" and root.get_node("Audio").music.stream.loop, "música en loop")
	var bus := AudioServer.get_bus_index("Musica")
	root.get_node("Save").set_music_on(false)
	check(AudioServer.is_bus_mute(bus) and not AudioServer.is_bus_mute(0), "silenciar solo la música")
	check(g.engine.bus == "Motor" and g.engine.playing, "motor en su propio volumen")
	root.get_node("Save").set_music_on(true)
	var esc := InputEventAction.new(); esc.action = "ui_cancel"; esc.pressed = true
	root.push_input(esc)
	await process_frame
	var pausa: Control = g.get_node("%Pausa")
	check(pausa.visible and paused, "Esc abre la pausa")
	pausa.hide(); paused = false

	# golpe leve con casco: sigue vivo y pierde el casco
	reset(); moto.shield = true; await hit("hueco")
	check(g.playing and not moto.shield, "casco salva golpe leve")
	# primer golpe leve sin casco: parpadea y sigue
	moto.invul = 0; await hit("bici")
	check(g.playing and moto.hits == 1 and moto.invul > 0, "1er golpe leve parpadea")
	# segundo golpe leve: fin
	moto.invul = 0; await hit("hueco")
	check(not g.playing, "2do golpe leve termina")
	# golpe fuerte con casco: fin igual
	reset(); moto.shield = true; await hit("camion")
	check(not g.playing, "casco no salva golpe fuerte")
	# turbo atraviesa obstáculos fuertes
	reset(); await hit("vive"); await hit("valla")
	check(g.playing and moto.turbo > 0, "turbo atraviesa valla")
	# velocidad sube con la distancia
	reset(); g.dist = 400; await physics_frame
	check(g.speed > g.BASE_SPEED + 90, "más recorrido, más rápido")
	# gasolina recarga y se acaba
	reset(); g.fuel = 10; await hit("gas")
	check(absf(g.fuel - 50) < 1, "gasolina +40")
	g.fuel = 0.01; await physics_frame; await physics_frame
	check(not g.playing, "sin gasolina termina")
	# spawner: cada objeto aparece donde dice su placement
	var bici: RoadObject = g.spawner.spawn(load("res://scenes/objects/bici.tscn"))
	var valla: RoadObject = g.spawner.spawn(load("res://scenes/objects/valla.tscn"))
	check(bici.position.x < Road.LEFT or bici.position.x > Road.RIGHT, "bici entra por la orilla")
	check(int(valla.position.x - Road.LEFT) % int(Road.LANE_W) == 0, "valla sobre una línea")

	# teclado en pantalla: escribe, borra y respeta el máximo
	var fin = g.game_over
	fin.open("x", 10)
	fin.type_char("A"); fin.type_char("B"); fin.backspace()
	check(fin.get_node("%NombreCampo").text == "A", "teclado en pantalla")
	for i in 20:
		fin.type_char("Z")
	check(fin.get_node("%NombreCampo").text.length() == 12, "nombre máximo 12")

	# sonidos generados con la duración correcta
	var audio = root.get_node("Audio")
	check(audio.sfx["click"].data.size() == int(audio.RATE * 0.04) * 2 and audio.sfx.size() == 8, "sonidos generados")

	# tabla: ordena de mayor a menor, máximo 10, devuelve el puesto (en memoria)
	var save = root.get_node("Save")
	save.scores = []
	for d in [50, 300, 120]:
		save.add_score("p%d" % d, d)
	check(save.scores.map(func(s): return s.dist) == [300, 120, 50], "tabla ordenada")
	for i in 10:
		save.add_score("x", 1000)
	check(save.scores.size() == 10, "tabla máximo 10")
	check(save.add_score("malo", 1) == -1 and save.add_score("top", 5000) == 0, "puesto en la tabla")
	quit()

func reset() -> void:
	for o in g.objects.get_children():
		o.free()
	g.playing = true
	g.fuel = 100.0
	g.dist = 0.0
	moto.active = true
	moto.shield = false
	moto.hits = 0
	moto.turbo = 0.0
	moto.invul = 0.0

## Pone el objeto encima de la moto y deja correr la física para que choquen.
func hit(kind: String) -> void:
	var o: RoadObject = load("res://scenes/objects/%s.tscn" % kind).instantiate()
	o.position = moto.position
	g.objects.add_child(o)
	for i in 3:
		await physics_frame

func check(ok: bool, what: String) -> void:
	print(("OK   " if ok else "FAIL ") + what)
