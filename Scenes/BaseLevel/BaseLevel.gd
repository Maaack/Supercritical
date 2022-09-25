class_name BaseLevel
extends Node2D

signal nutrients_changed(delta, reason)
signal state_changed(nutrients, turn_counter, turn_limit, goal_turns_left)
signal turn_started
signal success
signal failure(reason)
signal goals_updated(level_turn_limit, supercritical_limit, nutrient_goal_rounds, nutrient_goal_min, nutrient_goal_max, cut_vine)
signal goals_visibility_updated(local_visible)
signal ingame_message_sent(message_text, message_counter)

const VINE_TILE = 3
const DEAD_VINE_TILE = 2
const NUCLEAR_DEPOSIT_TILE = 0
const HARVEST_VINE_TILE = 2
const NO_TILE = -1
const VINE_TAX = 16
const CARDINAL_DIRECTIONS : Array = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT
	]

enum FAILURE_REASON{
	STARVATION,
	NUCLEAR_EXPLOSION,
	TIMEOUT
}

export(Vector2) var level_size : Vector2 = Vector2(18, 18)
export(int) var nutrients_at_flower : int = 6
export(float, 0.05, 2) var turn_time : float = 0.5
export(Array, PackedScene) var opening_tutorials : Array = []
export(Array, Resource) var level_goals : Array = []

onready var flower = $Flower
onready var vines = $Vines
onready var dead_vines = $DeadVines
onready var cell_size = $Vines.cell_size
onready var half_cell_size = $Vines.cell_size / 2

var nuclear_nutrient_scene = preload("res://Scenes/NuclearNutrient/NuclearNutrient.tscn")
var nuclear_update_scene = preload("res://Scenes/Flower/NutrientUpdate.tscn")
var turn_counter : int = 0
var stage_counter : int = 0
var goal_counter : int = 0
var tutorial_counter : int = 0
var current_level_goal : int = 0
var vine_distance_map : Dictionary = {}
var furthest_vine_distance : int = 0
var connected_vines : Array = []
var controls_locked = false
var finished_tutorials = false

func _controlled_autotile_dead_vine(cellv : Vector2) -> void:
	var auto_tile_coord : Vector2 = vines.get_cell_autotile_coord(cellv.x, cellv.y)
	dead_vines.set_cellv(cellv, DEAD_VINE_TILE, false, false, false, auto_tile_coord)
	for direction in CARDINAL_DIRECTIONS:
		var neighboring_cell = cellv + direction
		if _is_cell_vine(neighboring_cell):
			auto_tile_coord = vines.get_cell_autotile_coord(neighboring_cell.x, neighboring_cell.y)
			dead_vines.set_cellv(neighboring_cell, DEAD_VINE_TILE, false, false, false, auto_tile_coord)

func _kill_vine(cellv : Vector2) -> void:
	if not _is_cell_vine(cellv):
		return
	_controlled_autotile_dead_vine(cellv)
	vines.set_cellv(cellv, NO_TILE)
	vines.update()

func _cull_vine(cellv : Vector2) -> void:
	$PlayerControlledCharacter.cut_vine()
	_kill_vine(cellv)

func _clear_dead_vine(cellv : Vector2) -> void:
	$PlayerControlledCharacter.cut_vine()
	dead_vines.set_cellv(cellv, NO_TILE)
	vines.update_bitmask_area(cellv)

func _get_flower_cellv() -> Vector2:
	return ((flower.position - half_cell_size) / cell_size).floor()

func _map_vines_connected_to_flower():
	connected_vines.clear()
	vine_distance_map.clear()
	furthest_vine_distance = 0
	var target_cell : Vector2 = _get_flower_cellv() * cell_size
	var start_cell : Vector2
	for cellv in vines.get_used_cells():
		start_cell = cellv * cell_size
		var distance = vines.get_astar_path_avoiding_obstacles(start_cell, target_cell).size()
		if distance > 0:
			connected_vines.append(cellv)
		if distance > furthest_vine_distance:
			furthest_vine_distance = distance
		if not distance in vine_distance_map:
			vine_distance_map[distance] = []
		vine_distance_map[distance].append(cellv)

