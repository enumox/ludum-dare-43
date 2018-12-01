extends Navigation

func _ready() -> void:
	for animal in $Animals.get_children():
		animal.connect('path_requested', self, '_on_path_requested')

func _on_path_requested(start : Vector3, end : Vector3, requester) -> void:
	requester.path = get_simple_path(start, end)
	