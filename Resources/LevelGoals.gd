class_name LevelGoals
extends Resource

export(int) var turn_limit : int = 50
export(bool) var turn_limit_success : bool = true
export(int) var nutrient_goal_rounds : int = 8
export(int) var nutrient_goal_min : int = 8
export(int) var nutrient_goal_max : int = 16
export(int) var supercritical_limit : int = 20
export(int) var growth_nutrient_divider : int = 4
export(bool) var advance_flower : bool = false
export(Vector2) var trim_vine : Vector2 = -Vector2.ONE

func is_nutrient_goal() -> bool:
	return nutrient_goal_rounds > 0

func is_vine_cut_goal() -> bool:
	return trim_vine != -Vector2.ONE

func check_nutrient_goal(nutrients : int) -> bool:
	return nutrient_goal_rounds > 0 and nutrients <= nutrient_goal_max and nutrients >= nutrient_goal_min

func check_nutrient_goal_complete(rounds : int) -> bool:
	return nutrient_goal_rounds > 0 and rounds >= nutrient_goal_rounds

func check_nutrients_supercritical(nutrients : int) -> bool:
	return supercritical_limit > 0 and nutrients >= supercritical_limit

func check_turn_limit(turns : int) -> bool:
	return turns >= turn_limit 

