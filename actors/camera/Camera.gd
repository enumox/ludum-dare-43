extends Spatial

signal interactable_found(text)
signal item_lost()

export(float, 0.1, 1.0) var mouse_sensibility : float
onready var raycast = $Raycast

var yaw : float
var pitch : float
var found_item = null

func _input(event) -> void:
	if event is InputEventMouseMotion:
		pitch = max(min(pitch - event.relative.y * 0.5, 90), -90)
		rotation = Vector3(deg2rad(pitch), rotation.y, 0)
