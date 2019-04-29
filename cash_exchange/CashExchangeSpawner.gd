extends TileMap

var exchange_shop = preload("res://cash_exchange/CashExchange.tscn")
var tileset = preload("res://cash_exchange/CashExchangeTileset.tres")

func _ready():
	var cells = get_used_cells()

	for cell in cells:
		var tile_idx = get_cell(cell.x, cell.y)
		var three_letter_currency = tileset.tile_get_name(tile_idx)
		var currency = Global.inverse_skins[three_letter_currency]
		
		# clear current cell, then spawn the exchange shop corresponding to the tile
		set_cell(cell.x, cell.y, -1)
		
		var new_tile = exchange_shop.instance()
		new_tile.global_position = Vector2(cell.x * cell_size.x + cell_size.x / 2, cell.y * cell_size.y + cell_size.y / 2)
		new_tile.initialize(currency)
		
		add_child(new_tile)