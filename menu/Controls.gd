extends TextureRect

func _process(delta):
	if Input.is_action_pressed("key_esc"):
		GameManager.show_menu()