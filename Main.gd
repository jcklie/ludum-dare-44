extends Node2D

func _ready():
	OS.set_window_maximized(true)
	GameManager.start_random_level()
	seed(OS.get_time().second)