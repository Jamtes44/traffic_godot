extends Node2D
# Escena de juego: lleva distancia, velocidad y gasolina, mueve lo que hay en la vía y reparte avisos.
# Las señales (moto -> juego, fin del recorrido -> juego) están conectadas en game.tscn (pestaña Nodo > Señales).

const BASE_SPEED := 120.0
const MAX_SPEED := 480.0  # tope a ~1440 m para que siga siendo jugable
const SPEED_PER_M := 0.25  # más recorrido = más rápido
const TURBO_MULT := 1.5
const FUEL_USE := 4.0  # % por segundo; tentativo
const GAS_REFILL := 40.0
const MENU := "res://scenes/menu/menu.tscn"

static var skip_help := false  # "Otra vez" arranca directo, sin instrucciones

var playing := false  # arranca al cerrar las instrucciones
var speed := BASE_SPEED
var dist := 0.0
var fuel := 100.0

@onready var road: Road = $Carretera
@onready var objects: Node2D = $Objetos
@onready var moto: Moto = $Moto
@onready var spawner: Spawner = $Spawner
@onready var engine: AudioStreamPlayer = $Motor
@onready var hud: Control = $UI/HUD
@onready var game_over: Control = $UI/FinRecorrido

func _ready() -> void:
	engine.stream = Audio.engine_loop
	moto.active = false
	if skip_help:
		skip_help = false
		begin()
	else:
		%Instrucciones.show()
		create_tween().set_loops().tween_property(%PulsaTecla, "modulate:a", 0.2, 0.5).from(1.0)

func begin() -> void:
	%Instrucciones.hide()
	playing = true
	moto.active = true
	engine.play()

func _unhandled_input(event: InputEvent) -> void:
	if %Instrucciones.visible and event.is_pressed() and not event.is_echo():  # tecla, botón del control o clic
		get_viewport().set_input_as_handled()
		begin()
	elif playing and event.is_action_pressed("ui_cancel"):  # Esc
		get_viewport().set_input_as_handled()
		pause()

func pause() -> void:
	if playing:
		%Pausa.open()

func _physics_process(delta: float) -> void:
	if not playing:
		return
	var v := speed * (TURBO_MULT if moto.turbo > 0 else 1.0)
	speed = min(BASE_SPEED + dist * SPEED_PER_M, MAX_SPEED)
	dist += v * delta / 10  # metros
	fuel -= FUEL_USE * delta
	road.scroll += v * delta
	engine.pitch_scale = lerp(engine.pitch_scale, sqrt(v / BASE_SPEED), 0.1)  # sube suave y sin pasar de ~2.4x
	for o in objects.get_children():
		o.advance(v, delta)
	spawner.tick(delta, speed)
	if fuel <= 0:
		Audio.play("sin_gas")
		moto.active = false
		end_run("Te quedaste sin gasolina")

func _process(_delta: float) -> void:
	hud.refresh(dist, fuel, moto.shield, moto.hits, Moto.MAX_HITS, moto.turbo > 0)

func _on_moto_picked(kind: String) -> void:
	if kind == "gas":
		fuel = min(fuel + GAS_REFILL, 100)

func end_run(reason: String) -> void:
	playing = false
	engine.stop()
	hud.hide()
	game_over.open(reason, int(dist))

func retry() -> void:
	skip_help = true
	get_tree().reload_current_scene()

func go_menu() -> void:
	get_tree().change_scene_to_file(MENU)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # botón Atrás del control de Android
		if %Pausa.visible:
			%Pausa.close()
		elif playing:
			pause()
		else:
			go_menu()
