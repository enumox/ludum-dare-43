extends Control

func _ready() -> void:
	Scores.score = 0

func _on_PlayButton_pressed() -> void:
	get_tree().change_scene("res://Game.tscn")

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
