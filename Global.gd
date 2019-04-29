extends Node

const IDLE = "idle"
const SKIN_ANGULAR_STEPS = 16

enum Currency {Euro, Dollar, Yen, Pound}

# The lineChart singleton has to be assigned to this variable
# Currently, it assigns itself inside _ready
var line_chart = null
func get_currency_scaling(currency):
	return line_chart.get_currency_scale(currency)

const currencies = [Currency.Euro, Currency.Dollar, Currency.Yen, Currency.Pound]

const colors = {
	Currency.Euro: Color.blue,
	Currency.Dollar: Color.green,
	Currency.Yen: Color.purple,
	Currency.Pound: Color.orange
}

# The skin directory names of the currencies
const skins = {
	Currency.Euro: "eur",
	Currency.Dollar: "usd",
	Currency.Yen: "yen",
	Currency.Pound: "gbp"
}

var sprite_frames = {}

const symbols = {
	Currency.Euro: "€",
	Currency.Dollar: "$",
	Currency.Yen: "¥",
	Currency.Pound: "£"
}

func _ready():
	# load all animation sprite frames
	var path_template = "res://player/skin/{skin}/{ani}/{step}.png"
	for currency in currencies:
		var sf = SpriteFrames.new()
		for ani in [IDLE]:
			for ang_step in range(SKIN_ANGULAR_STEPS):
				var ani_ang_step = ani + "_" + str(ang_step)
				sf.add_animation(ani_ang_step)
				# we only one frame per animation right now
				var path = path_template.format({"skin": skins[currency], "ani": ani, "step": ang_step})
				sf.add_frame(ani_ang_step, load(path))
		
		sprite_frames[currency] = sf