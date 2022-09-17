extends CanvasLayer

const TIMEOUT_TEXT : String = "Ran out of time!"
const NUCLEAR_EXPLOSION_TEXT : String = "Nutrients went\nsupercritical\nand exploded!"
const STARVATION_TEXT : String = "Flower starved..."
const FAILURE_TEXT : String = "You failed..."

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $Control/ConfirmExit.visible:
			$Control/ConfirmExit.hide()
		elif $Control/ConfirmMainMenu.visible:
			$Control/ConfirmMainMenu.hide()

func set_failure_reason(rest_stops : int = 0) -> void:
	match(rest_stops):
		0:
			get_node("%Title").text = STARVATION_TEXT
		1:
			get_node("%Title").text = NUCLEAR_EXPLOSION_TEXT
		2:
			get_node("%Title").text = TIMEOUT_TEXT
		_:
			get_node("%Title").text = FAILURE_TEXT

func _on_ConfirmMainMenu_confirmed():
	InGameMenuController.close_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_ConfirmExit_confirmed():
	get_tree().quit()

func _on_RestartButton_pressed():
	SceneLoader.reload_current_scene()

func _on_MainMenuButton_pressed():
	$Control/ConfirmMainMenu.popup_centered()

func _on_ExitButton_pressed():
	$Control/ConfirmExit.popup_centered()

func _ready():
	if OS.has_feature("web"):
		get_node("%ExitButton").hide()
