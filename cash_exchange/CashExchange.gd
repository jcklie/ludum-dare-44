extends Node

# TODO ideas:
# - add random offset to timings (RandomNumberGenerator)

enum CashExchangeState {Open, Exchanging, Closed}
signal cash_exchange_state_changed(old_state, new_state)

const SECONDS_FOR_EXCHANGING = 1
const COOLDOWN_UNTIL_OPEN = 5
const COOLDOWN_UNTIL_FIRST_OPEN = 10

var currency = Global.Currency.Dollar
var state
var player_id_in_exchange = null

# TODO for the future
# func _init(currency):
#	 self.currency = currency

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_enter")
	$Timer.connect("timeout", self, "_on_timing_event")
	
	# all exchanges start closed, open after a while
	state = CashExchangeState.Closed
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
	
func _start_exchange(player_id):
	player_id_in_exchange = player_id
	
	emit_signal("cash_exchange_state_changed", state, CashExchangeState.Exchanging)
	state = CashExchangeState.Exchanging
	
	# TODO put player to center of shop
	# TODO make player immobile
	# TODO disable player collision
	# TODO make player invincible
	
	$Timer.start(SECONDS_FOR_EXCHANGING)

func _end_exchange():
	emit_signal("cash_exchange_state_changed", state, CashExchangeState.Closed)
	state = CashExchangeState.Closed	
	
	# TODO change player currency
	# TODO eject player in random free direction (NOSW+in between?)
	player_id_in_exchange = null
	
	$Timer.start(COOLDOWN_UNTIL_OPEN)

func _open_shop():
	emit_signal("cash_exchange_state_changed", state, CashExchangeState.Open)
	state = CashExchangeState.Open	
	