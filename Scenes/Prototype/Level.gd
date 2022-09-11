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

func _move_nutrient_along_vine_to_flower(nutrient : Node2D):
	var start_cell = (nutrient.global_position - (vines.cell_size / 2)).floor()
	var target_cell = ((flower.position - (vines.cell_size / 2)) / vines.cell_size).floor() * vines.cell_size
	var path_points = vines.get_astar_path_avoiding_obstacles(start_cell, target_cell)
	if path_points.size() < 2:
		return
	var path_point = path_points[1] + (vines.cell_size / 2)
	var tween = get_tree().create_tween()
	tween.tween_property(nutrient, "position", path_point, 5.0)

func _vines_move_nutrients():
	for nutrient in $Nutrients.get_children():
		_move_nutrient_along_vine_to_flower(nutrient)

func _plants_take_turn():
	_vines_make_nutrients()
	_vines_move_nutrients()


func _on_Timer_timeout():
	_plants_take_turn()
