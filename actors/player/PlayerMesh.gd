extends Spatial

func _on_PickableArea_weapon_picked(weapon):
	$Armature/WeaponSlot._on_PickableArea_weapon_picked(weapon)
