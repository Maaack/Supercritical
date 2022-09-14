extends Node2D

signal nutrients_updated(value)

const VINE_TILE = 3
const DEAD_VINE_TILE = 2
const NO_TILE = -1
const CARDINAL_DIRECTIONS : Array = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]

export(Vector2) var level_size : Vector2 = Vector2(16, 16)
export(int) var nutrients_at_flower : int = 0
export(float, 0.05, 2) var turn_time : float = 0.5

onready var flower = $Vines/Flower
onready var vines = $Vines
onready var dead_vines = $DeadVines
onready var cell_size = $Vines.cell_size
onready var half_cell_size = $Vines.cell_size / 2

var nuclear_nutrient_scene = preload("res://Scenes/NuclearNutrient/NuclearNutrient.tscn")
var turn_counter : int = 0

func _controlled_autotile_dead_vine(cellv : Vector2) -> void:
	var auto_tile_coord : Vector2 = vines.get_cell_autotile_coord(cellv.x, cellv.y)
	dead_vines.set_cellv(cellv, DEAD_VINE_TILE, false, false, false, auto_tile_coord)
	for direction in CARDINAL_DIRECTIONS:
		var neighboring_cell = cellv + direction
		if _is_cell_vine(neighboring_cell):
			auto_tile_coord = vines.get_cell_autotile_coord(neighboring_cell.x, neighboring_cell.y)
			dead_vines.set_cellv(neighboring_cell, DEAD_VINE_TILE, false, false, false, auto_tile_coord)

func _cull_vine(cellv : Vector2) -> void:
	_controlled_autotile_dead_vine(cellv)
	vines.set_cellv(cellv, NO_TILE)
	vines.update()

func _input(event):
	if event.is_action_pressed("interact") and $TileHighlighter.visible:
		_cull_vine($TileHighlighter.cell_vector)

func _move_nutrient_along_vine_to_flower(nutrient : Node2D, delay : float):
	var start_cell = (nutrient.global_position - half_cell_size).floor()
	var target_cell = ((flower.position - half_cell_size) / cell_size).floor() * cell_size
	var path_points = vines.get_astar_path_avoiding_obstacles(start_cell, target_cell)
	if path_points.size() < 2:
		return
	var path_point = path_points[1] + half_cell_size
	var tween = get_tree().create_tween()
	tween.tween_property(nutrient, "position", path_point, delay)

func _vines_move_nutrients(delay : float):
	for nutrient in $Nutrients.get_children():
		_move_nutrient_along_vine_to_flower(nutrient, delay)

func _add_nutrients_to_flower(count : int = 1) -> void:
	nutrients_at_flower += count
	emit_signal("nutrients_updated", nutrients_at_flower)

func _absorb_nutrients_at_flower():
	for nutrient in $Nutrients.get_children():
		if nutrient.position.floor() == flower.position.floor():
			_add_nutrients_to_flower(1)
			nutrient.queue_free()

func _get_extra_food() -> int:
	return nutrients_at_flower / 4

func _eat_nutrients_at_flower(extra : int) -> void:
	nutrients_at_flower -= 1 + extra

func _is_in_bounds(cellv : Vector2) -> bool:
	return cellv.x >= 0 and cellv.y >= 0 and cellv.x < level_size.x and cellv.y < level_size.y

func _filter_values_greater_than(dict : Dictionary, max_value : int) -> Dictionary:
	var return_dict : Dictionary = {}
	for key in dict:
		if dict[key] <= max_value:
			return_dict[key] = dict[key]
	return return_dict

func _filter_out_of_bounds(vectors : Array) -> Array:
	var return_vectors : Array = []
	for vector in vectors:
		if vector is Vector2 and _is_in_bounds(vector):
			return_vectors.append(vector)
	return return_vectors

func _is_vine_connected_to_flower(cellv : Vector2):
	var target_cell = ((flower.position - half_cell_size) / cell_size).floor() * cell_size
	var start_cell = cellv * cell_size
	var path_points = vines.get_astar_path_avoiding_obstacles(start_cell, target_cell)
	return path_points.size() > 0

