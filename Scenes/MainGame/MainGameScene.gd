tool
extends Node

export(PackedScene) var level_scene : PackedScene setget set_level_scene

var success_screen_packed = preload("res://Scenes/SuccessScreen/SuccessScreen.tscn")
var failure_screen_packed = preload("res://Scenes/FailureScreen/FailureScreen.tscn")
var nutrient_change_map : Dictionary = {}

func _ready():
	self.level_scene = level_scene

func _clear_gain_loss():
	get_node("%GainList").text = ""
	get_node("%LossList").text = ""

func _update_gain_loss():
	_clear_gain_loss()
	for reason in nutrient_change_map:
		var delta = nutrient_change_map[reason]
		var delta_list : Label
		if delta > 0:
			delta_list = get_node_or_null("%GainList")
		elif delta < 0:
			delta_list = get_node_or_null("%LossList")
		if delta_list == null:
			continue
		delta_list.text += "%s : %+d\n" % [reason, delta] 

func _level_nutrients_changed(delta : int = 0, reason : String = ""):
	if not reason in nutrient_change_map:
		nutrient_change_map[reason] = 0
	nutrient_change_map[reason] += delta

func _level_turn_started():
	nutrient_change_map.clear()

func _level_state_changed(current_nutrients : int, turns_left : int, goal_turns_left : int):
	var nutrient_label = get_node_or_null("%NutrientCounterLabel")
	if nutrient_label == null:
		return
	nutrient_label.text = "Flower: %d" % current_nutrients
	_update_gain_loss()
	get_node("%TurnCounterLabel").text = "Turns Left: %d" % turns_left
	get_node("%TurnGoalLabel").text = "%d turns" % goal_turns_left

func _level_success():
	InGameMenuController.open_menu(success_screen_packed)

func _level_failure(reason : int):
	InGameMenuController.open_menu(failure_screen_packed)
	if InGameMenuController.current_menu.has_method("set_failure_reason"):
		InGameMenuController.current_menu.set_failure_reason(reason)

func set_level_scene(value : PackedScene) -> void:
	level_scene = value
	var level_viewport_node = get_node_or_null("HBoxContainer/LevelViewportContainer/Viewport")
	if level_viewport_node == null:
		return
	for child in level_viewport_node.get_children():
		child.queue_free()
	if level_scene == null:
		return
	var level_instance = level_scene.instance()
	level_instance.connect("nutrients_changed", self, "_level_nutrients_changed")
	level_instance.connect("turn_started", self, "_level_turn_started")
	level_instance.connect("state_changed", self, "_level_state_changed")
	level_instance.connect("success", self, "_level_success")
	level_instance.connect("failure", self, "_level_failure")
	level_viewport_node.add_child(level_instance)