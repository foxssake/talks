extends Object
class_name Utils

static func generate_player_color(id: int) -> Color:
	var rng := RandomNumberGenerator.new()
	rng.seed = id
	var hue := rng.randf()

	return Color.from_ok_hsl(hue, 1., .5)

static func override_mesh_color(of: Node, color: Color) -> void:
	for node in of.find_children("*", "MeshInstance3D"):
		var mesh_instance := node as MeshInstance3D
		var material := mesh_instance.get_surface_override_material(0)
		if not material or not material is StandardMaterial3D:
			continue

		var standard_material := material  as StandardMaterial3D
		standard_material = standard_material.duplicate()
		standard_material.albedo_color = color

		mesh_instance.set_surface_override_material(0, standard_material)
