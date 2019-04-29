extends Node

# TODO ideas:
# - add random offset to timings (RandomNumberGenerator)

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
const COOLDOWN_UNTIL_FIRST_OPEN = 2 # TODO 10

# game state
var currency = Global.Currency.Dollar
var state
var player_id_in_exchange = null

# UI-related stuff
const ANIMATION_STEPS_PER_STATE = 1
var sprite_frames

# TODO for the future
func _init():
	# TODO soon...
	#self.currency = currency
	
	# load all animation sprite frames
	var path_template = "res://cash_exchange/{currency}/{state}/{step}.png"
	sprite_frames = SpriteFrames.new()
	for ani_state in CashExchangeState:
		sprite_frames.add_animation(ani_state)
		for step in ANIMATION_STEPS_PER_STATE:
			var path = path_template.format({"currency": Global.skins[currency], "state": ani_state, "step": step})
			sprite_frames.add_frame(ani_state, load(path))

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_enter")
	$Timer.connect("timeout", self, "_on_timing_event")
	
	# attach frames
	$AnimatedSprite.frames = sprite_frames
	
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
		_end_exchange()
	elif state == CashExchangeState.Closed:
		_open_shop()

func _change_state(new_state):
	emit_signal("cash_exchange_state_changed", state, new_state)
	$AnimatedSprite.animation = CashExchangeValues[new_state]
	state = new_state
	
func _start_exchange(player_id):
	player_id_in_exchange = player_id	
	
	# TODO put player to center of shop
	# TODO make player immobile
	# TODO disable player collision
	# TODO make player invincible
	
	_change_state(CashExchangeState.Exchanging)
	$Timer.start(SECONDS_FOR_EXCHANGING)

func _end_exchange():	
	# TODO change player currency - use signals?
	# TODO dash player to direction he came from
	player_id_in_exchange = null
	
	_change_state(CashExchangeState.Closed)
	$Timer.start(COOLDOWN_UNTIL_OPEN)

func _open_shop():
	_change_state(CashExchangeState.Open)