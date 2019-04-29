extends TileMap

var exchange_shop = preload("res://cash_exchange/CashExchange.tscn")

func _ready():
	#Gets coordinates (x, y) of all used cells 
	var cells = get_used_cells()

	#Clear all the existing tiles
	clear()

	#Loop through all the cells, spawn the preloaded object, make it tilemap's child
	#and reposition it to wherever the cell was before.
	for cell in cells:
		var new_tile = exchange_shop.instance()
		new_tile.global_position = Vector2(cell.x * cell_size.x + cell_size.x / 2, cell.y * cell_size.y + cell_size.y / 2)
		
		add_child(new_tile)