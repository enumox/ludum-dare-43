extends Spatial

export(float, 0.1, 1.0) var mouse_sensibility : float

var yaw : float
var pitch : float

func _input(event) -> void:
	if event is InputEventMouseMotion:
		pitch = max(min(pitch - event.relative.y * 0.5, 90), -90)
		rotation = Vector3(deg2rad(pitch), rotation.y, 0)
