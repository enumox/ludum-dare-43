extends Spatial

signal quest_finished()

var ongoing_quest : Dictionary setget set_ongoing_quest
var description

func _on_Altar_offering_offered(offering : Object) -> void:
	ongoing_quest.clear()
	print(ongoing_quest)
	if offering.description != description:
		print('WRONG')
	else:
		print('RIGHT')

func set_ongoing_quest(new_value):
	ongoing_quest = new_value
	print('SET ONGOING QUEST')

func _on_QuestGiver_quest_started(quest : Dictionary) -> void:
	self.ongoing_quest = quest
	description = quest.description
	print(ongoing_quest)
