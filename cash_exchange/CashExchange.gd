extends Node2D

# global stuff
enum CashExchangeState {Open, Exchanging, Closed}
var CashExchangeValues = {
	CashExchangeState.Open: "Open",
	CashExchangeState.Exchanging: "Exchanging",
	CashExchangeState.Closed: "Closed"
}

signal cash_exchange_state_changed(old_state, new_state)

# local constants
const SECONDS_FOR_EXCHANGING = 1
const COOLDOWN_UNTIL_OPEN = 5
const COOLDOWN_UNTIL_FIRST_OPEN = 7

# game state
var currency
var state
var player_id_in_exchange = null

# UI-related stuff
var animation_steps_per_state = {
	"Open": 1,
	"Closed": 1,
	"Exchanging": 16
}
var sprite_frames

func initialize(currency):
	self.currency = currency
		
	# load all animation sprite frames
	var path_template = "res://cash_exchange/{currency}/{state}/{step}.png"
	sprite_frames = SpriteFrames.new()
	for ani_state in CashExchangeState:
		sprite_frames.add_animation(ani_state)		
		for step in range(animation_steps_per_state[ani_state]):
			var path = path_template.format({"currency": Global.skins[currency], "state": ani_state, "step": step})
			sprite_frames.add_frame(ani_state, load(path))

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.connect("body_entered", self, "_on_body_enter")
	$Timer.connect("timeout", self, "_on_timing_event")
	
	# attach frames
	$AnimatedSprite.frames = sprite_frames
	$AnimatedSprite.speed_scale = 4
	$AnimatedSprite.playing = true
	
	# all exchanges start closed, open after a while
	state = CashExchangeState.Closed
	$AnimatedSprite.animation = CashExchangeValues[state]
	$Timer.start(COOLDOWN_UNTIL_FIRST_OPEN)

func _on_body_enter(body):
	var player_id = body.get("player_id")
	
	# only react to collisions with players and while the shop is open
	if state == CashExchangeState.Open and player_id != null:
		_start_exchange(player_id)

func _on_timing_event():
	if state == CashExchangeState.Exchanging:
		_close_shop()
	elif state == CashExchangeState.Closed:
		# if there is still a player of this shop's currency alive, the shop must remain closed (no duplicate currencies allowed)
		var shop_allowed_to_open = true
		for player_obj in GameManager.players.values():
			if player_obj.currency == currency and not player_obj.dead:
				shop_allowed_to_open = false
		
		if shop_allowed_to_open:
			_open_shop()
		else:	# try again some time later
			$Timer.start(COOLDOWN_UNTIL_OPEN)
		
func _change_state(new_state):
	emit_signal("cash_exchange_state_changed", state, new_state)
	$AnimatedSprite.animation = CashExchangeValues[new_state]
	state = new_state
	
func _start_exchange(player_id):
	var player_obj = GameManager.players[player_id]
	$TransParticles.emitting = true
	player_id_in_exchange = player_id

	# make player immobile, invincible and put to center of shop
	player_obj.immobile = true
	player_obj.invincible = true
	player_obj.scale = Vector2(0,0)
	player_obj.position = position
	
	# while exchanging, the shop is solid on the outside and the trigger on the inside is disabled
	set_deferred("Area2D/InsideShopCollider.disabled", true)
	set_deferred("StaticBody2D/OutsideShopCollider.disabled", false)
	_change_state(CashExchangeState.Exchanging)
	$Timer.start(SECONDS_FOR_EXCHANGING)

func _close_shop():	
	var player_obj = GameManager.players[player_id_in_exchange]
	player_obj.update_currency(currency)
	
	# when kicking out the player, the outer collider must be temporarily disabled
	$StaticBody2D/OutsideShopCollider.disabled = true
	player_obj.immobile = false
	player_obj.invincible = false
	player_obj.velocity *= -1
	player_obj.scale = Vector2(1,1)
	player_obj.dash()
	$TransParticles.emitting = false
	
	# while closed, the shop should be solid on the outside
	$StaticBody2D/OutsideShopCollider.disabled = false
	
	_change_state(CashExchangeState.Closed)
	$Timer.start(COOLDOWN_UNTIL_OPEN)
	
	# reset for next exchange
	player_id_in_exchange = null

func _open_shop():
	# once open, the outside of the shop is not solid, but the trigger on the inside is enabled
	$Area2D/InsideShopCollider.disabled = false
	$StaticBody2D/OutsideShopCollider.disabled = true
	_change_state(CashExchangeState.Open)