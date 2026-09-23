extends Label

@export var velocidad := 0.05

func escribir(texto: String):
	text = ""
	
	for caracter in texto:
		text += caracter
		await get_tree().create_timer(velocidad).timeout
