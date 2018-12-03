extends Spatial

signal quest_finished()

onready var audio : = $AudioStreamPlayer

var ongoing_quest : Dictionary setget set_ongoing_quest
var description
var gods_mad_level : int = 0

func _on_Altar_offering_offered(offering : Object) -> void:
	ongoing_quest.clear()
	print(ongoing_quest)
	if offering.description != description:
		gods_mad_level += 1
		if gods_mad_level >= 3:
			get_tree().change_scene("res://interface/FinalMenu.tscn")
	else:
		Scores.score += 1
		audio.play()

func set_ongoing_quest(new_value):
	ongoing_quest = new_value

func _on_QuestGiver_quest_started(quest : Dictionary) -> void:
	self.ongoing_quest = quest
	description = quest.description
	print(ongoing_quest)
