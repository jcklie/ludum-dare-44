extends Control

var win_textures = {
	Global.Currency.Euro: preload("res://winscreen/eur_profile.png"),
	Global.Currency.Dollar: preload("res://winscreen/usd_profile.png"),
	Global.Currency.Yen: preload("res://winscreen/yen_profile.png"),
	Global.Currency.Pound: preload("res://winscreen/gbp_profile.png")
}

func _ready():
	var winning_text = "Player %s wins" % GameManager.winning_player
	$WinLabel.text = winning_text
	$WinPic.texture = win_textures[GameManager.winning_currency]
	
func _process(delta):
	if Input.is_action_pressed("key_continue"):
		GameManager.start_random_level()
	elif Input.is_action_pressed("key_esc"):
		GameManager.show_menu()