tool
extends Node

export(PackedScene) var level_scene : PackedScene setget set_level_scene

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

func _update_nutrient_counter(value : int = 1, delta : int = 0, reason : String = ""):
	var nutrient_label = get_node_or_null("%NutrientCounterLabel")
	if nutrient_label == null:
		return
	nutrient_label.text = "Flower: %d" % value
	if not reason in nutrient_change_map:
		nutrient_change_map[reason] = 0
	nutrient_change_map[reason] += delta
	_update_gain_loss()

func _turn_started():
	nutrient_change_map.clear()
	_clear_gain_loss()

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
	level_instance.connect("nutrients_updated", self, "_update_nutrient_counter")
	level_instance.connect("turn_started", self, "_turn_started")
	level_viewport_node.add_child(level_instance)
