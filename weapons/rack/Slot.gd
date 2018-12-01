extends Spatial
class_name WeaponRackSlot

const UI_MESSAGE = 'Press (E) to pickup'

func set_weapon(new_weapon, old_parent):
	old_parent.remove_child(new_weapon)
	add_child(new_weapon)
	new_weapon.translation = Vector3()
	new_weapon.active = false