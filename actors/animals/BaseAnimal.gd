extends KinematicBody
class_name BaseAnimal

signal path_requested(start, end, requester)

onready var body = $BodyHitBox
onready var presence_shape = $PresenseArea/CollisionShape
onready var sight = $Sight
onready var presence = $PresenseArea
onready var raycast = $RayCast
onready var gui = $GUI
onready var animation = $AnimalMesh/AnimationPlayer
onready var audio : = $AudioStreamPlayer3D

export var max_hp : float
export var gravity : float
export var move_speed : float
export var run_speed : float
export var description : String
export var sense_of_presence_radius : float setget set_sense_of_presence_radius
export var attack_on_sight : bool
export(float, 1.5, 2.5) var weak_spot_hit_multiplier : float 

enum States { IDLING, RUNNING, ATTACKING, DEAD, FALLING }

var state = States.IDLING
var health : float
var target = null
var movement : = Vector3()
var path = Array()
var player = null
var dead : bool = false

var hit_sounds = [
	preload("res://sounds/hit.wav"),
	preload("res://sounds/hit-2.wav"),
	preload("res://sounds/hit-3.wav"),
]

func _ready() -> void:
	randomize()
	health = max_hp
	sight.connect('body_entered', self, '_on_sight_body_entered')
	presence.connect('body_entered', self, '_on_presence_body_entered')
	presence.connect('body_exited', self, '_on_presence_body_exited')
	body.connect('area_entered', self, '_on_body_area_entered')

func _process(delta : float) -> void:
	if player == null or state != States.IDLING:
		return
	var distance_to_check = presence_shape.shape.radius
	if player.walking:
		distance_to_check *= 0.5
	elif player.crouching:
		distance_to_check *= 0.25
	
	if player.translation.distance_to(translation) < distance_to_check and state != States.RUNNING:
		state = States.RUNNING

func _input(event) -> void:
	if player == null:
		return
	if event.is_action_pressed('interact') and dead and not player.carrying_offering:
		$CollisionShape.queue_free()
		$PresenseArea.queue_free()
		$RayCast.queue_free()
		$Sight.queue_free()
		$BodyHitBox.queue_free()
		$GUI.queue_free()
		player.carry(self, get_parent())
		set_process_input(false)

func _physics_process(delta : float) -> void:
	match state:
		States.IDLING:
			_handle_idling(delta)
		States.RUNNING:
			_handle_running(delta)
		States.ATTACKING:
			_handle_attacking(delta)
		States.DEAD:
			_handle_dead(delta)
		States.FALLING:
			_handle_falling(delta)

func _handle_idling(delta : float) -> void:
	if not is_on_floor():
		state = States.FALLING
	if path.size() == 0:
		randomize()
		emit_signal('path_requested', translation, Vector3(randi() % 45, 0, randi() % 45), self)
		return
	var direction = (path[0] - translation).normalized() - (path[0] - translation).normalized().project(raycast.get_collision_normal())
	direction = direction.normalized()
	var movement = direction * move_speed
	movement.y = -gravity
	move_and_slide(movement, Vector3(0, 1, 0), 2)
	look_at(Vector3(path[0].x, translation.y, path[0].z), Vector3(0, 1, 0))
	if path[0].distance_to(translation) < 5:
		path.remove(0)
	
func _handle_running(delta : float) -> void:
	if path.size() == 0:
		emit_signal('path_requested', translation, -(player.translation - translation).normalized() * 150, self)
		return
	var direction = (path[0] - translation).normalized() - (path[0] - translation).normalized().project(raycast.get_collision_normal())
	direction = direction.normalized()
	var movement = direction * run_speed
	movement.y = -gravity
	move_and_slide(movement, Vector3(0, 1, 0), 2)
	look_at(Vector3(path[0].x, translation.y, path[0].z), Vector3(0, 1, 0))
	if path[0].distance_to(translation) < 5:
		path.remove(0)
		if path.size() == 0 and player == null:
			state = States.IDLING

func _handle_attacking(delta : float) -> void:
	if not is_on_floor():
		state = States.FALLING

func _handle_dead(delta : float) -> void:
	if not is_on_floor():
		state = States.FALLING

func _handle_falling(delta : float) -> void:
	if is_on_floor():
		state = States.IDLING
		return
	move_and_slide(Vector3(0, -gravity, 0), Vector3(0, 1, 0))

func _take_damage(value : float, weak_spot_hit : bool = false) -> void:
	print('damage: ' + str(value))
	OS.delay_msec(100)
	health -= value
	audio.stream = hit_sounds[randi() % hit_sounds.size()]
	audio.play()
	if health <= 0:
		dead = true
		set_physics_process(false)
		set_process(false)
		animation.stop()
		rotation.z = 90
		if player != null:
			presence_shape.shape.radius /= 2
			gui.show_text('Press (E) to pick body up')

func set_sense_of_presence_radius(new_value : float) -> void:
	if $PresenseArea/CollisionShape == null:
		return
	sense_of_presence_radius = new_value
	$PresenseArea/CollisionShape.shape.radius = sense_of_presence_radius

func _on_weak_spot_body_entered(body : PhysicsBody) -> void:
	pass

func _on_sight_body_entered(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	if self.player == null:
		self.player = player
		if dead:
			return
	if attack_on_sight or state == States.RUNNING:
		return
	state = States.RUNNING
	path = []

func _on_presence_body_entered(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	if self.player == null:
		self.player = player
		if dead:
			gui.show_text('Press (E) to pick body up')

func _on_presence_body_exited(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	if self.player != null:
		self.player = null
	if dead == true:
		gui.show_text('')

func _on_body_area_entered(area) -> void:
	var weapon = area as Weapon
	if weapon == null:
		return
	_take_damage(weapon.damage)
