extends CharacterBody3D

@export var move_speed := 8.
@export var gravity := 24.

@onready var state_synchronizer: StateSynchronizer = $StateSynchronizer

func _ready() -> void:
	# Set player color
	var color := Utils.generate_player_color(get_multiplayer_authority())
	Utils.override_mesh_color(self, color)

	# Connect signals
	NetworkTime.on_tick.connect(_tick)

	# Set schema for better bandwidth usage
	state_synchronizer.set_schema({
		":position": NetworkSchemas.vec3f16(),
		":quaternion": NetworkSchemas.quatf16()
	})

func _tick(dt: float, _t: int) -> void:
	if not is_multiplayer_authority():
		return

	var input_movement := Vector3(
		Input.get_axis("move_west", "move_east"),
		0.,
		Input.get_axis("move_north", "move_south")
	)
	if not DisplayServer.window_is_focused():
		input_movement = Vector3.ZERO

	var movement_basis := get_viewport().get_camera_3d().basis

	var movement := movement_basis * input_movement
	movement.y = 0.
	movement = movement.normalized() * move_speed

	velocity.x = movement.x
	velocity.y -= gravity * dt
	velocity.z = movement.z

	Cheats.use_if_active(self)

	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
