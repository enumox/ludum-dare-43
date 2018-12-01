extends KinematicBody
class_name Player

export var move_speed : float
export var jump_force : float
export var gravity : float
export var acceleration : float
export var deceleration : float

var movement : = Vector3()
var dir = Vector3()
var yaw : float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta : float) -> void:
	dir = Vector3()
	var motion = Vector3()
	motion.x = int(Input.is_action_pressed('move_right')) - int(Input.is_action_pressed('move_left'))
	motion.z = int(Input.is_action_pressed('move_forward')) - int(Input.is_action_pressed('move_backward'))
	if Input.is_action_just_released('jump') and is_on_floor():
		movement.y = jump_force
	
	motion = motion.normalized()
	
	dir += -$CameraHolder.global_transform.basis.z.normalized() * motion.z
	dir += $CameraHolder.global_transform.basis.x.normalized() * motion.x
	dir.y = 0
	dir = dir.normalized()
	
	var frame_velocity = movement
	frame_velocity = movement.linear_interpolate(dir * move_speed, acceleration * delta)
	movement.x = frame_velocity.x
	movement.z = frame_velocity.z
	movement.y += delta * gravity
	movement = move_and_slide(movement, Vector3(0, 1, 0), 2)

func _input(event) -> void:
	if event is InputEventMouseMotion:
		yaw = fmod(yaw - event.relative.x * 0.5, 360)
		rotation = Vector3(rotation.x, deg2rad(yaw), 0)