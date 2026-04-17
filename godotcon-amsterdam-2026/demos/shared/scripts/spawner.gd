extends MultiplayerSpawner

@export var spawn_points: Array[Node3D]

var _avatars := {} as Dictionary[int, Node3D]

func _ready() -> void:
	spawn_function = _spawn

	NetworkEvents.on_server_start.connect(func(): spawn(1))
	NetworkEvents.on_peer_join.connect(func(peer: int): spawn(peer))
	NetworkEvents.on_peer_leave.connect(func(peer: int): _despawn(peer))

func _spawn(peer: int) -> Node3D:
	var spawnable_scene := load(get_spawnable_scene(0)) as PackedScene
	var avatar := spawnable_scene.instantiate() as Node3D

	if avatar.has_method("set_peer"):
		avatar.set_peer(peer)
	else:
		avatar.set_multiplayer_authority(peer)
	_avatars[peer] = avatar

	var spawn_idx := peer % spawn_points.size()
	avatar.position = spawn_points[spawn_idx].global_position
	avatar.scale *= 1.0	# HACK: Adjust during demo for visibility
	avatar.name += " #%d" % peer

	return avatar

func _despawn(peer: int) -> void:
	if not _avatars.has(peer):
		return

	var avatar := _avatars[peer]
	avatar.queue_free()
	_avatars.erase(peer)
