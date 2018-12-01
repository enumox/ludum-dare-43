extends KinematicBody
class_name BaseAnimal

signal path_requested(start, end, requester)

onready var weak_spot = $WeakSpot
onready var body = $BodyHitBox
onready var presence_shape = $PresenseArea/CollisionShape
onready var sight = $Sight
onready var presence = $PresenseArea
onready var raycast = $RayCast

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

func _ready() -> void:
	health = max_hp
	weak_spot.connect('body_entered', self, '_on_weak_spot_body_entered')
	sight.connect('body_entered', self, '_on_sight_body_entered')
	presence.connect('body_entered', self, '_on_presence_body_entered')
	presence.connect('body_exited', self, '_on_presence_body_exited')
	body.connect('area_entered', self, '_on_body_area_entered')

func _process(delta : float) -> void:
	if player == null or state != States.IDLING:
		return
	#TODO: Check for player running/walking/crouching
	var distance_to_check = presence_shape.shape.radius
	if player.walking:
		distance_to_check *= 0.5
	elif player.crouching:
		distance_to_check *= 0.25
	
	if player.translation.distance_to(translation) < distance_to_check and state != States.RUNNING:
		state = States.RUNNING

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
	print('damage')
	health -= value
	if health <= 0:
		queue_free()

func set_sense_of_presence_radius(new_value : float) -> void:
	if presence_shape == null:
		return
	sense_of_presence_radius = new_value
	presence_shape.shape.radius = sense_of_presence_radius

func _on_weak_spot_body_entered(body : PhysicsBody) -> void:
	pass

func _on_sight_body_entered(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	if self.player == null:
		self.player = player
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

func _on_presence_body_exited(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	if self.player != null:
		self.player = null

func _on_body_area_entered(area) -> void:
	var weapon = area as Weapon
	if weapon == null:
		return
	_take_damage(weapon.damage)
