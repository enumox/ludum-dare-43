extends Area

signal found_pickupable(display_message)
signal lost_pickupable()
signal weapon_picked(weapon)

var found_item = null

func _ready() -> void:
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')

func _process(delta : float) -> void:
	if found_item == null:
		return
	if Input.is_action_just_pressed('interact'):
		emit_signal('weapon_picked', found_item)
		found_item = null
		emit_signal('lost_pickupable')

func _on_body_entered(body) -> void:
	var weapon = body as WeaponRackSlot
	if weapon == null or found_item != null:
		return
	found_item = weapon
	emit_signal('found_pickupable', found_item.UI_MESSAGE)

func _on_body_exited(body) -> void:
	var weapon = body as WeaponRackSlot
	if weapon == null:
		return
	found_item = null
	emit_signal('lost_pickupable')