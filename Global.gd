extends Node

enum Currency {Euro, Dollar, Yen, Pound}

func get_currencies():
	return [Currency.Euro, Currency.Dollar, Currency.Yen, Currency.Pound]

func get_color(currency):
	match currency:
		Currency.Euro: 
			return Color.blue
		Currency.Dollar:
			return Color.green
		Currency.Yen:
			return Color.purple
		Currency.Pound:
			return Color.orange
		_:
			print("Error: Got unknown currency!")
			breakpoint
			return "eur"

func get_skin_path(currency):
	match currency:
		Currency.Euro: 
			return "eur"
		Currency.Dollar:
			return "usd"
		Currency.Yen:
			return "yen"
		Currency.Pound:
			return "gbp"
		_:
			print("Error: Got unknown currency!")
			breakpoint
			return "eur"

func get_symbol(currency):
	match currency:
		Currency.Euro: 
			return "€"
		Currency.Dollar:
			return "$"
		Currency.Yen:
			return "¥"
		Currency.Pound:
			return "£"
		_:
			print("Error: Got unknown currency!")
			breakpoint
			return "€"