func _move_nutrient_along_vine_to_flower(nutrient : Node2D, delay : float):
	var start_cell = (nutrient.position - half_cell_size).floor()
	var target_cell = _get_flower_cellv() * cell_size
	var path_points = vines.get_astar_path_avoiding_obstacles(start_cell, target_cell)
	if path_points.size() < 2:
		return
	var path_point = path_points[1] + half_cell_size
	var tween = get_tree().create_tween()
	tween.tween_property(nutrient, "position", path_point, delay)

func _get_furthest_connected_vines(offset : int = 0) -> Array:
	if (furthest_vine_distance - offset) in vine_distance_map:
		return vine_distance_map[furthest_vine_distance - offset]
	else:
		return []

func _get_distant_vines(desired : int):
	var distant_vines : Array = []
	var offset = 0
	while(distant_vines.size() < desired):
		var vines = _get_furthest_connected_vines(offset)
		if vines.empty():
			break
		distant_vines.append_array(vines)
		offset += 1
	return distant_vines.slice(0, desired-1)

func _vines_move_nutrients(delay : float):
	for nutrient in $Nutrients.get_children():
		_move_nutrient_along_vine_to_flower(nutrient, delay)

func _show_nutrient_change(amount : int, location : Vector2) -> void:
	var change_instance = nuclear_update_scene.instance()
	change_instance.position = location
	change_instance.amount = amount
	add_child(change_instance)

func _add_nutrients_to_flower(delta : int = 1, reason : String = "") -> void:
	nutrients_at_flower += delta
	emit_signal("nutrients_changed", delta, reason)

func _consume_nutrients_for_flower() -> void:
	var flower_consumption = pow(2, flower.current_stage)
	_show_nutrient_change(-flower_consumption, flower.position)
	_add_nutrients_to_flower(-flower_consumption, "Flower")

func _consume_nutrients_for_vines() -> void:
	var vine_cost : int = floor(connected_vines.size() / VINE_TAX)
	var final_vine_cost : int = vine_cost
	if vine_cost >= nutrients_at_flower:
		final_vine_cost = max(nutrients_at_flower - 1, 0)
		var vine_debt = (vine_cost - final_vine_cost) * VINE_TAX
		vine_debt -= VINE_TAX - 1
		vine_debt = max(vine_debt, 0)
		var vines_to_kill = _get_distant_vines(vine_debt)
		for vine_to_kill in vines_to_kill:
			_kill_vine(vine_to_kill)
	_add_nutrients_to_flower(-final_vine_cost, "Vines")
	var vines_that_cost = _get_distant_vines(final_vine_cost+2)
	vines_that_cost.shuffle()
	for _i in range(final_vine_cost):
		var cellv = vines_that_cost.pop_back()
		var vine_position = (cellv * cell_size) + half_cell_size
		_show_nutrient_change(-1, vine_position)

func _consume_nutrients_for_growth(cellv : Vector2) -> void:
	_add_nutrients_to_flower(-1, "Growth")
	var grow_position = vines.map_to_world(cellv) + half_cell_size
	_show_nutrient_change(-1, grow_position)
	
func _consume_base_nutrients() -> void:
	_consume_nutrients_for_flower()
	_consume_nutrients_for_vines()

func _absorb_nutrients_at_flower():
	for nutrient in $Nutrients.get_children():
		if nutrient.position.floor() == flower.position.floor():
			_show_nutrient_change(1, vines.map_to_world(nutrient.starting_cell) + half_cell_size)
			_add_nutrients_to_flower(1, "Harvest")
			nutrient.queue_free()

func _get_extra_food() -> int:
	var current_goal : LevelGoals = _get_current_level_goals()
	return nutrients_at_flower / current_goal.growth_nutrient_divider

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

func _is_cell_walkable(cellv : Vector2) -> bool:
	return _is_in_bounds(cellv) and $Obstacles.get_cellv(cellv) == -1

func _is_cell_growable(cellv : Vector2) -> bool:
	return vines.get_cellv(cellv) == -1 and dead_vines.get_cellv(cellv) == -1 and $Obstacles.get_cellv(cellv) == -1

