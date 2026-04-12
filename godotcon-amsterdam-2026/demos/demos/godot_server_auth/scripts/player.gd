extends CharacterBody3D

@export var move_speed := 8.
@export var gravity := 24.

@onready var input := $Input

var _peer := 1

func set_peer(peer: int) -> void:
	_peer = peer

func _enter_tree() -> void:
	set_multiplayer_authority(1)
	$Input.set_multiplayer_authority(_peer)
	$"Input Synchronizer".set_multiplayer_authority(_peer)

func _ready() -> void:
	# Set player color
	var color := Utils.generate_player_color(_peer)
	Utils.override_mesh_color(self, color)

func _physics_process(dt: float) -> void:
	if not is_multiplayer_authority():
		return

	var movement_basis := get_viewport().get_camera_3d().basis
	var movement := movement_basis * input.movement as Vector3
	movement.y = 0.
	movement = movement.normalized() * move_speed

	velocity.x = movement.x
	velocity.y -= gravity * dt
	velocity.z = movement.z

	move_and_slide()
