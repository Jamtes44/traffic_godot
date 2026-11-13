extends Control
# Barra superior: metros, gasolina, casco, vidas y turbo. El juego llama refresh() cada frame.

signal pause_pressed

func _on_pausa_pressed() -> void:
	pause_pressed.emit()

func refresh(dist: float, fuel: float, shield: bool, hits: int, max_hits: int, turbo: bool) -> void:
	%Distancia.text = "%d m" % dist
	%Gasolina.value = fuel
	%Gasolina.modulate = Color(1, 0.3, 0.3) if fuel < 25 else Color.WHITE  # rojo: queda poca
	%Casco.visible = shield
	for i in %Vidas.get_child_count():  # un corazón por golpe leve que aguanta; los perdidos quedan tenues
		%Vidas.get_child(i).modulate.a = 1.0 if i < max_hits - hits else 0.25
	%Turbo.visible = turbo
