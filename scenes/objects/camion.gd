extends Obstacle
# Camión: avanza casi tan rápido como tú y luego frena de golpe (se le prenden las luces).

const BRAKE_AT := 1.5  # segundos

var _t := 0.0

func advance(v: float, delta: float) -> void:
	_t += delta
	var fwd: float = 0.8 if _t < BRAKE_AT else max(0.1, 0.8 - (_t - BRAKE_AT) * 0.8)  # fracción de tu velocidad
	$LucesFreno.visible = _t >= BRAKE_AT
	super.advance(v * (1 - fwd), delta)
