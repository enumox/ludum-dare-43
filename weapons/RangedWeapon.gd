extends Spatial

export var ammo : PackedScene
export var attack_delay : float
export var active_rotation : Vector3
export var active : bool = true setget set_active

onready var timer : = $Timer as Timer

func _ready() -> void:
	timer.wait_time = attack_delay
	print(active)
	set_process(active)

func _process(delta : float) -> void:
	if Input.is_action_pressed('attack') and timer.is_stopped():
		_shoot()

func _shoot() -> void:
	timer.start()
	var new_ammo = ammo.instance()
	var direction = Vector3(0,0,1).rotated(Vector3(0,1,0), global_transform.basis.get_euler().y)
	new_ammo.initialize(direction)
	$SpawnPos.add_child(new_ammo)

func set_active(new_value : bool) -> void:
	active = new_value
	set_process(active)
	if active:
		rotation_degrees = active_rotation
	else:
		rotation = Vector3()
		