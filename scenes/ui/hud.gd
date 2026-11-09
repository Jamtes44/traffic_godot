extends Control
# Barra superior: metros, gasolina, casco, golpes y turbo. El juego llama refresh() cada frame.

func refresh(dist: float, fuel: float, shield: bool, hits: int, max_hits: int, turbo: bool) -> void:
	%Distancia.text = "%d m" % dist
	%Gasolina.value = fuel
	%Gasolina.modulate = Color(1, 0.3, 0.3) if fuel < 25 else Color.WHITE  # rojo: queda poca
	%Casco.visible = shield
	%Golpes.visible = hits > 0
	%Golpes.text = "Golpe leve %d/%d" % [hits, max_hits]
	%Turbo.visible = turbo
