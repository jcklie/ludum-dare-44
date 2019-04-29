extends Button

func _ready():
	connect("pressed", self, "start_game")
	
func start_game():
	OS.set_window_maximized(true)
	GameManager.start_random_level()
	seed(OS.get_time().second)

