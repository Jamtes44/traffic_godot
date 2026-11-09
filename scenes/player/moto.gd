class_name Moto
extends Area2D
# La moto del jugador: se mueve, recibe golpes y recoge power-ups. Avisa al juego con señales.

signal crashed(reason: String)  ## Fin del recorrido.
signal picked(kind: String)  ## Recogió un power-up (gas, escudo, vive).

const STEER_SPEED := 90.0
const MAX_HITS := 2  ## Golpes leves que aguanta.
const TURBO_TIME := 3.0
const BLINK_TIME := 1.0  ## Tras un golpe leve parpadea y no recibe más golpes.

var active := true
var shield := false
var hits := 0
var turbo := 0.0
var invul := 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if not active:
		return
	var half: float = $Forma.shape.size.x / 2
	position.x = clamp(position.x + Input.get_axis("ui_left", "ui_right") * STEER_SPEED * delta,
		Road.LEFT + half, Road.RIGHT - half)
	turbo = max(turbo - delta, 0)
	invul = max(invul - delta, 0)

func _process(_delta: float) -> void:
	$Aura.visible = shield
	$Llama.visible = turbo > 0
	$Llama.scale.y = randf_range(0.6, 1.0)  # la llama titila
	$Sprite.visible = not (invul > 0 and turbo == 0 and int(invul * 12) % 2 == 0)  # parpadeo

func _on_area_entered(area: Area2D) -> void:
	if not active:
		return
	area.queue_free()
	if area is Pickup:
		Audio.play(area.kind)
		if area.kind == "escudo":
			shield = true
		elif area.kind == "vive":
			turbo = TURBO_TIME
			invul = TURBO_TIME
		picked.emit(area.kind)
	elif area is Obstacle:
		_hit(area)

func _hit(o: Obstacle) -> void:
	if invul > 0:
		Audio.play("leve")  # turbo o recién golpeado: lo atraviesas
	elif o.heavy:
		_crash("Chocaste con " + o.display_name)
	elif shield:
		shield = false
		invul = BLINK_TIME
		Audio.play("leve")
	else:
		hits += 1
		if hits >= MAX_HITS:
			_crash("Dos golpes leves")
		else:
			invul = BLINK_TIME
			Audio.play("leve")

func _crash(reason: String) -> void:
	active = false
	Audio.play("fuerte")
	crashed.emit(reason)
