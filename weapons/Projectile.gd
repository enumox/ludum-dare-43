extends Area

export var damage : float
export var speed : float
export var decay_speed : float

var direction : Vector3 = Vector3(0, 0, 1)

func _ready() -> void:
	set_as_toplevel(true)
	connect('area_entered', self, '_on_area_entered')

func initialize(direction : Vector3) -> void:
	self.direction = direction
	print(rotation_degrees)
#	rotation_degrees = init_rotation
#	direction = direction.rotated(Vector3(0, 1, 0), deg2rad(rotation_degrees.y))

func _process(delta : float) -> void:
	print(rotation_degrees)
	translation += direction * speed * delta
	translation += Vector3(0, -1 * delta, 0)

func _on_area_entered(body) -> void:
	if body.is_a_parent_of(self):
		return
	queue_free()
