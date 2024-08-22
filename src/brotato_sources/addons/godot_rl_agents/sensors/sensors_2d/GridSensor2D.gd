tool
extends Node2D

export(bool) var debug_view = false setget set_debug_view, get_debug_view
export(int, "PhysicsBody2D, Area2D") var detection_mask = 0 setget set_detection_mask, get_detection_mask
export(bool) var collide_with_areas = false setget set_collide_with_areas, get_collide_with_areas
export(bool) var collide_with_bodies = true setget set_collide_with_bodies, get_collide_with_bodies
export(float, 1, 200, 0.1) var cell_width = 20.0 setget set_cell_width, get_cell_width
export(float, 1, 200, 0.1) var cell_height = 20.0 setget set_cell_height, get_cell_height
export(int, 1, 21, 2) var grid_size_x = 3 setget set_grid_size_x, get_grid_size_x
export(int, 1, 21, 2) var grid_size_y = 3 setget set_grid_size_y, get_grid_size_y

var _obs_buffer: PoolRealArray
var _rectangle_shape: RectangleShape2D
var _collision_mapping: Dictionary
var _n_layers_per_cell: int

var _highlighted_cell_color: Color
var _standard_cell_color: Color

func get_debug_view():
	return debug_view

func set_debug_view(value):
	debug_view = value
	_update()

func get_detection_mask():
	return detection_mask

func set_detection_mask(value):
	detection_mask = value
	_update()

func get_collide_with_areas():
	return collide_with_areas

func set_collide_with_areas(value):
	collide_with_areas = value
	_update()

func get_collide_with_bodies():
	return collide_with_bodies

func set_collide_with_bodies(value):
	collide_with_bodies = value
	_update()

func get_cell_width():
	return cell_width

func set_cell_width(value):
	cell_width = value
	_update()

func get_cell_height():
	return cell_height

func set_cell_height(value):
	cell_height = value
	_update()

func get_grid_size_x():
	return grid_size_x

func set_grid_size_x(value):
	grid_size_x = value
	_update()

func get_grid_size_y():
	return grid_size_y

func set_grid_size_y(value):
	grid_size_y = value
	_update()

func get_observation():
	return _obs_buffer

func _update():
	if Engine.is_editor_hint():
		if is_inside_tree():
			_spawn_nodes()

func _ready() -> void:
	_set_colors()

	if Engine.is_editor_hint():
		if get_child_count() == 0:
			_spawn_nodes()
	else:
		_spawn_nodes()

func _set_colors() -> void:
	_standard_cell_color = Color(100.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0)
	_highlighted_cell_color = Color(255.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0)

func _get_collision_mapping() -> Dictionary:
	# defines which layer is mapped to which cell obs index
	var total_bits = 0
	var collision_mapping = {}
	for i in range(32):
		var bit_mask = 2 & i
		if (detection_mask & bit_mask) > 0:
			collision_mapping[i] = total_bits
			total_bits += 1

	return collision_mapping

func _spawn_nodes():
	for cell in get_children():
		cell.name = "_%s" % cell.name  # Otherwise naming below will fail
		cell.queue_free()

	_collision_mapping = _get_collision_mapping()
	_n_layers_per_cell = len(_collision_mapping)
	_obs_buffer = PoolRealArray()
	_obs_buffer.resize(grid_size_x * grid_size_y * _n_layers_per_cell)
	_obs_buffer.fill(0)

	_rectangle_shape = RectangleShape2D.new()
	_rectangle_shape.set_extents(Vector2(cell_width, cell_height) * 0.5)

	var shift := Vector2(
		-(grid_size_x / 2) * cell_width,
		-(grid_size_y / 2) * cell_height
	)

	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var cell_position = Vector2(i * cell_width, j * cell_height) + shift
			_create_cell(i, j, cell_position)

func _create_cell(i: int, j: int, position: Vector2):
	var cell := Area2D.new()
	cell.position = position
	cell.name = "GridCell %s %s" % [i, j]
	cell.modulate = _standard_cell_color

	if collide_with_areas:
		cell.connect("area_entered", self, "_on_cell_area_entered", [i, j])
		cell.connect("area_exited", self, "_on_cell_area_exited", [i, j])

	if collide_with_bodies:
		cell.connect("body_entered", self, "_on_cell_body_entered", [i, j])
		cell.connect("body_exited", self, "_on_cell_body_exited", [i, j])

	cell.collision_layer = 0
	cell.collision_mask = detection_mask
	cell.monitorable = true
	add_child(cell)
	cell.set_owner(get_tree().root)

	var col_shape := CollisionShape2D.new()
	col_shape.shape = _rectangle_shape
	col_shape.name = "CollisionShape2D"
	cell.add_child(col_shape)
	col_shape.set_owner(get_tree().root)

	if debug_view:
		var quad = Polygon2D.new()
		quad.name = "Polygon2D"
		quad.polygon = PoolVector2Array([Vector2(0, 0), Vector2(cell_width, 0), Vector2(cell_width, cell_height), Vector2(0, cell_height)])
		cell.add_child(quad)
		quad.set_owner(get_tree().root)

func _update_obs(cell_i: int, cell_j: int, collision_layer: int, entered: bool):
	for key in _collision_mapping:
		var bit_mask = 2 & key
		if (collision_layer & bit_mask) > 0:
			var collision_map_index = _collision_mapping[key]
			var obs_index = (cell_i * grid_size_x * _n_layers_per_cell) + (cell_j * _n_layers_per_cell) + collision_map_index
			if entered:
				_obs_buffer[obs_index] += 1
			else:
				_obs_buffer[obs_index] -= 1

func _toggle_cell(cell_i: int, cell_j: int):
	var cell = get_node_or_null("GridCell %s %s" % [cell_i, cell_j])
	if cell == null:
		print("cell not found, returning")
		return

	var n_hits = 0
	var start_index = (cell_i * grid_size_x * _n_layers_per_cell) + (cell_j * _n_layers_per_cell)
	for i in range(_n_layers_per_cell):
		n_hits += _obs_buffer[start_index + i]

	if n_hits > 0:
		cell.modulate = _highlighted_cell_color
	else:
		cell.modulate = _standard_cell_color

func _on_cell_area_entered(area: Area2D, cell_i: int, cell_j: int):
	_update_obs(cell_i, cell_j, area.collision_layer, true)
	if debug_view:
		_toggle_cell(cell_i, cell_j)

func _on_cell_area_exited(area: Area2D, cell_i: int, cell_j: int):
	_update_obs(cell_i, cell_j, area.collision_layer, false)
	if debug_view:
		_toggle_cell(cell_i, cell_j)

func _on_cell_body_entered(body: Node2D, cell_i: int, cell_j: int):
	_update_obs(cell_i, cell_j, body.collision_layer, true)
	if debug_view:
		_toggle_cell(cell_i, cell_j)

func _on_cell_body_exited(body: Node2D, cell_i: int, cell_j: int):
	_update_obs(cell_i, cell_j, body.collision_layer, false)
	if debug_view:
		_toggle_cell(cell_i, cell_j)
