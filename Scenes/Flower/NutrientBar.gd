tool
extends Control

enum PROGRESS_STATES{
	NORMAL,
	GOAL,
	DANGER_LOW,
	DANGER_MID,
	DANGER_HIGH
	}

export(Array, StyleBox) var style_box_states : Array = []
export(PROGRESS_STATES) var progress_state : int = PROGRESS_STATES.NORMAL setget set_progress_state
export(Color) var hover_modulate : Color = Color.white
export(int) var value : int = 64 setget set_value

func set_progress_state(local_value : int) -> void:
	progress_state = local_value
	progress_state %= style_box_states.size()
	var style_box = style_box_states[progress_state]
	var node = get_node_or_null("ProgressBar")
	if node == null:
		return
	node.set("custom_styles/fg", style_box)

func _on_NutrientBar_mouse_entered():
	self.modulate = Color.white

func _on_NutrientBar_mouse_exited():
	self.modulate = hover_modulate

func set_value(local_value : int):
	value = local_value
	$ProgressBar.value = value
	$Label.text = "%d" % int(value)

func set_max_value(local_max_value : int):
	$ProgressBar.max_value = local_max_value

func show_target_range(range_visible : bool):
	$GoalPanel.visible = range_visible
