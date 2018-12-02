extends Spatial

signal quest_started()

export var peaceful_animals : Array
export var aggressive_animals : Array

onready var gui = $GUI

var completed_quests : int = 0
var ongoing_quest : Dictionary = {}

func _on_Area_body_entered(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	if not ongoing_quest.empty():
		gui.show_text('Have you already found what the GODS want? It\'s something ' + ongoing_quest.description + '.')
		return
	var animal = peaceful_animals[randi() % peaceful_animals.size()].instance()
	gui.show_text('The GODS wish for something ' + animal.description + '.')
	ongoing_quest = { 
		'description': animal.description
	}
	animal.queue_free()

func _on_Area_body_exited(body : PhysicsBody) -> void:
	var player = body as Player
	if player == null:
		return
	gui.show_text('')
