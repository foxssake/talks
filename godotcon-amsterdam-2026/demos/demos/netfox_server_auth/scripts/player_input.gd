extends BaseNetInput

@export var movement: Vector3

func _gather() -> void:
	if DisplayServer.window_is_focused():
		movement = Vector3(
			Input.get_axis("move_west", "move_east"),
			0.,
			Input.get_axis("move_north", "move_south")
		)
	else:
		movement = Vector3.ZERO