func _is_cell_growable(cellv : Vector2) -> bool:
	return dead_vines.get_cellv(cellv) == -1 and $Obstacles.get_cellv(cellv) == -1

func _is_cell_vine(cellv: Vector2) -> bool:
	return vines.get_cellv(cellv) == VINE_TILE

func _vines_make_nutrients():
	for cell_position in $Deposits.get_used_cells():
		if _is_cell_vine(cell_position):
			var nutrient_instance = nuclear_nutrient_scene.instance()
			nutrient_instance.position = vines.map_to_world(cell_position) + half_cell_size
			$Nutrients.add_child(nutrient_instance)

func _highlight_tile_at_position(position : Vector2):
	var cell_position = (position / cell_size).floor()
	if not _is_cell_vine(cell_position):
		$TileHighlighter.hide()
		return
	$TileHighlighter.cell_vector = cell_position
	var tile_position = cell_position * cell_size
	tile_position += half_cell_size
	$TileHighlighter.show()
	$TileHighlighter.position = tile_position

func _get_growable_cells():
	var neighboring_cells : Dictionary = {}
	for cell_position in vines.get_used_cells():
		if not _is_vine_connected_to_flower(cell_position):
			continue
		for direction in CARDINAL_DIRECTIONS:
			var neighboring_cell = cell_position + direction
			if not _is_cell_growable(neighboring_cell):
				continue
			if not neighboring_cell in neighboring_cells:
				neighboring_cells[neighboring_cell] = 0
			neighboring_cells[neighboring_cell] += 1
	neighboring_cells = _filter_values_greater_than(neighboring_cells, 1)
	return neighboring_cells.keys()

func _grow_vine(cellv : Vector2):
	vines.set_cellv(cellv, VINE_TILE)
	vines.update_bitmask_area(cellv)
	_controlled_autotile_dead_vine(cellv)
	vines.update()

func _vines_grow(grow_count : int) -> int:
	var grew : int = 0
	for _i in range(grow_count):
		var optional_cells : Array = _get_growable_cells()
		optional_cells = _filter_out_of_bounds(optional_cells)
		if optional_cells.size() == 0:
			break
		optional_cells.shuffle()
		_grow_vine(optional_cells.pop_front())
		grew += 1
	return grew

func _is_cell_dead(cellv : Vector2) -> bool:
	return not _is_cell_vine(cellv) and dead_vines.get_cellv(cellv) == DEAD_VINE_TILE

func _vines_die():
	var cullable_vines : Array = []
	for cell_position in vines.get_used_cells():
		var has_dead_neighbor = false
		for direction in CARDINAL_DIRECTIONS:
			var neighboring_cell = cell_position + direction
			if _is_cell_dead(neighboring_cell):
				has_dead_neighbor = true
				break
		if has_dead_neighbor and not _is_vine_connected_to_flower(cell_position):
			cullable_vines.append(cell_position)
	for cell_position in cullable_vines:
		_cull_vine(cell_position)

func _level_takes_turn(delay : float):
	turn_counter += 1
	if turn_counter % 2 == 0:
		_vines_make_nutrients()
	_vines_die()
	_absorb_nutrients_at_flower()
	var vines_grew = _vines_grow(_get_extra_food())
	_eat_nutrients_at_flower(vines_grew)
	_vines_move_nutrients(delay - 0.05)

func _on_PlayerControlledCharacter_unit_moved(direction):
	var target_position = $PlayerControlledCharacter.position + (direction * cell_size)
	if not _is_in_bounds(target_position / cell_size):
		return
	$PlayerControlledCharacter.set_process_input(false)
	var tween = get_tree().create_tween()
	tween.tween_property($PlayerControlledCharacter, "position", target_position, turn_time)
	tween.play()
	_level_takes_turn(turn_time)
	yield(tween, "finished")
	_highlight_tile_at_position(target_position)
	$PlayerControlledCharacter.set_process_input(true)

func _ready():
	emit_signal("nutrients_updated", nutrients_at_flower)
