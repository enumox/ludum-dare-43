extends Control

func _ready() -> void:
	var final_score : String = str(Scores.score)
	$VBoxContainer/Score.text = "Sacrifices: " + final_score

func _on_QuitButton_pressed() -> void:
	get_tree().change_scene("res://interface/MainMenu.tscn")