func _is_cell_vine(cellv: Vector2) -> bool:
	return vines.get_cellv(cellv) == VINE_TILE

func _is_cell_dead_vine(cellv: Vector2) -> bool:
	return dead_vines.get_cellv(cellv) == DEAD_VINE_TILE

func _is_cell_harvestable(cellv: Vector2) -> bool:
	return $Deposits.get_cellv(cellv) == NUCLEAR_DEPOSIT_TILE

func _vines_make_nutrients():
	for cellv in $Deposits.get_used_cells():
		if _is_cell_vine(cellv):
			var nutrient_instance = nuclear_nutrient_scene.instance()
			nutrient_instance.starting_cell = cellv
			nutrient_instance.position = vines.map_to_world(cellv) + half_cell_size
			$Nutrients.add_child(nutrient_instance)

func _highlight_tile_at_position(local_position : Vector2):
	var cell_position = (local_position / cell_size).floor()
	if not _is_cell_vine(cell_position) and not _is_cell_dead_vine(cell_position):
		$TileHighlighter.hide()
		return
	$TileHighlighter.cell_vector = cell_position
	$TileHighlighter.show()
	$TileHighlighter.position = local_position

func _get_growable_cells():
	var neighboring_cells : Dictionary = {}
	var growable_cells : Dictionary = {}
	var filter_crowd : int = 1
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
	while growable_cells.empty() and filter_crowd < 5:
		growable_cells = _filter_values_greater_than(neighboring_cells, filter_crowd)
		filter_crowd += 1
	return growable_cells.keys()

func _grow_vine(cellv : Vector2, iter : int = 0):
	if _is_cell_vine(cellv):
		return
	vines.set_cellv(cellv, VINE_TILE)
	vines.update_bitmask_area(cellv)
	vines.update()
	vines.grow_vine(cellv * cell_size, iter)

func _vines_grow(growth_max : int = 0) -> int:
	var extra_food = _get_extra_food()
	if growth_max == 0:
		growth_max = extra_food
	else:
		growth_max = min(extra_food, growth_max)
	var grew : int = 0
	for i in range(growth_max):
		var optional_cells : Array = _get_growable_cells()
		optional_cells = _filter_out_of_bounds(optional_cells)
		if optional_cells.size() == 0:
			break
		optional_cells.shuffle()
		var cellv = optional_cells.pop_back()
		_grow_vine(cellv, i)
		_consume_nutrients_for_growth(cellv)
		grew += 1
	return grew

func _vines_die():
	var cullable_vines : Array = []
	if not 0 in vine_distance_map:
		return
	for cell_position in vine_distance_map[0]:
		var has_dead_neighbor = false
		for direction in CARDINAL_DIRECTIONS:
			var neighboring_cell = cell_position + direction
			if _is_cell_dead_vine(neighboring_cell):
				has_dead_neighbor = true
				break
		if has_dead_neighbor:
			cullable_vines.append(cell_position)
	for cell_position in cullable_vines:
		_kill_vine(cell_position)

func _crosshair_on_target(current_goal : LevelGoals):
	if current_goal.is_vine_cut_goal():
		$Crosshair.position = (current_goal.trim_vine * cell_size) + half_cell_size
		$Crosshair.show()
	else:
		$Crosshair.hide()

func _update_nutrient_bar(current_goal : LevelGoals):
	var node = get_node_or_null("NutrientNode/NutrientBar")
	if node == null:
		return
	node.set_max_value(current_goal.supercritical_limit)
	node.set_range_visible(current_goal.is_nutrient_goal())

func update_goals():
	var current_goal : LevelGoals = _get_current_level_goals()
	stage_counter = 0
	_update_nutrient_bar(current_goal)
	_crosshair_on_target(current_goal)
	emit_signal("goals_updated", current_goal.turn_limit, current_goal.supercritical_limit, current_goal.nutrient_goal_rounds, current_goal.nutrient_goal_min, current_goal.nutrient_goal_max, current_goal.trim_vine)

