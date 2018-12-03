tool
extends Spatial

var rocks = [
	preload("res://world/props/Rock.tscn")
]

func _process(delta : float) -> void:
	if Input.is_action_just_pressed('jump'):
		print('yes')
		var rock = rocks[0].instance()
		rock.translation = translation
		add_child(rock)
		rock.owner = self