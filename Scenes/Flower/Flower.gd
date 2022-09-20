tool
extends Node2D


enum STAGE{FIRST, SECOND, THIRD}
enum DANGER_LEVEL{NONE, LOW, MID, HIGH}

export(STAGE) var current_stage : int = STAGE.FIRST setget set_current_stage
export(DANGER_LEVEL) var danger_level : int = DANGER_LEVEL.NONE setget set_danger_level

var stage_textures : Array = [
	preload("res://Assets/Original/Textures/flower-small.png"),
	preload("res://Assets/Original/Textures/flower-mid.png"),
	preload("res://Assets/Original/Textures/flower-large.png"),
]

func set_current_stage(value : int) -> void:
	current_stage = value
	var node = get_node_or_null("Sprite")
	if node != null and current_stage >= 0 and current_stage < stage_textures.size():
		node.texture = stage_textures[current_stage]

func set_danger_level(value : int) -> void:
	danger_level = value
	$GeigerCounter1.stop()
	$GeigerCounter2.stop()
	$GeigerCounter3.stop()
	match danger_level:
		DANGER_LEVEL.NONE:
			if $DangerPlayer.is_playing():
				$DangerPlayer.seek(0, true)
				$DangerPlayer.stop()
		DANGER_LEVEL.LOW:
			if $DangerPlayer.is_playing():
				$DangerPlayer.seek(0, true)
				$DangerPlayer.stop()
			$GeigerCounter1.play()
		DANGER_LEVEL.MID:
			$DangerPlayer.play("Danger")
			$GeigerCounter2.play()
		DANGER_LEVEL.HIGH:
			$DangerPlayer.play("Danger")
			$GeigerCounter3.play()

func _ready():
	self.current_stage = current_stage