func _get_nutrients_danger(nutrients : int, supercritical_limit : int) -> int:
	if supercritical_limit <= 0:
		return 0
	elif nutrients >= round(supercritical_limit * 0.875):
		return 3
	elif nutrients >= round(supercritical_limit * 0.75):
		return 2
	elif nutrients >= round(supercritical_limit * 0.5):
		return 1
	return 0

func _set_nutrient_bar_danger_level(danger_level : int) -> void:
	match danger_level:
		flower.DANGER_LEVEL.NONE:
			$NutrientNode/NutrientBar.progress_state = $NutrientNode/NutrientBar.PROGRESS_STATES.NORMAL
		flower.DANGER_LEVEL.LOW:
			$NutrientNode/NutrientBar.progress_state = $NutrientNode/NutrientBar.PROGRESS_STATES.DANGER_LOW
		flower.DANGER_LEVEL.MID:
			$NutrientNode/NutrientBar.progress_state = $NutrientNode/NutrientBar.PROGRESS_STATES.DANGER_MID
		flower.DANGER_LEVEL.HIGH:
			$NutrientNode/NutrientBar.progress_state = $NutrientNode/NutrientBar.PROGRESS_STATES.DANGER_HIGH

func _update_nutrient_levels(current_goal : LevelGoals) -> void:
	var danger_level = _get_nutrients_danger(nutrients_at_flower, current_goal.supercritical_limit)
	$NutrientNode/NutrientBar.set_value(nutrients_at_flower)
	if current_goal.nutrient_goal_rounds > 0 and nutrients_at_flower >= current_goal.nutrient_goal_min and nutrients_at_flower <= current_goal.nutrient_goal_max:
		$NutrientNode/NutrientBar.progress_state = $NutrientNode/NutrientBar.PROGRESS_STATES.GOAL
	else:
		_set_nutrient_bar_danger_level(danger_level)
	flower.danger_level = danger_level

func update_state():
	var current_goal : LevelGoals = _get_current_level_goals()
	_update_nutrient_levels(current_goal)
	emit_signal("state_changed", nutrients_at_flower, stage_counter, current_goal.turn_limit, current_goal.nutrient_goal_rounds - goal_counter)

func _complete_level():
	emit_signal("success")

func _update_nutrient_bar_position():
	$NutrientNode/NutrientBar.rect_position.y = -20 + (flower.current_stage * -5)

func _complete_goal(goal : LevelGoals):
	if goal.advance_flower:
		flower.current_stage += 1
		_update_nutrient_bar_position()
	current_level_goal += 1
	if current_level_goal >= level_goals.size():
		_complete_level()
		return
	update_goals()

func _supercritical_limit_reached():
	controls_locked = true
	$Vines.critical_failure()
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("failure", FAILURE_REASON.NUCLEAR_EXPLOSION)

func _turn_limit_reached(goal : LevelGoals):
	if goal.turn_limit_success:
		_complete_goal(goal)
	else: 
		emit_signal("failure", FAILURE_REASON.TIMEOUT)

func _get_current_level_goals() -> LevelGoals:
	if current_level_goal < 0 or current_level_goal >= level_goals.size():
		current_level_goal = 0
	return level_goals[current_level_goal]

func _evauluate_goal():
	if nutrients_at_flower <= 0:
		emit_signal("failure", FAILURE_REASON.STARVATION)
		return
	var current_goal : LevelGoals = _get_current_level_goals()
	if current_goal.check_nutrient_goal(nutrients_at_flower):
		goal_counter += 1
		$Vines.success()
	else:
		goal_counter = 0
	if current_goal.check_nutrients_supercritical(nutrients_at_flower):
		_supercritical_limit_reached()
	elif current_goal.check_nutrient_goal_complete(goal_counter):
		_complete_goal(current_goal)
	elif current_goal.is_vine_cut_goal():
		if not _is_cell_vine(current_goal.trim_vine):
			_complete_goal(current_goal)
	if current_goal.check_turn_limit(stage_counter):
		_turn_limit_reached(current_goal)

func _update_harvest_vines():
	$HarvestVines.clear()
	for cellv in vines.get_used_cells():
		if _is_cell_harvestable(cellv):
			$HarvestVines.set_cellv(cellv, HARVEST_VINE_TILE, false, false, false, vines.get_cell_autotile_coord(cellv.x, cellv.y))

