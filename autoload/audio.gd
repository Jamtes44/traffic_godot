extends Node
# Autoload "Audio": efectos de sonido. Todo botón del juego suena "click" solo (ver _on_node_added).
# shortcut: sonidos retro generados por código; cambiar por .wav/.ogg en _ready cuando haya audio propio.

const RATE := 22050

var sfx := {}
var engine_loop: AudioStreamWAV  # motor de la moto, en loop
var _voices: Array[AudioStreamPlayer] = []

func _ready() -> void:
	sfx = {
		"click": tone(800, 800, 0.04, "square", 0.2),
		"gas": tone(600, 1000, 0.12, "square", 0.3),
		"escudo": tone(400, 800, 0.2, "sine", 0.5),
		"vive": tone(300, 1400, 0.4, "square", 0.3),
		"leve": tone(0, 0, 0.15, "noise", 0.4),
		"fuerte": tone(0, 0, 0.6, "noise", 0.7),
		"sin_gas": tone(400, 80, 0.6, "square", 0.3),
		"record": tone(523, 1046, 0.5, "square", 0.3),
	}
	engine_loop = tone(60, 60, 0.5, "square", 0.12, true)  # 0.5 s = 30 ciclos exactos: loop sin clic
	for i in 4:  # varios sonidos a la vez
		_voices.append(AudioStreamPlayer.new())
		add_child(_voices[-1])
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(play.bind("click"))

func play(sound: String) -> void:
	for v in _voices:
		if not v.playing:
			v.stream = sfx[sound]
			v.play()
			return
	_voices[0].stream = sfx[sound]  # todas ocupadas: reusa la primera
	_voices[0].play()

func tone(f_from: float, f_to: float, dur: float, wave: String, vol: float, loop := false) -> AudioStreamWAV:
	var n := int(RATE * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var k := float(i) / n
		phase += lerp(f_from, f_to, k) / RATE
		var s: float
		match wave:
			"square": s = 1.0 if fmod(phase, 1.0) < 0.5 else -1.0
			"noise": s = randf() * 2 - 1
			_: s = sin(phase * TAU)
		var env := 1.0 if loop else 1.0 - k  # se apaga al final
		data.encode_s16(i * 2, int(s * env * vol * 32767))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_end = n
	return w
