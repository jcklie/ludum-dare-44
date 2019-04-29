extends Container

func _ready():
	$StartButton.connect("pressed", self, "_start_game")
	$ExitButton.connect("pressed", self, "_exit_game")
	
func _start_game():
	OS.set_window_maximized(true)
	GameManager.number_of_players = $PlayersSpinner.value
	GameManager.start_random_level()
	seed(OS.get_time().second)
	
func _exit_game():
	get_tree().quit()

