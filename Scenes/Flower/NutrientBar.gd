extends ProgressBar

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

func set_progress_state(local_value : int) -> void:
	progress_state = local_value
	progress_state %= style_box_states.size()
	var style_box = style_box_states[progress_state]
	set("custom_styles/fg", style_box)

func _on_NutrientBar_mouse_entered():
	self.modulate = Color.white

func _on_NutrientBar_mouse_exited():
	self.modulate = hover_modulate

func set_value(local_value : float):
	.set_value(local_value)
	$Label.text = "%d" % int(local_value)
