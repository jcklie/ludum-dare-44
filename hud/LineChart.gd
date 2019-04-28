extends Node2D

class ValueSource:
	"""
	Some source which creates and stores currency values.
	"""
	
	var values = []
	var timestamps = []
	var currency
	var symbol
	var color: Color
	
	var key_timespan = 4
	var future_lookahead
	
	func _init(currency, future_lookahead):
		self.currency = currency
		self.color = Global.colors[currency]
		self.symbol = Global.symbols[currency]
		self.future_lookahead = future_lookahead
	
	func generate_value(gametime):
		return randi() % 10
	
	func process(total_elapsed):
		while len(values) == 0 or timestamps[len(timestamps) - 1] <= total_elapsed + future_lookahead:
			var gametime
			if len(timestamps) == 0:
				gametime = 0
			else:
				gametime = timestamps[len(timestamps) - 1] + key_timespan
			
			values.append(generate_value(gametime))
			timestamps.append(gametime)
			
	func get_current_value(gametime):
		for a in range(0, len(timestamps)):
			if timestamps[a] >= gametime:
				# use this and the last timestamp to interpolate the value
				var diff = timestamps[a] - timestamps[a - 1]
				var diff_back = gametime - timestamps[a - 1]
				var diff_forw = timestamps[a] - gametime
				
				return diff_forw / diff * values[a - 1] + diff_back / diff * values[a]
		
		# this will only happen when there are no future timestamps, which should be never
		return 0

export var x = 700
export var y = 0
export var width = 200
export var height = 100
export var border_size = 5
# the point in the chart which is considered as "now"
var now_x = x + width * 0.25

# max value used for scaling
# WARNING: NEEDS TO BE ADAPTED ACCORDING TO THE GENERATION!
var max_value = 10
# the width of one second in pixels
export var second_width = 10

# currently active value sources
var sources = {}
# saves the total elapsed game time
var total_elapsed = 0

onready var legend = get_node("../Legend")

# Called when the node enters the scene tree for the first time.
func _ready():
	var future_lookahead = ceil(0.75 * width / second_width) + 1
	# Add all currencies to the chart
	for currency in Global.currencies:
		sources[currency] = ValueSource.new(currency, future_lookahead)

func get_currency_value(currency):
	"""
	Get the value of the given currency (type Global.Currency) at the last gametime.
	"""
	
	return sources[currency].get_current_value(total_elapsed)

func generate_legend():
	legend.clear()
	legend.push_align(RichTextLabel.ALIGN_CENTER)
	
	var i = 0
	var size = sources.size()
	for currency in sources:
		var valueSource = sources[currency]

		legend.push_color(valueSource.color)
		legend.add_text(valueSource.symbol)
		
		i += 1
		if i < size:
			legend.add_text("  ")
	

func _process(delta):
	total_elapsed += delta
	
	# generate new currency values (if needed)
	for sourceKey in sources:
		sources[sourceKey].process(total_elapsed)
	
	# update the legend
	generate_legend()
	
	# update the gui (draw the lines)
	update()

func get_timestamp_x(timestamp):
	# use total elapsed time to retrieve the timestamp x coordinate
	return (timestamp - total_elapsed) * second_width
	
func get_scaled_value(value):
	return value * height / max_value

func draw_line_clipped(a: Vector2, b: Vector2, color: Color, line_width: float):
	"""
	Clips a line from a to b left and right at the bounding box. Assumes a.x < b.x
	"""
	
	# the line is completely out of bounds
	if a.x > x + width || b.x < x:
		return
	
	# clip it left
	if a.x < x:
		var diff_x = b.x - a.x
		var diff_left_side_x = x - a.x
		a += diff_left_side_x / diff_x * (b - a)
		
	# clip it right
	if b.x > x + width:
		var diff_x = b.x - a.x
		var diff_right_side_x = b.x - (x + width)
		b -= diff_right_side_x / diff_x * (b - a) 

	draw_line(a, b, color, line_width, true)

func _draw():
	draw_rect(Rect2(x - border_size, y - border_size, width + 2 * border_size, height + 2 * border_size), Color(0, 0, 0, 0.6), true)
	
	for sourceKey in sources:
		var source = sources[sourceKey]
		var first_was_too_old = false
		var last_value
		var last_timestep_x
		for a in range(0, len(source.values)):
			# obtain the current line segment
			
			if a == 0:
				# we have just started, there is no line yet
				last_value = get_scaled_value(source.values[0])
				last_timestep_x = get_timestamp_x(source.timestamps[0])
				continue
			
			var current_value = get_scaled_value(source.values[a])
			var current_timestep_x = get_timestamp_x(source.timestamps[a])
			
			#  check whether the first element in the list is too old and can be deleted
			if a == 1 && now_x + current_timestep_x <= x:
				first_was_too_old = true
			
			draw_line_clipped(Vector2(now_x + last_timestep_x, y + height - last_value), Vector2(now_x + current_timestep_x, y + height - current_value), source.color, 2)
			
			last_value = current_value
			last_timestep_x = current_timestep_x
			
		if first_was_too_old:
			# delete old currency values
			source.values.remove(0)
			source.timestamps.remove(0)
	
	draw_line(Vector2(now_x, y), Vector2(now_x, y + height), Color.white, 1)
