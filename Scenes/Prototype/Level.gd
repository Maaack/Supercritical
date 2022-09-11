extends Node2D

onready var astarDebug = $AStarDebug
onready var flower = $Vines/Flower
onready var vines = $Vines

var nuclear_nutrient_scene = preload("res://Scenes/NuclearNutrient/NuclearNutrient.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		astarDebug.visible = !astarDebug.visible

func _vines_make_nutrients():
	for cell_position in $Deposits.get_used_cells():
		if $Vines.get_cellv(cell_position) > -1:
			var nutrient_instance = nuclear_nutrient_scene.instance()
			nutrient_instance.position = $Vines.map_to_world(cell_position) + ($Vines.cell_size / 2)
			$Nutrients.add_child(nutrient_instance)

func _move_nutrient_along_vine_to_flower(nutrient : Node2D, delay : float):
	var start_cell = (nutrient.global_position - (vines.cell_size / 2)).floor()
	var target_cell = ((flower.position - (vines.cell_size / 2)) / vines.cell_size).floor() * vines.cell_size
	var path_points = vines.get_astar_path_avoiding_obstacles(start_cell, target_cell)
	if path_points.size() < 2:
		return
	var path_point = path_points[1] + (vines.cell_size / 2)
	var tween = get_tree().create_tween()
	tween.tween_property(nutrient, "position", path_point, delay)

func _vines_move_nutrients(delay : float):
	for nutrient in $Nutrients.get_children():
		_move_nutrient_along_vine_to_flower(nutrient, delay)

func _filter_values_greater_than(dict : Dictionary, max_value : int) -> Dictionary:
	var return_dict : Dictionary = {}
	for key in dict:
		if dict[key] <= max_value:
			return_dict[key] = dict[key]
	return return_dict

func _filter_negative_vectors(vectors : Array) -> Array:
	var return_vectors : Array = []
	for vector in vectors:
		if vector is Vector2 and vector.x >= 0 and vector.y >= 0:
			return_vectors.append(vector)
	return return_vectors

func _cell_is_growable(cellv : Vector2) -> bool:
	return $Vines.get_cellv(cellv) == -1 and $Obstacles.get_cellv(cellv) == -1

func _cell_is_vine(cellv: Vector2) -> bool:
	return $Vines.get_cellv(cellv) > -1

func _highlight_tile_at_position(position : Vector2):
	var cell_position =  (position / vines.cell_size).floor()
	if not _cell_is_vine(cell_position):
		$TileHighlighter.hide()
		return
	var tile_position = cell_position * vines.cell_size
	tile_position += vines.cell_size / 2
	$TileHighlighter.show()
	$TileHighlighter.position = tile_position

func _get_growable_cells():
	var neighboring_directions : Array = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]
	var neighboring_cells : Dictionary = {}
	for cell_position in $Vines.get_used_cells():
		for direction in neighboring_directions:
			var neighboring_cell = cell_position + direction
			if not _cell_is_growable(neighboring_cell):
				continue
			if not neighboring_cell in neighboring_cells:
				neighboring_cells[neighboring_cell] = 0
			neighboring_cells[neighboring_cell] += 1
	neighboring_cells = _filter_values_greater_than(neighboring_cells, 1)
	return neighboring_cells.keys()

func _grow_vine(cellv : Vector2):
	$Vines.set_cellv(cellv, 1)
	$Vines.update_bitmask_area(cellv)
	$Vines.update()

func _vines_grow(grow_count : int):
	for i in range(grow_count):
		var optional_cells : Array = _get_growable_cells()
		optional_cells = _filter_negative_vectors(optional_cells)
		if optional_cells.size() == 0:
			return
		optional_cells.shuffle()
		_grow_vine(optional_cells.pop_front())

func _on_HarvetTimer_timeout():
	_vines_make_nutrients()
	_vines_grow(2)

func _on_TransportTimer_timeout():
	_vines_move_nutrients($TransportTimer.wait_time - 0.01)

func _on_PlayerControlledCharacter_unit_moved():
	_highlight_tile_at_position($PlayerControlledCharacter.position)
