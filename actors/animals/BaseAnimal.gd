extends KinematicBody
class_name BaseAnimal

signal path_requested(start, end, requester)

onready var weak_spot = $WeakSpot
onready var presence_shape = $PresenseArea/CollisionShape
onready var raycast = $RayCast

export var max_hp : float
export var gravity : float
export var move_speed : float
export var description : String
export var sense_of_presence_radius : float setget set_sense_of_presence_radius
export(float, 1.5, 2.5) var weak_spot_hit_multiplier : float 

enum States { IDLING, RUNNING, ATTACKING, DEAD, FALLING }

var state = States.IDLING
var health : float = max_hp
var target = null
var movement : = Vector3()
var path = Array()

func _ready() -> void:
	weak_spot.connect('body_entered', self, '_on_weak_spot_body_entered')

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
		emit_signal('path_requested', translation, Vector3(randi() % 45, 0, randi() % 45), self)
	var direction = (path[0] - translation).normalized() - (path[0] - translation).normalized().project(raycast.get_collision_normal())
	direction = direction.normalized()
	var movement = direction * move_speed
	movement.y = -gravity
	move_and_slide(movement, Vector3(0, 1, 0))
	look_at(path[0], Vector3(0, 1, 0))
	if path[0].distance_to(translation) < 5:
		path.remove(0)
		print("popped")
	
func _handle_running(delta : float) -> void:
	if not is_on_floor():
		state = States.FALLING

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

func set_sense_of_presence_radius(new_value : float) -> void:
	if presence_shape == null:
		return
	sense_of_presence_radius = new_value
	presence_shape.shape.radius = sense_of_presence_radius

func _on_weak_spot_body_entered(body : PhysicsBody) -> void:
	pass
