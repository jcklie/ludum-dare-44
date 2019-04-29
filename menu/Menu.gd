extends Container

func _ready():
	OS.set_window_maximized(true)
	$StartButton.connect("pressed", self, "_start_game")
	$ControlsButton.connect("pressed", self, "_view_controls")
	$ExitButton.connect("pressed", self, "_exit_game")
	
func _start_game():
	OS.set_window_maximized(true)
	GameManager.number_of_players = $PlayersSpinner.value
	GameManager.start_random_level()
	seed(OS.get_time().second)

func _view_controls():
	get_tree().change_scene("res://menu/Controls.tscn")

func _exit_game():
	get_tree().quit()

