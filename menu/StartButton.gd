extends Button

func _ready():
	connect("pressed", self, "start_game")
	
func start_game():
	get_tree().change_scene("res://Main.tscn")