func _level_takes_turn(delay : float):
	set_process_unhandled_input(false)
	emit_signal("turn_started")
	turn_counter += 1
	stage_counter += 1
	if turn_counter % 2 == 0:
		_vines_make_nutrients()
	_map_vines_connected_to_flower()
	_vines_die()
	_consume_base_nutrients()
	_vines_grow()
	_update_harvest_vines()
	_vines_move_nutrients(delay - 0.05)
	yield(get_tree().create_timer(delay), "timeout")
	_absorb_nutrients_at_flower()
	update_state()
	_evauluate_goal()
	set_process_unhandled_input(true)

func _hide_ui_for_pc_on_finished_tween():
	if (($PlayerControlledCharacter.position - ($NutrientNode.position + Vector2(0, $NutrientNode/NutrientBar.rect_position.y))) * Vector2(0.5, 1)).length_squared() < pow(cell_size.x, 2):
		$NutrientNode.modulate.a = 0.25
	else:
		$NutrientNode.modulate.a = 1.0

func _post_player_tween_updates(tween : SceneTreeTween):
	yield(tween, "finished")
	_hide_ui_for_pc_on_finished_tween()
	_highlight_tile_at_position($PlayerControlledCharacter.position)

func _can_move_player(direction) -> bool:
	var target_position = $PlayerControlledCharacter.position + (direction * cell_size)
	if not _is_cell_walkable(target_position / cell_size):
		return false
	return true

func _move_player(direction) -> bool:
	if not _can_move_player(direction):
		return false
	var target_position = $PlayerControlledCharacter.position + (direction * cell_size)
	var tween = get_tree().create_tween()
	tween.tween_property($PlayerControlledCharacter, "position", target_position, turn_time)
	tween.play()
	_level_takes_turn(turn_time)
	_post_player_tween_updates(tween)
	return true

func _position_camera() -> void:
	pass

func _finish_tutorials():
	finished_tutorials = true
	set_process(false)

func _play_opening_tutorials():
	if finished_tutorials:
		return
	if tutorial_counter >= opening_tutorials.size():
		_finish_tutorials()
		return
	var tutorial = opening_tutorials[tutorial_counter]
	tutorial_counter += 1
	InGameMenuController.open_menu(tutorial)

func _ready():
	set_process(false)
	_grow_vine(_get_flower_cellv(), 0)
	_vines_make_nutrients()
	update_goals()
	update_state()
	$NutrientNode.position = flower.position
	$NutrientNode.show()
	_update_nutrient_bar_position()
	yield(get_tree().create_timer(0.1), "timeout")
	set_process(true)

func _process(_delta):
	_play_opening_tutorials()

func _unhandled_input(event):
	if controls_locked:
		return
	var direction : Vector2 = Vector2.ZERO
	if event is InputEventKey:
		if event.is_action_pressed("move_up"):
			direction = Vector2.UP
		elif event.is_action_pressed("move_down"):
			direction = Vector2.DOWN
		elif event.is_action_pressed("move_left"):
			direction = Vector2.LEFT
		elif event.is_action_pressed("move_right"):
			direction = Vector2.RIGHT
	if direction != Vector2.ZERO:
		var can_move = _can_move_player(direction)
		if can_move and Input.is_action_pressed("run"):
			var can_move_2 = _can_move_player(direction * 2)
			if can_move_2:
				direction *= 2
		var moved = _move_player(direction)
		if moved:
			$PlayerControlledCharacter.walk()
	if event.is_action_pressed("skip_turn"):
		_level_takes_turn(turn_time * 0.75)
	if event.is_action_pressed("interact") and $TileHighlighter.visible:
		if _is_cell_vine($TileHighlighter.cell_vector):
			_level_takes_turn(turn_time)
			_cull_vine($TileHighlighter.cell_vector)
		elif _is_cell_dead_vine($TileHighlighter.cell_vector):
			_level_takes_turn(turn_time)
			_clear_dead_vine($TileHighlighter.cell_vector)
