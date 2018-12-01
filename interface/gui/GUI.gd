extends CanvasLayer

onready var bottom_text : = $Container/BottomText as Label

func show_text(text : String) -> void:
	bottom_text.text = text
