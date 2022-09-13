tool
extends Node

export(PackedScene) var level_scene : PackedScene setget set_level_scene

func _ready():
	self.level_scene = level_scene

func _update_nutrient_counter(value : int = 1):
	var nutrient_label = get_node_or_null("HBoxContainer/Panel/Control/NutrientCounterLabel")
	if nutrient_label == null:
		return
	nutrient_label.text = "Flower: %d" % value

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
	level_viewport_node.add_child(level_instance)
