extends Control

func _ready():
	var winning_text = "Player %s wins" % GameManager.winning_player
	$WinLabel.text = winning_text
	
func _process(delta):
	if Input.action_release("key_continue"):
		GameManager.start_random_level()