extends Object
class_name Cheats

static var _is_active := false

static func is_active() -> bool:
	return _is_active

static func toggle() -> void:
	_is_active = not _is_active

static func use_if_active(target: CharacterBody3D) -> void:
	if is_active():
		target.velocity.y = 0.
		target.collision_mask = 0
	else:
		target.collision_mask = 0xffff_ffff
