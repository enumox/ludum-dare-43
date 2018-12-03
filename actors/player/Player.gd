extends KinematicBody
class_name Player

signal interactable_found(text)
signal item_lost()

onready var gui = $GUI
onready var carry_location : = $CarryLocation as Spatial

export var move_speed : float
export var jump_force : float
export var gravity : float
export var acceleration : float
export var deceleration : float

var movement : = Vector3()
var dir = Vector3()
var yaw : float
var carrying_offering : bool = false
var offering = null

var crouching : bool
var walking : bool

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta : float) -> void:
	dir = Vector3()
	var motion = Vector3()
	walking = false
	crouching = false
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
	var frame_speed = move_speed
	#TODO: Play correct animations
	if Input.is_action_pressed('walk'):
		frame_speed *= 0.75
		walking = true
	elif Input.is_action_pressed('crouch'):
		frame_speed *= 0.5
		crouching = true
	
	if frame_speed < move_speed:
		frame_velocity = movement.linear_interpolate(dir * frame_speed, deceleration * delta)
	else:
		frame_velocity = movement.linear_interpolate(dir * frame_speed, acceleration * delta)
	
	movement.x = frame_velocity.x
	movement.z = frame_velocity.z
	movement.y += delta * gravity
	movement = move_and_slide(movement, Vector3(0, 1, 0), 2)

func _input(event) -> void:
	if event is InputEventMouseMotion:
		yaw = fmod(yaw - event.relative.x * 0.5, 360)
		rotation = Vector3(rotation.x, deg2rad(yaw), 0)

func _on_PickableArea_found_pickupable(display_message : String) -> void:
	gui.show_text(display_message)

func _on_PickableArea_lost_pickupable() -> void:
	gui.show_text('')

func carry(animal, parent) -> void:
	if carrying_offering:
		return
	parent.remove_child(animal)
	carrying_offering = true
	carry_location.add_child(animal)
	offering = animal
	animal.translation = Vector3()

func take_offering() -> Object:
	carrying_offering = false
	carry_location.remove_child(offering)
	return offering
