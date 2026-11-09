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

var playing := true
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
	engine.play()

func _physics_process(delta: float) -> void:
	if not playing:
		return
	var v := speed * (TURBO_MULT if moto.turbo > 0 else 1.0)
	speed = min(BASE_SPEED + dist * SPEED_PER_M, MAX_SPEED)
	dist += v * delta / 10  # metros
	fuel -= FUEL_USE * delta
	road.scroll += v * delta
	engine.pitch_scale = v / BASE_SPEED  # el motor suena más agudo con la velocidad
	for o in objects.get_children():
		o.advance(v, delta)
	spawner.tick(delta, speed)
	if fuel <= 0:
		Audio.play("sin_gas")
		moto.active = false
		end_run("Te quedaste sin gasolina")

func _process(_delta: float) -> void:
	hud.refresh(dist, fuel, moto.shield, moto.hits, Moto.MAX_HITS, moto.turbo > 0)
	if playing and Input.is_action_just_pressed("ui_cancel"):
		go_menu()

func _on_moto_picked(kind: String) -> void:
	if kind == "gas":
		fuel = min(fuel + GAS_REFILL, 100)

func end_run(reason: String) -> void:
	playing = false
	engine.stop()
	hud.hide()
	game_over.open(reason, int(dist))

func retry() -> void:
	get_tree().reload_current_scene()

func go_menu() -> void:
	get_tree().change_scene_to_file(MENU)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # botón Atrás del control de Android
		go_menu()
