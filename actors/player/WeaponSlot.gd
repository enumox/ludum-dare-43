extends Spatial

func _on_PickableArea_weapon_picked(weapon_slot):
	if get_child_count() > 0:
		weapon_slot.set_weapon(get_child(0), self)
	var weapon = weapon_slot.get_child(1)
	weapon_slot.remove_child(weapon)
	add_child(weapon)
	weapon.active = true
	get_child(0).translation = Vector3()
