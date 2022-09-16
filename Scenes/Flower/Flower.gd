tool
extends Node2D


enum STAGE{FIRST, SECOND, THIRD}

export(STAGE) var current_stage : int = STAGE.FIRST setget set_current_stage
export(bool) var danger_zone : bool = false setget set_danger_zone

var small_flower = preload("res://Assets/Original/Textures/flower-small.png")

var stage_textures : Array = [
	preload("res://Assets/Original/Textures/flower-small.png"),
	preload("res://Assets/Original/Textures/flower-mid.png"),
	preload("res://Assets/Original/Textures/flower-large.png"),
]

func set_current_stage(value : int) -> void:
	current_stage = value
	if current_stage >= 0 and current_stage < stage_textures.size():
		$Sprite.texture = stage_textures[current_stage]

func set_danger_zone(value : bool) -> void:
	danger_zone = value
	if danger_zone:
		$DangerPlayer.play("Danger")
	elif $DangerPlayer.is_playing():
		$DangerPlayer.seek(0, true)
		$DangerPlayer.stop()
