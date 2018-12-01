extends Spatial
class_name Weapon

export var damage : float
export(float, 0.1, 2.0) var attack_delay : float

onready var timer : = $Timer as Timer
onready var animation : = $AnimationPlayer as AnimationPlayer

func _ready() -> void:
	timer.wait_time = attack_delay

func _process(delta : float) -> void:
	if Input.is_action_pressed('attack') and timer.is_stopped():
		timer.start()
		animation.play('attack')