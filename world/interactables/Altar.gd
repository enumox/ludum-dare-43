extends Spatial

signal offering_offered(offering)

onready var sacrifice_position : = $SacrificePosition as Spatial
onready var gui : = $GUI

var player

func _ready() -> void:
	set_process_input(false)
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')

func place_offering(offering : Spatial) -> void:
	sacrifice_position.add_child(offering)
	offering.translation = Vector3()
	#TODO: Add animation/effect
	yield(get_tree().create_timer(2.0), 'timeout')
	emit_signal('offering_offered', offering)
	sacrifice_position.get_child(0).queue_free()

func _input(event) -> void:
	if event.is_action_pressed('interact'):
		var offering = player.take_offering()
		place_offering(offering)

func _on_body_entered(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	if not player.carrying_offering:
		return
	self.player = player
	set_process_input(true)
	gui.show_text('Press (E) to place the animal on the altar')

func _on_body_exited(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	gui.show_text('')
	set_process_input(false)
	self.player = null