extends CanvasLayer

var can_close : bool = false

func _close():
	if not can_close:
		return
	InGameMenuController.close_menu()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_select") or event.is_action_pressed("interact"):
		_close()
		get_tree().set_input_as_handled()

func _on_ResumeButton_pressed():
	InGameMenuController.close_menu()

func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	can_close = true
